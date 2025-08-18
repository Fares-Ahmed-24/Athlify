import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/services.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:Athlify/services/trainer.dart';

final TrainerService _trainerService = TrainerService();

Future<void> showDeleteConfirmationDialogTrainer({
  required BuildContext context,
  required Trainer trainer,
  VoidCallback? onSuccess,
}) async {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.topSlide,
    title: 'Are you sure?',
    desc:
        'Do you really want to delete this Trainer card? This action cannot be undone.',
    btnCancelOnPress: () {},
    btnOkOnPress: () async {
      final result = await _trainerService.deleteTrainerById(trainer.id);

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

Future<void> showEditTrainerDialog({
  required BuildContext context,
  required Trainer trainer,
  VoidCallback? onSuccess,
}) async {
  TextEditingController nameController =
      TextEditingController(text: trainer.name);
  TextEditingController locationController =
      TextEditingController(text: trainer.location);
  TextEditingController priceController =
      TextEditingController(text: trainer.price.toString());
  TextEditingController phoneController =
      TextEditingController(text: trainer.phone);
  TextEditingController bioController =
      TextEditingController(text: trainer.bio ?? '');
  TextEditingController experienceController =
      TextEditingController(text: trainer.experienceYears?.toString() ?? '');
  bool isAvailable = trainer.isAvailable;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final List<String> trainerTypes = [
    "football",
    "basketball",
    "paddle",
    "tennis"
  ];
  String selectedTrainerType = trainer.category;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: PrimaryColor,
        title: Text('Edit Trainer Card', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]"))
                  ],
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.white),
                    errorStyle: TextStyle(color: SecondaryColor),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "The field cannot be empty"
                      : null,
                ),
                TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]"))
                  ],
                  controller: locationController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: Colors.white),
                    errorStyle: TextStyle(color: SecondaryColor),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "The field cannot be empty"
                      : null,
                ),
                TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: priceController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Colors.white),
                    errorStyle: TextStyle(color: SecondaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return "The field cannot be empty";
                    final int? price = int.tryParse(value.trim());
                    if (price == null || price < 100 || price > 1000)
                      return "Price must be between 100 and 1000";
                    return null;
                  },
                ),
                TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: phoneController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(color: Colors.white),
                    errorStyle: TextStyle(color: SecondaryColor),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "The field cannot be empty"
                      : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedTrainerType,
                  dropdownColor: PrimaryColor,
                  decoration: InputDecoration(
                    labelText: 'Trainer Type',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  iconEnabledColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  items: trainerTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) selectedTrainerType = newValue;
                  },
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please select a trainer type'
                      : null,
                ),
                TextFormField(
                  controller: bioController,
                  maxLength: 500,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Bio (optional)',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
                TextFormField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: experienceController,
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Experience Years (optional)',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final exp = int.tryParse(value);
                      if (exp == null || exp < 0 || exp > 30) {
                        return 'Enter a number between 0 and 30';
                      }
                    }
                    return null;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Available:', style: TextStyle(color: Colors.white)),
                    Switch(
                      value: isAvailable,
                      onChanged: (value) {
                        isAvailable = value;
                        (context as Element).markNeedsBuild();
                      },
                      activeColor: SecondaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SecondaryColor),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final result = await _trainerService.updateTrainerCard(
                  trainer.id,
                  nameController.text.trim(),
                  trainer.email,
                  locationController.text.trim(),
                  int.tryParse(priceController.text.trim()) ?? 0,
                  selectedTrainerType,
                  phoneController.text.trim(),
                  isAvailable,
                  bioController.text.trim().isEmpty
                      ? ''
                      : bioController.text.trim(),
                  experienceController.text.trim().isEmpty
                      ? 0
                      : int.tryParse(experienceController.text.trim()) ?? 0,
                  trainer.gallery ?? [], // ✅ ضفنا الجاليري الحالية أو فاضية
                  trainer.certifications ??
                      [], // ✅ ضفنا الشهادات الحالية أو فاضية
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
