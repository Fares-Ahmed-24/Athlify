import 'package:Athlify/views/bottom_nav_view/TrainersTab.dart';
import 'package:Athlify/widget/custome_image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/upload_image.dart';
import 'package:Athlify/services/trainer.dart';
import 'package:Athlify/widget/addTextfields.dart';
import 'package:Athlify/widget/customeButton.dart';
import 'package:Athlify/widget/label_trainer_field.dart';

class Addtrainer extends StatefulWidget {
  @override
  State<Addtrainer> createState() => _AddtrainerState();
}

class _AddtrainerState extends State<Addtrainer> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController experienceYearsController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final trainerService = TrainerService();
  String? _selectedSport;
  XFile? _pickedImage;
  String? _uploadedImageUrl;
  List<XFile> galleryImages = [];
  List<XFile> certificationImages = [];
  List<String> uploadedGallery = [];
  List<String> uploadedCertifications = [];
  bool isAvailable = true;

  final UploadImageService imageUploadService = UploadImageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 45.0, left: 14),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: CircleAvatar(
                        backgroundColor: ContainerColor,
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 82),
                    Text("Add TrainerCard",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 30),
                CustomeImagePicker(
                  icon: Icons.person,
                  context: context,
                  pickedImage: _pickedImage,
                  onImagePicked: (XFile? image) {
                    setState(() {
                      _pickedImage = image;
                    });
                  },
                  uploadedImageUrl: null,
                ),
                const SizedBox(height: 20),
                buildLabel(text: "Name"),
                CustomaddTextFormField(
                  hintText: 'Enter your name',
                  controller: nameController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]"))
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabel(text: "Price"),
                        CustomaddTextFormField(
                          keyboardType: TextInputType.number,
                          maxlength: 4,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          hintText: "Price",
                          controller: priceController,
                          widthTextField: 180,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 22.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabel(text: "Category"),
                          Container(
                            width: 175,
                            height: 67,
                            decoration: BoxDecoration(
                              color: ContainerColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10),
                              child: DropdownButton<String>(
                                dropdownColor: Colors.white,
                                value: _selectedSport,
                                hint: const Text('Select Sport'),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedSport = newValue;
                                  });
                                },
                                items: <String>[
                                  'football',
                                  'tennis',
                                  'basketball',
                                  'paddle'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                underline: Container(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                buildLabel(text: "Phone number"),
                CustomaddTextFormField(
                  keyboardType: TextInputType.phone,
                  maxlength: 11,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  hintText: "Enter your mobile number",
                  controller: phoneController,
                ),
                const SizedBox(height: 20),
                buildLabel(text: "Address"),
                CustomaddTextFormField(
                  hintText: "Enter your location",
                  controller: addressController,
                ),
                const SizedBox(height: 20),
                buildLabel(text: "Bio (optional)"),
                CustomaddTextFormField(
                  hintText: "Tell us about the trainer",
                  controller: bioController,
                  maxlines: 3,
                ),
                const SizedBox(height: 20),
                buildLabel(text: "Experience Years (optional)"),
                CustomaddTextFormField(
                  hintText: "e.g. 5",
                  controller: experienceYearsController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await ImagePicker().pickMultiImage();
                    if (picked.isNotEmpty) {
                      setState(() {
                        galleryImages = picked;
                      });
                    }
                  },
                  child: Text("Pick Gallery Images"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await ImagePicker().pickMultiImage();
                    if (picked.isNotEmpty) {
                      setState(() {
                        certificationImages = picked;
                      });
                    }
                  },
                  child: Text("Pick Certification Images"),
                ),
                const SizedBox(height: 30),
                customeButton(
                  onPressedCallback: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? email = prefs.getString('email');

                    if (formKey.currentState!.validate()) {
                      if (_selectedSport == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Please select a sport category'),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }

                      String? uploadedUrl = await imageUploadService
                          .uploadImageToCloudinary(_pickedImage!);

                      if (uploadedUrl == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Image upload failed. Please try again.'),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }

                      _uploadedImageUrl = uploadedUrl;

                      uploadedGallery.clear();
                      uploadedCertifications.clear();

                      for (var img in galleryImages) {
                        final url = await imageUploadService
                            .uploadImageToCloudinary(img);
                        if (url != null) uploadedGallery.add(url);
                      }

                      for (var img in certificationImages) {
                        final url = await imageUploadService
                            .uploadImageToCloudinary(img);
                        if (url != null) uploadedCertifications.add(url);
                      }

                      var response = await trainerService.addTrainerCard(
                        nameController.text,
                        _uploadedImageUrl!,
                        email!,
                        priceController.text,
                        phoneController.text,
                        _selectedSport!,
                        addressController.text,
                        isAvailable,
                        bioController.text,
                        int.tryParse(experienceYearsController.text) ?? 0,
                        uploadedGallery,
                        uploadedCertifications,
                      );
                      int resp = response['statusCode'];
                      String message = response['message'];

                      if (resp == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(message),
                              backgroundColor: Colors.green),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TrainersTab()),
                        );
                      } else {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.rightSlide,
                          title: 'Failed',
                          desc: message,
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {},
                        ).show();
                      }
                    }
                  },
                  labelText: "Add Trainer Card",
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
