import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Need to modify PLIST file for IOS

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});
  final void Function(File image) onPickImage;
  @override
  State<ImageInput> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;
  void _takePictureCamera() async {
    final imagePicker = ImagePicker();
    final XFile? pickedImage =
        await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
    widget.onPickImage(
        _selectedImage!); // Since it is defined in the widget class
  }

  void _takePictureGallery() async {
    final imagePicker = ImagePicker();
    final XFile? pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
    widget.onPickImage(
        _selectedImage!); // Since it is defined in the widget class
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.camera_alt_sharp),
            label: const Text('Take Picture'),
            onPressed: _takePictureCamera,
          ),
        ),
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Icons.photo),
            label: const Text('Pick Picture from Gallery'),
            onPressed: _takePictureGallery,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
    if (_selectedImage != null) {
      content = GestureDetector(
        onLongPress: () {
          setState(() {
            _selectedImage = null;
          });
        },
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.fill,
          height: double.infinity,
          width: double.infinity,
        ),
      );
    }
    return Container(
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        // border: Border.all(width: 1.5),
        color:
            Theme.of(context).colorScheme.copyWith().primary.withOpacity(0.1),
      ),
      child: content,
    );
  }
}
