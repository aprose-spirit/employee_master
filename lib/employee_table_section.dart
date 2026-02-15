import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/employee.dart';

class EmployeeTableSection extends StatefulWidget {
  final List<Employee> employees;

  final void Function(Employee e)? onView;
  final void Function(Employee e)? onEdit;
  final void Function(Employee e)? onDelete;

  const EmployeeTableSection({
    super.key,
    required this.employees,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<EmployeeTableSection> createState() => _EmployeeTableSectionState();
}

class _EmployeeTableSectionState extends State<EmployeeTableSection> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Employee> get _filtered {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return widget.employees;

    return widget.employees.where((e) {
      return e.idNumber.toLowerCase().contains(q) ||
          e.name.toLowerCase().contains(q) ||
          e.company.toLowerCase().contains(q) ||
          e.position.toLowerCase().contains(q) ||
          e.contactNumber.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q) ||
          e.govInfo.toLowerCase().contains(q) ||
          e.address.toLowerCase().contains(q) || // ✅ added
          e.emergencyName.toLowerCase().contains(q) ||
          e.emergencyNumber.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 448,
          height: 36,
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0x5B141428),
              hintText: 'Search employees...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.60)),
              prefixIcon: Icon(Icons.search, size: 18, color: Colors.white.withOpacity(0.70)),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
              contentPadding: const EdgeInsets.only(top: 4, bottom: 4, right: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0x4C00D9FF), width: 1.1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 1.2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _TableCard(
          child: list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Center(
                    child: Text(
                      'No employees found.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.60),
                        fontSize: 14,
                        height: 1.43,
                      ),
                    ),
                  ),
                )
              : _EmployeeTable(
                  employees: list,
                  onView: widget.onView,
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                ),
        ),
      ],
    );
  }
}

/* ================= TABLE CARD ================= */

class _TableCard extends StatelessWidget {
  final Widget child;
  const _TableCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.1),
      decoration: ShapeDecoration(
        color: const Color(0x5B141428),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0x4C00D9FF), width: 1.1),
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x1900D9FF),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x1900D9FF),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: child,
      ),
    );
  }
}

/* ================= TABLE ================= */

class _EmployeeTable extends StatelessWidget {
  final List<Employee> employees;
  final void Function(Employee e)? onView;
  final void Function(Employee e)? onEdit;
  final void Function(Employee e)? onDelete;

  const _EmployeeTable({
    required this.employees,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  static const double wId = 175;
  static const double wName = 140;
  static const double wCompany = 160;
  static const double wPosition = 150;
  static const double wContact = 150;
  static const double wEmail = 280;
  static const double wBirthday = 140;

  static const double wAddress = 280; // ✅ added
  static const double wGov = 240;
  static const double wEmergName = 190;
  static const double wEmergNo = 170;
  static const double wQr = 120;

  static const double wActions = 180;

  static const double headerH = 40;
  static const double rowH = 48.5;

  @override
  Widget build(BuildContext context) {
    final totalWidth = wId +
        wName +
        wCompany +
        wPosition +
        wContact +
        wEmail +
        wBirthday +
        wAddress + // ✅ added
        wGov +
        wEmergName +
        wEmergNo +
        wQr +
        wActions;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        child: Column(
          children: [
            _HeaderRow(),
            ...employees.map(
              (e) => _DataRow(
                e: e,
                onView: onView,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _EmployeeTable.headerH,
      child: Row(
        children: const [
          _CellHeader(text: 'ID Number', width: _EmployeeTable.wId),
          _CellHeader(text: 'Name', width: _EmployeeTable.wName),
          _CellHeader(text: 'Company', width: _EmployeeTable.wCompany),
          _CellHeader(text: 'Position', width: _EmployeeTable.wPosition),
          _CellHeader(text: 'Contact #', width: _EmployeeTable.wContact),
          _CellHeader(text: 'Email', width: _EmployeeTable.wEmail),
          _CellHeader(text: 'Birthday', width: _EmployeeTable.wBirthday),

          _CellHeader(text: 'Address', width: _EmployeeTable.wAddress), // ✅ added

          _CellHeader(text: 'Government Info', width: _EmployeeTable.wGov),
          _CellHeader(text: 'Emergency Name', width: _EmployeeTable.wEmergName),
          _CellHeader(text: 'Emergency #', width: _EmployeeTable.wEmergNo),
          _CellHeader(text: 'QR Code', width: _EmployeeTable.wQr),
          _CellHeader(text: 'Actions', width: _EmployeeTable.wActions, alignRight: true),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final Employee e;
  final void Function(Employee e)? onView;
  final void Function(Employee e)? onEdit;
  final void Function(Employee e)? onDelete;

  const _DataRow({
    required this.e,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _EmployeeTable.rowH,
      child: Row(
        children: [
          _CellText(text: e.idNumber, width: _EmployeeTable.wId),
          _CellText(text: e.name, width: _EmployeeTable.wName, clip: true),
          _CellText(text: e.company, width: _EmployeeTable.wCompany, clip: true),
          _CellText(text: e.position, width: _EmployeeTable.wPosition, clip: true),
          _CellText(text: e.contactNumber, width: _EmployeeTable.wContact),
          _CellText(text: e.email, width: _EmployeeTable.wEmail, clip: true),
          _CellText(text: e.birthday, width: _EmployeeTable.wBirthday),

          _CellText(text: e.address, width: _EmployeeTable.wAddress, clip: true), // ✅ added

          _CellText(text: e.govInfo, width: _EmployeeTable.wGov, clip: true),
          _CellText(text: e.emergencyName, width: _EmployeeTable.wEmergName, clip: true),
          _CellText(text: e.emergencyNumber, width: _EmployeeTable.wEmergNo),

          _QrCell(data: e.qrData, width: _EmployeeTable.wQr),

          _ActionsCell(
            width: _EmployeeTable.wActions,
            onView: onView == null ? null : () => onView!(e),
            onEdit: onEdit == null ? null : () => onEdit!(e),
            onDelete: onDelete == null
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => AlertDialog(
                        backgroundColor: const Color(0xFF0A0A0F),
                        title: const Text('Delete employee?', style: TextStyle(color: Colors.white)),
                        content: Text(
                          'Delete ${e.name} (${e.idNumber})?',
                          style: TextStyle(color: Colors.white.withOpacity(0.75)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (ok == true) onDelete!(e);
                  },
          ),
        ],
      ),
    );
  }
}

/* ================= CELLS ================= */

class _CellHeader extends StatelessWidget {
  final String text;
  final double width;
  final bool alignRight;

  const _CellHeader({
    required this.text,
    required this.width,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0x4C00D9FF), width: 1.1),
          bottom: BorderSide(color: Color(0x4C00D9FF), width: 1.1),
        ),
      ),
      padding: const EdgeInsets.only(left: 8, right: 8),
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Arimo',
          fontWeight: FontWeight.w400,
          height: 1.43,
        ),
      ),
    );
  }
}

class _CellText extends StatelessWidget {
  final String text;
  final double width;
  final bool clip;

  const _CellText({
    required this.text,
    required this.width,
    this.clip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0x4C00D9FF), width: 1.1),
          bottom: BorderSide(color: Color(0x4C00D9FF), width: 1.1),
        ),
      ),
      padding: const EdgeInsets.only(left: 8, right: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        overflow: clip ? TextOverflow.ellipsis : TextOverflow.visible,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Arimo',
          fontWeight: FontWeight.w400,
          height: 1.43,
        ),
      ),
    );
  }
}

class _QrCell extends StatelessWidget {
  final String data;
  final double width;

  const _QrCell({required this.data, required this.width});

  @override
  Widget build(BuildContext context) {
    final cleaned = data.trim();

    return Container(
      width: width,
      height: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0x4C00D9FF), width: 1.1),
          bottom: BorderSide(color: Color(0x4C00D9FF), width: 1.1),
        ),
      ),
      alignment: Alignment.center,
      child: cleaned.isEmpty
          ? Text(
              '—',
              style: TextStyle(color: Colors.white.withOpacity(0.60), fontSize: 14),
            )
          : QrImageView(
              data: cleaned,
              version: QrVersions.auto,
              size: 34,
              gapless: true,
              backgroundColor: Colors.white,
            ),
    );
  }
}

class _ActionsCell extends StatelessWidget {
  final double width;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ActionsCell({
    required this.width,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Widget actionBtn(IconData icon, VoidCallback? onTap) {
      return SizedBox(
        width: 36,
        height: 32,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.white.withOpacity(onTap == null ? 0.35 : 0.9),
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x4C00D9FF), width: 1.1),
        ),
      ),
      padding: const EdgeInsets.only(left: 8, right: 8),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          actionBtn(Icons.visibility, onView),
          const SizedBox(width: 8),
          actionBtn(Icons.edit, onEdit),
          const SizedBox(width: 8),
          actionBtn(Icons.delete, onDelete), // ✅ delete works + confirm
        ],
      ),
    );
  }
}
