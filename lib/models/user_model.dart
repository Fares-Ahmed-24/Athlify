class User {
  String id;
  String Username;
  String email;
  String password;
  int age;
  String phone;
  String? requestedRole;
  String userType;
  String? imageUrl;
  final String? blockUntil;
  int? reports;

  User(
      {required this.id,
      required this.Username,
      required this.email,
      required this.password,
      required this.age,
      required this.phone,
      required this.userType,
      this.requestedRole,
      this.imageUrl,
      this.reports,
      this.blockUntil});

  factory User.fromJson(Map<String, dynamic> jsonData) {
    return User(
      Username: jsonData['name'] ?? '',
      email: jsonData['Email'] ?? '',
      password: jsonData['Password'] ?? '',
      age: jsonData['Age'] ?? 0,
      phone: jsonData['Phone'] ?? '',
      userType: jsonData['userType'] ?? '',
      id: jsonData['_id']?.toString() ?? '',
      requestedRole: jsonData['requestedRole'],
      imageUrl: jsonData['imageUrl'] ??
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Lionel-Messi-Argentina-2022-FIFA-World-Cup_%28cropped%29.jpg/320px-Lionel-Messi-Argentina-2022-FIFA-World-Cup_%28cropped%29.jpg',
      blockUntil: jsonData['blockUntil'],
      reports: jsonData['reportCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': Username,
      'Email': email,
      'Password': password,
      'Age': age,
      'Phone': phone,
      'userType': userType,
      'requestedRole': requestedRole,
      'imageUrl': imageUrl,
      'blockUntil': blockUntil,
      'reportCount':reports
    };
  }
}
