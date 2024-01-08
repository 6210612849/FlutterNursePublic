// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:excel/excel.dart';
// import 'package:flutter/services.dart';
// import 'dart:developer' as developer;
// import 'package:path_provider/path_provider.dart';

import 'dart:convert';
import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:my_app/home/edit.dart';
import 'package:my_app/home/graphMain.dart';
import 'package:my_app/home/search.dart';
import 'package:my_app/home/user.dart';

class myHome extends StatefulWidget {
  const myHome({super.key});

  @override
  State<myHome> createState() => myHomeState();
}

void _navigateToNextExcel(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => ExcelDataScreen()));
}

void _navigateToNextInsert(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => EditScreen()));
}

void _navigateToNextGraph(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => GraphMain()));
}

void _navigateToNextSearch(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => SearchMainScreen()));
}

class myHomeState extends State<myHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Home"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 100,
              ),
              Text(
                "บริษัท เพ็ญศิริ การพยาบาล จำกัด PHENSIRI KARNPHAYABAN COMPANY LIMITED",
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              Image(
                image: AssetImage('images/myLogo.png'),
                height: 150,
              ),
              SizedBox(
                height: 100,
              ),
              ElevatedButton(
                child: const Text(
                  'Mode Search>>',
                  style: TextStyle(fontSize: 24.0),
                ),
                onPressed: () {
                  _navigateToNextSearch(context);
                },
              ),
              ElevatedButton(
                child: const Text(
                  'Mode View >>',
                  style: TextStyle(fontSize: 24.0),
                ),
                onPressed: () {
                  _navigateToNextExcel(context);
                },
              ),
              ElevatedButton(
                child: const Text(
                  'Insert >>',
                  style: TextStyle(fontSize: 24.0),
                ),
                onPressed: () => {
                  _navigateToNextInsert(context),
                },
              ),
              ElevatedButton(
                child: const Text(
                  'Graph >>',
                  style: TextStyle(fontSize: 24.0),
                ),
                onPressed: () => {
                  _navigateToNextGraph(context),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
