import 'dart:io';
import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/UserController.dart';
import 'package:Athlify/widget/edit_profile_widgets/customeEdit_text_field.dart';
import 'package:flutter/material.dart';
import 'package:Athlify/models/user_model.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Athlify/services/upload_image.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late Future<Map<String, dynamic>> _userDataFuture;
  late UserController _userController;
  String? userProfile;
  XFile? _pickedImage;
  String? _uploadedImageUrl;

  // Add controllers
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    _userController = UserController(); // Initialize UserController
    _userDataFuture = _userController.getUserByEmail(); // Fetch user data
    nameController = TextEditingController(); // Initialize controllers
    ageController = TextEditingController();
    phoneController = TextEditingController();
  }

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final UploadImageService imageUploadService = UploadImageService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!['success']) {
            return Center(
              child: Text(
                snapshot.data!['message']?.toString() ?? 'No data available',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          // Extract the user data
          User user = snapshot.data!['user'];

          // Set up text controllers with user data
          nameController.text = user.Username.toString();
          ageController.text = user.age.toString();
          phoneController.text = user.phone.toString();

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _pickedImage != null
                            ? FileImage(File(
                                _pickedImage!.path)) // If a new image is picked
                            : (_uploadedImageUrl != null
                                ? NetworkImage(
                                    _uploadedImageUrl!) // If an uploaded image URL is available
                                : (user.imageUrl != null
                                    ? NetworkImage(user
                                        .imageUrl!) // If the user has an image URL
                                    : null)), // If no image URL exists
                        child: (_pickedImage == null &&
                                _uploadedImageUrl == null &&
                                user.imageUrl == null)
                            ? Icon(Icons.person,
                                size: 70,
                                color: Colors
                                    .grey[700]) // If no image is available
                            : null,
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () async {
                            await pickImage(); // Pick image from gallery
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color:
                                  PrimaryColor, // Assuming PrimaryColor is blue
                              border: Border.all(color: Colors.white, width: 3),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.camera_alt_sharp,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  CustomEditInputField(
                      label: 'Name',
                      controller: nameController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-Z\s]")),
                      ],
                      keyboardType: TextInputType.name,
                      screenWidth: screenWidth),
                  CustomEditInputField(
                      label: 'Age',
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxlength: 2,
                      screenWidth: screenWidth),
                  CustomEditInputField(
                    label: 'Email',
                    controller: TextEditingController(text: user.email),
                    screenWidth: screenWidth,
                    enabled: false,
                  ),
                  PasswordEditField(context, screenWidth),
                  CustomEditInputField(
                    label: 'Phone number',
                    controller: phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    maxlength: 11,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  ElevatedButton(
                    onPressed: () async {
                      String? uploadedUrl;

                      // If a new image is picked, upload it
                      if (_pickedImage != null) {
                        uploadedUrl = await imageUploadService
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
                      } else {
                        // If no new image is picked, keep the old image URL or set it to null if it's unavailable
                        uploadedUrl = _uploadedImageUrl ?? user.imageUrl;
                      }

                      // Proceed with updating user details
                      var response = await _userController.updateUserDetails(
                        user.email.toString(),
                        nameController.text,
                        int.parse(ageController.text),
                        phoneController.text,
                        uploadedUrl!,
                      );

                      // Display the result of the update
                      if (response['success']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(response['message']),
                              backgroundColor: Colors.green),
                        );
                        Navigator.pop(
                            context); // Go back to the previous screen
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(response['message']),
                              backgroundColor: Colors.red),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          PrimaryColor, // Assuming PrimaryColor is blue
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1,
                          vertical: screenHeight * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
