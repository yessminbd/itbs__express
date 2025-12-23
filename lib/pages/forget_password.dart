import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String email = "";

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Email de réinitialisation envoyé à ${emailController.text}'),
          backgroundColor: Colors.red,
        ),
      );
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40.0),

                  // Titre
                  const Text(
                    "Mot de passe oublié?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12.0),

                  // Sous-titre
                  const Text(
                    "Pas de soucis, nous vous enverrons\nles instructions de réinitialisation",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                    ),
                  ),

                  const SizedBox(height: 40.0),

                  // Image centrale - password.png
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'images/password.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.lock_reset,
                              size: 100,
                              color: Colors.red[700],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 40.0),

                  // Champ Email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                        child: Text(
                          "Adresse email",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre adresse email';
                            }
                            if (!value.contains('@')) {
                              return 'Veuillez saisir une adresse email valide';
                            }
                            return null;
                          },
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                          decoration: InputDecoration(
                            hintText: "exemple@email.com",
                            hintStyle: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[400],
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.grey[600],
                              size: 24.0,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30.0),

                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          email = emailController.text;
                        });
                        passwordReset();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Envoyer l'email",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // Retour à la connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Retour à la connexion",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
