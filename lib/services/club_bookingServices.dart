import 'dart:convert';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/book_Model.dart';
import 'package:http/http.dart' as http;

class BookingService {
  final String Url = '$baseUrl/api/club-booking';

  Future<Booking> createBooking({
    required String userId,
    required String userEmail,
    String? fieldId,
    String? coachId,
    required String date,        // <- from user calendar (already 'yyyy-MM-dd')
    required String startTime,   // full ISO: "2025-07-01T13:00:00"
    required String endTime,     // full ISO: "2025-07-01T14:00:00"
    required int duration,
    required int price,
  }) async {
    // Parse the full start and end times
    final DateTime parsedStart = DateTime.parse(startTime);
    final DateTime parsedEnd = DateTime.parse(endTime);

    // Extract only the HH:mm portion
    final String formattedStartTime =
        "${parsedStart.hour.toString().padLeft(2, '0')}:"
        "${parsedStart.minute.toString().padLeft(2, '0')}";

    final String formattedEndTime =
        "${parsedEnd.hour.toString().padLeft(2, '0')}:"
        "${parsedEnd.minute.toString().padLeft(2, '0')}";

    final response = await http.post(
      Uri.parse('$Url/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'userEmail': userEmail,
        'fieldId': fieldId,
        'coachId': coachId,
        'date': date, // directly from the calendar
        'startTime': formattedStartTime,
        'endTime': formattedEndTime,
        'duration': duration,
        'price': price,
      }),
    );

    if (response.statusCode == 201) {
      print('✅ Booking created successfully: ${response.body}');
      return Booking.fromJson(jsonDecode(response.body));
    } else {
      print('❌ Booking failed: ${response.body}');
      throw Exception('Failed to create booking: ${response.body}');
    }
  }

  Future<bool> checkAvailability({
    required String fieldId,
    required String date,
    required String startTime,
    required int duration,
  }) async {
    final response = await http.post(
      Uri.parse('$Url/check-availability'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fieldId': fieldId,
        'date': date,
        'startTime': startTime,
        'duration': duration,
      }),
    );

    final json = jsonDecode(response.body);
    print(json);
    if (response.statusCode == 200) {
      return json['available'];
    } else {
      print(json['error']);
      throw Exception('Failed to check availability: ${json['error']}');
    }
  }

  Future<bool> checkTrainerAvailability({
    String? fieldId,
    String? trainerId, // This maps to `coachId` in backend
    required String date,
    required String startTime,
    required int duration,
  }) async {
    final response = await http.post(
      Uri.parse('$Url/check-availability-T'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (fieldId != null) 'fieldId': fieldId,
        if (trainerId != null)  'coachId': trainerId, // ✅ match backend param name
        'date': date,
        'startTime': startTime,
        'duration': duration,
      }),
    );

    final json = jsonDecode(response.body);
    print(json);
    if (response.statusCode == 200) {
      return json['available'];
    } else {
      print(json['error']);
      throw Exception('Failed to check availability: ${json['error']}');
    }
  }

  Future<List<Booking>> getAllBookingsForClub(String clubId) async {
    final response = await http.get(Uri.parse('$Url/club/$clubId'));

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => Booking.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch bookings for club');
    }
  }

  Future<List<Booking>> getAllBookingsForTrainer(String trainer) async {
    final response = await http.get(Uri.parse('$Url/trainer/$trainer'));

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => Booking.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch sessions for club');
    }
  }


  Future<List<Booking>> getBookingsByUser(String userId) async {
    final response = await http.get(Uri.parse('$Url/user/$userId'));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => Booking.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch user bookings');
    }
  }

  Future<Booking?> getNearestBookingByUser(String userId) async {
    final response = await http.get(Uri.parse('$Url/user/$userId'));

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      final now = DateTime.now();

      final futureBookings = list.map((e) => Booking.fromJson(e)).where((booking) {
        // Directly use startTime as DateTime
        return booking.startTime.isAfter(now);
      }).toList();

      if (futureBookings.isEmpty) return null;

      // Sort based on startTime
      futureBookings.sort((a, b) => a.startTime.compareTo(b.startTime));

      return futureBookings.first;
    } else {
      throw Exception('Failed to fetch user bookings');
    }
  }

  Future<Booking> getBookingById(String id) async {
    final response = await http.get(Uri.parse('$Url/$id'));
    if (response.statusCode == 200) {
      return Booking.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch booking');
    }
  }

  Future<Booking> updateBooking(String id, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$Url/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return Booking.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update booking');
    }
  }

  Future<Booking> cancelBooking(String id) async {
    final response = await http.patch(Uri.parse('$Url/$id/cancel'));
    if (response.statusCode == 200) {
      return Booking.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to cancel booking');
    }
  }
}
