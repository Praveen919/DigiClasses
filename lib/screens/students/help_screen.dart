import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  final String option;

  const HelpScreen({super.key, this.option = 'contactUs'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (option) {
      case 'contactUs':
        return const ContactUsScreen();
      default:
        return const Center(child: Text('Unknown Option'));
    }
  }
}

void _openInstagram() async {
  const String instagramUrl = 'https://www.instagram.com/digi.class2024/';
  await FlutterWebBrowser.openWebPage(url: instagramUrl);
}

// Function to open the Facebook page
void _openFacebook() async {
  const facebookUrl =
      'https://www.facebook.com/yourProfileLink'; // Replace with your Facebook profile link
  if (await canLaunchUrl(Uri.parse(facebookUrl))) {
    await launchUrl(Uri.parse(facebookUrl));
  } else {
    throw 'Could not launch $facebookUrl';
  }
}

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Contact Us'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon and heading
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(
                Icons.support_agent,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 24),

            // Email section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                leading: Icon(
                  Icons.email,
                  color: Colors.blueAccent,
                  size: 30,
                ),
                title: Text(
                  'Email Us',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'digiclass737@gmail.com',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Call section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                leading: Icon(
                  Icons.phone,
                  color: Colors.green,
                  size: 30,
                ),
                title: Text(
                  'Call Us',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '+91 81695 56700',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Social media links section
            const Text(
              'Follow Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.facebook),
                  color: Colors.blue,
                  iconSize: 30,
                  onPressed: _openFacebook, // Link to your Facebook page
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.instagram),
                  color: Colors.pinkAccent,
                  iconSize: 30,
                  onPressed: _openInstagram, // Link to your Instagram page
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
