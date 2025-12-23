import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:itbs__express/widgets/widget_support.dart';

class Details extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String price;

  const Details({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int a = 1;
  bool isAdding = false;

  // Fonction pour ajouter au panier
  Future<void> addToCart() async {
    // Vérifier si l'utilisateur est connecté
    auth.User? currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // L'utilisateur n'est pas connecté
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Veuillez vous connecter pour ajouter au panier',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      isAdding = true;
    });

    try {
      // Calcul du prix total
      double totalPrice = double.parse(widget.price) * a;

      // Référence au panier avec userId
      String userId = currentUser.uid;
      String userEmail = currentUser.email ?? 'unknown';

      // Vérifier si l'article existe déjà dans le panier
      QuerySnapshot existingItem = await FirebaseFirestore.instance
          .collection('Cart')
          .where('userId', isEqualTo: userId)
          .where('name', isEqualTo: widget.name)
          .get();

      if (existingItem.docs.isNotEmpty) {
        // Article existe déjà, mettre à jour la quantité
        DocumentSnapshot doc = existingItem.docs.first;
        int currentQuantity = doc.get('quantity') ?? 0;
        int newQuantity = currentQuantity + a;
        double newTotalPrice = double.parse(widget.price) * newQuantity;

        await FirebaseFirestore.instance.collection('Cart').doc(doc.id).update({
          'quantity': newQuantity,
          'totalPrice': newTotalPrice,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Nouvel article, l'ajouter au panier
        await FirebaseFirestore.instance.collection('Cart').add({
          'userId': userId,
          'userEmail': userEmail,
          'name': widget.name,
          'imageUrl': widget.imageUrl,
          'price': widget.price,
          'quantity': a,
          'totalPrice': totalPrice,
          'description': widget.description,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$a × ${widget.name} ajouté(s) au panier !',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Optionnel: Retourner à la page précédente après 1 seconde
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      // Gérer les erreurs
      print('Erreur lors de l\'ajout au panier: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Erreur lors de l\'ajout au panier: ${e.toString()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = double.parse(widget.price) * a;

    return Scaffold(
      primary: false,
      body: Container(
        margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 Retour
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
                height: 30.0,
              ),
              // 🖼️ IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.imageUrl,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 2.5,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 2.5,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 80),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 2.5,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              // 📝 NOM + QUANTITÉ
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Délicieux",
                            style: AppWidget.LightTextFeildStyle()),
                        Text(widget.name,
                            style: AppWidget.boldTextFeildStyle(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // –
                  GestureDetector(
                    onTap: () {
                      if (a > 1) setState(() => a--);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: a > 1 ? Colors.black : Colors.grey[400],
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.remove,
                          color: Colors.white, size: 20),
                    ),
                  ),

                  const SizedBox(width: 15),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(a.toString(),
                        style: AppWidget.SemiBoldTextFeildStyle()),
                  ),
                  const SizedBox(width: 15),

                  // +
                  GestureDetector(
                    onTap: () => setState(() => a++),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8)),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 📄 DESCRIPTION
              Text(
                widget.description,
                style: AppWidget.Light1TextFeildStyle(),
                maxLines: 4,
              ),

              const SizedBox(height: 30),

              // ⏱️ TEMPS
              Row(
                children: [
                  Text("Temps de préparation",
                      style: AppWidget.Light1TextFeildStyle()),
                  const SizedBox(width: 25),
                  const Icon(Icons.alarm, color: Colors.black87),
                  const SizedBox(width: 5),
                  Text("20 min", style: AppWidget.Light1TextFeildStyle()),
                ],
              ),
            ],
          ),
        ),
      ),

      // 🛒 BAS DE PAGE
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "${totalPrice.toStringAsFixed(2)} DT",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),

            // 🛒 BOUTON
            GestureDetector(
              onTap: isAdding ? null : addToCart,
              child: Container(
                decoration: BoxDecoration(
                    color: isAdding ? Colors.grey[400] : Colors.black,
                    borderRadius: BorderRadius.circular(15)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    if (isAdding)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      const Text("AJOUTER AU PANIER ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w200)),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
