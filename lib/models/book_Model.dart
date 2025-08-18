class Booking {
  final String id;
  final String userId;
  final String userEmail;
  final String? coachId;
  final String? fieldId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;
  final double price;
  final String status;

  Booking({
    required this.id,
    required this.userId,
    required this.userEmail,
    this.coachId,
    this.fieldId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.price,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      userId: json['userId'],
      coachId: json['coachId'],
      fieldId: json['fieldId'],
      date: DateTime.parse(json['date']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: json['duration'],
      price: (json['price'] as num).toDouble(),
      status: json['status'] ?? 'active',
      userEmail: json['userEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'coachId': coachId,
      'fieldId': fieldId,
      'date': date.toIso8601String().split('T')[0],
      'startTime': startTime.toIso8601String().split('T')[1].substring(0, 5),
      'duration': duration,
      'price': price,
      'userEmail':userEmail
    };
  }
}
