import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/employee.dart';

class AddEmployeeOverlay extends StatefulWidget {
  const AddEmployeeOverlay({super.key});

  @override
  State<AddEmployeeOverlay> createState() => _AddEmployeeOverlayState();
}

class _AddEmployeeOverlayState extends State<AddEmployeeOverlay> {
  final _formKey = GlobalKey<FormState>();

  // Basic
  final _name = TextEditingController();
  final _company = TextEditingController();
  final _position = TextEditingController();
  final _idNumber = TextEditingController();

  // Personal
  final _birthday = TextEditingController();
  final _address = TextEditingController();
  final _govInfo = TextEditingController();

  // Contact
  final _email = TextEditingController();
  final _contactNumber = TextEditingController();

  // Emergency
  final _emergencyName = TextEditingController();
  final _emergencyNumber = TextEditingController();

  // Documents (URLs)
  final _photoUrl = TextEditingController(text: 'https://example.com/photo.jpg');
  final _signatureUrl = TextEditingController(text: 'https://example.com/signature.jpg');

  // ✅ ID Front/Back bytes
  Uint8List? _idFrontBytes;
  Uint8List? _idBackBytes;
  String? _idFrontName;
  String? _idBackName;

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _position.dispose();
    _idNumber.dispose();
    _birthday.dispose();
    _address.dispose();
    _govInfo.dispose();
    _email.dispose();
    _contactNumber.dispose();
    _emergencyName.dispose();
    _emergencyNumber.dispose();
    _photoUrl.dispose();
    _signatureUrl.dispose();
    super.dispose();
  }

  Future<void> _pickIdFront() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (res == null || res.files.isEmpty) return;
    final f = res.files.single;
    if (f.bytes == null) return;

    setState(() {
      _idFrontBytes = f.bytes!;
      _idFrontName = f.name;
    });
  }

  Future<void> _pickIdBack() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (res == null || res.files.isEmpty) return;
    final f = res.files.single;
    if (f.bytes == null) return;

    setState(() {
      _idBackBytes = f.bytes!;
      _idBackName = f.name;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // require uploads
    if (_idFrontBytes == null || _idBackBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload ID Front and ID Back first.')),
      );
      return;
    }

    final id = _idNumber.text.trim();
    final name = _name.text.trim();
    final position = _position.text.trim();
    final email = _email.text.trim();
    final number = _contactNumber.text.trim();
    final company = _company.text.trim();

    final qrData = EmployeeQr.buildQrData(
      idNumber: id,
      name: name,
      position: position,
      email: email,
      number: number,
      company: company,
    );

    final employee = Employee(
      name: name,
      company: company,
      position: position,
      idNumber: id,
      birthday: _birthday.text.trim(),
      address: _address.text.trim(),
      govInfo: _govInfo.text.trim(),
      email: email,
      contactNumber: number,
      emergencyName: _emergencyName.text.trim(),
      emergencyNumber: _emergencyNumber.text.trim(),
      photoUrl: _photoUrl.text.trim(),
      signatureUrl: _signatureUrl.text.trim(),
      qrData: qrData,
      // refs are set in HomeScreen (source of truth)
    );

    Navigator.pop(context, {
      'employee': employee,
      'idFrontBytes': _idFrontBytes,
      'idBackBytes': _idBackBytes,
      'idFrontName': _idFrontName,
      'idBackName': _idBackName,
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width < 640 ? size.width * 0.94 : 600.0;
    final height = size.height < 760 ? size.height * 0.92 : 701.0;

    return Material(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x4C00D9FF), width: 1),
            boxShadow: const [
              BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4), spreadRadius: -4),
              BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add New Employee',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the details of the new employee.',
                          style: TextStyle(color: Colors.white.withOpacity(0.60), fontSize: 14, fontWeight: FontWeight.w400, height: 1.43),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionTitle('Basic Information'),
                              const SizedBox(height: 16),

                              _LabeledInput(label: 'Name *', controller: _name, requiredField: true),
                              const SizedBox(height: 16),
                              _LabeledInput(label: 'Company *', controller: _company, requiredField: true),
                              const SizedBox(height: 16),
                              _LabeledInput(label: 'Position *', controller: _position, requiredField: true),
                              const SizedBox(height: 16),
                              _LabeledInput(label: 'ID Number *', controller: _idNumber, requiredField: true),
                              const SizedBox(height: 16),

                              _DividerLine(),
                              const SizedBox(height: 16),
                              _SectionTitle('Personal Information'),
                              const SizedBox(height: 16),

                              _LabeledInput(label: 'Birthday *', controller: _birthday, requiredField: true),
                              const SizedBox(height: 16),
                              _LabeledInput(
                                label: 'Home Address *',
                                controller: _address,
                                requiredField: true,
                                maxLines: 3,
                                fieldHeight: 64,
                              ),
                              const SizedBox(height: 16),
                              _LabeledInput(
                                label: 'Government Info (SSS, PhilHealth, etc.)',
                                controller: _govInfo,
                                maxLines: 3,
                                fieldHeight: 64,
                              ),
                              const SizedBox(height: 24),

                              _DividerLine(),
                              const SizedBox(height: 16),
                              _SectionTitle('Contact Information'),
                              const SizedBox(height: 16),

                              _LabeledInput(label: 'Email *', controller: _email, requiredField: true),
                              const SizedBox(height: 16),
                              _LabeledInput(label: 'Contact Number *', controller: _contactNumber, requiredField: true),
                              const SizedBox(height: 24),

                              _DividerLine(),
                              const SizedBox(height: 16),
                              _SectionTitle('Emergency Contact'),
                              const SizedBox(height: 16),

                              _LabeledInput(label: 'Emergency Contact Name *', controller: _emergencyName, requiredField: true),
                              const SizedBox(height: 16),
                              _LabeledInput(label: 'Emergency Contact Number *', controller: _emergencyNumber, requiredField: true),
                              const SizedBox(height: 24),

                              _DividerLine(),
                              const SizedBox(height: 16),
                              _SectionTitle('Documents (URLs)'),
                              const SizedBox(height: 16),

                              _LabeledInput(label: 'Picture URL', controller: _photoUrl),
                              const SizedBox(height: 16),
                              _LabeledInput(label: 'Signature URL', controller: _signatureUrl),

                              // ✅ NEW upload section
                              const SizedBox(height: 24),
                              _DividerLine(),
                              const SizedBox(height: 16),
                              _SectionTitle('ID Card Uploads'),
                              const SizedBox(height: 16),

                              _UploadField(
                                label: 'ID Front *',
                                fileName: _idFrontName,
                                hasFile: _idFrontBytes != null,
                                onPick: _pickIdFront,
                                onClear: () => setState(() {
                                  _idFrontBytes = null;
                                  _idFrontName = null;
                                }),
                              ),
                              const SizedBox(height: 16),
                              _UploadField(
                                label: 'ID Back *',
                                fileName: _idBackName,
                                hasFile: _idBackBytes != null,
                                onPick: _pickIdBack,
                                onClear: () => setState(() {
                                  _idBackBytes = null;
                                  _idBackName = null;
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _CancelButton(onPressed: () => Navigator.pop(context)),
                        const SizedBox(width: 8),
                        _AddEmployeeButton(onPressed: _submit),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 17,
                top: 17,
                child: Opacity(
                  opacity: 0.70,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: Center(child: Icon(Icons.close, size: 18, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ==== small widgets unchanged ==== */

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400, height: 1.43),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(height: 1, color: const Color(0x4C00D9FF));
}

class _LabeledInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool requiredField;
  final int maxLines;
  final double fieldHeight;

  const _LabeledInput({
    required this.label,
    required this.controller,
    this.requiredField = false,
    this.maxLines = 1,
    this.fieldHeight = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400, height: 1)),
        const SizedBox(height: 8),
        SizedBox(
          height: fieldHeight,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            validator: requiredField ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
            decoration: InputDecoration(
              hintText: '',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.60)),
              filled: true,
              fillColor: const Color(0x7F141428),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.0), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0x4C00D9FF), width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CancelButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF0A0A0F),
          side: const BorderSide(color: Color(0x4C00D9FF), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text('Cancel', style: TextStyle(fontSize: 14, height: 1.43)),
      ),
    );
  }
}

class _AddEmployeeButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddEmployeeButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D9FF),
          foregroundColor: const Color(0xFF0A0A0F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
        ),
        child: const Text('Add Employee', style: TextStyle(fontSize: 14, height: 1.43)),
      ),
    );
  }
}

class _UploadField extends StatelessWidget {
  final String label;
  final bool hasFile;
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _UploadField({
    required this.label,
    required this.hasFile,
    required this.onPick,
    required this.onClear,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final display = hasFile ? (fileName ?? 'Selected') : 'No file selected';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400, height: 1)),
        const SizedBox(height: 8),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0x7F141428),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  display,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withOpacity(hasFile ? 0.9 : 0.6), fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 28,
                child: OutlinedButton(
                  onPressed: onPick,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x4C00D9FF), width: 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Choose', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              if (hasFile)
                SizedBox(
                  height: 28,
                  child: OutlinedButton(
                    onPressed: onClear,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.25), width: 1),
                      foregroundColor: Colors.white.withOpacity(0.85),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Remove', style: TextStyle(fontSize: 12)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
