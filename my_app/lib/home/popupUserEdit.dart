import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';

class EditableData {
  String field1;
  String field2;
  String field3;

  EditableData(
      {required this.field1, required this.field2, required this.field3});
}

class EditDataDialog extends StatefulWidget {
  final List<dynamic> initialData;
  final List<dynamic> initialAlldData;

  EditDataDialog({required this.initialData, required this.initialAlldData});

  @override
  _EditDataDialogState createState() => _EditDataDialogState();
}

class _EditDataDialogState extends State<EditDataDialog> {
  late TextEditingController _field1Controller;
  late TextEditingController _field2Controller;
  // late TextEditingController _field3Controller;
  late List<String> checkUUID;
  late bool isUUIDSame;
  late String roleSelectedValue;
  // Add more controllers for other fields if needed

  @override
  void initState() {
    try {
      super.initState();
      print(widget.initialData.toString());
      _field1Controller =
          TextEditingController(text: widget.initialData[0].toString());
      print(_field1Controller.text.toString());
      _field2Controller =
          TextEditingController(text: widget.initialData[1].toString());
      roleSelectedValue = widget.initialData[2].toString();
      List<String> tempAllUUID = [];
      for (var element in widget.initialAlldData) {
        tempAllUUID.add(element[0].toString());
      }
      checkUUID = tempAllUUID;
      isUUIDSame = false;
    } on Exception catch (_) {
      print('never reached');
    }
  }

  @override
  void dispose() {
    _field1Controller.dispose();
    _field2Controller.dispose();
    // roleSelectedValue.dispose();
    super.dispose();
  }

  Future<List<String>> loadRoleData() async {
    await dotenv.load(fileName: ".env");
    String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";

    File dataTest = File(path.current + testEnv + "/json/myRole.json");

    String test = dataTest.readAsStringSync();
    List<String> roleData = List<String>.from(jsonDecode(test));
    return roleData;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _field1Controller,
            onChanged: (value) {
              if (checkUUID.contains(value) &&
                  value != widget.initialData[0].toString()) {
                setState(() {
                  isUUIDSame = true;
                });
              } else {
                setState(() {
                  isUUIDSame = false;
                });
              }
            },
            style:
                TextStyle(fontSize: 15.0, color: Color.fromARGB(255, 7, 0, 48)),
            decoration: InputDecoration(
                suffixIcon: Tooltip(
                  message: isUUIDSame ? 'เลขประจำตัวซ้ำกัน' : "ใช้เลขนี้ได้",
                  child: isUUIDSame
                      ? Icon(
                          Icons.error_outline,
                          color: Colors.blueGrey,
                        )
                      : Icon(
                          Icons.check_circle,
                          color: Colors.blueGrey,
                        ),
                ),
                labelText: 'ชื่อ-นามสกุล'),
          ),
          TextField(
            controller: _field2Controller,
            decoration: InputDecoration(labelText: 'ชื่อ-นามสกุล'),
          ),
          FutureBuilder<List<String>>(
              future: loadRoleData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                      'Loading...'); // Display a loading message while waiting for the data
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<String> roleJson = snapshot.data ?? [];
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      itemHeight: 100.0,
                      iconSize: 24,
                      elevation: 16,
                      isExpanded: true,
                      style:
                          TextStyle(color: Colors.deepPurple, fontSize: 20.0),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      value: roleSelectedValue,
                      onChanged: (newValue) {
                        setState(() {
                          roleSelectedValue = newValue.toString();
                        });
                      },
                      items: roleJson.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            height: 100,
                            child: Wrap(
                              children: [
                                Text(
                                  entry,
                                  style: TextStyle(
                                    fontSize: 18, // Adjust the font size
                                    color: Colors.black, // Customize text color
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
              })
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            List<String> newData = [
              widget.initialData[0].toString(),
              widget.initialData[1].toString(),
              widget.initialData[2].toString()
            ];

            Navigator.of(context).pop(newData);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith((states) {
              if (isUUIDSame) {
                return Colors.grey; // Icon color when the button is disabled
              }
              return Colors
                  .blue; // Icon color for other states (normal, pressed, etc.)
            }),
          ),
          onPressed: () {
            // Save the changes and close the dialog
            List<String> newData = [
              _field1Controller.text.toString(),
              _field2Controller.text.toString(),
              roleSelectedValue.toString()
            ];
            print("newDXata" + newData.toString());
            Navigator.of(context).pop(newData);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
