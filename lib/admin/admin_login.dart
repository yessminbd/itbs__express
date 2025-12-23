import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itbs__express/admin/home_admin.dart';
import 'package:itbs__express/pages/login.dart';
import 'package:itbs__express/widgets/widget_support.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  String username = "";
  String password = "";
  final _formKey = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  LoginAdmin() async {
    String enteredUsername = userNameController.text.trim();
    String enteredPassword = passwordController.text.trim();

    if (enteredUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez saisir le nom d’utilisateur")),
      );
      return;
    }

    if (enteredPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez saisir le mot de passe")),
      );
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('id', isEqualTo: enteredUsername)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Nom d’utilisateur incorrect"),
          ),
        );
        return;
      }

      var adminData = snapshot.docs.first.data() as Map<String, dynamic>;

      if (adminData['password'] != enteredPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Mot de passe incorrect"),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeAdmin()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Erreur de connexion"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFededeb),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width,
              height: size.height * 0.6, // couvre le bas 60% de l'écran
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 53, 51, 51), Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(size.width, 110.0),
                ),
              ),
            ),
          ),
          // Formulaire admin
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      "images/logo1.png",
                      width: MediaQuery.of(context).size.width / 1.5,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2.2,
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 30),

                            // Champ Nom d'utilisateur
                            Container(
                              padding: EdgeInsets.only(
                                  left: 20.0, top: 5.0, bottom: 5.0),
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          Color.fromARGB(255, 160, 160, 147)),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: TextFormField(
                                  controller: userNameController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Nom d’utilisateur",
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20),

                            // Champ Mot de passe
                            Container(
                              padding: EdgeInsets.only(
                                  left: 20.0, top: 5.0, bottom: 5.0),
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          Color.fromARGB(255, 160, 160, 147)),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      hintText: "Mot de passe",
                                      prefixIcon: Icon(Icons.lock),
                                      border: InputBorder.none),
                                ),
                              ),
                            ),

                            // Icône alignée avec les champs
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LogIn()));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_2,
                                        size: 18,
                                        color: Colors.grey[700],
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Connexion utilisateur",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 30),

                            // Bouton Se connecter
                            GestureDetector(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    username = userNameController.text;
                                    password = passwordController.text;
                                  });
                                  LoginAdmin();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 20.0, top: 5.0, bottom: 5.0),
                                margin: EdgeInsets.symmetric(horizontal: 20.0),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text("Se connecter",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.normal)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
