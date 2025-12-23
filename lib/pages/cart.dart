import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:itbs__express/pages/profile.dart';
import 'package:itbs__express/widgets/widget_support.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final Color primaryColor = Colors.red;
  final String? currentUserId = auth.FirebaseAuth.instance.currentUser?.uid;

  double calculateTotal(List<DocumentSnapshot> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      try {
        // Le prix total est stocké en String dans Firestore, on le parse en double
        total += double.parse(item['totalPrice'].toString());
      } catch (e) {
        print('Erreur calcul total: $e');
      }
    }
    return total;
  }

  Future<void> removeItemFromCart(String docId) async {
    await FirebaseFirestore.instance.collection('Cart').doc(docId).delete();
  }

  Future<void> increaseQuantity(DocumentSnapshot item) async {
    int currentQuantity = item['quantity'];
    // Assurez-vous que le prix est correctement parsé
    double price = double.parse(item['price'].toString());

    int newQuantity = currentQuantity + 1;
    double newTotal = newQuantity * price;

    await FirebaseFirestore.instance.collection('Cart').doc(item.id).update({
      'quantity': newQuantity,
      // On le sauvegarde en String avec 2 décimales pour l'uniformité
      'totalPrice': newTotal.toStringAsFixed(2),
    });
  }

  Future<void> decreaseQuantity(DocumentSnapshot item) async {
    int currentQuantity = item['quantity'];
    double price = double.parse(item['price'].toString());

    if (currentQuantity > 1) {
      int newQuantity = currentQuantity - 1;
      double newTotal = newQuantity * price;

      await FirebaseFirestore.instance.collection('Cart').doc(item.id).update({
        'quantity': newQuantity,
        'totalPrice': newTotal.toStringAsFixed(2),
      });
    } else {
      await FirebaseFirestore.instance.collection('Cart').doc(item.id).delete();
    }
  }

  // 🆕 FONCTION POUR PLACER LA COMMANDE
  Future<void> placeOrder(
      List<DocumentSnapshot> cartItems, double totalAmount) async {
    if (currentUserId == null || cartItems.isEmpty) return;

    // 1. Préparer les données des produits
    List<Map<String, dynamic>> products = cartItems.map((item) {
      return {
        'productId': item.id, // L'ID du document Cart
        'name': item['name'],
        'quantity': item['quantity'],
        'unitPrice': double.parse(item['price'].toString()),
        'totalPriceItem': double.parse(item['totalPrice'].toString()),
        'imageUrl': item['imageUrl'],
      };
    }).toList();

    // 2. Créer l'objet Commande
    Map<String, dynamic> orderData = {
      'userId': currentUserId,
      'products': products,
      'totalAmount': totalAmount.toStringAsFixed(2),
      'status': 'En attente', // 🌟 État par défaut pour l'administrateur
      'orderDate': FieldValue.serverTimestamp(), // Date d'enregistrement
    };

    // 3. Enregistrer dans la collection 'Orders'
    try {
      await FirebaseFirestore.instance.collection('Orders').add(orderData);

      // 4. Vider le panier après la commande
      // On supprime tous les documents du panier de cet utilisateur
      for (var item in cartItems) {
        await FirebaseFirestore.instance
            .collection('Cart')
            .doc(item.id)
            .delete();
      }

      // 5. Confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Commande validée"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Assurez-vous que le nom de votre page est bien 'UserOrders'
          builder: (context) => const Profile(),
        ),
      );
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la commande: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text("Veuillez vous connecter")),
      );
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Cart')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data!.docs;

          // Remplacer la section 'if (cartItems.isEmpty)' par ce code :
          if (cartItems.isEmpty) {
            return Stack(
              children: [
                // 1. Bouton de retour (en haut à gauche)
                Positioned(
                  top: 20, // Ajustez selon votre AppBar ou Scaffold
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // 2. Contenu central (Image et Texte)
                Center(
                  child: Column(
                    // Centre les éléments verticalement (MainAxisAlignment.center)
                    mainAxisAlignment: MainAxisAlignment.center,
                    // Centre les éléments horizontalement (CrossAxisAlignment.center)
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/cart.png', // <<< VÉRIFIEZ CE CHEMIN D'IMAGE
                        height: 200,
                        width: 200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Votre panier est vide",
                        style: AppWidget.Light1TextFeildStyle(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          double finalTotal = calculateTotal(cartItems);

          // ➡️ AFFICHAGE DES ARTICLES ET DU TOTAL
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Row(
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
                    SizedBox(
                      width: 65,
                    ),
                    Center(
                        child: Text(
                      "Mon panier",
                      style: AppWidget.SemiBoldTextFeildStyle(),
                    ))
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];

                    final String name = item['name'];
                    final String imageUrl = item['imageUrl'];
                    final int quantity = item['quantity'];
                    // Prix unitaire (utilisé pour l'affichage)
                    final double price = double.parse(item['price'].toString());

                    return Container(
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors
                            .white, // Ajout d'une couleur de fond pour la visibilité
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          // IMAGE DU PRODUIT
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 15),
                          // NOM ET PRIX UNITAIRE
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(name,
                                    style: AppWidget.SemiBoldTextFeildStyle()),
                                // Affiche le prix unitaire
                                Text("${price.toStringAsFixed(2)} DT",
                                    style: AppWidget.Light1TextFeildStyle()),
                              ],
                            ),
                          ),
                          // CONTRÔLE DE QUANTITÉ
                          Row(
                            children: [
                              // Bouton MOINS (-)
                              GestureDetector(
                                onTap: () => decreaseQuantity(item),
                                child: Container(
                                  height: 25, // Taille ajustée
                                  width: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              // QUANTITÉ
                              Text(
                                "$quantity",
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 12),
                              // Bouton PLUS (+)
                              GestureDetector(
                                onTap: () => increaseQuantity(item),
                                child: Container(
                                  height: 25, // Taille ajustée
                                  width: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // ➡️ FOOTER (Total et bouton Commander)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total à Payer",
                          style: AppWidget.SemiBoldTextFeildStyle(),
                        ),
                        Text(
                          "${finalTotal.toStringAsFixed(2)} DT",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // BOUTON COMMANDER
                    GestureDetector(
                      onTap: () {
                        // Appel de la fonction pour enregistrer la commande et vider le panier
                        placeOrder(cartItems, finalTotal);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          "COMMANDER",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
