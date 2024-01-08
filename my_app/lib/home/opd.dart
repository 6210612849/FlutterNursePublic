import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_app/home/edit.dart';
import 'package:intl/intl.dart';
import 'package:my_app/home/noti.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:path/path.dart' as path;

class OPDScreen extends StatefulWidget {
  const OPDScreen({Key? key, required this.myFirst}) : super(key: key);

  final firstOPD myFirst;

  @override
  State<OPDScreen> createState() => _OPDScreenState();
}

class _OPDScreenState extends State<OPDScreen> {
  bool? isResume = false;
  bool? isSleep = false;
  bool? isSent = false;
  bool? isBackHome = false;

  TextEditingController illController = TextEditingController();
  TextEditingController loseController = TextEditingController();
  TextEditingController temController = TextEditingController();
  TextEditingController BPController = TextEditingController();
  TextEditingController heartController = TextEditingController();
  TextEditingController DTXController = TextEditingController();
  TextEditingController curseController = TextEditingController();
  TextEditingController numController = TextEditingController();
  TextEditingController handController = TextEditingController();
  TextEditingController activeController = TextEditingController();
  TextEditingController headController = TextEditingController();
  TextEditingController ETCController = TextEditingController();
  TextEditingController medController = TextEditingController();
  Map<String, dynamic> cursedChoice = Map<String, dynamic>();

  List<List<String>> ListMedController = [];
  TextEditingController numMedController = TextEditingController();
  late List<String> showPrev;
  late final firstOPD myFirst2;
  String? curseSelectedValue;
  String? med1SelectedValue;
  String? med2SelectedValue;
  List<String>? med2RealSelectedValue;
  @override
  void initState() {
    super.initState();
    myFirst2 = widget.myFirst;
    showPrev = [
      (myFirst2.uuid.toString()),
      myFirst2.name.toString(),
      myFirst2.date.toString(),
      myFirst2.time.toString()
    ];
  }

  List<TextEditingController> controllers =
      List.generate(9, (_) => TextEditingController());

  void resetOPD() {
    setState(() {
      illController = TextEditingController();
      loseController = TextEditingController();
      temController = TextEditingController();
      BPController = TextEditingController();
      heartController = TextEditingController();
      DTXController = TextEditingController();

      curseController = TextEditingController();
      curseSelectedValue = "";
      med1SelectedValue = "";
      med2SelectedValue = "";
      med2RealSelectedValue = [];

      // numController = TextEditingController();
      handController = TextEditingController();
      activeController = TextEditingController();
      headController = TextEditingController();
      ETCController = TextEditingController();
      medController = TextEditingController();
      isResume = false;
      isSleep = false;
      isSent = false;
      isBackHome = false;
    });
  }

  Future<bool> assetExists(String assetPath) async {
    try {
      // File(assetPath);
      return File(assetPath).exists();
    } catch (_) {
      print(_.toString());
      return false;
    }
  }

  Future<bool> editExits(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createExits(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getCurseJson() async {
    String jsonString = await rootBundle.loadString('json/myCursed.json');
    Map<String, dynamic> dataJson = json.decode(jsonString);
    return dataJson;
  }

  Future<Map<String, List<String>>> getMedJson() async {
    String jsonString = await rootBundle.loadString('json/myMed.json');
    Map<String, dynamic> dataJson = json.decode(jsonString);
    Map<String, List<String>> data = {};
    dataJson.forEach((key, value) {
      if (value is List) {
        data[key] = value.map((item) => item.toString()).toList();
      }
    });
    return data;
  }

  Future<void> createList(BuildContext context) async {
    try {
      final manifestJson =
          await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
      final assetKeys = json
          .decode(manifestJson)
          .keys
          .where((String key) => key.startsWith('history/'));
      List<String> assetList = assetKeys.toList();
      String timeName = DateFormat('dd-MM-yyyy').format(myFirst2.date!);
      await dotenv.load(fileName: ".env");
      String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";
      String checkExits = path.current +
          testEnv +
          "/" +
          'history/' +
          myFirst2.factory.toString() +
          "_" +
          timeName +
          ".csv";

      List<String> tempData = [
        myFirst2.uuid.toString(), //0
        myFirst2.name.toString(), //1
        myFirst2.role.toString(), //2
        myFirst2.time.toString(), //3
        illController.value.text.toString(), //4
        loseController.value.text.toString(), //5
        temController.value.text.toString(), //6
        BPController.value.text.toString(), //7
        heartController.value.text.toString(), //8
        DTXController.value.text.toString(), //9
        curseController.value.text.toString(), //10
        curseSelectedValue.toString(), //11
        handController.value.text.toString(), //12
        headController.value.text.toString(), //13
        ETCController.value.text.toString(), //14

        ListMedController.toString(), //15
        isResume.toString(), //16
        isSleep.toString(), //17
        isSent.toString(), //18
        isBackHome.toString(), //19
      ];
      String csv = const ListToCsvConverter().convert([tempData]);
      if (await assetExists(checkExits)) {
        File file = File(checkExits);
        String csvData = await file.readAsString();
        List<List<dynamic>> csvRows = CsvToListConverter().convert(csvData);
        print(csvRows.toString());
        csvRows.add(tempData);
        print(csvRows.toString());
        String updatedCSV = const ListToCsvConverter().convert(csvRows);
        file.writeAsStringSync(updatedCSV);
      } else {
        File file = File(checkExits);

        // Write the CSV data to the file
        file.writeAsStringSync(csv);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void createMedOPD(List<String> myList) {
    String tempMed = "";
    setState(() {
      ListMedController.add(myList);
      for (var element in ListMedController) {
        tempMed = tempMed + element.toString();
      }
      medController.text = tempMed;
    });
    print(ListMedController.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('กลับไป'),
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          Row(
            children: [
              SizedBox(
                child: Text(
                  "Creating OPD",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 46),
                ),
              )
            ],
          ),
          Column(children: [
            Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [for (var i in showPrev) Text(i)]),
            )
          ]),
          // Row(children: [
          //   const Column(children: [
          //     const SizedBox(
          //         height: 75,
          //         child: TextField(
          //           obscureText: true,
          //           decoration: InputDecoration(
          //             border: OutlineInputBorder(),
          //             labelText: 'Password',
          //           ),
          //         )),
          //     // TextField(
          //     //     style: TextStyle(
          //     //         fontSize: 40.0, height: 2.0, color: Colors.black),
          //     //     decoration: InputDecoration(
          //     //       border: OutlineInputBorder(),
          //     //       labelText: 'โรคประจำตัว',
          //     //     )),
          //     // TextField(
          //     //     style: TextStyle(
          //     //         fontSize: 40.0, height: 2.0, color: Colors.black),
          //     //     decoration: InputDecoration(
          //     //       border: OutlineInputBorder(),
          //     //       labelText: 'โรคประจำตัว',
          //     //     )),
          //   ]),
          //   // Column(children: []),
          //   // Column(children: []),
          // ]),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                // color: Colors.black,
                width: MediaQuery.of(context).size.width / 3,

                child: Column(children: [
                  Text(
                    "โรคประจำตัว",
                    style: TextStyle(fontSize: 25),
                  ),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                          autofocus: true,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          controller: illController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'เขียนรายละเอียดโรคประจำตัว',
                          ))),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "เเพ้ยา-อาหาร",
                    style: TextStyle(fontSize: 25),
                  ),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                          autofocus: true,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          controller: loseController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'เขียนรายละเอียดเเพ้ยา-อาหาร',
                          ))),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      child: Row(children: [
                    Expanded(
                        child: Row(children: [
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "อุณหภูมิ",
                          )),
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                  controller: temController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'C',
                                  ))))
                    ])),
                    Expanded(
                        child: Row(children: [
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Bloodpressure",
                          )),
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                  controller: BPController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'mm/HG',
                                  ))))
                    ])),
                  ])),
                  SizedBox(
                      child: Row(children: [
                    Expanded(
                        child: Row(children: [
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "ชีพจร",
                            textAlign: TextAlign.left,
                          )),
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                  controller: heartController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'ครั้ง/นาที',
                                  ))))
                    ])),
                    Expanded(
                        child: Row(children: [
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "ระดับน้ำตาล",
                          )),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            controller: DTXController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'DTX',
                            ),
                          ),
                        ),
                      )
                    ])),
                  ]))
                ]),
              ),
              Container(
                  // alignment: Alignment.topCenter,

                  // color: Colors.black54,
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "อาการเจ็บป่วย",
                          style: TextStyle(fontSize: 25),
                        ),
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                                autofocus: true,
                                keyboardType: TextInputType.multiline,
                                maxLines: 4,
                                controller: curseController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'เขียนรายละเอียดอาการเจ็ปป่วย',
                                ))),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "หัตถาการ",
                                )),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 6,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: handController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'ระบุการรักษา',
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                child: FutureBuilder<Map<String, dynamic>>(
                                    future: getCurseJson(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text(
                                            'Loading...'); // Display a loading message while waiting for the data
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        Map<String, dynamic> curseCount =
                                            snapshot.data ??
                                                Map<String, dynamic>();
                                        return Padding(
                                          padding: EdgeInsets.all(8.0),

                                          // child: TextField(
                                          //   keyboardType: TextInputType.number,
                                          //   controller: numController,
                                          //   decoration: InputDecoration(
                                          //     border: OutlineInputBorder(),
                                          //     labelText: 'รหัสโรค',
                                          //   ),
                                          // ),
                                          child: DropdownButton<String>(
                                            itemHeight: 100.0,
                                            iconSize: 24,
                                            elevation: 16,
                                            isExpanded: true,
                                            style: TextStyle(
                                                color: Colors.deepPurple,
                                                fontSize: 20.0),
                                            underline: Container(
                                              height: 2,
                                              color: Colors.deepPurpleAccent,
                                            ),
                                            value: curseSelectedValue,
                                            onChanged: (newValue) {
                                              setState(() {
                                                curseSelectedValue = newValue;
                                              });
                                            },
                                            items:
                                                curseCount.entries.map((entry) {
                                              return DropdownMenuItem<String>(
                                                value: entry.key,
                                                child: Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    height: 100,
                                                    child: Wrap(
                                                      children: [
                                                        Text(
                                                          entry.key,
                                                          style: TextStyle(
                                                            fontSize:
                                                                18, // Adjust the font size
                                                            color: Colors
                                                                .black, // Customize text color
                                                          ),
                                                        ),
                                                        Text(
                                                          entry.value,
                                                          style: TextStyle(
                                                            fontSize:
                                                                18, // Adjust the font size
                                                            color: Colors
                                                                .black, // Customize text color
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      }
                                    }))
                          ],
                        ),
                        Text(
                          "หมายเหตุ",
                          style: TextStyle(fontSize: 25),
                        ),
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                                autofocus: true,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                controller: ETCController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'ระบุหมายเหตุ',
                                ))),
                      ])),
              Expanded(
                  child: Column(
                children: [
                  Text(
                    "จ่ายยา",
                    style: TextStyle(fontSize: 25),
                  ),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                          autofocus: true,
                          readOnly: true,
                          keyboardType: TextInputType.multiline,
                          maxLines: 2,
                          controller: medController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'เขียนรายละเอียดการจ่ายยา',
                          ))),
                  FutureBuilder<Map<String, List<String>>>(
                      future: getMedJson(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SkeletonAnimation(
                            shimmerColor: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                            shimmerDuration: 1000,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: EdgeInsets.only(top: 40),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          Map<String, List<String>> medCount =
                              snapshot.data ?? Map<String, List<String>>();

                          return Row(children: [
                            SizedBox(
                                width: 100,
                                height: 100,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: DropdownButton<String>(
                                    itemHeight: 100.0,
                                    iconSize: 24,
                                    elevation: 16,
                                    isExpanded: true,
                                    style: TextStyle(
                                        color: Colors.deepPurple,
                                        fontSize: 20.0),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    value: med1SelectedValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        med1SelectedValue = newValue;
                                        med2RealSelectedValue =
                                            medCount[newValue]!;

                                        if (med2SelectedValue != null) {
                                          med2SelectedValue = null;
                                        }
                                      });
                                    },
                                    items: medCount.entries.map((entry) {
                                      return DropdownMenuItem<String>(
                                        value: entry.key,
                                        child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 100,
                                            child: Wrap(
                                              children: [
                                                Text(
                                                  entry.key,
                                                  style: TextStyle(
                                                    fontSize:
                                                        18, // Adjust the font size
                                                    color: Colors
                                                        .black, // Customize text color
                                                  ),
                                                ),
                                                // Text(
                                                //   entry.value,
                                                //   style: TextStyle(
                                                //     fontSize:
                                                //         18, // Adjust the font size
                                                //     color: Colors
                                                //         .black, // Customize text color
                                                //   ),
                                                // )
                                              ],
                                            )),
                                      );
                                    }).toList(),
                                  ),
                                )),
                            SizedBox(
                                width: 150,
                                height: 100,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: DropdownButton<String>(
                                    itemHeight: 100.0,
                                    iconSize: 24,
                                    elevation: 16,
                                    isExpanded: true,
                                    style: TextStyle(
                                        color: Colors.deepPurple,
                                        fontSize: 20.0),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    value: med2SelectedValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        med2SelectedValue = newValue;
                                      });
                                    },
                                    items: med2RealSelectedValue?.map((entry) {
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
                                                  fontSize:
                                                      18, // Adjust the font size
                                                  color: Colors
                                                      .black, // Customize text color
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: numMedController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Enter a number',
                                ),
                              ),
                            ),
                            Expanded(
                                child: Row(children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (med1SelectedValue != null &&
                                      med2SelectedValue != null &&
                                      numMedController.value.text != "") {
                                    createMedOPD([
                                      med1SelectedValue.toString(),
                                      med2SelectedValue.toString(),
                                      numMedController.value.text
                                    ]);
                                  }
                                },
                                child: Text('add'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    ListMedController = [];
                                    medController.text = "";
                                  });
                                },
                                child: Text('Reset'),
                              ),
                            ]))
                          ]);

                          // Padding(
                          //   padding: EdgeInsets.all(8.0),
                          //   child: DropdownButton<String>(
                          //     itemHeight: 100.0,
                          //     iconSize: 24,
                          //     elevation: 16,
                          //     isExpanded: true,
                          //     style: TextStyle(
                          //         color: Colors.deepPurple, fontSize: 20.0),
                          //     underline: Container(
                          //       height: 2,
                          //       color: Colors.deepPurpleAccent,
                          //     ),
                          //     value: med2SelectedValue,
                          //     onChanged: (newValue) {
                          //       setState(() {
                          //         med2SelectedValue = newValue;
                          //       });
                          //     },
                          //     items: medCount[med1SelectedValue]
                          //         ?.entries
                          //         .map((entry) {
                          //       return DropdownMenuItem<String>(
                          //         value: entry.key,
                          //         child: Container(
                          //             alignment: Alignment.centerLeft,
                          //             height: 100,
                          //             child: Wrap(
                          //               children: [
                          //                 Text(
                          //                   entry.key,
                          //                   style: TextStyle(
                          //                     fontSize:
                          //                         18, // Adjust the font size
                          //                     color: Colors
                          //                         .black, // Customize text color
                          //                   ),
                          //                 ),
                          //                 Text(
                          //                   entry.value,
                          //                   style: TextStyle(
                          //                     fontSize:
                          //                         18, // Adjust the font size
                          //                     color: Colors
                          //                         .black, // Customize text color
                          //                   ),
                          //                 )
                          //               ],
                          //             )),
                          //       );
                          //     }).toList(),
                          //   ),
                          // ),
                        }
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "หัวหน้างาน",
                    style: TextStyle(fontSize: 25),
                  ),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                          autofocus: true,
                          keyboardType: TextInputType.multiline,
                          maxLines: 2,
                          controller: headController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ชื่อหัวหน้างาน/ผู้รับผิดชอบ',
                          ))),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ทำงานได้"),
                        Checkbox(
                            value: isResume,
                            activeColor: Colors.green,
                            onChanged: (newbool) {
                              setState(() {
                                isResume = newbool;
                              });
                            }),
                        Text("นอนพัก"),
                        Checkbox(
                            value: isSleep,
                            activeColor: Colors.green,
                            onChanged: (newbool) {
                              setState(() {
                                isSleep = newbool;
                              });
                            }),
                        Text("ส่งต่อ"),
                        Checkbox(
                            value: isSent,
                            activeColor: Colors.green,
                            onChanged: (newbool) {
                              setState(() {
                                isSent = newbool;
                              });
                            }),
                        Text("กลับบ้าน"),
                        Checkbox(
                            value: isBackHome,
                            activeColor: Colors.green,
                            onChanged: (newbool) {
                              setState(() {
                                isBackHome = newbool;
                              });
                            }),
                      ]),
                ],
              ))
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
                child: Text("ยืนยัน"),
                onPressed: (() => {_ConfrimBuilder(context)})),
            ElevatedButton(
                child: Text("รีเซ็ท"), onPressed: (() => {resetOPD()}))
          ])
        ])));

    // child: Column(
    //   children: [
    //     // for (int i = 0; i < 2; i++)

    //     TextField(
    //         obscureText: true,
    //         decoration: InputDecoration(
    //           border: OutlineInputBorder(),
    //           labelText: 'Password',
    //         )),
    //   ],
    // ),

    // Column(
    //   children: [
    //     Text(widget.myFirst.uuid.toString()),
    //     Text(widget.myFirst.name.toString()),
    //     Text(widget.myFirst.role.toString()),
    //     Text(widget.myFirst.date.toString()),
    //     Text(widget.myFirst.time.toString()),
    //   ],
    // )
  }

  Future<void> _ConfrimBuilder(BuildContext context) {
    List<NotificationItem> notifications = [];
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          String textBody = "ข้อมูลที่ใส่ไม่ครบ";

          // Calculate the dialog's width and height based on the available screen size
          double dialogWidth = MediaQuery.of(context).size.width * 0.8;
          double dialogHeight = MediaQuery.of(context).size.height * 0.4;

          return Center(
            child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                // title: Column(children: [
                //   Text(
                //     'ใส่ข้อมูลไม่ครบ',
                //     textAlign: TextAlign.start,
                //   ),
                //   SizedBox(
                //     height: 20,
                //   ),
                //   Divider(
                //     thickness: 2.0,
                //     color: Colors.black,
                //   )
                // ]),
                content: Container(
                  // Figma Flutter Generator Frame5Widget - FRAME

                  // decoration: BoxDecoration(
                  //   color: Color.fromRGBO(255, 255, 255, 1),
                  //   borderRadius: BorderRadius.circular(10),
                  //   boxShadow: [
                  //     BoxShadow(
                  //         color: Color.fromARGB(255, 255, 7, 7),
                  //         spreadRadius: 3),
                  //   ],
                  // ),
                  child: Row(children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8 * 0.4,
                      height: MediaQuery.of(context).size.height * 0.7,
                      color: Colors.amber,
                      child: Column(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.8 *
                                  0.15),
                          Card(
                            child: FittedBox(
                                child: Text(
                              "Confrim",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 48),
                            )),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.8 *
                                  0.15),
                          Expanded(
                              child: Card(
                            margin: EdgeInsets.all(10.0),
                            child: Column(children: [
                              Text("ชื่อ" + myFirst2.name.toString()),
                              Text("หมาเลข" + myFirst2.uuid.toString()),
                              Text("Role" + myFirst2.role.toString()),
                              Text("วันที่" + myFirst2.date.toString()),
                              Text("เวลา" + myFirst2.time.toString()),
                            ]),
                          ))
                        ],
                      ),
                    ),
                    Expanded(
                        child: Container(
                            color: const Color.fromARGB(255, 44, 38, 18),
                            child: Row(
                              children: [
                                Card(
                                  child: Column(children: [
                                    Text("โรคประจำตัว" +
                                        myFirst2.name.toString()),
                                    Text(
                                        "เเพ้อาหาร" + myFirst2.uuid.toString()),
                                    Text("อุณห๓มิ" + myFirst2.role.toString()),
                                    Text("วันที่" + myFirst2.date.toString()),
                                    Text("เวลา" + myFirst2.time.toString()),
                                  ]),
                                ),
                                Card(
                                  child: Column(children: [
                                    Text("โรคประจำตัว" +
                                        myFirst2.name.toString()),
                                    Text(
                                        "เเพ้อาหาร" + myFirst2.uuid.toString()),
                                    Text("อุณห๓มิ" + myFirst2.role.toString()),
                                    Text("วันที่" + myFirst2.date.toString()),
                                    Text("เวลา" + myFirst2.time.toString()),
                                  ]),
                                )
                              ],
                            ))),
                    ElevatedButton(
                      onPressed: (() => {
                            createList(context),
                            notifications = [
                              NotificationItem(
                                friendName: 'John Doe',
                                gameName: 'Fortnite',
                                time: '3 minutes ago',
                              ),
                            ],
                            ListView.builder(
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                return AnimatedNotificationCard(
                                  notification: notifications[index],
                                  delay: Duration(milliseconds: 200 * index),
                                );
                              },
                            ),
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst)
                          }),
                      child: Text('Button'),
                    )
                  ]),
                )),
          );
        });
  }
}
