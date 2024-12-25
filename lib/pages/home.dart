import 'package:flutter/material.dart';
import 'package:lef_mob/pages/favourites.dart';
import 'package:lef_mob/pages/profile.dart';
import 'package:lef_mob/pages/setting.dart';
//import 'eventdetails.dart'; // Import the EventDetailsPage

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
    _pages = <Widget>[
      const HomePageContent(),
      ProfilePage(
        profileImageUrl: widget.profileImageUrl,
        displayName: widget.displayName,
        email: widget.email,
      ),
      const AccountSettingsPage(),
      const FavoritesPage(),
    ];
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
        toolbarHeight: 0,
        backgroundColor: const Color.fromARGB(255, 15, 14, 14),
        elevation: 0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 255, 81, 0),
        unselectedItemColor: const Color.fromARGB(255, 15, 9, 5),
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
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String selectedLocation = 'Colombo';
  String selectedCategory = 'All';
  String searchQuery = '';

  final List<String> sriLankanLocations = [
    'Colombo',
    'Kandy',
    'Galle',
    'Jaffna',
    'Matara',
    'Negombo',
    'Anuradhapura',
    'Ratnapura',
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
    {
      'title': 'Music Festival in Colombo',
      'dateTime': 'Fri, Dec 29 • 06:00 PM',
      'location': 'Colombo',
      'category': 'Music',
      'image': 'lib/assets/main1.jpg',
      'description': 'A vibrant music festival with top artists.',
      'organizer': 'Music Inc.',
      'ticketPrice': 'RS.5000',
    },
    {
      'title': 'Musical show in Colombo',
      'dateTime': 'Fri, Dec 30 • 07:00 PM',
      'location': 'Colombo',
      'category': 'Music',
      'image': 'lib/assets/main2.jpg',
      'description': 'An amazing night with live music.',
      'organizer': 'Concerts Ltd.',
      'ticketPrice': 'Rs.4000',
    },
    {
      'title': 'Business Conference ',
      'dateTime': 'Mon, Jan 3 • 1:00 PM',
      'location': 'Kandy',
      'category': 'Business',
      'image': 'lib/assets/main2.jpg',
      'description': 'An conference for future businessmans career devlopment.',
      'organizer': 'LEO company pvt Ltd.',
      'ticketPrice': 'Rs.4000',
    },
    // Add other events here with the same structure
  ];

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
            // Search Bar
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
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
                  ),
                ),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    items: eventCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
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
                return buildEventCard(event, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEventCard(Map<String, dynamic> event, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsPage(event: event),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              event['image'],
              fit: BoxFit.cover,
              height: 150,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(event['dateTime'], style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(event['location'], style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                event['image'],
                fit: BoxFit.cover,
                height: 250,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              Text(
                event['title'],
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                event['dateTime'],
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Location: ${event['location']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                event['description'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Organizer: ${event['organizer']}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Ticket Price: ${event['ticketPrice']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      // Add event to favorites functionality here
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Handle "Get Ticket" action here
                    },
                    child: const Text('Get Ticket'),
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
