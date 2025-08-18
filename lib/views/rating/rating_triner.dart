import 'package:Athlify/services/rating%20_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:Athlify/models/rating_model.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:Athlify/constant/Constants.dart';

void showTrainerRatingDialog({
  required BuildContext context,
  required String userId,
  required String itemId,
  required String itemType,
}) {
  showDialog(
    context: context,
    builder: (context) => TrainerRatingDialog(
      userId: userId,
      itemId: itemId,
      itemType: itemType,
    ),
  );
}

class TrainerRatingDialog extends StatefulWidget {
  final String userId;
  final String itemId;
  final String itemType;

  const TrainerRatingDialog({
    super.key,
    required this.userId,
    required this.itemId,
    required this.itemType,
  });

  @override
  State<TrainerRatingDialog> createState() => _TrainerRatingDialogState();
}

class _TrainerRatingDialogState extends State<TrainerRatingDialog> {
  double _rating = 0;
  bool _isLoading = false;
  RatingResponse? _ratingData;

  @override
  void initState() {
    super.initState();
    _loadRatingData();
  }

  Future<void> _loadRatingData() async {
    try {
      final data = await RatingService.fetchAverageRating(widget.itemId);
      if (mounted) {
        setState(() {
          _ratingData = data;
        });
      }
    } catch (e) {
      print("Error loading rating: $e");
    }
  }

  void _submitRating() async {
    setState(() {
      _isLoading = true;
    });

    bool success = await RatingService.submitRating(
      userId: widget.userId,
      itemId: widget.itemId,
      itemType: widget.itemType,
      rating: _rating,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      await _loadRatingData();
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Thanks!',
        desc: 'Your rating has been submitted successfully.',
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.leftSlide,
        title: 'Error',
        desc: 'Something went wrong. Please try again later.',
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final average = _ratingData?.averageRating ?? 0.0;
    final count = _ratingData?.ratingCount ?? 0;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Rate the Trainer",
        style: TextStyle(color: PrimaryColor, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_ratingData != null) ...[
              Text(
                "Average rating: ${average.toStringAsFixed(1)} / 5",
                style: const TextStyle(
                    fontSize: 16,
                    color: PrimaryColor,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                "Rated by $count user${count == 1 ? '' : 's'}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
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
          onPressed: _rating == 0 || _isLoading ? null : _submitRating,
          style: ElevatedButton.styleFrom(backgroundColor: PrimaryColor),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  "Submit",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
