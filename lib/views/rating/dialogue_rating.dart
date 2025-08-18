import 'package:Athlify/constant/Constants.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:Athlify/services/rating%20_service.dart';
import 'package:Athlify/models/rating_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketRatingDialog extends StatefulWidget {
  final String itemId;

  const MarketRatingDialog({
    super.key,
    required this.itemId,
  });

  @override
  State<MarketRatingDialog> createState() => _MarketRatingDialogState();
}

class _MarketRatingDialogState extends State<MarketRatingDialog> {
  double _rating = 0;
  bool _isLoading = false;
  RatingResponse? _ratingData;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserIdAndData();
  }

  Future<void> _loadUserIdAndData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('email') ?? '';

    if (!mounted) return;

    setState(() {
      _userId = userId;
    });

    _loadRatingData();
  }

  void _loadRatingData() async {
    try {
      final data = await RatingService.fetchAverageRating(widget.itemId);
      if (mounted) {
        setState(() {
          _ratingData = data;
        });
      }
    } catch (e) {
      print("Error fetching market rating: $e");
    }
  }

  void _submitRating() async {
    setState(() {
      _isLoading = true;
    });

    bool success = await RatingService.submitRating(
      userId: _userId,
      itemId: widget.itemId,
      itemType: 'market',
      rating: _rating,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    AwesomeDialog(
      context: context,
      dialogType: success ? DialogType.success : DialogType.error,
      title: success ? 'Thank you!' : 'Error',
      desc:
          success ? 'Rating submitted successfully.' : 'Something went wrong.',
      btnOkOnPress: () {
        Navigator.of(context).pop();
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final average = _ratingData?.averageRating ?? 0.0;
    final count = _ratingData?.ratingCount ?? 0;

    return AlertDialog(
      title: const Text("Rate this Product"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_ratingData != null) ...[
            Text("Average: ${average.toStringAsFixed(1)} / 5"),
            Text("Rated by $count user${count == 1 ? '' : 's'}"),
            const SizedBox(height: 10),
          ],
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            allowHalfRating: false,
            itemCount: 5,
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: SecondaryContainerText),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: PrimaryColor),
          onPressed: _rating == 0 || _isLoading || _userId.isEmpty
              ? null
              : _submitRating,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
