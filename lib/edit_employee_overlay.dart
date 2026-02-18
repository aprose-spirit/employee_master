import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'models/employee.dart';

class EditEmployeeOverlay extends StatefulWidget {
  final Employee employee;
  const EditEmployeeOverlay({super.key, required this.employee});

  @override
  State<EditEmployeeOverlay> createState() => _EditEmployeeOverlayState();
}

class _EditEmployeeOverlayState extends State<EditEmployeeOverlay> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController idNumber;
  late final TextEditingController name;
  late final TextEditingController company;
  late final TextEditingController position;
  late final TextEditingController birthday;
  late final TextEditingController address;
  late final TextEditingController govInfo;
  late final TextEditingController email;
  late final TextEditingController contactNumber;
  late final TextEditingController emergencyName;
  late final TextEditingController emergencyNumber;

  // ✅ extra details
  late final TextEditingController photoUrl;
  late final TextEditingController signatureUrl;
  late final TextEditingController qrData;
  late final TextEditingController idFrontRef;
  late final TextEditingController idBackRef;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;

    idNumber = TextEditingController(text: e.idNumber);
    name = TextEditingController(text: e.name);
    company = TextEditingController(text: e.company);
    position = TextEditingController(text: e.position);
    birthday = TextEditingController(text: e.birthday);
    address = TextEditingController(text: e.address);
    govInfo = TextEditingController(text: e.govInfo);
    email = TextEditingController(text: e.email);
    contactNumber = TextEditingController(text: e.contactNumber);
    emergencyName = TextEditingController(text: e.emergencyName);
    emergencyNumber = TextEditingController(text: e.emergencyNumber);

    photoUrl = TextEditingController(text: e.photoUrl);
    signatureUrl = TextEditingController(text: e.signatureUrl);
    qrData = TextEditingController(text: e.qrData);
    idFrontRef = TextEditingController(text: e.idFrontRef);
    idBackRef = TextEditingController(text: e.idBackRef);
  }

  @override
  void dispose() {
    idNumber.dispose();
    name.dispose();
    company.dispose();
    position.dispose();
    birthday.dispose();
    address.dispose();
    govInfo.dispose();
    email.dispose();
    contactNumber.dispose();
    emergencyName.dispose();
    emergencyNumber.dispose();

    photoUrl.dispose();
    signatureUrl.dispose();
    qrData.dispose();
    idFrontRef.dispose();
    idBackRef.dispose();

    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  /// Picks an image file and stores it into:
  ///   <app_documents>/employee_assets/<prefix>_<timestamp>.<ext>
  /// Returns the stored filename (or file name on web).
  Future<String?> _pickAndStoreImage({required String prefix}) async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: kIsWeb,
      );

      if (res == null || res.files.isEmpty) return null;
      final f = res.files.first;

      // ✅ Web: no stable filesystem path to copy to
      if (kIsWeb) {
        final picked = (f.name).trim();
        if (picked.isEmpty) return null;
        _toast('Picked (web): $picked');
        return picked;
      }

      // ✅ Desktop/Mobile: copy file into app documents folder
      final srcPath = f.path;
      if (srcPath == null || srcPath.isEmpty) return null;

      final srcFile = File(srcPath);
      if (!await srcFile.exists()) return null;

      final docDir = await getApplicationDocumentsDirectory();
      final outDir = Directory(p.join(docDir.path, 'employee_assets'));
      if (!await outDir.exists()) {
        await outDir.create(recursive: true);
      }

      final ext = p.extension(srcPath).isNotEmpty ? p.extension(srcPath) : '.png';
      final safePrefix = prefix.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final outName = '${safePrefix}_${DateTime.now().millisecondsSinceEpoch}$ext';
      final outPath = p.join(outDir.path, outName);

      await srcFile.copy(outPath);
      _toast('Saved: $outName');

      // Store only the filename (consistent with refs)
      return outName;
    } catch (e) {
      _toast('Pick failed: $e');
      return null;
    }
  }

  Future<void> _pickPhoto() async {
    final stored = await _pickAndStoreImage(prefix: 'photo');
    if (stored == null) return;
    setState(() => photoUrl.text = stored);
  }

  Future<void> _pickSignature() async {
    final stored = await _pickAndStoreImage(prefix: 'signature');
    if (stored == null) return;
    setState(() => signatureUrl.text = stored);
  }

  Future<void> _pickIdFront() async {
    final stored = await _pickAndStoreImage(prefix: 'id_front');
    if (stored == null) return;
    setState(() => idFrontRef.text = stored);
  }

  Future<void> _pickIdBack() async {
    final stored = await _pickAndStoreImage(prefix: 'id_back');
    if (stored == null) return;
    setState(() => idBackRef.text = stored);
  }

  void _fillShortQr() {
    final id = idNumber.text.trim();
    setState(() => qrData.text = id.isEmpty ? '' : 'EMP:$id');
  }

  void _fillJsonQr() {
    final data = {
      "id": idNumber.text.trim(),
      "name": name.text.trim(),
      "position": position.text.trim(),
      "email": email.text.trim(),
      "number": contactNumber.text.trim(),
      "company": company.text.trim(),
    };
    setState(() => qrData.text = jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    final original = widget.employee;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: _CardShell(
        title: 'Edit Employee',
        subtitle: original.name,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.80, // ✅ height cap
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  _Row2(
                    left: _field(idNumber, 'ID Number', required: true),
                    right: _field(name, 'Name', required: true),
                  ),
                  const SizedBox(height: 10),

                  _Row2(
                    left: _field(company, 'Company'),
                    right: _field(position, 'Position'),
                  ),
                  const SizedBox(height: 10),

                  _Row2(
                    left: _field(contactNumber, 'Contact Number'),
                    right: _field(email, 'Email'),
                  ),
                  const SizedBox(height: 10),

                  _Row2(
                    left: _field(birthday, 'Birthday'),
                    right: _field(govInfo, 'Government Info'),
                  ),
                  const SizedBox(height: 10),

                  _field(address, 'Address', maxLines: 2),
                  const SizedBox(height: 10),

                  _Row2(
                    left: _field(emergencyName, 'Emergency Name'),
                    right: _field(emergencyNumber, 'Emergency Number'),
                  ),

                  const SizedBox(height: 18),
                  const _SectionTitle('Assets / References'),
                  const SizedBox(height: 10),

                  _Row2(
                    left: _pickField(
                      controller: photoUrl,
                      label: 'Photo Ref',
                      onPick: _pickPhoto,
                      icon: Icons.photo,
                      hint: 'Pick image → stored filename/path',
                    ),
                    right: _pickField(
                      controller: signatureUrl,
                      label: 'Signature Ref',
                      onPick: _pickSignature,
                      icon: Icons.draw,
                      hint: 'Pick image → stored filename/path',
                    ),
                  ),
                  const SizedBox(height: 10),

                  _Row2(
                    left: _pickField(
                      controller: idFrontRef,
                      label: 'ID Front Ref',
                      onPick: _pickIdFront,
                      icon: Icons.badge,
                      hint: 'Pick image → stored filename/path',
                    ),
                    right: _pickField(
                      controller: idBackRef,
                      label: 'ID Back Ref',
                      onPick: _pickIdBack,
                      icon: Icons.badge_outlined,
                      hint: 'Pick image → stored filename/path',
                    ),
                  ),

                  const SizedBox(height: 18),
                  const _SectionTitle('QR Data'),
                  const SizedBox(height: 10),

                  _field(qrData, 'QR Data (JSON or short code)', maxLines: 3),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _fillShortQr,
                          icon: const Icon(Icons.qr_code_2, size: 16),
                          label: const Text('Use short QR (EMP:ID)'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0x7F00D9FF), width: 1),
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF0A0A0F),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _fillJsonQr,
                          icon: const Icon(Icons.data_object, size: 16),
                          label: const Text('Build JSON QR'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0x7F00D9FF), width: 1),
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF0A0A0F),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0x7F00D9FF), width: 1),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF0A0A0F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;

                          final updated = original.copyWith(
                            idNumber: idNumber.text.trim(),
                            name: name.text.trim(),
                            company: company.text.trim(),
                            position: position.text.trim(),
                            birthday: birthday.text.trim(),
                            address: address.text.trim(),
                            govInfo: govInfo.text.trim(),
                            email: email.text.trim(),
                            contactNumber: contactNumber.text.trim(),
                            emergencyName: emergencyName.text.trim(),
                            emergencyNumber: emergencyNumber.text.trim(),

                            photoUrl: photoUrl.text.trim(),
                            signatureUrl: signatureUrl.text.trim(),
                            qrData: qrData.text.trim(),
                            idFrontRef: idFrontRef.text.trim(),
                            idBackRef: idBackRef.text.trim(),
                          );

                          final finalQr = updated.qrData.trim().isNotEmpty
                              ? updated.qrData.trim()
                              : 'EMP:${updated.idNumber.trim()}';

                          Navigator.pop(context, updated.copyWith(qrData: finalQr));
                        },
                        icon: const Icon(Icons.save, size: 16, color: Color(0xFF0A0A0F)),
                        label: const Text(
                          'Save',
                          style: TextStyle(
                            color: Color(0xFF0A0A0F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D9FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (kIsWeb) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Note: On Flutter Web, picked images cannot be copied to an app folder.\n'
                      'This will store only the file name ref.',
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: (v) {
        if (!required) return null;
        if ((v ?? '').trim().isEmpty) return '$label is required';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.70)),
        filled: true,
        fillColor: const Color(0x5B141428),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x4C00D9FF), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 1.2),
        ),
      ),
    );
  }

  Widget _pickField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onPick,
    required IconData icon,
    String? hint,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12),
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.70)),
              filled: true,
              fillColor: const Color(0x5B141428),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0x4C00D9FF), width: 1.1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 1.2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onPick,
          icon: Icon(icon, color: const Color(0xFF00D9FF)),
          tooltip: 'Pick image',
        ),
      ],
    );
  }
}

/* ================= UI HELPERS ================= */

class _Row2 extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _Row2({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final twoCols = c.maxWidth >= 640;
        if (!twoCols) {
          return Column(
            children: [left, const SizedBox(height: 10), right],
          );
        }
        return Row(
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _CardShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _CardShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 720),
      padding: const EdgeInsets.all(1.2),
      decoration: ShapeDecoration(
        color: const Color(0x5B141428),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0x4C00D9FF), width: 1.2),
          borderRadius: BorderRadius.circular(14),
        ),
        shadows: const [
          BoxShadow(color: Color(0x1900D9FF), blurRadius: 18, offset: Offset(0, 12)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Container(
          color: const Color(0xFF0A0A0F),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(title: title, subtitle: subtitle),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TopBar({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.edit, color: Color(0xFF00D9FF), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
