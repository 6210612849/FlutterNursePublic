import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;

class AddDataDialog extends StatefulWidget {
  final List<dynamic> initialAlldData;
  AddDataDialog({Key? key, required this.initialAlldData}) : super(key: key);

  @override
  _AddDataDialogState createState() => _AddDataDialogState();
}

class _AddDataDialogState extends State<AddDataDialog> {
  late TextEditingController _field1Controller;
  late TextEditingController _field2Controller;
  late TextEditingController _field3Controller;
  late List<String> checkUUID;
  late List<String> checkName;
  late bool isUUIDSame = false;
  bool isToolUUID = false;
  bool isToolName = false;
  late bool isNameSame = false;
  late String? roleSelectedValue;

  // Add more controllers for other fields if needed
  Future<List<String>> loadRoleData() async {
    await dotenv.load(fileName: ".env");
    String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";

    File dataTest = File(path.current + testEnv + "/json/myRole.json");

    String test = dataTest.readAsStringSync();
    List<String> roleData = List<String>.from(jsonDecode(test));
    return roleData;
  }

  @override
  void initState() {
    try {
      super.initState();
      roleSelectedValue = null;
      List<String> tempAllUUID = [];
      List<String> tempAllName = [];
      for (var element in widget.initialAlldData) {
        tempAllUUID.add(element[0].toString());
        tempAllName.add(element[1].toString());
      }
      checkUUID = tempAllUUID;
      checkName = tempAllName;

      _field1Controller = TextEditingController(text: "");
      _field2Controller = TextEditingController(text: "");
      _field3Controller = TextEditingController(text: "");
    } on Exception catch (_) {
      print('never reached');
    }
  }

  @override
  void dispose() {
    _field1Controller.dispose();
    _field2Controller.dispose();
    _field3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _field1Controller,
            onChanged: (value) {
              if (_field1Controller.value.text != "" && !isToolUUID) {
                setState(() {
                  isToolUUID = true;
                });
              }
              if (_field1Controller.value.text == "" && isToolUUID) {
                setState(() {
                  isToolUUID = false;
                });
              }

              if (checkUUID.contains(value)) {
                setState(() {
                  isUUIDSame = true;
                });
              } else {
                if (isUUIDSame) {
                  setState(() {
                    isUUIDSame = false;
                  });
                }
              }
            },
            style:
                TextStyle(fontSize: 15.0, color: Color.fromARGB(255, 7, 0, 48)),
            decoration: InputDecoration(
                suffixIcon: Visibility(
                    visible: isToolUUID,
                    child: Tooltip(
                      message:
                          isUUIDSame ? 'เลขประจำตัวซ้ำกัน' : "ใช้เลขนี้ได้",
                      child: isUUIDSame
                          ? Icon(
                              Icons.error_outline,
                              color: Colors.blueGrey,
                            )
                          : Icon(
                              Icons.check_circle,
                              color: Colors.blueGrey,
                            ),
                    )),
                labelText: 'เลขประจำตัว'),
          ),
          TextField(
            controller: _field2Controller,
            onChanged: (value) {
              if (_field2Controller.value.text != "" && !isToolName) {
                setState(() {
                  isToolName = true;
                });
              }
              if (_field2Controller.value.text == "" && isToolName) {
                setState(() {
                  isToolName = false;
                });
              }
              // if (!isToolName) {
              //   setState(() {
              //     isToolName = true;
              //   });
              // }

              if (checkName.contains(value)) {
                setState(() {
                  isNameSame = true;
                });
              } else {
                if (isNameSame) {
                  setState(() {
                    isNameSame = false;
                  });
                }
              }
            },
            style:
                TextStyle(fontSize: 15.0, color: Color.fromARGB(255, 7, 0, 48)),
            decoration: InputDecoration(
                suffixIcon: Visibility(
                    visible: isToolName,
                    child: Tooltip(
                      message:
                          isNameSame ? 'ชื่อ-นามสกุลซ้ำกัน' : "ใช้เลขนี้ได้",
                      child: isNameSame
                          ? Icon(
                              Icons.error_outline,
                              color: Colors.blueGrey,
                            )
                          : Icon(
                              Icons.check_circle,
                              color: Colors.blueGrey,
                            ),
                    )),
                labelText: 'ชื่อ-นามสกุล'),
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
          // Add more TextFields for other fields if needed
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context)
                .pop(null); // Close the dialog without saving changes
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
            if (!isNameSame &&
                !isUUIDSame &&
                isToolUUID &&
                isToolName &&
                roleSelectedValue != null) {
              List<dynamic> newData = [
                _field1Controller.text.toString(),
                _field2Controller.text.toString(),
                roleSelectedValue.toString()
              ];

              Navigator.of(context).pop(newData);
            }
          },
          child: Text('Create'),
        ),
      ],
    );
  }
}
