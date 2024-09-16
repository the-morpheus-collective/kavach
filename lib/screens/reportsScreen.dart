import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kavach/components/main_component.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui';

final List<String> events = [
  "Other",
  "Children in Danger",
  "Street Harassment",
  "Natural Disasters",
  "Volatile Groups",
  "Sexual Harassment",
  "Theft/Pickpocketing",
  "Physical Conflict"
];

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsState();
}

class _ReportsState extends State<ReportsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DropdownMenuItem<String>> simplified_events = events.map((String value) {
    return DropdownMenuItem<String>(value: value, child: Text(value));
  }).toList();
  final supabaseClient = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();
  final TextEditingController _descriptionController = TextEditingController();
  Object? _userId;
  bool _fetched = false;
  List<Widget> _report_widgets = [];
  String dropdownValue = events.first;
  bool chosen = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    const space = const SizedBox(
      width: 12,
      height: 12,
    );

    const half_space = const SizedBox(
      width: 8,
      height: 8,
    );
    const red = const Color(0xFFFF6666);
    const gray = const Color(0xFF242829);
    const green = const Color(0xFF95F6A7);
    const hero_icon = const Icon(
      Icons.report,
      color: red,
      size: 192.0,
    );

    void editReport() {
      print("hey!");
      showModalBottomSheet<void>(
        // context and builder are
        // required properties in this widget
        context: context,
        builder: (BuildContext context) {
          const border_styling = const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            borderSide: BorderSide(color: Colors.black, width: 2.0),
          );

          var additional_details = TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: "Additional Details",
              enabledBorder: border_styling,
              focusedBorder: border_styling,
            ),
          );

          print("isee");
          print(chosen);

          var submit = Stack(
            children: [
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
                    onPressed: () async {
                      print("Pressed");
                      try {
                        setState(() {
                          _isLoading = true;
                        });
                        await supabaseClient.from('incidents').update({
                          'description': _descriptionController.text,
                        }).eq('user_id', _userId as Object);

                        print("DEBUG: Report updated");
                        setState(() {
                          _isLoading = false;
                        });

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Success'),
                              content:
                                  const Text('Report updated successfully'),
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

                        Navigator.of(context).pop();
                      } catch (e) {
                        // showDialog(
                        //   context: context,
                        //   builder: (BuildContext context) {
                        //     return AlertDialog(
                        //       title: const Text('Error'),
                        //       content: const Text('No reports found'),
                        //       actions: <Widget>[
                        //         TextButton(
                        //           onPressed: () {
                        //             Navigator.of(context).pop();
                        //           },
                        //           child: const Text('OK'),
                        //         ),
                        //       ],
                        //     );
                        //   },
                        // );
                      }
                      Navigator.of(context).pop();
                    },
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
                          'Add description',
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
              if (_isLoading)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: LoadingAnimationWidget.beat(
                          color: Colors.white, size: 50),
                    ),
                  ),
                ),
            ],
          );
          return SizedBox(
            height: 400 + MediaQuery.of(context).viewInsets.bottom,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20.0, 0.0, 20.0, MediaQuery.of(context).viewInsets.bottom),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Editing Report',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 32)),
                    space,
                    additional_details,
                    space,
                    submit,
                    space,
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    Widget make_report_widget(String indcidentType, String discription) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
        child: GestureDetector(
            onTap: editReport,
            child: Container(
              decoration: BoxDecoration(
                border: const Border(
                  top: BorderSide(color: Colors.black, width: 2),
                  right: BorderSide(color: Colors.black, width: 2),
                  bottom: BorderSide(color: Colors.black, width: 2),
                  left: BorderSide(color: Colors.black, width: 2),
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    top: 8.0, bottom: 8.0, left: 18.0, right: 18.0),
                child: Row(
                  children: [
                    Text(indcidentType,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Spacer(),
                    Text(discription),
                  ],
                ),
              ),
            )),
      );
    }

    const heading_text = const Text(
      "My Reports",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 48, color: red, fontWeight: FontWeight.bold),
    );

    const subtitle_text = const Text(
      "These are the reports you have done in the past, you can update them here",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    );

    Future<String?> getPhoneNumber() async {
      final user = await _storage.read(key: 'user_id');
      print("Phone No: $user");
      return user;
    }

    Future<Object> _getUserId() async {
      print("DEBUG: Getting journey id");
      var phoneNumber = await getPhoneNumber();

      print("DEBUG: Gettong db!");
      final user = await supabaseClient
          .from('users')
          .select()
          .eq('phone_number', phoneNumber as Object);

      print("DEBUG: User" + user[0]['user_id']);
      _userId ??= user[0]['user_id'] as Object;
      return user[0]['user_id'] as Object;
    }

    void getReports() {
      // setState(() {
      //   const half_space = const SizedBox(
      //     width: 8,
      //     height: 8,
      //   );
      //   _report_widgets.addAll(
      //     <Widget>[make_report_widget("India Gate", "02-09-2024"), half_space],
      //   );
      // });

      setState(() {
        _isLoading = true;
      });

      if (!_fetched) {
        _getUserId().then((value) {
          print(value);
          supabaseClient
              .from('incidents')
              .select()
              .eq('user_id', value)
              .then((response) {
            print(response);
            if (response.length == 0) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: const Text('No reports found'),
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
            print("LENGTH: " + response.length.toString());
            setState(() {
              _fetched = true;
            });
            for (var i = 0; i < response.length; i++) {
              setState(() {
                _report_widgets.addAll([
                  make_report_widget(
                    response[i]['incident_type'] as String,
                    DateFormat("dd-MM").format(
                      DateTime.parse(
                        response[i]['timestamp'],
                      ),
                    ),
                  ),
                ]);
              });
            }

            setState(() {
              _isLoading = false;
            });
          });
        });
      }

      setState(() {
        _isLoading = false;
      });
    }

    Widget add_report_button = Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
              onPressed: getReports,
              style: OutlinedButton.styleFrom(
                  backgroundColor: green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  side: BorderSide(width: 2.0, color: Colors.black)),
              child: const Row(children: <Widget>[
                const Text('Fetch my reports',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    )),
                const Spacer(),
                const Icon(Icons.add)
              ])),
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
      ],
    );

    // if (_report_widgets.length < 1) _report_widgets.add(add_report_button);
    getReports();
    Container all_reports = Container(
      height: 364,
      child: ListView.builder(
        itemCount: _report_widgets.length,
        itemBuilder: (BuildContext context, int index) {
          return _report_widgets[index];
        },
      ),
    );

    return Stack(children: [
      Scaffold(
        // resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        drawer: myDrawer,
        appBar: getAppBar(_scaffoldKey),
        backgroundColor: const Color(0xFFFFFFFF),
        body: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              hero_icon,
              heading_text,
              subtitle_text,
              space,
              all_reports,
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
              child: LoadingAnimationWidget.beat(color: Colors.white, size: 50),
            ),
          ),
        ),
    ]);
  }
}
