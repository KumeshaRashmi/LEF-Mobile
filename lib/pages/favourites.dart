import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lef_mob/pages/eventdetails.dart';

class FavoritesPage extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteEvents;
  final Function(Map<String, dynamic>) removeFavorite;

  const FavoritesPage({
    super.key,
    required this.favoriteEvents,
    required this.removeFavorite,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // Method to navigate to EventDetailsPage
  void navigateToEventDetails(Map<String, dynamic> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(
          event: event,
          addFavorite: (Map<String, dynamic> event) {
            // Add to favorites logic here if needed
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: widget.favoriteEvents.isEmpty
          ? const Center(child: Text('No favorite events added yet.'))
          : ListView.builder(
              itemCount: widget.favoriteEvents.length,
              itemBuilder: (context, index) {
                final event = widget.favoriteEvents[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: () => navigateToEventDetails(event), // Navigate on tap
                      child: Row(
                        children: [
                          Image.asset(
                            event['image'],
                            fit: BoxFit.cover,
                            height: 80,
                            width: 80,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(event['dateTime']),
                                const SizedBox(height: 4),
                                Text(event['location']),
                                const SizedBox(height: 4),
                                Text(
                                  'Category: ${event['category']}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                // Immediately remove from UI
                                widget.favoriteEvents.removeAt(index);
                              });
                              // Remove from Firestore and handle background operation
                              widget.removeFavorite(event);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// FavoritesScreen widget - StatefulWidget to manage favorites state
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> favoriteEvents = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void removeFavorite(Map<String, dynamic> event) async {
    setState(() {
      favoriteEvents.remove(event);
    });
    try {
      String userId = 'userId'; // Replace this with the actual user ID
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([event]),
      });
    } catch (e) {
      print("Error removing favorite from Firestore: $e");
    }
  }

  void fetchFavoritesFromFirestore(String userId) async {
    try {
      var snapshot = await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        setState(() {
          favoriteEvents = List<Map<String, dynamic>>.from(snapshot.data()?['favorites'] ?? []);
        });
      }
    } catch (e) {
      print("Error fetching favorites: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    String userId = 'userId'; // Replace this with actual user ID from Firebase Auth
    fetchFavoritesFromFirestore(userId);
  }

  @override
  Widget build(BuildContext context) {
    return FavoritesPage(
      favoriteEvents: favoriteEvents,
      removeFavorite: removeFavorite,
    );
  }
}
