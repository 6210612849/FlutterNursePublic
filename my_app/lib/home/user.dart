import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_app/home/viewUser.dart';

Future<List<List<dynamic>>> readExcelData(String myPath) async {
  // Replace 'assets/sample.xlsx' with the path to your Excel file
  // final data = await rootBundle.loadString(myPath);

  // List<List<dynamic>> _excelData = const CsvToListConverter().convert(data);

  String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";

  File dataTest = File(path.current + testEnv + "/" + myPath);

  String test = dataTest.readAsStringSync();

  List<List<dynamic>> _excelData = const CsvToListConverter().convert(test);

  return _excelData;
}

Future<List<List<dynamic>>> readExcelDataExtra(String myPath) async {
  // Replace 'assets/sample.xlsx' with the path to your Excel file
  // final data = await rootBundle.loadString(myPath);

  // List<List<dynamic>> _excelData = const CsvToListConverter().convert(data);

  File dataTest = File(path.current + "/" + myPath);

  String test = dataTest.readAsStringSync();

  List<List<dynamic>> _excelData = const CsvToListConverter().convert(test);

  return _excelData;
}

Future<String> readExcelSize(String myPath) async {
  // Replace 'assets/sample.xlsx' with the path to your Excel file
  // final data = await rootBundle.loadString(myPath);
  // final fileBytes = await File(myPath).readAsBytes();
  File dataTest = File(path.current + "/" + myPath);

  // String test = dataTest.readAsStringSync();

  // final ByteData assetData = await rootBundle.load(myPath);

  // Convert the ByteData to Uint8List
  // final Uint8List fileBytes = assetData.buffer.asUint8List();

  // return assetData.lengthInBytes.toString();
  return dataTest.lengthSync().toString();
}

class ExcelDataScreen extends StatefulWidget {
  const ExcelDataScreen({super.key});
  @override
  _ExcelDataScreenState createState() => _ExcelDataScreenState();
}

class _ExcelDataScreenState extends State<ExcelDataScreen> {
  List<List<dynamic>> excelData = [];
  List<String> fatoryData = [];
  List<String> fatoryName = [];
  List<String> fatoryCount = [];
  List<String> fatorySize = [];

  @override
  void initState() {
    loadExcelData();
    super.initState();
    // loadExcelData();
  }

  Future<void> loadExcelData() async {
    await dotenv.load(fileName: ".env");
    _showAllData();
  }

  Future<List<String>> calCountData(List<String> fatoryDataTemp) async {
    List<String> fatoryCount = [];
    String myLength = "0";
    for (var element in fatoryDataTemp) {
      try {
        List<List<dynamic>> temp = await readExcelDataExtra(element);
        myLength = temp.length.toString();
      } catch (e) {
        print("count" + e.toString());
      }
      fatoryCount.add(myLength.toString());
    }

    return fatoryCount;
    // setState(() {

    // });
  }

  Future<List<String>> calCountSize(List<String> fatoryDataTemp) async {
    List<String> fatorySize = [];
    String temp = "0";
    for (var element in fatoryDataTemp) {
      try {
        temp = await readExcelSize(element);
      } catch (e) {
        print("countSize" + e.toString());
      }
      fatorySize.add(temp.length.toString());
    }

    return fatorySize;
    // setState(() {

    // });
  }

  Future<void> _showAllData() async {
    final manifestJson =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    // final assetKeys = json
    //     .decode(manifestJson)
    //     .keys
    //     .where((String key) => key.startsWith('assets/'));
    String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";
    Directory directory = Directory(path.current + testEnv + "/assets");
    List<FileSystemEntity> filesDir = directory.listSync();
    List<String> assetKeys = [];
    for (var file in filesDir) {
      assetKeys.add(file.path
          .replaceAll(path.current, "")
          .substring(1)
          .replaceAll("\\", "/"));
    }

    // String jsonString = await rootBundle.loadString('json/myFactory.json');
    // Map<String, dynamic> dataJson = json.decode(jsonString);
    File dataTest = File(path.current + testEnv + "/json/myFactory.json");
    final jsonString = await dataTest.readAsString();
    Map<String, dynamic> dataJson = json.decode(jsonString);

    List<String> assetList = assetKeys.toList();

    List<String> myName = [];
    for (var element in assetList) {
      String fileName =
          element.split('/').last; // Get the file name ("4_data.csv")
      String numberPart = fileName.split('_').first;
      // print("test" + numberPart);
      // print(dataJson.entries.map((e) => e));
      myName.add(dataJson[numberPart]);
    }

    List<String> fatoryCountTemp = await calCountData(assetList);
    List<String> fatorySizeTemp = await calCountSize(assetList);
    setState(() {
      fatoryName = myName;
      fatoryData = assetList;
      fatoryCount = fatoryCountTemp;
      fatorySize = fatorySizeTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Excel Data'),
        ),
        body: SingleChildScrollView(
            child: fatorySize == []
                ? Center(
                    child: Text("Loading"),
                  )
                : Center(
                    child: Column(children: [
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      "ข้อมูลทั้งหมด ",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 46),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Table(
                      columnWidths: {
                        0: FixedColumnWidth(40.0),
                        1: FixedColumnWidth(300.0),
                        2: FixedColumnWidth(200.0),
                        3: FixedColumnWidth(100.0),
                        4: FixedColumnWidth(100.0),
                        5: FixedColumnWidth(100.0),
                      },
                      border: TableBorder.all(width: 1.0),
                      children: fatoryData.asMap().entries.map((entry) {
                        int index = entry.key;
                        String value = entry.value;

                        return TableRow(
                          children: [
                            TableCell(child: Text('$index')),
                            TableCell(child: Text(fatoryName[index])),
                            TableCell(child: Text(value)),
                            TableCell(child: Text(fatoryCount[index] + "คน")),
                            TableCell(child: Text(fatorySize[index] + "mb")),
                            TableCell(
                                child: ElevatedButton(
                              onPressed: () async {
                                String testEnv = dotenv.env['historyPath'] ??
                                    "/data/flutter_assets";
                                List<List<dynamic>> temp =
                                    await readExcelDataExtra(fatoryData[index]);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => viewUser(
                                          tableData: temp,
                                          tableName: fatoryName[index],
                                          tablePath:
                                              value.replaceAll(testEnv, ""),
                                          factoryIndex: index.toString(),
                                        )));
                              },
                              child: Text('Button'),
                            ))
                          ],
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          try {
                            String testEnv = dotenv.env['historyPath'] ??
                                "/data/flutter_assets";

                            String factoryNameTemp =
                                await _showAddFactory(context);

                            if (factoryNameTemp != "") {
                              File dataTest2 = File(path.current +
                                  testEnv +
                                  "/json/myFactory.json");
                              final jsonString2 =
                                  await dataTest2.readAsString();

                              Map<String, dynamic> dataJson2 =
                                  json.decode(jsonString2);
                              String nextString = (dataJson2.length).toString();
                              dataJson2[nextString] = factoryNameTemp;

                              String jsonData = jsonEncode(dataJson2);
                              await dataTest2.writeAsString(jsonData);

                              File dataTest3 = File(path.current +
                                  testEnv +
                                  "/assets/" +
                                  nextString +
                                  "_data.csv");
                              final csvFile3 = ListToCsvConverter()
                                  .convert([]); // Pass an empty list
                              await dataTest3.writeAsString(csvFile3);
                              await loadExcelData();
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Text("เพิ่มโรงงาน"))
                  ]))));
  }

  Future<String> _showAddFactory(BuildContext context) async {
    Completer<String> completer = Completer<String>();

    TextEditingController myName = TextEditingController();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('สร้างข้อมูลโรงงาน'),
          content: Container(
            width: 500,
            height: 500,
            child: Column(
              children: [
                Text(
                  "ชื่อบริษัท",
                  style: TextStyle(fontSize: 36),
                ),
                TextField(
                  controller: myName,
                  decoration: InputDecoration(hintText: "ใส่ชื่อบริษัท"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                completer.complete(""); // Complete with false
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                completer.complete(myName.text); // Complete with true
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );

    return completer.future;
  }
  // List<TableRow> _buildTableRows() {
  //   return fatoryData.asMap().entries.map((entry) {
  //     int index = entry.key;
  //     String value = entry.value;

  //     return TableRow(
  //       children: [
  //         TableCell(child: Text('$index')),
  //         TableCell(child: Text(fatoryName[index])),
  //         // TableCell(child: Text(fatoryCount[0])),
  //         TableCell(child: Text("1")),
  //         TableCell(
  //             child: ElevatedButton(
  //           onPressed: () {
  //             // Button action here
  //           },
  //           child: Text('Button'),
  //         ))
  //       ],
  //     );
  //   }).toList();
  // }
}
