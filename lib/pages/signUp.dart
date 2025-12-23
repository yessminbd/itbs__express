import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itbs__express/pages/buttom_nav.dart';
import 'package:itbs__express/pages/login.dart';
import 'package:itbs__express/widgets/widget_support.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "";
  String password = "";
  String name = "";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  void userSignUp() async {
    if (password != null) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Inscription réussie",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ButtomNav()));
      } on FirebaseException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Le mot de passe est trop faible",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Un compte existe déjà avec cet e-mail",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // HEADER ORANGE
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red, Colors.red],
              ),
            ),
          ),

          // PARTIE BLANCHE
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          ),

          // CONTENU PRINCIPAL SCROLLABLE
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
            child: Column(
              children: [
                // LOGO
                Center(
                  child: Image.asset(
                    "images/logo.png",
                    width: MediaQuery.of(context).size.width / 1.5,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 40.0),

                // CARD INSCRIPTION
                Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          Text(
                            "Inscription",
                            style: AppWidget.HeadlineTextFeildStyle(),
                          ),

                          const SizedBox(height: 30.0),

                          // NOM
                          TextFormField(
                            controller: nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir le nom';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Nom',
                              hintStyle: AppWidget.SemiBoldTextFeildStyle(),
                              prefixIcon: const Icon(Icons.person_outlined),
                            ),
                          ),

                          const SizedBox(height: 20.0),

                          // EMAIL
                          TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir votre adresse e-mail';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: AppWidget.SemiBoldTextFeildStyle(),
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                          ),

                          const SizedBox(height: 20.0),

                          // MOT DE PASSE
                          TextFormField(
                            obscureText: true,
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir un mot de passel';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Mot de passe',
                              hintStyle: AppWidget.SemiBoldTextFeildStyle(),
                              prefixIcon: const Icon(Icons.password_outlined),
                            ),
                          ),

                          const SizedBox(height: 30.0),

                          // BOUTON INSCRIPTION
                          GestureDetector(
                            onTap: () async {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = emailController.text;
                                  name = nameController.text;
                                  password = passwordController.text;
                                });
                              }
                              userSignUp();
                            },
                            child: Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                width: 200,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: Text(
                                    "S’INSCRIRE",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontFamily: 'Poppins1',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30.0),

                // LIEN VERS LOGIN
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LogIn()),
                    );
                  },
                  child: Text(
                    "Vous avez déjà un compte ? Connexion",
                    style: AppWidget.TitleTextFeildStyle(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
