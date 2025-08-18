import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/book_Model.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:Athlify/services/club.dart';
import 'package:Athlify/services/trainer.dart';
import 'package:Athlify/services/club_bookingServices.dart';
import 'package:Athlify/widget/clubTicket.dart';
import 'package:Athlify/widget/sessionTicket.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widget/Filterchip.dart';

class BookHistory extends StatefulWidget {
  const BookHistory({Key? key}) : super(key: key);

  @override
  State<BookHistory> createState() => _BookHistoryState();
}

enum BookingTypeFilter { all, games, sessions }

class _BookHistoryState extends State<BookHistory> {
  final BookingService bookingService = BookingService();
  Future<List<Map<String, dynamic>>>? _futureBookingsWithDetails;
  List<Map<String, dynamic>> _allBookings = [];
  BookingTypeFilter _selectedFilter = BookingTypeFilter.all;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';
      List<Booking> bookings = await bookingService.getBookingsByUser(userId);

      List<Map<String, dynamic>> bookingsWithDetails = [];
      for (var booking in bookings) {
        ClubModel? club;
        Trainer? trainer;

        if (booking.fieldId != null && booking.fieldId!.isNotEmpty) {
          try {
            club = await ClubService().getClubById(booking.fieldId!);
          } catch (e) {
            print('Failed to load club ${booking.fieldId}: $e');
          }
        }

        if (booking.coachId != null && booking.coachId!.isNotEmpty) {
          try {
            trainer = await TrainerService().getTrainerById(booking.coachId!);
          } catch (e) {
            print('Failed to load trainer ${booking.coachId}: $e');
          }
        }

        bookingsWithDetails.add({
          'booking': booking,
          'club': club,
          'trainer': trainer,
        });
      }

      // Sort bookings by descending start time (most recent first)
      bookingsWithDetails.sort((a, b) {
        final aTime = a['booking'].startTime;
        final bTime = b['booking'].startTime;
        return bTime.compareTo(aTime);
      });

      setState(() {
        _allBookings = bookingsWithDetails;
        _futureBookingsWithDetails = Future.value(bookingsWithDetails);
      });
    } catch (e) {
      print('Error loading bookings or related data: $e');
    }
  }

  void _filterBookings(BookingTypeFilter filter) {
    setState(() {
      _selectedFilter = filter;
      _futureBookingsWithDetails =
          Future.value(_applyFilter(_allBookings, filter));
    });
  }

  List<Map<String, dynamic>> _applyFilter(
      List<Map<String, dynamic>> list, BookingTypeFilter filter) {
    switch (filter) {
      case BookingTypeFilter.games:
        return list.where((item) => item['trainer'] == null).toList();
      case BookingTypeFilter.sessions:
        return list.where((item) => item['trainer'] != null).toList();
      case BookingTypeFilter.all:
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: PrimaryColor,
          title: const Text(
            'Booking History',
            style: TextStyle(color: Colors.white),
          )),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildFilterChip('All', BookingTypeFilter.all),
                _buildFilterChip('Games', BookingTypeFilter.games),
                _buildFilterChip('Sessions', BookingTypeFilter.sessions),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _futureBookingsWithDetails == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _futureBookingsWithDetails,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No bookings found.'));
                      }

                      final dataList = snapshot.data!;
                      return ListView.builder(
                        itemCount: dataList.length,
                        itemBuilder: (context, index) {
                          final booking = dataList[index]['booking'] as Booking;
                          final club = dataList[index]['club'] as ClubModel?;
                          final trainer =
                              dataList[index]['trainer'] as Trainer?;

                          final startDateTime = booking.startTime;
                          final endDateTime = booking.endTime;
                          final startTime =
                              TimeOfDay.fromDateTime(startDateTime);
                          final endTime = TimeOfDay.fromDateTime(endDateTime);
                          final duration =
                              endDateTime.difference(startDateTime);

                         return Padding(
  padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
  child: Dismissible(
    key: ValueKey(booking.id),
    direction: DismissDirection.endToStart,
    background: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      color: Colors.red,
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    confirmDismiss: (direction) async {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Cancel Booking?"),
          content: const Text("Are you sure you want to cancel this booking?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        ),
      );
    },
    onDismissed: (direction) async {
      await bookingService.cancelBooking(booking.id!); // 🛠 Your cancel logic
      _loadBookings(); // 🔁 Refresh after cancel
    },
    child: Column(
      children: [
        if (trainer != null)
          SessionTicketCard(
            trainer: trainer,
            clubId: club?.id ?? 'at_home',
            date: booking.date,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
          )
        else if (club != null)
          TicketCard(
            startTime: startTime,
            date: booking.date,
            duration: duration,
            endTime: endTime,
            club: club,
          )
        else
          const Text(
            "Invalid booking: No club or trainer info",
            style: TextStyle(color: Colors.redAccent),
          ),
        const SizedBox(height: 10),
      ],
    ),
  ),
);

                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, BookingTypeFilter value) {
    final isSelected = _selectedFilter == value;
    return Clubsfilterchip(
      label: label,
      isSelected: isSelected,
      onSelected: () => _filterBookings(value),
    );
  }
}
