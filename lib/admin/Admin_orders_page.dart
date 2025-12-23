import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final Stream<QuerySnapshot> ordersStream = FirebaseFirestore.instance
      .collection('Orders')
      .orderBy('orderDate', descending: true)
      .snapshots();

  // Variables pour les filtres
  DateTime? selectedDate;
  String? selectedStatus;

  // Liste des statuts disponibles
  final List<String> statusList = [
    'Tous',
    'En attente',
    'En préparation',
    'Livrée'
  ];

  // Fonction pour formater la date
  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Date inconnue';

    try {
      if (timestamp is Timestamp) {
        DateTime date = timestamp.toDate();
        return DateFormat('dd/MM/yyyy HH:mm').format(date);
      } else if (timestamp is String) {
        return timestamp;
      }
      return 'Date inconnue';
    } catch (e) {
      return 'Date inconnue';
    }
  }

  // Fonction pour obtenir la date seulement (sans l'heure)
  String getDateOnly(dynamic timestamp) {
    if (timestamp == null) return 'Date inconnue';

    try {
      if (timestamp is Timestamp) {
        DateTime date = timestamp.toDate();
        return DateFormat('dd/MM/yyyy').format(date);
      }
      return 'Date inconnue';
    } catch (e) {
      return 'Date inconnue';
    }
  }

  // Fonction pour formater DateTime en String pour comparaison
  String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Fonction pour changer l'état d'une commande
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('Orders')
          .doc(orderId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Statut mis à jour: $newStatus"),
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

  // Fonction pour obtenir la couleur selon le statut
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en attente':
        return Colors.orange;
      case 'en préparation':
        return Colors.blue;
      case 'livrée':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Fonction pour afficher le sélecteur de date - CORRIGÉE
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            hintColor: Colors.blue,
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Fonction pour effacer le filtre de date
  void _clearDateFilter() {
    setState(() {
      selectedDate = null;
    });
  }

  // Fonction pour effacer le filtre de statut
  void _clearStatusFilter() {
    setState(() {
      selectedStatus = null;
    });
  }

  // Fonction pour filtrer les commandes
  List<DocumentSnapshot> _filterOrders(List<DocumentSnapshot> allOrders) {
    return allOrders.where((order) {
      var data = order.data() as Map<String, dynamic>;

      // Filtrer par date
      bool dateMatch = true;
      if (selectedDate != null) {
        String orderDateStr = getDateOnly(data['orderDate']);
        String selectedDateStr = formatDateTime(selectedDate!);
        dateMatch = orderDateStr == selectedDateStr;
      }

      // Filtrer par statut
      bool statusMatch = true;
      if (selectedStatus != null && selectedStatus != 'Tous') {
        String orderStatus = data['status'] ?? 'En attente';
        statusMatch = orderStatus == selectedStatus;
      }

      return dateMatch && statusMatch;
    }).toList();
  }

  // Fonction pour compter les commandes par statut
  Map<String, int> _countOrdersByStatus(List<DocumentSnapshot> orders) {
    Map<String, int> counts = {
      'En attente': 0,
      'En préparation': 0,
      'Livrée': 0,
      'Total': 0,
    };

    for (var order in orders) {
      var data = order.data() as Map<String, dynamic>;
      String status = data['status'] ?? 'En attente';
      counts['Total'] = (counts['Total'] ?? 0) + 1;

      if (counts.containsKey(status)) {
        counts[status] = (counts[status] ?? 0) + 1;
      }
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Section des filtres
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Filtrer par statut:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: statusList.map((status) {
                          bool isSelected = selectedStatus == status;
                          return FilterChip(
                            label: Text(
                              status,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.blue,
                            checkmarkColor: Colors.white,
                            onSelected: (selected) {
                              setState(() {
                                selectedStatus = selected ? status : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (selectedStatus != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _clearStatusFilter,
                            child: const Text(
                              "Effacer le filtre",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Statistiques
                StreamBuilder<QuerySnapshot>(
                  stream: ordersStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    Map<String, int> counts =
                        _countOrdersByStatus(snapshot.data!.docs);

                    return Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            count: counts['En attente'] ?? 0,
                            label: "En attente",
                            color: Colors.orange,
                          ),
                          _buildStatItem(
                            count: counts['En préparation'] ?? 0,
                            label: "En préparation",
                            color: Colors.blue,
                          ),
                          _buildStatItem(
                            count: counts['Livrée'] ?? 0,
                            label: "Livrée",
                            color: Colors.green,
                          ),
                          _buildStatItem(
                            count: counts['Total'] ?? 0,
                            label: "Total",
                            color: Colors.blue,
                            isTotal: true,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Liste des commandes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ordersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Aucune commande pour le moment",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                List<DocumentSnapshot> allOrders = snapshot.data!.docs;
                List<DocumentSnapshot> filteredOrders =
                    _filterOrders(allOrders);

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.filter_list_off,
                            size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          selectedDate != null || selectedStatus != null
                              ? "Aucune commande trouvée avec les filtres actuels"
                              : "Aucune commande pour le moment",
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        if (selectedDate != null || selectedStatus != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedDate = null;
                                selectedStatus = null;
                              });
                            },
                            child: const Text(
                              "Effacer tous les filtres",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    var order = filteredOrders[index];
                    var data = order.data() as Map<String, dynamic>;
                    String orderDate = getDateOnly(data['orderDate']);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          "Commande #${order.id.substring(0, 8).toUpperCase()}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(
                                        data['status'] ?? 'En attente'),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    data['status'] ?? 'En attente',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  orderDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Produits commandés
                                const Text(
                                  "Produits commandés:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                if (data['products'] != null &&
                                    data['products'] is List)
                                  ...(data['products'] as List)
                                      .map<Widget>((product) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              product['imageUrl'] ?? '',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.image,
                                                      size: 30,
                                                      color: Colors.grey),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product['name'] ??
                                                      'Produit inconnu',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Quantité: ${product['quantity'] ?? 0}",
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                                Text(
                                                  "Prix unitaire: ${product['unitPrice'] ?? 0} DT",
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            "${product['totalPriceItem'] ?? 0} DT",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),

                                const SizedBox(height: 16),

                                // Total et informations de commande
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Total:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "${data['totalAmount'] ?? '0'} DT",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Date de commande: ${formatTimestamp(data['orderDate'])}",
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Boutons pour changer le statut
                                const Text(
                                  "Changer le statut:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    // Bouton "En cours de préparation"
                                    ElevatedButton(
                                      onPressed: () => updateOrderStatus(
                                          order.id, 'En préparation'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.restaurant_menu, size: 16),
                                          SizedBox(width: 4),
                                          Text("En préparation"),
                                        ],
                                      ),
                                    ),

                                    // Bouton "Livrée"
                                    ElevatedButton(
                                      onPressed: () =>
                                          updateOrderStatus(order.id, 'Livrée'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.delivery_dining, size: 16),
                                          SizedBox(width: 4),
                                          Text("Livrée"),
                                        ],
                                      ),
                                    ),

                                    // Bouton "En attente"
                                    ElevatedButton(
                                      onPressed: () => updateOrderStatus(
                                          order.id, 'En attente'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.timer, size: 16),
                                          SizedBox(width: 4),
                                          Text("En attente"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher une statistique
  Widget _buildStatItem({
    required int count,
    required String label,
    required Color color,
    bool isTotal = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isTotal ? Colors.blue[50] : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$count",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.blue : color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
