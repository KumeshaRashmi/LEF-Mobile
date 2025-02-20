import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'eventdetails.dart';
import 'favourites.dart';
import 'profile.dart';
import 'setting.dart';

class Home extends StatefulWidget {
  final String profileImageUrl;
  final String displayName;
  final String email;

  const Home({
    super.key,
    required this.profileImageUrl,
    required this.displayName,
    required this.email,
  });

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePageContent(
        onFavorite: _addFavorite,
        displayName: widget.displayName,
        profileImageUrl: widget.profileImageUrl,
      ),
      ProfilePage(
        profileImageUrl: widget.profileImageUrl,
        displayName: widget.displayName,
        email: widget.email,
      ),
      const AccountSettingsPage(),
      const FavoritesScreen(),
    ];
  }

  void _addFavorite(Map<String, dynamic> event) {

  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Hide the AppBar
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:const Color.fromARGB(255, 250, 67, 67),
        unselectedItemColor: const Color.fromARGB(255, 130, 128, 128),
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  final Function(Map<String, dynamic>) onFavorite;
  final String displayName;
  final String profileImageUrl;

  const HomePageContent({
    super.key,
    required this.onFavorite,
    required this.displayName,
    required this.profileImageUrl,
  });

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String selectedLocation = 'All';
  String selectedCategory = 'All';
  String searchQuery = '';

  final List<String> sriLankanLocations = [
    'All',
    'Colombo',
    'Gampaha',
    'Kalutara',
    'Kandy',
    'Matale',
    'Nuwara Eliya',
    'Galle',
    'Matara',
    'Hambantota',
    'Jaffna',
    'Kilinochchi',
    'Mannar',
    'Mullaitivu',
    'Vavuniya',
    'Batticaloa',
    'Ampara',
    'Trincomalee',
    'Kurunegala',
    'Puttalam',
    'Anuradhapura',
    'Polonnaruwa',
    'Badulla',
    'Monaragala',
    'Ratnapura',
    'Kegalle',
  ];

  final List<String> eventCategories = [
    'All',
    'Music',
    'Business',
    'Food',
    'Art',
    'Films',
    'Sports',
  ];

  final List<Map<String, dynamic>> events = [
    
  ];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      events.addAll(snapshot.docs.map((doc) => doc.data()).toList());
    });
  }

  List<Map<String, dynamic>> getFilteredEvents() {
    return events.where((event) {
      final matchesLocation = selectedLocation == 'All' || event['location'] == selectedLocation;
      final matchesCategory = selectedCategory == 'All' || event['category'] == selectedCategory;
      final matchesSearchQuery = event['title'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesLocation && matchesCategory && matchesSearchQuery;
    }).toList();
  }

@override
  Widget build(BuildContext context) {
    final filteredEvents = getFilteredEvents();

  return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                "Welcome, ${widget.displayName.split(' ')[0]} to EventFy",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            CircleAvatar(
              backgroundImage: NetworkImage(widget.profileImageUrl),
              radius: 18,
            ),
          ],
        ),
            const SizedBox(height: 16),
            // Search bar and dropdowns
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  Text(
                    'Ef',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search events...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Dropdowns for Location and Category
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedLocation,
                    decoration: InputDecoration(
                      labelText: 'Select Location',
                      floatingLabelStyle: TextStyle(
                      color: Colors.red, 
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                        color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                    color: Colors.grey,
                    ),
                    ),
                  ),
                    items: sriLankanLocations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLocation = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                child: DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Select Category',
                  floatingLabelStyle: TextStyle(
                  color: Colors.red, 
                ),
      
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                  color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                color: Colors.grey,
                  ),
                ),
              ),
              items: eventCategories.map((category) {
                return DropdownMenuItem(
                value: category,
                child: Text(
                category,
                style: TextStyle(
                  color: Colors.black,
                  ),
                ),
              );
              }).toList(),
              onChanged: (value) {
              setState(() {
              selectedCategory = value!; // Update selected category
              });
            },
              dropdownColor: Colors.white, // Background color for dropdown
              ),
            ),
          ],
        ),
            const SizedBox(height: 20),
            const Text(
              'Discover Events',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredEvents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return buildEventCard(event, context, widget.onFavorite);
              },
            ),
          ],
        ),
      ),
    );
  }

    Widget buildEventCard(Map<String, dynamic> event, BuildContext context, Function(Map<String, dynamic>) onFavorite) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsPage(event: event, addFavorite: widget.onFavorite),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                event['image'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
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
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        event['dateTime'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        event['location'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rs. ${event['ticketPrice']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

