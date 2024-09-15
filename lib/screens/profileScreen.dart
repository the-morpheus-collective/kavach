import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kavach/components/main_component.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kavach/secrets.dart' as s;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final List<Map<String, String>> _emergencyContacts = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  String _phoneNumber = '';
  final supabaseClient = SupabaseClient(s.supabaseUrl, s.supabaseAnonKey);
  final _storage = const FlutterSecureStorage();

  Future<String?> getPhoneNumber() async {
    final user = await _storage.read(key: 'user_id');
    print(user);
    return user;
  }

  Future<String?> getUserName() async {
    _phoneNumber = (await getPhoneNumber())!;

    final response = await supabaseClient
        .from('users')
        .select()
        .eq('phone_number', _phoneNumber as Object);

    if (response.length == 0) {
      return null;
    }

    return response[0]['username'] as String;
  }

  Future<void> storeDB() async {
    try {
      final response =
          await Supabase.instance.client.from('emergency_contacts').insert({
        'name': _nameController.text,
      });

      print(response);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error: ${error.toString()}'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: myDrawer,
      appBar: getAppBar(_scaffoldKey),
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage("https://placehold.co/200/png"),
                ),
                const SizedBox(height: 10),
                FutureBuilder<String?>(
                  future: getUserName(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                FutureBuilder<String?>(
                  future: getPhoneNumber(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        '+91 ${snapshot.data}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                const SizedBox(height: 30),

                // Emergency Contact Section
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: const Border(
                      top: BorderSide(
                        color: Colors.black,
                        width: 0.1,
                      ),
                      left: BorderSide(
                        color: Colors.black,
                        width: 0.1,
                      ),
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 4,
                      ),
                      right: BorderSide(
                        color: Colors.black,
                        width: 4,
                      ),
                    ),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Names',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: const Border(
                      top: BorderSide(
                        color: Colors.black,
                        width: 0.1,
                      ),
                      left: BorderSide(
                        color: Colors.black,
                        width: 0.1,
                      ),
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 4,
                      ),
                      right: BorderSide(
                        color: Colors.black,
                        width: 4,
                      ),
                    ),
                  ),
                  child: TextField(
                    controller: _numberController,
                    decoration: InputDecoration(
                      labelText: 'Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Add Emergency Contact Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: const Border(
                      top: BorderSide(
                        color: Color(0xFF900927),
                        width: 1.0,
                      ),
                      left: BorderSide(
                        color: Color(0xFF900927),
                        width: 1.0,
                      ),
                      bottom: BorderSide(
                        color: Color(0xFF900927),
                        width: 4,
                      ),
                      right: BorderSide(
                        color: Color(0xFF900927),
                        width: 4,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addEmergencyContact,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        backgroundColor: const Color(0xFFFF6666),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Add emergency contact',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(
                  thickness: 2,
                  color: Color(0xFF555555),
                ),
                const SizedBox(height: 20),

                // Display List of Emergency Contacts
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _emergencyContacts.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: const Border(
                          top: BorderSide(
                            color: Colors.black,
                            width: 0.1,
                          ),
                          left: BorderSide(
                            color: Colors.black,
                            width: 0.1,
                          ),
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 4,
                          ),
                          right: BorderSide(
                            color: Colors.black,
                            width: 4,
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text(_emergencyContacts[index]['name']!),
                        subtitle: Text(_emergencyContacts[index]['number']!),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeEmergencyContact(index),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child:
                    LoadingAnimationWidget.beat(color: Colors.white, size: 50),
              ),
            ),
          ),
      ]),
    );
  }

  void _addEmergencyContact() {
    if (_nameController.text.isNotEmpty &&
        _numberController.text.isNotEmpty &&
        _numberController.text.length == 10) {
      setState(() {
        _emergencyContacts.add({
          'name': _nameController.text,
          'number': _numberController.text,
        });
      });
      updateEmergencyContactsDB();
      _nameController.clear();
      _numberController.clear();
    }
  }

  void _removeEmergencyContact(int index) {
    setState(() {
      _emergencyContacts.removeAt(index);
    });
  }

  Future<void> updateEmergencyContactsDB() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await supabaseClient.from('emergencycontacts').insert({
        'emergency_contacts': jsonEncode(_emergencyContacts),
      });
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error: ${error.toString()}'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
