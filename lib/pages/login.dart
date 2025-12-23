import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itbs__express/admin/admin_login.dart';
import 'package:itbs__express/pages/buttom_nav.dart';
import 'package:itbs__express/pages/forget_password.dart';
import 'package:itbs__express/pages/signUp.dart';
import 'package:itbs__express/widgets/widget_support.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "";
  String password = "";
  final _formkey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void userLogin() async {
    if (password != null) {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ButtomNav()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Aucun utilisateur trouvé pour cet e-mail",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        } else if (e.code == "wrong-password") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Mot de passe incorrect",
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
      resizeToAvoidBottomInset: true, // utile si clavier ouvert
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
                colors: [
                  Colors.red,
                  Colors.red,
                ],
              ),
            ),
          ),

          // PARTIE BLANCHE
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            height: MediaQuery.of(context).size.height / 2,
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

                const SizedBox(height: 50.0),

                // CARD LOGIN
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
                            "Connexion",
                            style: AppWidget.HeadlineTextFeildStyle(),
                          ),

                          const SizedBox(height: 30.0),

                          // EMAIL
                          TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir votre adresse e-mail ';
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
                                return 'Veuillez saisir votre mot de passe ';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Mot de passe',
                              hintStyle: AppWidget.SemiBoldTextFeildStyle(),
                              prefixIcon: const Icon(Icons.password_outlined),
                            ),
                          ),

                          const SizedBox(height: 10.0),

                          // MOT DE PASSE OUBLIÉ
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AdminLogin()));
                                  },
                                  child: Container(
                                      alignment: Alignment.topLeft,
                                      child: Icon(
                                        Icons.person,
                                        size: 15,
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ForgotPassword()));
                                  },
                                  child: Container(
                                    alignment: Alignment.topRight,
                                    child: Text(
                                      "Mot de passe oublié ?",
                                      style: AppWidget.TitleTextFeildStyle(),
                                    ),
                                  ),
                                ),
                              ]),

                          const SizedBox(height: 30.0),

                          // BOUTON CONNEXION
                          GestureDetector(
                            onTap: () {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = emailController.text;
                                  password = passwordController.text;
                                });
                              }
                              userLogin();
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
                                    "CONNEXION",
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

                // LIEN VERS INSCRIPTION
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    );
                  },
                  child: Text(
                    "Vous n’avez pas de compte ? S’inscrire",
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
