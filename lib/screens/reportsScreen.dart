import 'package:flutter/material.dart';
import 'package:kavach/components/main_component.dart';

Container make_report_widget(String name, int phone_number) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: Colors.black, width: 2),
        right: BorderSide(color: Colors.black, width: 2),
        bottom: BorderSide(color: Colors.black, width: 2),
        left: BorderSide(color: Colors.black, width: 2),
      ),
      borderRadius: BorderRadius.circular(16.0),
    ),
    child: Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 18.0, right: 18.0),
      child: Row(
        children: [
          Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          Spacer(),
          Text("$phone_number"),
        ],
      ),
    ),
  );
}



class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsState();
}

class _ReportsState extends State<ReportsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Widget> _report_widgets = [];

  @override
  Widget build(BuildContext context) {
    const red = const Color(0xFFFF6666);
    const green = const Color(0xFF95F6A7);
    const hero_icon = const Icon(
      Icons.report,
      color: red,
      size: 192.0,
    );
    const heading_text = const Text(
      "My Reports",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 64, color: red, fontWeight: FontWeight.bold),
    );

    const subtitle_text = const Text(
      "These are the reports you have done in the past, you can update them here",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    );

    const space = const SizedBox(
      width: 12,
      height: 12,
    );

    const half_space = const SizedBox(
      width: 8,
      height: 8,
    );

    SizedBox add_report_button = SizedBox(
      width: double.infinity,
      child: OutlinedButton(
          onPressed: _update_report_widgets,
          style: OutlinedButton.styleFrom(
              backgroundColor: green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              side: BorderSide(width: 2.0, color: Colors.black)),
          child: const Row(children: <Widget>[
            const Text('Add a report',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                )),
            const Spacer(),
            const Icon(Icons.add)
          ])),
    );

    if (_report_widgets.length < 1) _report_widgets.add(add_report_button);
    Container all_reports = Container(
      height: 320,
      child: ListView.builder(
        itemCount: _report_widgets.length,
        itemBuilder: (BuildContext context, int index) {
          return _report_widgets[index];
        },
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: myDrawer,
      appBar: getAppBar(_scaffoldKey),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
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
    );
  }

void _update_report_widgets() {
    setState( () { 
      const half_space = const SizedBox(
      width: 8,
      height: 8,
    );
      _report_widgets.addAll(
        <Widget>[
          make_report_widget("Pranjal Rastogi", 9910708969),
          half_space
        ],
      );
    });
}
}
