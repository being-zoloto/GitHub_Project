import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_details.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> _fetchUserDetails(String username) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http
          .get(Uri.parse('https://api.github.com/search/users?q=$username'));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          searchResults = List<Map<String, dynamic>>.from(jsonData['items']);
        });
      } else {
        setState(() {
          errorMessage = 'Error fetching user data';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching user data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleSearch() {
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      _fetchUserDetails(searchText);
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      searchResults.clear();
      errorMessage = '';
    });
  }

  void _navigateToUserDetails(String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(
          username: username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub'),
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) {
                        _handleSearch();
                      },
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _handleSearch,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        ),
                        border: InputBorder.none,
                        hintText: 'Search here..',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            const CircularProgressIndicator()
          else if (errorMessage.isNotEmpty)
            Text(errorMessage)
          else
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _navigateToUserDetails(searchResults[index]['login']);
                    },
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              searchResults[index]['avatar_url']),
                        ),
                        title: Text(
                          searchResults[index]['login'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
