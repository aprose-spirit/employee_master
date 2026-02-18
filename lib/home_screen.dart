import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:excel/excel.dart' as ex;

import 'add_employee_screen.dart';
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

  // ✅ store ID images in memory, keyed by idNumber
  final Map<String, Uint8List> _idFrontById = {};
  final Map<String, Uint8List> _idBackById = {};

  Future<void> _openAddEmployee() async {
    final result = await showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AddEmployeeOverlay(),
    );

    if (result == null) return;
    if (result is! Map) return;

    final e = result['employee'];
    if (e is! Employee) return;

    final Uint8List? front = result['idFrontBytes'] as Uint8List?;
    final Uint8List? back = result['idBackBytes'] as Uint8List?;

    if (front != null) _idFrontById[e.idNumber] = front;
    if (back != null) _idBackById[e.idNumber] = back;

    final qrData = e.qrData.trim().isNotEmpty
        ? e.qrData
        : jsonEncode({
            "id": e.idNumber,
            "name": e.name,
            "position": e.position,
            "email": e.email,
            "number": e.contactNumber,
            "company": e.company,
          });

    setState(() => _employees.add(e.copyWith(qrData: qrData)));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Employee added.')),
    );
  }

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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete All')),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      _employees.clear();
      _idFrontById.clear();
      _idBackById.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All employees deleted.')),
    );
  }

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

    final header = Employee.csvHeader();

    for (int c = 0; c < header.length; c++) {
      final cell = sheet.getRangeByIndex(1, c + 1);
      cell.setText(header[c]);
      cell.cellStyle.bold = true;
    }

    int colOf(String key) {
      final i = header.indexOf(key);
      return i == -1 ? -1 : i + 1;
    }

    final qrCol = colOf('qrData');
    final frontCol = colOf('idFrontRef');
    final backCol = colOf('idBackRef');

    if (qrCol == -1 || frontCol == -1 || backCol == -1) {
      workbook.dispose();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("csvHeader() must include qrData, idFrontRef, idBackRef.")),
      );
      return;
    }

    const double imgPx = 110.0;
    sheet.getRangeByIndex(1, qrCol).columnWidth = (imgPx / 7.0) + 2;
    sheet.getRangeByIndex(1, frontCol).columnWidth = (imgPx / 7.0) + 2;
    sheet.getRangeByIndex(1, backCol).columnWidth = (imgPx / 7.0) + 2;

    for (int r = 0; r < _employees.length; r++) {
      final emp = _employees[r];
      final rowIndex = r + 2;

      final row = emp.toCsvRow();
      for (int c = 0; c < row.length; c++) {
        final colIndex = c + 1;
        if (colIndex == qrCol || colIndex == frontCol || colIndex == backCol) continue;
        sheet.getRangeByIndex(rowIndex, colIndex).setText(row[c]);
      }

      sheet.getRangeByIndex(rowIndex, 1).rowHeight = imgPx + 10;

      // QR image
      final data = emp.qrData.trim().isNotEmpty ? emp.qrData.trim() : 'EMP:${emp.idNumber}';
      try {
        final png = await QrService.qrPngBytes(data, size: 520);
        final pic = sheet.pictures.addStream(rowIndex, qrCol, png);
        pic.width = imgPx.toInt();
        pic.height = imgPx.toInt();
      } catch (_) {
        sheet.getRangeByIndex(rowIndex, qrCol).setText('QR ERR');
      }

      // ID Front
      final frontBytes = _idFrontById[emp.idNumber];
      if (frontBytes != null) {
        final pic = sheet.pictures.addStream(rowIndex, frontCol, frontBytes);
        pic.width = imgPx.toInt();
        pic.height = imgPx.toInt();
        sheet.getRangeByIndex(rowIndex, frontCol).setText('embedded');
      } else {
        sheet.getRangeByIndex(rowIndex, frontCol).setText('');
      }

      // ID Back
      final backBytes = _idBackById[emp.idNumber];
      if (backBytes != null) {
        final pic = sheet.pictures.addStream(rowIndex, backCol, backBytes);
        pic.width = imgPx.toInt();
        pic.height = imgPx.toInt();
        sheet.getRangeByIndex(rowIndex, backCol).setText('embedded');
      } else {
        sheet.getRangeByIndex(rowIndex, backCol).setText('');
      }
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
      const SnackBar(content: Text('XLSX exported with QR + ID Front/Back images.')),
    );
  }

  Future<void> _importXlsx() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;
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
        const SnackBar(content: Text('Invalid XLSX header. Missing required columns (name, idNumber).')),
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
      final qrData = emp.qrData.trim().isNotEmpty ? emp.qrData : 'EMP:${emp.idNumber}';
      imported.add(emp.copyWith(qrData: qrData));
    }

    setState(() => _employees.addAll(imported));

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
                  onDeleteAll: _deleteAllEmployees,
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

                      // ✅ NEW: pass bytes lookup so the table can show images
                      idFrontBytesOf: (id) => _idFrontById[id],
                      idBackBytesOf: (id) => _idBackById[id],

                      onView: (e) {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => ViewEmployeeOverlay(
                            employee: e,
                            idFrontBytes: _idFrontById[e.idNumber],
                            idBackBytes: _idBackById[e.idNumber],
                          ),
                        );
                      },
                      onEdit: (e) async {
                        final oldId = e.idNumber;

                        final updated = await showDialog<Employee>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => EditEmployeeOverlay(employee: e),
                        );

                        if (updated == null) return;

                        final newId = updated.idNumber;

                        setState(() {
                          final i = _employees.indexOf(e);
                          if (i != -1) {
                            _employees[i] = updated;
                          } else {
                            final j = _employees.indexWhere((x) => x.idNumber == oldId);
                            if (j != -1) _employees[j] = updated;
                          }

                          // if ID changed, move bytes maps
                          if (oldId != newId) {
                            final f = _idFrontById.remove(oldId);
                            final b = _idBackById.remove(oldId);
                            if (f != null) _idFrontById[newId] = f;
                            if (b != null) _idBackById[newId] = b;
                          }
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Updated: ${updated.name}')),
                        );
                      },
                      onDelete: (e) {
                        setState(() {
                          _employees.remove(e);
                          _idFrontById.remove(e.idNumber);
                          _idBackById.remove(e.idNumber);
                        });
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

/* ================= BACKGROUND + HEADER (unchanged UI) ================= */

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

class _TopHeader extends StatelessWidget {
  final int employeeCount;
  final VoidCallback onAdd;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onDeleteAll;
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
                  onDeleteAll: onDeleteAll,
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
          BoxShadow(color: Color(0x7F00D9FF), blurRadius: 6, offset: Offset(0, 4), spreadRadius: -4),
          BoxShadow(color: Color(0x7F00D9FF), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3),
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
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.33, color: Colors.white),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onDeleteAll;
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
        _PrimaryActionButton(label: 'Add Employee', icon: Icons.person_add_alt_1, onPressed: onAdd),
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

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryActionButton({required this.label, required this.icon, required this.onPressed});

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
            BoxShadow(color: Color(0x4C00D9FF), blurRadius: 6, offset: Offset(0, 4), spreadRadius: -4),
            BoxShadow(color: Color(0x4C00D9FF), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16, color: const Color(0xFF0A0A0F)),
          label: Text(label, style: const TextStyle(fontSize: 14, height: 1.43, color: Color(0xFF0A0A0F))),
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
