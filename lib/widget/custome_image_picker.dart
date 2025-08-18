import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Athlify/constant/Constants.dart';

class CustomeImagePicker extends FormField<bool> {
  CustomeImagePicker({
    Key? key,
    required BuildContext context,
    required XFile? pickedImage,
    required Function(XFile?) onImagePicked,
    String? uploadedImageUrl,
    required IconData icon,
  }) : super(
          key: key,
          validator: (value) {
            if (pickedImage == null) {
              return "Please pick your image";
            }
            return null;
          },
          builder: (FormFieldState<bool> image) {
            return Column(
              children: [
                Center(
                  child: SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 65,
                          backgroundColor: ContainerColor,
                          backgroundImage: pickedImage != null
                              ? FileImage(File(pickedImage.path))
                              : (uploadedImageUrl != null
                                  ? NetworkImage(uploadedImageUrl)
                                      as ImageProvider
                                  : null),
                          child: pickedImage == null && uploadedImageUrl == null
                              ? Icon(icon, size: 70, color: Colors.grey[700])
                              : null,
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () async {
                              // Show bottom sheet on tap
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return SafeArea(
                                    child: Wrap(
                                      children: <Widget>[
                                        ListTile(
                                          leading:
                                              const Icon(Icons.photo_library),
                                          title: const Text('Gallery'),
                                          onTap: () async {
                                            Navigator.of(context).pop();
                                            final productImage =
                                                await ImagePicker().pickImage(
                                                    source:
                                                        ImageSource.gallery);
                                            if (productImage != null) {
                                              onImagePicked(productImage);
                                              image.didChange(true);
                                            }
                                          },
                                        ),
                                        ListTile(
                                          leading:
                                              const Icon(Icons.photo_camera),
                                          title: const Text('Camera'),
                                          onTap: () async {
                                            Navigator.of(context).pop();
                                            final productImage =
                                                await ImagePicker().pickImage(
                                                    source: ImageSource.camera);
                                            if (productImage != null) {
                                              onImagePicked(productImage);
                                              image.didChange(true);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: PrimaryColor,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(Icons.camera_alt_sharp,
                                  color: Colors.white, size: 25),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                if (image.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      image.errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            );
          },
        );
}
