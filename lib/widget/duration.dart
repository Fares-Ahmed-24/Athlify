import 'package:Athlify/constant/Constants.dart';
import 'package:flutter/material.dart';

class DurationPicker extends StatefulWidget {
  final int initialValue;
  final Function(int) onDurationSelected;

  const DurationPicker({
    Key? key,
    this.initialValue = 1,
    required this.onDurationSelected,
  }) : super(key: key);

  @override
  _DurationPickerState createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late int selectedHours;
  final int minHour = 1;
  final int maxHour = 3;

  @override
  void initState() {
    super.initState();
    selectedHours = widget.initialValue;
  }

  void _selectHour(int hour) {
    setState(() {
      selectedHours = hour;
      widget.onDurationSelected(selectedHours);
    });
  }

  @override
  Widget build(BuildContext context) {
    int? prevHour = selectedHours > minHour ? selectedHours - 1 : null;
    int? nextHour = selectedHours < maxHour ? selectedHours + 1 : null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous hour
                if (prevHour != null)
                  GestureDetector(
                    onTap: () => _selectHour(prevHour),
                    child: Text(
                      "${prevHour}h",
                      style: TextStyle(
                        fontSize: 14, // smaller
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  )
                else
                  SizedBox(height: 18),
                // Selected hour with lines
                Container(
                  margin: EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    children: [
                      Container(
                        width: 28, // smaller
                        height: 2,
                        color: PrimaryColor,
                      ),
                      SizedBox(height: 2),
                      Text(
                        "${selectedHours}h",
                        style: TextStyle(
                          fontSize: 20, // smaller
                          color: PrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Container(
                        width: 28, // smaller
                        height: 2,
                        color: PrimaryColor,
                      ),
                    ],
                  ),
                ),
                // Next hour
                if (nextHour != null)
                  GestureDetector(
                    onTap: () => _selectHour(nextHour),
                    child: Text(
                      "${nextHour}h",
                      style: TextStyle(
                        fontSize: 14, // smaller
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  )
                else
                  SizedBox(height: 18),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
