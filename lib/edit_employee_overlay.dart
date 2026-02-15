import 'dart:convert';
import 'package:flutter/material.dart';
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
    super.dispose();
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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

                        final updatedBase = original.copyWith(
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
                        );

                        // ✅ Keep existing qrData if present, else generate SHORT scannable one
                        final qr = updatedBase.qrData.trim().isNotEmpty
                            ? updatedBase.qrData
                            : 'EMP:${updatedBase.idNumber}';

                        Navigator.pop(context, updatedBase.copyWith(qrData: qr));
                      },
                      icon: const Icon(Icons.save, size: 16, color: Color(0xFF0A0A0F)),
                      label: const Text('Save',
                          style: TextStyle(color: Color(0xFF0A0A0F), fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D9FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
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
              Text(title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 2),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13)),
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
