import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import '../services/sms_service.dart';
import '../services/database_service.dart';
import '../models/emergency_contact.dart';
import 'contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final SMSService _smsService = SMSService();
  final DatabaseService _databaseService = DatabaseService();
  
  List<EmergencyContact> _contacts = [];
  bool _isLoading = false;
  String _statusMessage = 'Ready for emergencies';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _databaseService.getAllContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  Future<void> _triggerEmergencyAlert() async {
    if (_contacts.isEmpty) {
      _showMessage('No emergency contacts added. Please add contacts first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Getting location...';
    });

    try {
      final location = await _locationService.getCurrentLocation();
      
      if (location != null) {
        setState(() {
          _statusMessage = 'Sending emergency alerts...';
        });

        final mapsUrl = 'https://maps.google.com/?q=${location.latitude},${location.longitude}';
        final message = '🚨 EMERGENCY ALERT! I need help. My current location is: $mapsUrl';

        bool success = true;
        for (final contact in _contacts) {
          final result = await _smsService.sendSMS(contact.phoneNumber, message);
          if (!result) {
            success = false;
          }
        }

        setState(() {
          _statusMessage = success 
            ? 'Emergency alerts sent to ${_contacts.length} contacts!'
            : 'Some alerts failed to send. Please try again.';
        });

        _showMessage(_statusMessage);
        
        if (success) {
          _showLocationDialog(mapsUrl);
        }
      } else {
        setState(() {
          _statusMessage = 'Could not get location. Please check GPS settings.';
        });
        _showMessage(_statusMessage);
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
      _showMessage(_statusMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLocationDialog(String mapsUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Emergency Alert Sent'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your location has been shared with emergency contacts.'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(mapsUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'View Location on Maps',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('Error') || message.contains('failed') 
          ? Colors.red 
          : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Safety'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactsScreen()),
              );
              _loadContacts();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _triggerEmergencyAlert,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isLoading ? Colors.grey : Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: (_isLoading ? Colors.grey : Colors.red).withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isLoading
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 3,
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.emergency,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                          const SizedBox(height: 10),
                          Text(
                            _isLoading ? 'SENDING...' : 'SOS',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.contacts,
                          color: Colors.blue,
                          size: 30,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${_contacts.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Contacts',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 30,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'GPS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Ready',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.sms,
                          color: Colors.orange,
                          size: 30,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'SMS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Ready',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
