import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:excel/excel.dart' as ex;

import 'add_employee_screen.dart'; // AddEmployeeOverlay
import 'employee_table_section.dart';
import 'login_screen.dart';
import 'models/employee.dart';
import 'qr_service.dart';

import 'view_employee_overlay.dart';
import 'edit_employee_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Employee> _employees = [];

  Future<void> _openAddEmployee() async {
    final employee = await showDialog<Employee>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AddEmployeeOverlay(),
    );

    if (employee == null) return;

    final qrData = employee.qrData.trim().isNotEmpty
        ? employee.qrData
        : jsonEncode({
            "id": employee.idNumber,
            "name": employee.name,
            "position": employee.position,
            "email": employee.email,
            "number": employee.contactNumber,
            "company": employee.company,
          });

    final withQr = employee.copyWith(qrData: qrData);

    setState(() => _employees.add(withQr));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Employee added (runtime). QR generated in Flutter.')),
    );
  }

  // ✅ DELETE ALL
  Future<void> _deleteAllEmployees() async {
    if (_employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No employees to delete.')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text('Delete ALL employees?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will remove ${_employees.length} employee(s) from the table.',
          style: TextStyle(color: Colors.white.withOpacity(0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _employees.clear());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All employees deleted.')),
    );
  }

  // ✅ XLSX Export (with embedded QR images)
  Future<void> _exportXlsx() async {
    if (_employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No employees to export.')),
      );
      return;
    }

    final workbook = xls.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Employees';

    final header = Employee.csvHeader(); // must include 'qrData'
    for (int c = 0; c < header.length; c++) {
      final cell = sheet.getRangeByIndex(1, c + 1);
      cell.setText(header[c]);
      cell.cellStyle.bold = true;
    }

    final qrIndex0 = header.indexOf('qrData');
    if (qrIndex0 == -1) {
      workbook.dispose();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Employee.csvHeader() must include 'qrData'.")),
      );
      return;
    }
    final qrCol = qrIndex0 + 1;

    const double qrPx = 110.0;

    // px -> approx char width for Syncfusion
    sheet.getRangeByIndex(1, qrCol).columnWidth = (qrPx / 7.0) + 2;

    for (int r = 0; r < _employees.length; r++) {
      final emp = _employees[r];
      final rowIndex = r + 2;

      final row = emp.toCsvRow();
      for (int c = 0; c < row.length; c++) {
        if ((c + 1) == qrCol) continue;
        sheet.getRangeByIndex(rowIndex, c + 1).setText(row[c]);
      }

      // ✅ set row height so the image fits
      sheet.getRangeByIndex(rowIndex, qrCol).rowHeight = qrPx + 10;

      final data = emp.qrData.trim().isNotEmpty ? emp.qrData.trim() : 'EMP:${emp.idNumber}';

      Uint8List png;
      try {
        // ✅ create large QR then Excel scales it down
        png = await QrService.qrPngBytes(data, size: 520);
      } catch (_) {
        sheet.getRangeByIndex(rowIndex, qrCol).setText('QR ERR');
        continue;
      }

      final pic = sheet.pictures.addStream(rowIndex, qrCol, png);

      // ✅ force square
      pic.width = qrPx.toInt();
      pic.height = qrPx.toInt();
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    await FileSaver.instance.saveFile(
      name: 'employees',
      bytes: Uint8List.fromList(bytes),
      ext: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('XLSX exported with QR images.')),
    );
  }

  // ✅ XLSX Import (APPEND, not replace)
  Future<void> _importXlsx() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;

    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read the selected file.')),
      );
      return;
    }

    final excel = ex.Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('XLSX has no sheets.')),
      );
      return;
    }

    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName];
    if (sheet == null || sheet.rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('XLSX sheet is empty.')),
      );
      return;
    }

    final headerRow = sheet.rows.first;
    final header = headerRow.map((cell) => (cell?.value?.toString() ?? '').trim()).toList();

    if (!header.contains('name') || !header.contains('idNumber')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid XLSX header. Missing required columns (name, idNumber).'),
        ),
      );
      return;
    }

    final imported = <Employee>[];

    for (int r = 1; r < sheet.rows.length; r++) {
      final rowCells = sheet.rows[r];
      final isEmptyRow = rowCells.every((c) => (c?.value?.toString() ?? '').trim().isEmpty);
      if (isEmptyRow) continue;

      final map = <String, String>{};
      for (int i = 0; i < header.length; i++) {
        final key = header[i];
        final val = (i < rowCells.length) ? (rowCells[i]?.value?.toString() ?? '') : '';
        map[key] = val.trim();
      }

      final emp = Employee.fromCsvMap(map);

      // ✅ keep existing qrData if present, else short scannable
      final qrData = emp.qrData.trim().isNotEmpty ? emp.qrData : 'EMP:${emp.idNumber}';

      imported.add(emp.copyWith(qrData: qrData));
    }

    setState(() {
      _employees.addAll(imported);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported ${imported.length} employees (appended).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _HomeBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopHeader(
                  employeeCount: _employees.length,
                  onAdd: _openAddEmployee,
                  onExport: _exportXlsx,
                  onImport: _importXlsx,
                  onDeleteAll: _deleteAllEmployees, // ✅ new
                  onLogout: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: EmployeeTableSection(
                      employees: _employees,
                      onView: (e) {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => ViewEmployeeOverlay(employee: e),
                        );
                      },
                      onEdit: (e) async {
                        final updated = await showDialog<Employee>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => EditEmployeeOverlay(employee: e),
                        );

                        if (updated == null) return;

                        setState(() {
                          final i = _employees.indexOf(e);
                          if (i != -1) {
                            _employees[i] = updated;
                          } else {
                            final j = _employees.indexWhere((x) => x.idNumber == e.idNumber);
                            if (j != -1) _employees[j] = updated;
                          }
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Updated: ${updated.name}')),
                        );
                      },
                      onDelete: (e) {
                        setState(() => _employees.remove(e));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Deleted: ${e.name}')),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= BACKGROUND ================= */

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [
            Color(0xFF0A0A0F),
            Color(0xFF1A0A2E),
            Color(0xFF0A0A0F),
          ],
        ),
      ),
    );
  }
}

/* ================= HEADER ================= */

class _TopHeader extends StatelessWidget {
  final int employeeCount;
  final VoidCallback onAdd;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onDeleteAll; // ✅ new
  final VoidCallback onLogout;

  const _TopHeader({
    required this.employeeCount,
    required this.onAdd,
    required this.onExport,
    required this.onImport,
    required this.onDeleteAll,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0x5B141428),
        border: Border.all(color: const Color(0x4C00D9FF), width: 1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(0.0, 0.5),
                  end: const Alignment(1.0, 0.5),
                  colors: [
                    const Color(0x1900D9FF),
                    Colors.black.withOpacity(0.0),
                    const Color(0x19FF0080),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    _HeaderIcon(),
                    SizedBox(width: 12),
                    Expanded(child: _HeaderTitle()),
                  ],
                ),
                const SizedBox(height: 16),
                _HeaderActions(
                  onAdd: onAdd,
                  onExport: onExport,
                  onImport: onImport,
                  onDeleteAll: onDeleteAll, // ✅ new
                  onLogout: onLogout,
                ),
                const SizedBox(height: 12),
                Text(
                  '$employeeCount employee${employeeCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.43,
                    color: Colors.white.withOpacity(0.60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFF00D9FF), Color(0xFFFF0080)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x7F00D9FF),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x7F00D9FF),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.badge_outlined, size: 22, color: Color(0xFF0A0A0F)),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Employee Master',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33,
        color: Colors.white,
      ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onDeleteAll; // ✅ new
  final VoidCallback onLogout;

  const _HeaderActions({
    required this.onAdd,
    required this.onExport,
    required this.onImport,
    required this.onDeleteAll,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: [
        _PrimaryActionButton(
          label: 'Add Employee',
          icon: Icons.person_add_alt_1,
          onPressed: onAdd,
        ),
        _OutlineActionButton(
          label: 'Export XLSX',
          icon: Icons.upload_file,
          borderColor: const Color(0x7F00D9FF),
          opacity: 0.95,
          onPressed: onExport,
        ),
        _OutlineActionButton(
          label: 'Import XLSX',
          icon: Icons.download,
          borderColor: const Color(0x7FFF0080),
          onPressed: onImport,
        ),
        // ✅ NEW: Delete all
        _OutlineActionButton(
          label: 'Delete All',
          icon: Icons.delete_forever,
          borderColor: const Color(0x7FFF3B30),
          onPressed: onDeleteAll,
        ),
        _OutlineActionButton(
          label: 'Logout',
          icon: Icons.logout,
          borderColor: const Color(0x7F9D00FF),
          onPressed: onLogout,
        ),
      ],
    );
  }
}

/* ================= BUTTONS ================= */

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.50, 0.00),
            end: Alignment(0.50, 1.00),
            colors: [Color(0xFF00D9FF), Color(0xFF0099CC)],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4C00D9FF),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Color(0x4C00D9FF),
              blurRadius: 15,
              offset: Offset(0, 10),
              spreadRadius: -3,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16, color: const Color(0xFF0A0A0F)),
          label: Text(
            label,
            style: const TextStyle(fontSize: 14, height: 1.43, color: Color(0xFF0A0A0F)),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color borderColor;
  final double opacity;
  final VoidCallback onPressed;

  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.borderColor,
    required this.onPressed,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        height: 36,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16, color: Colors.white),
          label: Text(label, style: const TextStyle(fontSize: 14, height: 1.43)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: borderColor, width: 1),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF0A0A0F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}
