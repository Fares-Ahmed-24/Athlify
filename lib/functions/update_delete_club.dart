import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/services.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/club_model.dart';
import 'package:Athlify/services/club.dart';

final ClubService _clubService = ClubService();

Future<void> showDeleteConfirmationDialog({
  required BuildContext context,
  required ClubModel club,
  VoidCallback? onSuccess,
}) async {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.topSlide,
    title: 'Are you sure?',
    desc:
        'Do you really want to delete this club? This action cannot be undone.',
    btnCancelOnPress: () {},
    btnOkOnPress: () async {
      final result = await _clubService.deleteClubById(club.id);

      if (result['statusCode'] == 200 && onSuccess != null) {
        onSuccess();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(result['message'], style: TextStyle(color: Colors.white)),
          backgroundColor:
              result['statusCode'] == 200 ? Colors.green : Colors.red,
        ),
      );
    },
  ).show();
}

Future<void> showEditClubDialog({
  required BuildContext context,
  required ClubModel club,
  VoidCallback? onSuccess,
}) async {
  TextEditingController nameController = TextEditingController(text: club.name);
  TextEditingController locationController =
      TextEditingController(text: club.location);
  TextEditingController priceController =
      TextEditingController(text: club.price.toString());
  TextEditingController imageController =
      TextEditingController(text: club.image);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final List<String> clubTypes = ["Football", "Tennis", "Basketball", "Paddle"];
  String selectedClubType = club.clubType;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: PrimaryColor,
        title: Text(
          'Edit Club',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
                  ],
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.white),
                    errorStyle: TextStyle(
                        color:
                            SecondaryColor), // Set error text color to SecondaryColor
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "The field cannot be empty";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
                  ],
                  controller: locationController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: Colors.white),
                    errorStyle: TextStyle(
                        color:
                            SecondaryColor), // Set error text color to SecondaryColor
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "The field cannot be empty";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: priceController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Colors.white),
                    errorStyle: TextStyle(
                        color:
                            SecondaryColor), // Set error text color to SecondaryColor
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "The field cannot be empty";
                    }
                    final int? price = int.tryParse(value.trim());
                    if (price == null) {
                      return "Price must be a number";
                    }
                    if (price < 100 || price > 1000) {
                      return "Price must be between 100 and 1000";
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedClubType,
                  dropdownColor: PrimaryColor,
                  decoration: InputDecoration(
                    labelText: 'Club Type',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  iconEnabledColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  items: clubTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedClubType = newValue;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please select a club type';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SecondaryColor),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final result = await _clubService.updateClub(
                  club.id,
                  nameController.text.trim(),
                  club.email,
                  locationController.text.trim(),
                  int.tryParse(priceController.text.trim()) ?? 0,
                  selectedClubType,
                  imageController.text,
                );

                Navigator.of(context).pop();

                if (result['statusCode'] == 200 && onSuccess != null) {
                  onSuccess();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'],
                        style: TextStyle(color: Colors.white)),
                    backgroundColor:
                        result['statusCode'] == 200 ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
