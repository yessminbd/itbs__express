import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // Import pour Cloudinary

// Assurez-vous que cette classe existe et est correctement définie dans widget_support.dart
// import 'package:itbs__express/widgets/widget_support.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final List<String> items = ['Boissons', 'Cafés', 'Sandwichs', 'Plats'];
  String? selectedValue;

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  String?
      _imageUrl; // Variable pour stocker l'URL Cloudinary obtenue (principalement pour setState)

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  // --- FONCTION D'UPLOAD VERS CLOUDINARY ---
  Future<String?> _uploadImageToCloudinary() async {
    if (selectedImage == null) return null;

    // Constantes Cloudinary
    const String CLOUDINARY_URL =
        'https://api.cloudinary.com/v1_1/de8nt6hm5/upload';
    const String UPLOAD_PRESET = 'itbs-express';
    try {
      final url = Uri.parse(CLOUDINARY_URL);

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = UPLOAD_PRESET
        ..files.add(
            await http.MultipartFile.fromPath('file', selectedImage!.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        final String uploadedUrl = jsonMap['url'];

        setState(() {
          _imageUrl = uploadedUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Image uploadée avec succès!"),
          ),
        );
        return uploadedUrl;
      } else {
        print("Erreur d'upload Cloudinary: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
                "Erreur lors de l'upload de l'image. Code: ${response.statusCode}"),
          ),
        );
        return null;
      }
    } catch (e) {
      print("Erreur lors de la requête Cloudinary: $e");
      return null;
    }
  }

  Future<void> uploadProduct() async {
    // Vérification des champs
    if (selectedImage == null ||
        nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
              "Veuillez remplir tous les champs et sélectionner une image."),
        ),
      );
      return;
    }

    final String? productImageUrl = await _uploadImageToCloudinary();

    if (productImageUrl != null) {
      Map<String, dynamic> productInfoMap = {
        'name': nameController.text,
        // Conversion du prix en Double. tryParse gère les erreurs de format.
        'price': double.tryParse(priceController.text) ?? 0.0,
        'description': descriptionController.text,
        'category': selectedValue,
        'imageUrl': productImageUrl, // L'URL Cloudinary en string
      };

      try {
        await FirebaseFirestore.instance
            .collection('Products')
            .add(productInfoMap);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Produit enregistré avec succès dans Firestore!"),
          ),
        );

        setState(() {
          selectedImage = null;
          nameController.clear();
          priceController.clear();
          descriptionController.clear();
          selectedValue = null;
          _imageUrl = null;
        });
      } catch (e) {
        print("Erreur d'enregistrement Firestore: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
                "Échec de l'enregistrement des données du produit dans Firestore."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle =
        const TextStyle(fontFamily: 'Poppins', fontSize: 18.0);
    TextStyle hintStyle = const TextStyle(
        fontFamily: 'Poppins', fontSize: 16.0, color: Colors.grey);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin:
              EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Color(0xFF373866),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                "Importer l’image du produit",
                style: defaultStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.0),

              /// IMAGE
              selectedImage == null
                  ? GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: Center(
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.black,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )),
                      ),
                    ),

              SizedBox(height: 30.0),

              /// NOM DU PRODUIT
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: nameController,
                  style: defaultStyle,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Entrer le nom du produit",
                    hintStyle: hintStyle,
                  ),
                ),
              ),

              SizedBox(height: 10.0),

              /// PRIX
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: defaultStyle,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Entrer le prix",
                    hintStyle: hintStyle,
                  ),
                ),
              ),

              SizedBox(height: 10.0),

              /// DESCRIPTION
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  style: defaultStyle,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Entrer la description",
                    hintStyle: hintStyle,
                  ),
                ),
              ),

              SizedBox(height: 20.0),

              /// DROPDOWN CATÉGORIE
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedValue,
                    items: items
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: defaultStyle,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                    },
                    dropdownColor: Colors.white,
                    hint: Text('Sélectionner la catégorie', style: hintStyle),
                    iconSize: 36,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              /// BOUTON AJOUTER (CORRIGÉ AVEC GESTUREDETECTOR)
              Center(
                child: GestureDetector(
                  onTap: () {
                    uploadProduct(); // Appel de la fonction pour uploader et enregistrer
                  },
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Ajouter",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
