import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'main.dart';

class ContactCreate extends StatefulWidget {
  const ContactCreate({super.key});

  @override
  State<ContactCreate> createState() => ContactCreateState();
}

class ContactCreateState extends State<ContactCreate> {
  TextEditingController name = TextEditingController();
  TextEditingController number = TextEditingController();
  File? file;
  ImagePicker image = ImagePicker();
  var url = '';
  DatabaseReference? dbRef;
  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('contacts/');
    print('====> insert | dbRef: ${dbRef.toString}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Contacts',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                  height: 200,
                  width: 200,
                  child: file == null
                      ? IconButton(
                          icon: const Icon(
                            Icons.add_a_photo,
                            size: 90,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            getImage();
                          },
                        )
                      : MaterialButton(
                          height: 100,
                          child: Image.file(
                            file!,
                            fit: BoxFit.fill,
                          ),
                          onPressed: () {
                            getImage();
                          },
                        )),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Name',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: number,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Number',
              ),
              maxLength: 10,
            ),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              height: 40,
              onPressed: () {
                if (file != null) {
                  uploadFile();
                } else {
                  getImage();
                }
              },
              color: Colors.blue,
              child: const Text(
                "Add",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getImage() async {
    var img = await image.pickImage(source: ImageSource.gallery);
    setState(() {
      file = File(img!.path);
    });

    print('====> insert | file: $file');
  }

  uploadFile() async {
    try {
      var imageFile = FirebaseStorage.instance
          .ref()
          .child("contact_photo")
          .child("/${name.text}.jpg");
      UploadTask task = imageFile.putFile(file!);
      TaskSnapshot snapshot = await task;
      url = await snapshot.ref.getDownloadURL();
      setState(() {
        url = url;
        print('====> insert | url: $url');
      });
      Map<String, String> Contact = {
        'name': name.text,
        'number': number.text,
        'url': url,
      };
      print('====> insert | Contact: $Contact');

      dbRef!.push().set(Contact).whenComplete(() {
        print('====> insert | dbRef: $dbRef');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Home(),
          ),
        );
      });
    } on Exception catch (e) {
      print('====> insert | error: $e');
    }
  }
}
