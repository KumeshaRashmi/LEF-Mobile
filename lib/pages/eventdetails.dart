import 'package:flutter/material.dart';
import 'package:lef_mob/pages/eventbooking/booking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailsPage extends StatefulWidget {
  final Map<String, dynamic> event;
  final Function(Map<String, dynamic>) addFavorite;

  const EventDetailsPage({
    super.key,
    required this.event,
    required this.addFavorite,
  });

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool isFavorited = false; // Tracks whether the event is favorited
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void toggleFavorite() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    setState(() {
      isFavorited = !isFavorited;
    });

    if (isFavorited) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(widget.event['id'])
          .set(widget.event);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.event['title']} added to favorites!')),
      );
    } else {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(widget.event['id'])
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.event['title']} removed from favorites!')),
      );
    }
  }

  void navigateToBookingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookingPage(event: widget.event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event['title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.asset(
                    widget.event['image'],
                    fit: BoxFit.cover,
                    height: 250,
                    width: double.infinity,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title and Favorite Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Organized by ${widget.event['organizer']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: toggleFavorite,
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Event Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.event['dateTime']),
                  Text(widget.event['location']),
                ],
              ),
              const SizedBox(height: 16),

              // Map Section
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: const Center(
                  child: Text('Map Placeholder'),
                ),
              ),
              const SizedBox(height: 16),

              // Description Section
              Text(
                'Program Details:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.event['description']),
              const SizedBox(height: 16),

              // Ticket Price and Book Now Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rs.${widget.event['ticketPrice']} Per Guest',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: navigateToBookingPage,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Book Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

