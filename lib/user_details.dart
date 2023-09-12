import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDetailsScreen extends StatefulWidget {
  final String username;

  const UserDetailsScreen({required this.username});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  Map<String, dynamic> userDetails = {};

  void _fetchUserDetails() async {
    try {
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
    } catch (e) {
      print('Error fetching user details: $e');
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
            Text(userDetails['login'], style: const TextStyle(fontSize: 18)),
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
