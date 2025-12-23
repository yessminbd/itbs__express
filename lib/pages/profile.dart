import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itbs__express/pages/login.dart';
import 'package:itbs__express/widgets/widget_support.dart';



class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final Color primaryColor = Colors.red;

  // Fonction de déconnexion
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LogIn()),
      );
    } catch (e) {
      print('Erreur de déconnexion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
            child: Text(
          "Veuillez vous connecter pour voir votre profil.",
          style: TextStyle(fontSize: 16),
        )),
      );
    }

    final String email = currentUser!.email ?? "Email non disponible";
    final String username = currentUser!.displayName ?? email.split('@')[0];


    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      )),
                ),
                IconButton(
                  onPressed:
                      _signOut, 
                  icon: const Icon(Icons.logout, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 20),

            
            const ListTile(
              leading: Icon(Icons.history, color: Colors.black),
              title: Text(
                  "Historique des Commandes", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Orders')
                  .where('userId', isEqualTo: currentUser!.uid)
                  .orderBy('orderDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Erreur de chargement: L'index Firestore est requis. Veuillez le créer et attendre l'activation.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.red[700], fontStyle: FontStyle.italic),
                    ),
                  ));
                }

                final orders = snapshot.data?.docs ?? [];
                if (orders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text("Vous n'avez pas encore passé de commande.",
                        style: TextStyle(fontStyle: FontStyle.italic)),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final orderData =
                        orders[index].data() as Map<String, dynamic>;

                    final int orderNumber = index + 1; 

                    final List products = orderData['products'] as List? ?? [];
                    final String status =
                        orderData['status'] ?? 'Statut inconnu';
                    final String total =
                        orderData['totalAmount']?.toString() ?? '0.00';
                    final orderDate = orderData['orderDate'] is Timestamp
                        ? orderData['orderDate'] as Timestamp
                        : Timestamp.now();

                    final dateString =
                        "${orderDate.toDate().day.toString().padLeft(2, '0')}/"
                        "${orderDate.toDate().month.toString().padLeft(2, '0')}/"
                        "${orderDate.toDate().year}";

                    Color statusColor = Colors.grey;
                    if (status.contains('Livré')) statusColor = Colors.green;
                    if (status.contains('En attente'))
                      statusColor = Colors.orange;
                    if (status.contains('En préparation'))
                      statusColor = Colors.blue;

                    return Theme(
                      data: Theme.of(context).copyWith(
                        highlightColor:
                            Colors.transparent, 
                        splashColor:
                            Colors.transparent, 
                        dividerColor: Colors
                            .transparent, 
                      ),
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: Icon(Icons.shopping_cart, color: Colors.red),
                          title: Text("Commande n°$orderNumber du $dateString",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total: $total DT",
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold)),
                              Text(status,
                                  style: TextStyle(color: statusColor)),
                            ],
                          ),
                          children: products.map((item) {
                            final product = item as Map<String, dynamic>;
                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.only(left: 30, right: 16),
                              title: Text(
                                product['name'] ?? 'Article',
                                style: AppWidget.Light1TextFeildStyle(),
                              ),
                              subtitle: Text(
                                "Quantité : ${product['quantity'] ?? 1}",
                                style: AppWidget.Light1TextFeildStyle(),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
