import 'dart:convert';
import 'dart:developer';
import 'dart:collection';
import 'package:path/path.dart' as path;

import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:my_app/home/opd.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

Future<List<List<dynamic>>> readExcelData(String pathExcel) async {
  // Replace 'assets/sample.xlsx' with the path to your Excel file
  await dotenv.load(fileName: ".env");
  String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";
  File files = File(path.current + testEnv + "/" + pathExcel);
  String data = files.readAsStringSync();
  List<List<dynamic>> _excelData = const CsvToListConverter().convert(data);

  return _excelData;
}

class firstOPD {
  String? uuid;
  String? name;
  String? role;
  DateTime? date;
  TimeOfDay? time;
  String? factory;
  firstOPD(this.uuid, this.name, this.role, this.date, this.time, this.factory);

  bool checkValid() {
    return [uuid, name, role, date, time, factory].contains(null);
  }

  List<String> checkAll() {
    List<String> res = [];
    var temp1 = uuid?.length ?? 0;
    var temp2 = name?.length ?? 0;
    var temp3 = role?.length ?? 0;
    var temp4 = date ?? 0;
    var temp5 = time ?? 0;
    var temp6 = factory ?? 0;
    if (temp1 == 0) {
      res.add("เลขประจำตัว");
    }
    if (temp2 == 0) {
      res.add("ชื่อ-นามสกุล");
    }
    if (temp3 == 0) {
      res.add("ตำเเหน่ง");
    }
    if (temp4 == 0) {
      res.add("วันที่");
    }
    if (temp5 == 0) {
      res.add("เวลา");
    }
    if (temp6 == 0) {
      res.add("factory");
    }

    return res;
  }
}

class UserModel {
  final String id;
  final String name;
  final String work;

  UserModel({required this.id, required this.name, required this.work});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // ignore: unnecessary_null_comparison

    return UserModel(
      id: json["id"],
      name: json["name"],
      work: json["work"],
    );
  }
}

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  List<List<dynamic>> excelData = [];
  HashMap<int, List<dynamic>> myHashMap = HashMap<int, List<dynamic>>();
  List<String> uuidData = [];
  List<String> nameData = [];
  List<String> roleData = [];
  // TextEditingController illController = TextEditingController();
  // TextEditingController loseController = TextEditingController();
  // TextEditingController temController = TextEditingController();
  // TextEditingController BPController = TextEditingController();
  // TextEditingController heartController = TextEditingController();
  // TextEditingController DTXController = TextEditingController();
  // TextEditingController curseController = TextEditingController();
  // TextEditingController numController = TextEditingController();
  // TextEditingController handController = TextEditingController();
  // TextEditingController activeController = TextEditingController();
  // TextEditingController headController = TextEditingController();
  // TextEditingController ETCController = TextEditingController();
  dynamic dateData = null;
  ValueNotifier<String?> _selectedValueName = ValueNotifier<String?>(null);
  ValueNotifier<String?> _selectedValueUUID = ValueNotifier<String?>(null);
  String showUUID = "";
  String showName = "";
  String showRole = "";
  String showFactoryData = "ไม่ได้เลือก";
  String? realFactoryData;
  String? realUUID;
  String? realName;
  String? realRole;
  DateTime? realDate;
  TimeOfDay? realTime;
  String showDate = "";
  String showTime = "";
  bool _isUserToggled = false;
  HashMap<String, String> detailOPD = HashMap<String, String>();

  Future<void> loadExcelData(String text) async {
    List<List> data = await readExcelData(text);
    setState(() {
      excelData = data;
      data.asMap().forEach((key, value) => {
            myHashMap[key] = value,
            uuidData.add(value[0].toString()),
            nameData.add(value[1].toString()),
            roleData.add(value[2].toString()),
          });
    });
  }

  void handleUserToUUID(int data) {
    setState(() {
      _selectedValueUUID.value = uuidData[data];
      showUUID = uuidData[data];

      showName = nameData[data];

      showRole = roleData[data];
      realUUID = showUUID;
      realName = showName;
      realRole = showRole;
    });
  }

  void handleUUIDToUser(int data) {
    setState(() {
      _selectedValueName.value = nameData[data];
      showUUID = uuidData[data];
      showName = nameData[data];
      showRole = roleData[data];
      realUUID = showUUID;
      realName = showName;
      realRole = showRole;
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      dateData = args.value;
      log(dateData.toString());
    });
  }

  void _navigateToNextOPD(BuildContext context) {
    firstOPD myFirst = firstOPD(
        showUUID, showName, showRole, realDate, realTime, realFactoryData);

    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => OPDScreen(myFirst: myFirst)));
  }

  bool checkShowDialog() {
    firstOPD myFirst2 = firstOPD(
        showUUID, showName, showRole, realDate, realTime, realFactoryData);
    if (myFirst2.checkValid()) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ย้อนกลับ'),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // floatingActionButton: FloatingActionButton(
        //     child: Icon(Icons.refresh),
        //     onPressed: () async {
        //       await loadExcelData();
        //       //print(data);
        //     }),
        // body: LayoutBuilder(
        //   builder: (context, constraints) {
        //     double width = constraints.maxWidth;
        //     int count = (width / 200).floor();
        //     double spacing = (width - (200 * count)) / (count - 1);
        //     return Wrap(
        //       spacing: spacing,
        //       runSpacing: 16.0, // Set the cross-axis spacing
        //       children: List.generate(count, (index) {
        //         return Container(
        //           constraints: BoxConstraints(minWidth: 100),
        //           child: Container(
        //             color: Colors.amber,
        //             constraints: BoxConstraints(minWidth: 100),
        //             height: 200,
        //             child: Text(
        //               "Creating OPD",
        //               textAlign: TextAlign.left,
        //               style: TextStyle(fontSize: 46),
        //             ),
        //           ),
        //         );
        //       }),
        //     );
        //   },
        // ));

        body: Card(
            child: Wrap(runSpacing: 16.0, children: <Widget>[
          // Container(
          //     child: Column(children: [

          Container(
              color: Colors.amber,
              width: 600,
              child: Column(children: [
                Text(
                  "Creating OPD",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 46),
                ),
                Container(
                    color: Color.fromARGB(255, 225, 240, 255),
                    height: 100,
                    child: Row(children: [
                      Flexible(
                        child: Text("Selection User Data",
                            style: TextStyle(
                              fontSize: 30,
                            )),
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      Text("Factory : " + showFactoryData),
                      TextButton(
                          onPressed: (() => {
                                _showDataSelect(context),
                              }),
                          child: Text("Select Data"))
                    ])),
                Container(
                    color: Color.fromARGB(255, 255, 206, 206),
                    child: Row(children: [
                      Flexible(
                        child: Text(showUUID),
                      ),
                      Flexible(
                        child: Text(showName),
                      ),
                      Flexible(
                        child: Text(showRole),
                      )
                    ])),
                Row(children: [
                  Flexible(
                    flex: 1,
                    child: ValueListenableBuilder(
                      valueListenable: _selectedValueUUID,
                      builder: (context, value, child) {
                        return (Container(
                            alignment: Alignment.centerLeft,
                            child: Row(children: [
                              Expanded(
                                  child: Container(
                                      child: DropdownSearch<String>(
                                mode: Mode.MENU,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.5,
                                selectedItem: _selectedValueUUID.value,
                                showSelectedItems: true,
                                items: uuidData,
                                dropdownSearchDecoration: InputDecoration(
                                    labelText: "ID", hintText: "uuid"),
                                showSearchBox: true,
                                searchFieldProps:
                                    TextFieldProps(cursorColor: Colors.blue),
                                onChanged: (String? data) => {
                                  setState(() {
                                    _selectedValueUUID.value = data;
                                    handleUUIDToUser(uuidData.indexOf(data!));
                                  })
                                },
                              )))
                            ])));
                      },
                    ),
                  ),
                  Flexible(
                      flex: 2,
                      child: ValueListenableBuilder(
                          valueListenable: _selectedValueName,
                          builder: (context, value, child) {
                            return (Container(
                                alignment: Alignment.centerLeft,
                                child: Row(children: [
                                  Expanded(
                                      child: Container(
                                          child: DropdownSearch<String>(
                                    mode: Mode.MENU,
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.5,
                                    selectedItem: _selectedValueName.value,
                                    showSelectedItems: true,
                                    items: nameData,
                                    dropdownSearchDecoration: InputDecoration(
                                        labelText: "Name", hintText: "name"),
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                        cursorColor: Colors.blue),
                                    onChanged: (String? data) => {
                                      setState(() {
                                        _selectedValueName.value = data;
                                        handleUserToUUID(
                                            nameData.indexOf(data!));
                                      })
                                    },
                                  )))
                                ])));
                          }))
                ])
              ])),

          Container(
              width: 200,
              constraints: BoxConstraints(minWidth: 400),
              color: Color.fromARGB(255, 255, 201, 201),
              child: Column(
                children: [
                  Text(
                    "Appointment",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 46),
                  ),
                  Row(children: [
                    Column(children: [
                      Text(showDate),
                      ElevatedButton(
                          onPressed: () async {
                            DateTime? newDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100));
                            var nullSelect = newDate ?? DateTime.now();

                            setState(() => {
                                  showDate = DateFormat('dd-MM-yyyy')
                                      .format(nullSelect),
                                  realDate = nullSelect
                                });
                          },
                          child: Text("Select Date"))
                    ]),
                    Column(children: [
                      Text(showTime),
                      ElevatedButton(
                          onPressed: () async {
                            TimeOfDay? selectedTime = await showTimePicker(
                              initialTime: TimeOfDay.now(),
                              context: context,
                            );
                            var nullSelect = selectedTime ?? TimeOfDay.now();

                            setState(() => {
                                  showTime = nullSelect.toString(),
                                  realTime = nullSelect
                                });
                          },
                          child: Text("Select Date"))
                    ]),
                    ElevatedButton(
                        child: Text("Secondphase"),
                        onPressed: (() => {
                              if (checkShowDialog())
                                {_dialogBuilder(context)}
                              else
                                {_navigateToNextOPD(context)}
                            }))
                  ])
                ],
              ))
        ])));
  }
  // ])),
  //   Flexible(
  //       child: Container(
  //           color: Color.fromARGB(255, 225, 240, 255),
  //           height: 100,
  //           child: Row(children: [
  //             Flexible(
  //               child: Text("Selection User",
  //                   style: TextStyle(
  //                     fontSize: 30,
  //                   )),
  //             )
  //           ]))),
  //   Flexible(
  //       child: Container(
  //           color: Color.fromARGB(255, 255, 206, 206),
  //           child: Row(children: [
  //             Flexible(
  //               child: Text(showUUID),
  //             ),
  //             Flexible(
  //               child: Text(showName),
  //             ),
  //             Flexible(
  //               child: Text(showRole),
  //             ),
  //           ]))),
  //   Flexible(
  //       child: Row(children: [
  //     Flexible(
  //       flex: 1,
  //       child: ValueListenableBuilder(
  //         valueListenable: _selectedValueUUID,
  //         builder: (context, value, child) {
  //           return (Container(
  //               alignment: Alignment.centerLeft,
  //               child: Row(children: [
  //                 Expanded(
  //                     child: Container(
  //                         child: DropdownSearch<String>(
  //                   mode: Mode.MENU,
  //                   maxHeight:
  //                       MediaQuery.of(context).size.height * 0.5,
  //                   selectedItem: _selectedValueUUID.value,
  //                   showSelectedItems: true,
  //                   items: uuidData,
  //                   dropdownSearchDecoration: InputDecoration(
  //                       labelText: "ID", hintText: "uuid"),
  //                   showSearchBox: true,
  //                   searchFieldProps:
  //                       TextFieldProps(cursorColor: Colors.blue),
  //                   onChanged: (String? data) => {
  //                     setState(() {
  //                       _selectedValueUUID.value = data;
  //                       handleUUIDToUser(uuidData.indexOf(data!));
  //                     })
  //                   },
  //                 )))
  //               ])));
  //         },
  //       ),
  //     ),
  //     Flexible(
  //       flex: 2,
  //       child: ValueListenableBuilder(
  //         valueListenable: _selectedValueName,
  //         builder: (context, value, child) {
  //           return (Container(
  //               alignment: Alignment.centerLeft,
  //               child: Row(children: [
  //                 Expanded(
  //                     child: Container(
  //                         child: DropdownSearch<String>(
  //                   mode: Mode.MENU,
  //                   maxHeight:
  //                       MediaQuery.of(context).size.height * 0.5,
  //                   selectedItem: _selectedValueName.value,
  //                   showSelectedItems: true,
  //                   items: nameData,
  //                   dropdownSearchDecoration: InputDecoration(
  //                       labelText: "Name", hintText: "name"),
  //                   showSearchBox: true,
  //                   searchFieldProps:
  //                       TextFieldProps(cursorColor: Colors.blue),
  //                   onChanged: (String? data) => {
  //                     setState(() {
  //                       _selectedValueName.value = data;
  //                       handleUserToUUID(nameData.indexOf(data!));
  //                     })
  //                   },
  //                 )))
  //               ])));
  //         },
  //       ),
  //     )
  //   ])),
  // ])),

  // Container(
  //   child: SizedBox(
  //     child: VerticalDivider(
  //       thickness: 3.0,
  //       color: Colors.black,
  //     ),
  //   ),
  // ),

  // SizedBox(
  //   child: VerticalDivider(
  //     thickness: 3.0,
  //     color: Colors.black,
  //   ),
  // ),

  // Container(
  //     //            // child: AbsorbPotertrue,
  //     color: Colors.black,
  //     child: Row(children: [
  //       Column(children: [
  //         Text(
  //           "Appointment",
  //           style: TextStyle(fontSize: 46),
  //         ),
  //         Row(children: [
  //           Column(children: [
  //             Text(showDate),
  //             ElevatedButton(
  //                 onPressed: () async {
  //                   DateTime? newDate = await showDatePicker(
  //                       context: context,
  //                       initialDate: DateTime.now(),
  //                       firstDate: DateTime(1900),
  //                       lastDate: DateTime(2100));
  //                   var nullSelect = newDate ?? DateTime.now();

  //                   setState(() => {
  //                         showDate = DateFormat('dd-MM-yyyy')
  //                             .format(nullSelect),
  //                         realDate = nullSelect
  //                       });
  //                 },
  //                 child: Text("Select Date"))
  //           ]),
  //           Column(children: [
  //             Text(showTime),
  //             ElevatedButton(
  //                 onPressed: () async {
  //                   TimeOfDay? selectedTime = await showTimePicker(
  //                     initialTime: TimeOfDay.now(),
  //                     context: context,
  //                   );
  //                   var nullSelect =
  //                       selectedTime ?? TimeOfDay.now();

  //                   setState(() => {
  //                         showTime = nullSelect.toString(),
  //                         realTime = nullSelect
  //                       });
  //                 },
  //                 child: Text("Select Date"))
  //           ]),
  //           ElevatedButton(
  //               child: Text("Secondphase"),
  //               onPressed: (() => {
  //                     if (checkShowDialog())
  //                       {_dialogBuilder(context)}
  //                     else
  //                       {_navigateToNextOPD(context)}
  //                   }))
  //         ]
  //             //         ])))),
  //             ),
  //       ])
  //     ]))

  // Future<void> _dialogBuilder(BuildContext context) {
  //   return showDialog<void>(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Basic dialog title'),
  //           content: const Text(
  //             'A dialog is a type of modal window that\n'
  //             'appears in front of app content to\n'
  //             'provide critical information, or prompt\n'
  //             'for a decision to be made.',
  //           ),
  //           actions: <Widget>[
  //             TextButton(
  //               style: TextButton.styleFrom(
  //                 textStyle: Theme.of(context).textTheme.labelLarge,
  //               ),
  //               child: const Text('Disable'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //             TextButton(
  //               style: TextButton.styleFrom(
  //                 textStyle: Theme.of(context).textTheme.labelLarge,
  //               ),
  //               child: const Text('Enable'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       });
  // }

  Future<void> _showDataSelect(BuildContext context) async {
    // final manifestJson =
    //     await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    // final assetKeys = json
    //     .decode(manifestJson)
    //     .keys
    //     .where((String key) => key.startsWith('assets/'));
    // List<String> assetList = assetKeys.toList();
    // Map<String, dynamic> manifestMap = json.decode(data);
    // List<String> assetList = manifestMap.keys
    //     .where((String key) => key.startsWith('assets'))
    //     .toList();
    // print(assetList);
    // Directory directory = Directory(data + "\assets");
    // List<String> fileNames = [];
    // for (var file in assetList) {
    //   if (file is File) {
    //     fileNames.add(file.path.split('/').last);
    // String jsonString = await rootBundle.loadString('json/myFactory.json');
    // Map<String, dynamic> dataJson = json.decode(jsonString);

    // List<String> assetList = assetKeys.toList();
    await dotenv.load(fileName: ".env");

    String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";
    Directory directory = Directory(path.current + testEnv + "/assets");
    List<FileSystemEntity> filesDir = directory.listSync();
    List<String> assetKeys = [];
    File dataTest = File(path.current + testEnv + "/json/myFactory.json");
    final jsonString = await dataTest.readAsString();
    Map<String, dynamic> dataJson = json.decode(jsonString);

    for (var file in filesDir) {
      assetKeys.add(file.path
          .replaceAll(path.current, "")
          .replaceAll(testEnv, "")
          .substring(1)
          .replaceAll("\\", "/"));
    }
    List<String> assetList = assetKeys.toList();
    print(assetList);

    List<String> myName = [];
    for (var element in assetList) {
      String temp = element.split("/")[1].split("_")[0];
      myName.add(dataJson[temp]);
    }

    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Center(
              child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            title: Column(children: [
              Text(
                'เลือกข้อมูลที่ต้องการ',
                textAlign: TextAlign.start,
              ),
              SizedBox(
                height: 20,
              ),
              Divider(
                thickness: 2.0,
                color: Colors.black,
              )
            ]),
            content: Container(
              margin: EdgeInsets.only(bottom: 40),
              width: 500,
              padding: EdgeInsets.only(left: 20),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: assetKeys.length,
                itemBuilder: (context, index) {
                  return Wrap(children: [
                    Text("บริษัทชื่อ" + myName[index]),
                    SizedBox(
                      width: 20,
                    ),
                    Text("ไฟล์ชื่อ" + assetList[index]),
                    SizedBox(
                      width: 20,
                    ),
                    TextButton(
                        onPressed: (() => {
                              loadExcelData(assetList[index]),
                              setState(() {
                                showFactoryData = myName[index];
                                realFactoryData = index.toString();
                              }),
                              Navigator.pop(context)
                            }),
                        child: Text("เลือก"))
                  ]);
                },
              ),
            ),

            // content: Card(
            //     child: ListView.builder(
            //   itemCount: assetList.length,
            //   itemBuilder: (context, index) {
            //     return ListTile(
            //       title: Text(assetList[index]),
            //     );
            //   },
            // ))
          ));
        });
  }

  //             // content: ListView.builder(
  //             //     itemCount: items.length,
  //             //     itemBuilder: (context, index) {
  //             //       return ElevatedButton(
  //             //         onPressed: () {
  //             //           setState(() {
  //             //             // Toggle the selection state of the button
  //             //             selectedItems[index] = !selectedItems[index];
  //             //           });
  //             //         },
  //             //         style: ElevatedButton.styleFrom(
  //             //           primary: selectedItems[index] ? Colors.blue : Colors.grey,
  //             //           padding: EdgeInsets.all(16.0),
  //             //         ),
  //             //         child: Text(items[index]),
  //             //       );
  //             //     }),
  //             ));
  //   },
  // );

  Future<void> _dialogBuilder(BuildContext context) {
    firstOPD myFirst = firstOPD(
        realUUID, realName, realRole, realDate, realTime, realFactoryData);

    // return showDialog<void>(

    //     context: context,
    //     builder: (BuildContext context) {
    //       String textBody = "ข้อมูลที่ใส่ไม่ครบ";
    //       return AlertDialog(

    //           title: const Text('ใส่ข้อมูลไม่ครบ'),
    //           content: Column(
    //               children:
    //                   myFirst.checkAll().map((item) => Text(item)).toList()));
    //     });
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            title: Column(children: [
              Text(
                'ใส่ข้อมูลไม่ครบ',
                textAlign: TextAlign.start,
              ),
              SizedBox(
                height: 20,
              ),
              Divider(
                thickness: 2.0,
                color: Colors.black,
              )
            ]),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16), // Add some spacing if needed
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Column(
                      children: myFirst
                          .checkAll()
                          .map((item) => Text(
                                item,
                                style: TextStyle(fontSize: 20),
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 16), // Add some spacing if needed
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
// Container(
//     color: Colors.blueGrey,
//     child: Row(children: [
//       ValueListenableBuilder(
//         valueListenable: _selectedValueUUID,
//         builder: (context, value, child) {
//           return DropdownSearch<String>(
//             mode: Mode.MENU,
//             selectedItem: _selectedValueUUID.value,
//             showSelectedItems: true,
//             items: uuidData,
//             dropdownSearchDecoration: InputDecoration(
//                 labelText: "ID", hintText: "uuid"),
//             showSearchBox: true,
//             searchFieldProps:
//                 TextFieldProps(cursorColor: Colors.blue),
//             onChanged: (String? data) => {
//               setState(() {
//                 _selectedValueUUID.value = data;
//                 handleUUIDToUser(uuidData.indexOf(data!));
//               })
//             },
//           );
//         },
//       ),
//     ])),

// TextField(
//   controller: timeController,
//   keyboardType: TextInputType.datetime,
//   decoration: InputDecoration(
//     labelText: 'Time',
//     border: OutlineInputBorder(),
//   ),
// ),

// const SizedBox(height: 16.0),
// TextField(
//   controller: uuidController,
//   keyboardType: TextInputType.text,
//   decoration: InputDecoration(
//     labelText: 'UUID',
//     border: OutlineInputBorder(),
//   ),
// ),
// const SizedBox(height: 24.0),
// ElevatedButton(
//   onPressed: () {
//     String time = timeController.text;
//     String uuid = uuidController.text;
//     // Do something with the inputs, e.g., validate, process, etc.
//   },
//   child: Text('Submit'),
// ),
// ValueListenableBuilder(
//   valueListenable: _selectedValueUUID,
//   builder: (context, value, child) {
//     return DropdownSearch<String>(
//       mode: Mode.MENU,
//       selectedItem: _selectedValueUUID.value,
//       showSelectedItems: true,
//       items: uuidData,
//       dropdownSearchDecoration:
//           InputDecoration(labelText: "ID", hintText: "uuid"),
//       showSearchBox: true,
//       searchFieldProps:
//           TextFieldProps(cursorColor: Colors.blue),
//       onChanged: (String? data) => {
//         setState(() {
//           _selectedValueUUID.value = data;
//           handleUUIDToUser(uuidData.indexOf(data!));
//         })
//       },
//     );
//   },
// ),
// ValueListenableBuilder(
//   valueListenable: _selectedValueName,
//   builder: (context, value, child) {
//     return DropdownSearch<String>(
//       mode: Mode.MENU,
//       selectedItem: _selectedValueName.value,
//       showSelectedItems: true,
//       items: nameData,
//       dropdownSearchDecoration: InputDecoration(
//           labelText: "Name Surname", hintText: "ชื่อ"),
//       showSearchBox: true,
//       searchFieldProps:
//           TextFieldProps(cursorColor: Colors.blue),
//       onChanged: (String? data) => {
//         setState(() {
//           _selectedValueName.value = data;
//           handleUserToUUID(nameData.indexOf(data!));
//         })
//       },
//     );
//   },
