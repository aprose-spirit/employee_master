import 'package:flutter/material.dart';

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
  final _updatedIdNumber = TextEditingController();

  // Personal
  final _birthday = TextEditingController();
  final _address = TextEditingController();
  final _govInfo = TextEditingController(text: 'SSS: , PhilHealth: ');

  // Contact
  final _email = TextEditingController();
  final _contactNumber = TextEditingController();

  // Emergency
  final _emergencyName = TextEditingController();
  final _emergencyNumber = TextEditingController();

  // Documents
  final _photoUrl = TextEditingController(text: 'https://example.com/photo.jpg');
  final _signatureUrl = TextEditingController(text: 'https://example.com/signature.jpg');

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _position.dispose();
    _idNumber.dispose();
    _updatedIdNumber.dispose();
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Later: Navigator.pop(context, employeeData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Keep 600x701 look, but responsive on smaller screens
    final width = size.width < 640 ? size.width * 0.94 : 600.0;
    final height = size.height < 760 ? size.height * 0.92 : 701.0;

    return Material(
      color: Colors.black.withOpacity(0.55), // backdrop
      child: Center(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x4C00D9FF), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 6,
                offset: Offset(0, 4),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 15,
                offset: Offset(0, 10),
                spreadRadius: -3,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Content layout
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add New Employee',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the details of the new employee.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.60),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Form (scrollable)
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
                              _LabeledInput(label: 'Updated ID Number', controller: _updatedIdNumber),
                              const SizedBox(height: 24),

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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Footer actions (pinned)
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

              // Close (X) top right
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
                      child: Center(
                        child: Icon(Icons.close, size: 18, color: Colors.white),
                      ),
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

/* ================= SMALL WIDGETS ================= */

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0x4C00D9FF));
  }
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
    final hint = '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: fieldHeight,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            validator: requiredField
                ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                : null,
            decoration: InputDecoration(
              hintText: hint,
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
