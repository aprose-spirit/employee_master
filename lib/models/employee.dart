import 'dart:convert';

class Employee {
  final String name;
  final String company;
  final String position;
  final String idNumber;

  final String birthday;
  final String address;
  final String govInfo;

  final String email;
  final String contactNumber;

  final String emergencyName;
  final String emergencyNumber;

  final String photoUrl;
  final String signatureUrl;

  /// Small JSON payload used to generate QR (shown in UI via qr_flutter)
  final String qrData;

  final String idFrontRef;
  final String idBackRef;

  const Employee({
    required this.name,
    required this.company,
    required this.position,
    required this.idNumber,
    required this.birthday,
    required this.address,
    required this.govInfo,
    required this.email,
    required this.contactNumber,
    required this.emergencyName,
    required this.emergencyNumber,
    required this.photoUrl,
    required this.signatureUrl,
    required this.qrData,
    this.idFrontRef = '',
    this.idBackRef = '',
  });

  Employee copyWith({
    String? name,
    String? company,
    String? position,
    String? idNumber,
    String? birthday,
    String? address,
    String? govInfo,
    String? email,
    String? contactNumber,
    String? emergencyName,
    String? emergencyNumber,
    String? photoUrl,
    String? signatureUrl,
    String? qrData,
    String? idFrontRef,
    String? idBackRef,
  }) {
    return Employee(
      name: name ?? this.name,
      company: company ?? this.company,
      position: position ?? this.position,
      idNumber: idNumber ?? this.idNumber,
      birthday: birthday ?? this.birthday,
      address: address ?? this.address,
      govInfo: govInfo ?? this.govInfo,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      emergencyName: emergencyName ?? this.emergencyName,
      emergencyNumber: emergencyNumber ?? this.emergencyNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      qrData: qrData ?? this.qrData,
      idFrontRef: idFrontRef ?? this.idFrontRef,
      idBackRef: idBackRef ?? this.idBackRef,
    );
  }

  /// CSV/XLSX Export (text-only columns)
  List<String> toCsvRow() => [
        name,
        company,
        position,
        idNumber,
        birthday,
        address,
        govInfo,
        email,
        contactNumber,
        emergencyName,
        emergencyNumber,
        photoUrl,
        signatureUrl,
        qrData,
        idFrontRef,
        idBackRef,
      ];

  static List<String> csvHeader() => const [
        'name',
        'company',
        'position',
        'idNumber',
        'birthday',
        'address',
        'govInfo',
        'email',
        'contactNumber',
        'emergencyName',
        'emergencyNumber',
        'photoUrl',
        'signatureUrl',
        'qrData',
        'idFrontRef',
        'idBackRef',
      ];

  /// CSV/XLSX Import (header-based)
  static Employee fromCsvMap(Map<String, String> m) {
    String v(String key) => (m[key] ?? '').trim();

    final rebuiltQr = EmployeeQr.buildQrData(
      idNumber: v('idNumber'),
      name: v('name'),
      position: v('position'),
      email: v('email'),
      number: v('contactNumber'),
      company: v('company'),
    );

    final existingQr = v('qrData');

    return Employee(
      name: v('name'),
      company: v('company'),
      position: v('position'),
      idNumber: v('idNumber'),
      birthday: v('birthday'),
      address: v('address'),
      govInfo: v('govInfo'),
      email: v('email'),
      contactNumber: v('contactNumber'),
      emergencyName: v('emergencyName'),
      emergencyNumber: v('emergencyNumber'),
      photoUrl: v('photoUrl'),
      signatureUrl: v('signatureUrl'),
      qrData: existingQr.isNotEmpty ? existingQr : rebuiltQr,

      // new fields (safe for old files)
      idFrontRef: v('idFrontRef'),
      idBackRef: v('idBackRef'),
    );
  }
}

class EmployeeQr {
  static String buildQrData({
    required String idNumber,
    required String name,
    required String position,
    required String email,
    required String number,
    required String company,
  }) {
    return jsonEncode({
      "id": idNumber,
      "name": name,
      "position": position,
      "email": email,
      "number": number,
      "company": company,
    });
  }
}
