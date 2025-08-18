import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/views/booking_view/book_confirmation.dart';
import 'package:Athlify/widget/duration.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/club_bookingServices.dart';

class Book extends StatefulWidget {
  final ClubModel club;
  Book({required this.club, Key? key}) : super(key: key);

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _startDateTime;
  int _duration = 1;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.transparent,
              height: screenHeight,
              width: screenWidth,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.85,
                  minHeight: screenHeight * 0.60,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 24,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 6,
                        margin: EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Text(
                        "Book Your Slot",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: PrimaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Select your preferred date & time",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 20),
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        shadowColor: PrimaryColor.withOpacity(0.18),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ContainerColor,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 8.0),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: PrimaryColor,
                                onPrimary: Colors.white,
                                surface: ContainerColor,
                                onSurface: Colors.black87,
                              ),
                              dialogBackgroundColor: ContainerColor,
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: PrimaryColor,
                                ),
                              ),
                            ),
                            child: CalendarDatePicker(
                              initialDate:
                              _selectedDate.isBefore(DateTime.now())
                                  ? DateTime.now()
                                  : _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 365)),
                              onDateChanged: (date) {
                                setState(() => _selectedDate = date);
                              },
                              selectableDayPredicate: (date) {
                                final now = DateTime.now();
                                return !date.isBefore(
                                    DateTime(now.year, now.month, now.day));
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: PrimaryColor.withOpacity(0.18),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                TimeOfDay now = TimeOfDay.now();
                                bool isToday =
                                    _selectedDate.year == DateTime.now().year &&
                                        _selectedDate.month ==
                                            DateTime.now().month &&
                                        _selectedDate.day == DateTime.now().day;

                                TimeOfDay initialTime = _startDateTime != null
                                    ? TimeOfDay(
                                    hour: _startDateTime!.hour, minute: 0)
                                    : (isToday
                                    ? TimeOfDay(hour: now.hour, minute: 0)
                                    : TimeOfDay(hour: 0, minute: 0));

                                TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: initialTime,
                                  builder: (context, child) {
                                    return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: false),
                                      child: child!,
                                    );
                                  },
                                  minuteLabelText: '00',
                                  helpText: 'Select Hour Only',
                                );
                                if (picked != null) {
                                  if (isToday && picked.hour < now.hour) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Cannot select a past time')),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    _startDateTime = DateTime(
                                      _selectedDate.year,
                                      _selectedDate.month,
                                      _selectedDate.day,
                                      picked.hour,
                                      0,
                                    );
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 20),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _startDateTime != null
                                          ? TimeOfDay(
                                          hour: _startDateTime!.hour,
                                          minute: 0)
                                          .format(context)
                                          .replaceAll(
                                          RegExp(r':\d\d'), ':00')
                                          : "Select Time",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: PrimaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 24),
                          DurationPicker(
                            initialValue: _duration,
                            onDurationSelected: (hours) {
                              setState(() {
                                _duration = hours;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () async {
                                  if (_startDateTime == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Please select a start time')),
                                    );
                                    return;
                                  }
                                  if (_duration <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Please select a valid duration')),
                                    );
                                    return;
                                  }

                                  BookingService bok = BookingService();
                                  try {
                                    final formattedTime =
                                        '${_startDateTime!.hour.toString().padLeft(2, '0')}:${_startDateTime!.minute.toString().padLeft(2, '0')}';

                                    bool? available =
                                    await bok.checkAvailability(
                                      fieldId: widget.club.id,
                                      date: _selectedDate
                                          .toIso8601String()
                                          .split('T')[0],
                                      startTime: formattedTime,
                                      duration: _duration,
                                    );

                                    if (available == true) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BookConfirmation(
                                                club: widget.club,
                                                date: _selectedDate,
                                                startTime: _startDateTime!,
                                                duration:
                                                Duration(hours: _duration),
                                              ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Selected slot is not available')),
                                      );
                                    }
                                  } catch (e) {
                                    print("Error checking availability: $e");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to check availability: $e')),
                                    );
                                  }
                                },
                                child: Text(
                                  'Confirm',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(width: 18),
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  side: BorderSide(
                                      color: PrimaryColor, width: 1.5),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: PrimaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
