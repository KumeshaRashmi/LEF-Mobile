import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            // Add to favorites logic if needed
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
                      onTap: () => navigateToEventDetails(event),
                      child: Row(
                        children: [
                          Image.network(
                            event['image'] ?? 'assets/placeholder.png',
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
                                  event['title'] ?? 'No Title',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(event['dateTime'] ?? 'No Date/Time'),
                                const SizedBox(height: 4),
                                Text(event['location'] ?? 'No Location'),
                                const SizedBox(height: 4),
                                Text(
                                  'Category: ${event['category'] ?? 'N/A'}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final eventId = event['id'];
                              if (eventId != null) {
                                setState(() {
                                  widget.favoriteEvents.removeAt(index);
                                });
                                await widget.removeFavorite(event);
                              } else {
                                print("Error: Event ID is null.");
                              }
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

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> favoriteEvents = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void removeFavorite(Map<String, dynamic> event) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(event['id'])
          .delete();
    } catch (e) {
      print("Error removing favorite from Firestore: $e");
    }
  }

  void fetchFavoritesFromFirestore() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      var snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          favoriteEvents = snapshot.docs
              .map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id; // Include the Firestore document ID
                return data;
              })
              .toList();
        });
      } else {
        setState(() {
          favoriteEvents = [];
        });
      }
    } catch (e) {
      print("Error fetching favorites: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        fetchFavoritesFromFirestore();
      } else {
        setState(() {
          favoriteEvents = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FavoritesPage(
      favoriteEvents: favoriteEvents,
      removeFavorite: removeFavorite,
    );
  }
}
