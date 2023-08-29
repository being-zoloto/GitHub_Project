import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitHub User Search',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          foregroundColor: Colors.black,
        ),
      ),
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  void _fetchUserDetails(String username) async {
    try {
      final response = await http
          .get(Uri.parse('https://api.github.com/search/users?q=$username'));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          searchResults = List<Map<String, dynamic>>.from(jsonData['items']);
        });
      } else {
        print('Error fetching user data');
      }
    } catch (e) {
      print('Enter The valid Name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _fetchUserDetails(_searchController.text);
                    },
                  ),
                  border: InputBorder.none,
                  hintText: 'Search here..',
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailsScreen(
                          username: searchResults[index]['login'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(searchResults[index]['avatar_url']),
                      ),
                      title: Text(
                        searchResults[index]['login'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Repos: ${searchResults[index]['public_repos']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserDetailsScreen extends StatefulWidget {
  final String username;

  const UserDetailsScreen({required this.username});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  Map<String, dynamic> userDetails = {};

  void _fetchUserDetails() async {
    final response = await http
        .get(Uri.parse('https://api.github.com/users/${widget.username}'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      setState(() {
        userDetails = jsonData;
      });
    } else {
      print('Error fetching user details');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: Center(
        child: userDetails.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(userDetails['avatar_url']),
                    radius: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userDetails['name'] ?? 'No Name',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(userDetails['login'], style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text('Location: ${userDetails['location'] ?? 'Unknown'}'),
                  const SizedBox(height: 10),
                  Text('Public Repos: ${userDetails['public_repos']}'),
                  const SizedBox(height: 10),
                  Text('Public Gists: ${userDetails['public_gists']}'),
                  const SizedBox(height: 10),
                  Text('Followers: ${userDetails['followers']}'),
                  const SizedBox(height: 10),
                  Text('Last Update: ${userDetails['updated_at']}'),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
