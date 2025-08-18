import 'package:Athlify/constant/Constants.dart';
import 'package:Athlify/services/club.dart';
import 'package:Athlify/views/bottom_nav_view/ClubsTab.dart';
import 'package:Athlify/widget/custome_image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class AddClubPage extends StatefulWidget {
  @override
  State<AddClubPage> createState() => _AddClubPageState();
}

class _AddClubPageState extends State<AddClubPage> {
  TextEditingController clubName = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController imageController = TextEditingController();
  List<String> categories = ["Football", "Tennis", "Basketball", "Paddle"];
  String selectedCategory = '';
  ClubService _clubService = ClubService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  XFile? _pickedImage; // Declare selected image variable
  String? _uploadedImageUrl;
  final ImageUploadService imageUploadService = ImageUploadService();

  // Function to pick image from the gallery
  Future<void> pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select Image Source",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context); // قفل البوتوم شيت
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.camera);
                      if (image != null) {
                        setState(() {
                          _pickedImage = image;
                        });
                      }
                    },
                    icon: Icon(Icons.camera_alt),
                    label: Text("Camera"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PrimaryColor,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context); // قفل البوتوم شيت
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          _pickedImage = image;
                        });
                      }
                    },
                    icon: Icon(Icons.photo),
                    label: Text("Gallery"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PrimaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add Club",
            style: TextStyle(color: PrimaryColor, fontWeight: FontWeight.w500)),
        iconTheme: IconThemeData(color: PrimaryColor),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomeImagePicker(
                  context: context,
                  pickedImage: _pickedImage,
                  onImagePicked: (XFile? image) {
                    setState(() {
                      _pickedImage = image;
                    });
                  },
                  icon: Icons.camera_alt),
              SizedBox(height: 20),
              Text("Club Name",
                  style: TextStyle(
                      color: PrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
              SizedBox(height: 10),
              TextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
                ],
                validator: (data) {
                  if (data!.isEmpty) {
                    return "field is empty";
                  }
                  return null;
                },
                controller: clubName,
                decoration: InputDecoration(
                    hintText: "Club name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
              SizedBox(height: 15),
              Text("Price",
                  style: TextStyle(
                      color: PrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
              SizedBox(height: 10),
              TextFormField(
                maxLength: 4,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                validator: (data) {
                  if (data!.isEmpty) {
                    return "field is empty";
                  }
                  return null;
                },
                controller: price,
                decoration: InputDecoration(
                    counter: Offstage(),
                    hintText: "Price",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
              SizedBox(height: 15),
              Text("Location",
                  style: TextStyle(
                      color: PrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
              SizedBox(height: 6),
              TextFormField(
                validator: (data) {
                  if (data!.isEmpty) {
                    return "field is empty";
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
                ],
                controller: location,
                decoration: InputDecoration(
                    hintText: "Location",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6))),
              ),
              SizedBox(height: 15),
              Text("Club Category",
                  style: TextStyle(
                      color: PrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
              SizedBox(height: 18),
              FormField(
                validator: (value) {
                  if (selectedCategory.isEmpty) {
                    return "Please select a category";
                  }
                  return null;
                },
                builder: (FormFieldState field) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 15,
                        children: categories.map((category) {
                          return ChoiceChip(
                            selectedColor: SecondaryColor,
                            backgroundColor: PrimaryColor,
                            label: Text(category,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            labelPadding: EdgeInsets.symmetric(horizontal: 12),
                            selected: selectedCategory.contains(category),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedCategory = category;
                                } else {
                                  selectedCategory = '';
                                }
                                field.didChange(selectedCategory);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (field.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            field.errorText!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (_pickedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please upload a club image"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Upload image to Cloudinary
                      String? uploadedUrl = await imageUploadService
                          .uploadImageToCloudinary(_pickedImage!);

                      _uploadedImageUrl = uploadedUrl;
                      if (_uploadedImageUrl == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Image upload failed"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String? email = prefs.getString('email');

                      // Add club to database
                      var response = await _clubService.addClub(
                        clubName.text,
                        email!,
                        location.text,
                        int.parse(price.text),
                        selectedCategory,
                        _uploadedImageUrl!, // Use the uploaded image URL
                      );

                      int resp = response['statusCode'];
                      String message = response['message'];

                      if (resp == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ClubsTab()),
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
                  style: ElevatedButton.styleFrom(
                      backgroundColor: PrimaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      fixedSize: Size(385, 60)),
                  child: Text("Add",
                      style: TextStyle(color: Colors.white, fontSize: 26)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
