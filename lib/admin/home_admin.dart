import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itbs__express/admin/Admin_orders_page.dart';
import 'package:itbs__express/admin/add_product.dart';
import 'package:itbs__express/admin/admin_login.dart';
import 'package:itbs__express/widgets/widget_support.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  // --- ÉTATS DE FILTRE ET RECHERCHE ---
  String? selectedCategory; // null = tous les produits
  String searchQuery = ""; // Texte de recherche
  final TextEditingController searchController = TextEditingController();

  // Le StreamBuilder écoutera TOUJOURS la collection 'Products'
  final Stream<QuerySnapshot> allProductsStream =
      FirebaseFirestore.instance.collection('Products').snapshots();

  @override
  void initState() {
    super.initState();
    // Écouter les changements dans le TextField pour mettre à jour la recherche
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  // Fonction appelée lorsque l'utilisateur tape du texte
  void _onSearchChanged() {
    final newQuery = searchController.text.toLowerCase();
    if (searchQuery != newQuery) {
      setState(() {
        searchQuery = newQuery;
      });
    }
  }

  // Fonction pour mettre à jour l'état du filtre de catégorie
  void updateCategoryFilter(String category) {
    setState(() {
      // Si on clique sur la même catégorie, on la désactive (toggle), sinon on la sélectionne
      selectedCategory = selectedCategory == category ? null : category;
    });
  }

  // --- LOGIQUE DE FILTRAGE DES PRODUITS ---
  List<DocumentSnapshot> _filterProducts(List<DocumentSnapshot> docs) {
    return docs.where((doc) {
      if (!doc.exists) return false;
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data == null) return false;

      // 1. Filtrer par Catégorie
      bool categoryMatch = true;
      if (selectedCategory != null) {
        try {
          String docCategory = data['category'] as String;
          categoryMatch = (docCategory == selectedCategory);
        } catch (e) {
          categoryMatch = false;
        }
      }

      // 2. Filtrer par Texte de Recherche
      bool searchMatch = true;
      if (searchQuery.isNotEmpty) {
        try {
          String docName = data['name'] as String;
          // Recherche dans le nom du produit
          searchMatch = docName.toLowerCase().contains(searchQuery);
        } catch (e) {
          searchMatch = false;
        }
      }

      // Le produit doit correspondre à la catégorie ET au terme de recherche
      return categoryMatch && searchMatch;
    }).toList();
  }

  // Fonction pour supprimer un produit
  Future<void> _deleteProduct(String productId, String productName) async {
    // Demande de confirmation avant suppression
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: Text("Voulez-vous vraiment supprimer '$productName' ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('Products')
            .doc(productId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'$productName' a été supprimé"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la suppression: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fonction pour modifier un produit
  void _editProduct(DocumentSnapshot product) {
    TextEditingController nameController = TextEditingController(
      text: product['name'] ?? '',
    );
    TextEditingController priceController = TextEditingController(
      text: product['price']?.toString() ?? '',
    );
    TextEditingController descriptionController = TextEditingController(
      text: product['description'] ?? '',
    );

    // Récupérer la catégorie actuelle
    String currentCategory = product['category'] ?? 'Cafés';

    // Liste des catégories disponibles
    List<String> categories = ['Cafés', 'Plats', 'Sandwichs', 'Boissons'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier le produit"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nom du produit",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: "Prix (DT)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: currentCategory,
                decoration: const InputDecoration(
                  labelText: "Catégorie",
                  border: OutlineInputBorder(),
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  currentCategory = newValue!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('Products')
                      .doc(product.id)
                      .update({
                    'name': nameController.text,
                    'price': double.parse(priceController.text),
                    'description': descriptionController.text,
                    'category': currentCategory,
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Produit modifié avec succès"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erreur: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text(
              "Enregistrer",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET LISTE DE PRODUITS ---
  Widget _buildProductList() {
    return StreamBuilder<QuerySnapshot>(
      stream: allProductsStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text("Aucun produit disponible.",
                  style: AppWidget.LightTextFeildStyle()));
        }

        // Application du double filtre (Catégorie ET Recherche)
        List<DocumentSnapshot> filteredDocs =
            _filterProducts(snapshot.data!.docs);

        if (filteredDocs.isEmpty) {
          return Center(
              child: Text("Aucun article trouvé.",
                  style: AppWidget.LightTextFeildStyle()));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: filteredDocs.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _buildProductItem(context, filteredDocs[index]);
          },
        );
      },
    );
  }

  // --- ÉLÉMENT DE PRODUIT AVEC BOUTONS MODIFIER/SUPPRIMER ---
  Widget _buildProductItem(BuildContext context, DocumentSnapshot ds) {
    Map<String, dynamic>? data = ds.data() as Map<String, dynamic>?;
    if (data == null) return const SizedBox.shrink();

    String imageUrl = data['imageUrl'] ?? "https://via.placeholder.com/150";
    String name = data['name'] ?? 'Article Inconnu';
    String priceText = data['price']?.toString() ?? 'N/A';
    String description = data['description'] ?? '';
    String category = data['category'] ?? 'Non catégorisé';

    return Container(
      margin: const EdgeInsets.only(right: 20.0, bottom: 20.0, left: 20.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du produit
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 40),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 15.0),

              // Informations du produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppWidget.TitleTextFeildStyle(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),

                    Text(
                      "$priceText DT",
                      style: AppWidget.SemiBoldTextFeildStyle(),
                    ),

                    const SizedBox(height: 10.0),

                    // Boutons Modifier et Supprimer
                    Row(
                      children: [
                        // Bouton Modifier
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _editProduct(ds),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, size: 18, color: Colors.white),
                                SizedBox(width: 5),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Bouton Supprimer
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _deleteProduct(ds.id, name),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete,
                                    size: 18, color: Colors.white),
                                SizedBox(width: 5),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget des catégories (boutons de filtre)
  Widget _showCategoryItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // TOUS LES PRODUITS
        // COFFEE (Cafés)
        _buildCategoryItem(category: "Cafés", imagePath: 'images/coffee.png'),
        // PIZZA (Plats)
        _buildCategoryItem(category: "Plats", imagePath: 'images/pizza.png'),
        // BURGER (Sandwichs)
        _buildCategoryItem(
            category: "Sandwichs", imagePath: 'images/burger.png'),
        // COCKTAIL (Boissons)
        _buildCategoryItem(
            category: "Boissons", imagePath: 'images/cocktail.png'),
      ],
    );
  }

  // Widget helper pour simplifier la création des boutons de catégorie
  Widget _buildCategoryItem({
    required String? category,
    required String imagePath,
  }) {
    final isSelected = selectedCategory == category;
    final displayText = category ?? "Tous";

    return GestureDetector(
      onTap: () {
        updateCategoryFilter(category ?? "");
      },
      child: Column(
        children: [
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                imagePath,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.red : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER AVEC RECHERCHE ET BOUTON COMMANDES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Titre
                  Expanded(
                    child: Text(
                      "Gestion des Produits",
                      style: AppWidget.HeadlineTextFeildStyle(),
                    ),
                  ),

                  // Bouton Déconnexion
                  IconButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdminLogin()),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                    ),
                    tooltip: "Déconnexion",
                  ),

                  // Bouton pour les commandes
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminOrdersPage(),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shopping_cart_checkout,
                              color: Colors.white, size: 24),
                          SizedBox(width: 5),
                          Text(
                            "Commandes",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // BARRE DE RECHERCHE
              Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: Colors.black54,
                        size: 25,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: "Rechercher un produit...",
                            border: InputBorder.none,
                          ),
                          style: AppWidget.LightTextFeildStyle(),
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = "";
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20.0),

              _showCategoryItems(),

              const SizedBox(height: 25.0),

              // NOMBRE DE PRODUITS TROUVÉS
              StreamBuilder<QuerySnapshot>(
                stream: allProductsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final filteredCount =
                      _filterProducts(snapshot.data!.docs).length;
                  final totalCount = snapshot.data!.docs.length;

                  return Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                    child: Text(
                      "$filteredCount produit${filteredCount > 1 ? 's' : ''} trouvé${filteredCount > 1 ? 's' : ''} (sur $totalCount)",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),

              // LISTE DES PRODUITS
              _buildProductList(),

              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProduct()),
          );
        },
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Ajouter un produit",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Fonction pour afficher le dialog d'ajout de produit
  void _showAddProductDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    String selectedCategory = "Cafés";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un nouveau produit"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nom du produit *",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: "Prix (DT) *",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Catégorie *",
                  border: OutlineInputBorder(),
                ),
                items: ['Cafés', 'Plats', 'Sandwichs', 'Boissons']
                    .map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedCategory = newValue!;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "* Image: L'image sera ajoutée ultérieurement",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance.collection('Products').add({
                    'name': nameController.text,
                    'price': double.parse(priceController.text),
                    'description': descriptionController.text,
                    'category': selectedCategory,
                    'imageUrl': 'https://via.placeholder.com/150',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Produit ajouté avec succès"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erreur: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text(
              "Ajouter",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// Page des commandes (à créer dans un fichier séparé admin_orders.dart)
