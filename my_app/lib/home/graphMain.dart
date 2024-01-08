import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_app/home/graphCustom.dart';
import 'package:my_app/home/graphOverview.dart';
import 'package:path/path.dart' as path;

class GraphMain extends StatefulWidget {
  @override
  _GraphMainState createState() => _GraphMainState();
}

class _GraphMainState extends State<GraphMain> {
  HashMap<int, List<dynamic>> myHashMap = HashMap<int, List<dynamic>>();

  List<String> opdData = [];
  String indexFatory = "";
  List<List<dynamic>> excelData = [];
  String showFactoryData = "ไม่ได้เลือก";
  String? realFactoryData;

  void _navigateToNextGraphOverview(
      BuildContext context, int myTemp, String? test) {
    List<String> filterOPD = [];
    DateTime now = DateTime.now().add(Duration(days: -1));
    // DateTime firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));

    DateTime? endOfWeek;
    List<String> cleanedFilePaths = opdData.map((filePath) {
      return filePath
          .replaceAll("history/" + indexFatory + "_", "")
          .replaceAll(".csv", "");
      ;
    }).toList();
    switch (myTemp) {
      case 1:
        {
          endOfWeek = now.subtract(Duration(days: 1));
        }
        break;
      case 2:
        {
          endOfWeek = now.subtract(Duration(days: now.weekday - 0));
        }
        break;
      case 3:
        {
          endOfWeek = DateTime(now.year, now.month, 1);
        }
        break;
      default:
        {
          endOfWeek = now.subtract(Duration(days: 1));
        }
        break;
    }

    for (var element in cleanedFilePaths) {
      DateTime dateTimeTemp = parseDateString(element);

      if (dateTimeTemp.isAfter(endOfWeek) &&
          dateTimeTemp.isBefore(DateTime.now())) {
        filterOPD.add("history/" + indexFatory + "_" + element + ".csv");
      }
    }
    print(filterOPD.toString());
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => GraphOverviewScreen(
              myPath: filterOPD,
              startDate: endOfWeek!,
              endDate: DateTime.now(),
            )));
  }

  DateTime parseDateString(String dateString) {
    List<String> dateComponents = dateString.split('-');
    int day = int.parse(dateComponents[0]);
    int month = int.parse(dateComponents[1]);
    int year = int.parse(dateComponents[2]);

    return DateTime(year, month, day, 0, 0, 0);
  }

  void _navigateToNextGraphCustom(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => GraphCustom()));
  }

  Future<void> loadOPDData(int text) async {
    await dotenv.load(fileName: ".env");
    // final manifestJson =
    //     await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    // final assetKeys = json
    //     .decode(manifestJson)
    //     .keys
    //     .where((String key) => key.startsWith('history/' + text.toString()));
    String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";
    Directory directory = Directory(path.current + testEnv + "/history");
    List<FileSystemEntity> filesDir = directory.listSync();
    List<String> assetKeys = [];
    for (var file in filesDir) {
      List<String> tempTest =
          file.path.replaceAll(path.current, "").split("\\");
      String fileName = tempTest.last;
      int underscoreIndex =
          fileName.indexOf('_'); // Find the index of underscore
      String numberPart = fileName.substring(0, underscoreIndex);
      if (numberPart == text.toString()) {
        assetKeys.add("history/" + fileName);
      }
    }

//  .replaceAll("history/" + indexFatory + "_", "")
//           .replaceAll(".csv", "");
//     List<String> opdList = assetKeys.toList();
    setState(() {
      opdData = assetKeys;
      indexFatory = text.toString();
    });
  }

  Future<List<List<dynamic>>> readExcelData(String pathExcel) async {
    // Replace 'assets/sample.xlsx' with the path to your Excel file
    final data = await rootBundle.loadString(pathExcel);

    List<List<dynamic>> _excelData = const CsvToListConverter().convert(data);

    return _excelData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Button App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Factory : " + showFactoryData),
            TextButton(
                onPressed: (() => {
                      _showDataSelect(context),
                    }),
                child: Text("Select Data")),
            ElevatedButton(
              onPressed: () {
                _navigateToNextGraphOverview(context, 1, null);
              },
              child: Text('วันนี้'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _navigateToNextGraphOverview(context, 2, null);
              },
              child: Text('สัปดาห์นี้'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _navigateToNextGraphOverview(context, 3, null);
              },
              child: Text('เดือนนี้'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _navigateToNextGraphCustom(context);
              },
              child: Text('Custom'),
            ),
          ],
        ),
      ),
    );
  }

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
                        onPressed: (() async {
                          List<String> tempIndex = assetList[index].split("/");
                          List<String> tempIndex2 = tempIndex.last.split("_");
                          loadOPDData(int.parse(tempIndex2.first));
                          setState(() {
                            showFactoryData = myName[index];
                            realFactoryData = index.toString();
                          });
                          Navigator.pop(context);
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
}
