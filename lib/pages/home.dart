import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itbs__express/pages/cart.dart';
import 'package:itbs__express/pages/details.dart';
import 'package:itbs__express/widgets/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? selectedCategory;
  String searchQuery = ""; 

  final Stream<QuerySnapshot> allProductsStream =
      FirebaseFirestore.instance.collection('Products').snapshots();

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final newQuery = searchController.text.toLowerCase();
    if (searchQuery != newQuery) {
      setState(() {
        searchQuery = newQuery;
      });
    }
  }

  void updateCategoryFilter(String category) {
    setState(() {
      selectedCategory = selectedCategory == category ? null : category;
    });
  }

  List<DocumentSnapshot> _filterProducts(List<DocumentSnapshot> docs) {
    return docs.where((doc) {
      if (!doc.exists) return false;
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data == null) return false;

      bool categoryMatch = true;
      if (selectedCategory != null) {
        try {
          String docCategory = data['category'] as String;
          categoryMatch = (docCategory == selectedCategory);
        } catch (e) {
          categoryMatch = false; 
        }
      }

      bool searchMatch = true;
      if (searchQuery.isNotEmpty) {
        try {
          String docName = data['name'] as String;
          searchMatch = docName.toLowerCase().contains(searchQuery);
        } catch (e) {
          searchMatch = false; 
        }
      }

      return categoryMatch && searchMatch;
    }).toList();
  }

  Widget _buildProductList({
    required Axis scrollDirection,
    required ScrollPhysics physics,
    required double listHeight, 
    required Widget Function(BuildContext, DocumentSnapshot) itemBuilder,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: allProductsStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: SizedBox(
                  height: listHeight,
                  child: const CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text("La collection 'Products' est vide.",
                  style: AppWidget.LightTextFeildStyle()));
        }

        List<DocumentSnapshot> filteredDocs =
            _filterProducts(snapshot.data!.docs);

        if (filteredDocs.isEmpty) {
          return Center(
              child: Text("Aucun article trouvé .",
                  style: AppWidget.LightTextFeildStyle()));
        }

        return SizedBox(
          height: scrollDirection == Axis.horizontal ? listHeight : null,
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: filteredDocs.length,
              shrinkWrap: true,
              scrollDirection: scrollDirection,
              physics: physics,
              itemBuilder: (context, index) {
                return itemBuilder(context, filteredDocs[index]);
              }),
        );
      },
    );
  }


  Widget _buildHorizontalItem(BuildContext context, DocumentSnapshot ds) {
    Map<String, dynamic>? data = ds.data() as Map<String, dynamic>?;
    if (data == null) return const SizedBox.shrink();

    String imageUrl = data['imageUrl'] ?? "https://via.placeholder.com/150";
    String name = data['name'] ?? 'Article Inconnu';
    String priceText = data['price']?.toString() ?? 'N/A';
    String description = data['description'] ?? 'Fraîche et gourmande';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Details(
              imageUrl: imageUrl,
              name: name,
              description: description,
              price: priceText,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(20),
          child: Container(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        imageUrl,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 150,
                            height: 150,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, size: 50),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            width: 150,
                            height: 150,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(name, style: AppWidget.TitleTextFeildStyle()),
                    const SizedBox(height: 5.0),
                    Text(
                      "Fraîche et gourmande",
                      style: AppWidget.LightTextFeildStyle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      "$priceText DT",
                      style: AppWidget.SemiBoldTextFeildStyle(),
                    ),
                  ])),
        ),
      ),
    );
  }

  Widget _buildVerticalItem(BuildContext context, DocumentSnapshot ds) {
    Map<String, dynamic>? data = ds.data() as Map<String, dynamic>?;
    if (data == null) return const SizedBox.shrink();

    String imageUrl = data['imageUrl'] ?? "https://via.placeholder.com/150";
    String name = data['name'] ?? 'Article Inconnu';
    String priceText = data['price']?.toString() ?? 'N/A';
    String description = data['description'] ?? 'Fraîche et gourmande';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Details(
              imageUrl: imageUrl,
              name: name,
              description: description,
              price: priceText,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 20.0, bottom: 20.0),
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(20),
          child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, size: 40),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 120,
                          height: 120,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10.0),
                        Text(
                          name,
                          style: AppWidget.TitleTextFeildStyle(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "Fraîche et gourmande",
                          style: AppWidget.LightTextFeildStyle(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "$priceText DT",
                          style: AppWidget.SemiBoldTextFeildStyle(),
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  Widget _showCategoryItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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

  Widget _buildCategoryItem({
    required String category,
    required String imagePath,
  }) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () {
        updateCategoryFilter(category);
      },
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
              color: isSelected ? Colors.red : Colors.white,
              borderRadius: BorderRadius.circular(10)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 50.0, left: 20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Champ de recherche
                  Expanded(
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.only(right: 20.0, left: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13.0,
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: "Chercher ...",
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.black54,
                              size: 25,
                            ),
                            border: InputBorder.none,
                          ),
                          style: AppWidget.LightTextFeildStyle(),
                        ),
                      ),
                    ),
                  ),

                  // Bouton Panier
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Cart()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 20.0),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20.0),
              Text("Repas délicieux,",
                  style: AppWidget.HeadlineTextFeildStyle()),
              Text("Découvrez et commandez vos encas préférés !",
                  style: AppWidget.LightTextFeildStyle()),
              const SizedBox(height: 20.0),

              // CATÉGORIES
              Container(
                  margin: const EdgeInsets.only(right: 20.0),
                  child: _showCategoryItems()),
              const SizedBox(height: 30.0),

              // LISTE HORIZONTALE
              _buildProductList(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                listHeight: 270, // Hauteur fixe pour le défilement horizontal
                itemBuilder: _buildHorizontalItem,
              ),

              const SizedBox(height: 30.0),

              // LISTE VERTICALE
              _buildProductList(
                scrollDirection: Axis.vertical,
                physics:
                    const NeverScrollableScrollPhysics(), // Désactivé car le parent est un SingleChildScrollView
                listHeight: 0, // Inutile ici
                itemBuilder: _buildVerticalItem,
              ),

              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
