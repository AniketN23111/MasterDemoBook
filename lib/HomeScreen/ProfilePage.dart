import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saloon/HomeScreen/EditProfilePage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading indicator while fetching data
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            // No user data available, handle navigation here
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, 'getStarted');
            });
            return Container(); // Return an empty container for now
          }

          // Extract user data from Firestore
          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
          String firstName = '${userData['firstName']}';
          String lastName = ' ${userData['lastName']}';
          String email = userData['email'];
          String dob = userData['dob'];
          String mobile = userData['mobile'];

          String profileImageURL = currentUser?.photoURL ?? generateDefaultProfileImageURL(firstName, lastName);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 100),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(profileImageURL),
                      ),
                      InkWell(
                        onTap: () {
                          // Navigate to the Edit Profile page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfilePage(profileImageURL)),
                          ).then((imageUrl) {
                            // Update the image URL if it changed in the EditProfilePage
                            if (imageUrl != null && imageUrl is String) {
                              setState(() {
                                profileImageURL = imageUrl;
                              });
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    '$firstName $lastName',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      ListTile(
                        title: Text('My Appointments'),
                        onTap: () {
                          // Navigate to My Appointments page
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text('My Favorites'),
                        onTap: () {
                          // Navigate to My Favorites page
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Privacy Policy'),
                        onTap: () {
                          // Navigate to Privacy Policy page
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Terms and Conditions'),
                        onTap: () {
                          // Navigate to Terms and Conditions page
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Contact Us'),
                        onTap: () {
                          // Navigate to Contact Us page
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text('About Us'),
                        onTap: () {
                          // Navigate to About Us page
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Cancellation/Refund Policy'),
                        onTap: () {
                          // Navigate to Cancellation/Refund Policy page
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Logout'),
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, 'loginScreen');
                        },
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Delete Account',style: TextStyle(
                          color: Colors.red
                        ),),
                        onTap: () async {
                          // Delete the user's account and data
                          await _deleteAccount();
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, 'loginScreen');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        await user.delete();
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
  }

  String generateDefaultProfileImageURL(String firstName, String lastName) {
    final initials = (firstName.isNotEmpty ? firstName[0] : '') + (lastName.isNotEmpty ? lastName[0] : '');
    return 'https://www.example.com/default_profile_images/$initials.png'; // Replace with your default image URL pattern
  }
}
