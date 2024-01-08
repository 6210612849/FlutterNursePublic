import 'dart:convert';
import 'dart:ffi';

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GraphOverviewScreen extends StatefulWidget {
  final List<String> myPath;
  final DateTime startDate;
  final DateTime endDate;
  const GraphOverviewScreen(
      {Key? key,
      required this.myPath,
      required this.startDate,
      required this.endDate})
      : super(key: key);

  @override
  _GraphOverviewScreenState createState() => _GraphOverviewScreenState();
}

class _GraphOverviewScreenState extends State<GraphOverviewScreen> {
  List<String> handList = [];
  List<String> timeList = [];
  List<TimeSeriesData> data = [];
  List<RoleSeriesData> dataRole = [];
  Map<String, double> SexPercentageData = {};
  int realManCount = 0;
  int realWomanCount = 0;
  int realCountOPD = 0;
  late List<String> testTest;
  UserSeriesUsageData? realTopUsaged =
      UserSeriesUsageData("ยังไม่คำนวน", "ยังไม่คำนวน", 0);
  List<MedicineSeriesData> dataMedicine = [];
  List<TypeMedicineSeriesData> dataTypeMedicine = [];
  List<NumCurseSeriesData>? dataNumCurse;
  @override
  void initState() {
    setOPDData();
    super.initState();
    // data = generateSampleData();
  }

  Future<List<TimeSeriesData>> convertToTimeOfDayDataList() async {
    List<TimeSeriesData> testTemp = [];
    await dotenv.load(fileName: ".env");
    List<String> tempTimeList = [];
    int countTest = 0;
    for (var element in widget.myPath) {
      String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";
      File dataTest = File(path.current + testEnv + "/" + element);
      String test = dataTest.readAsStringSync();
      List<List<dynamic>> _excelData = const CsvToListConverter().convert(test);
      for (var element1 in _excelData) {
        countTest = countTest + 1;

        tempTimeList.add(element1[3]);
      }
    }

    tempTimeList.forEach((e) {
      final match = RegExp(r'(\d+):(\d+)').firstMatch(e);
      final hour = int.parse(match!.group(1)!);
      final minute = int.parse(match.group(2)!);
      final timeOfDay = TimeOfDay(hour: hour, minute: minute);
      final timeDouble = timeOfDayToMinutesSinceMidnight(timeOfDay);

      var matchingIndex = testTemp.indexWhere(
        (element) => element.minutesSinceMidnight == timeDouble.toInt(),
      );

      if (matchingIndex != -1) {
        testTemp[matchingIndex].value += 1.0; // Add the value
      } else {
        testTemp.add(TimeSeriesData(timeDouble.toInt(), 1.0)); // Add a new item
      }
    });

    testTemp.sort(
      (a, b) => a.minutesSinceMidnight.compareTo(b.minutesSinceMidnight),
    );
    // setState(() {
    //   testTest = testTemp;
    //   print(testTest.toString());
    // });

    return testTemp;
  }

  double timeOfDayToDouble(TimeOfDay timeOfDay) {
    return timeOfDay.hour + timeOfDay.minute / 60.0;
  }

  void calSexCount(String temp) {
    String dataTemp = temp.substring(0, 3);
    if (dataTemp == "นาย") {
      setState(() {
        realManCount = realManCount + 1;
      });
    } else {
      setState(() {
        realWomanCount = realWomanCount + 1;
      });
    }
  }

  Future<void> testObject() async {
    // Directory appDocumentsDirectory =
    // await getApplicationDocumentsDirectory();
    // final Directory appDocumentsPath = await getTemporaryDirectory();
    // List<String> roleCheck = [];
    // File dataTest = File(path.current + "/" + 'assets/0_data.csv');
    // final file = File(path.current + "/" + 'json/my_Role.json');
    // String test = dataTest.readAsStringSync();
    // List<List<dynamic>> _excelData = const CsvToListConverter().convert(test);
    // for (var element1 in _excelData) {
    //   if (!roleCheck.contains(element1[2].toString())) {
    //     roleCheck.add(element1[2].toString());
    //   }
    // }
    // roleCheck.sort((a, b) => a.compareTo(b));
    // print("object hase length" + roleCheck.length.toString());
    // for (var element in roleCheck) {
    //   print(element.toString());
    // }
    // String jsonString = jsonEncode(roleCheck);
    // await file.writeAsString(jsonString);

    // List<MedicineSeriesData> tempMedData = await setMedCount(testTest);
  }

  Future<List<NumCurseSeriesData>> setNumCurseCount(
      List<dynamic> rawData) async {
    List<NumCurseSeriesData> tempNumCurse = [];
    int countNumCuresed = 0;
    int countNumUnknowCuresed = 0;
    await dotenv.load(fileName: ".env");
    String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";

    File dataTest = File(path.current + testEnv + "/json/myCursed.json");
    String test = dataTest.readAsStringSync();
    Map<dynamic, dynamic> numCursdeData =
        Map<dynamic, dynamic>.from(jsonDecode(test));
    for (var element in rawData) {
      countNumUnknowCuresed++;
      String input = element[11].toString();

      if (numCursdeData.containsKey(input)) {
        countNumCuresed = countNumCuresed + 1;

        var matchingIndex =
            tempNumCurse.indexWhere((element) => element.name == input);

        if (matchingIndex != -1) {
          tempNumCurse[matchingIndex].count += 1;
          tempNumCurse[matchingIndex].value += 1.0; // Add the value
        } else {
          tempNumCurse.add(NumCurseSeriesData(
              input, numCursdeData[input].toString(), 1.0, 1));
        }
      }
    }
    tempNumCurse.sort((a, b) => b.count.compareTo(a.count));

    List<NumCurseSeriesData> tempNumCurseSorted = [];
    int maxCount = 10; // Set the maximum count of elements you want to include
    int inNumCurseCount = 0;

    for (var i = 0; i < tempNumCurse.length && i < maxCount; i++) {
      inNumCurseCount++;

      tempNumCurseSorted.add(NumCurseSeriesData(
          tempNumCurse[i].name,
          tempNumCurse[i].fullname,
          tempNumCurse[i].value / countNumCuresed * 100,
          tempNumCurse[i].count));
    }

    if (countNumCuresed - inNumCurseCount != 0) {
      tempNumCurseSorted.add(NumCurseSeriesData(
          "อื่นๆ",
          "โรคอื่นๆ",
          (countNumCuresed - inNumCurseCount) / countNumCuresed * 100,
          countNumCuresed - inNumCurseCount));
    }

    // for (var element in tempNumCurseSorted) {
    //   print(element.name +
    //       element.fullname +
    //       "      " +
    //       element.value.toString() +
    //       "      " +
    //       element.count.toString());
    // }

    return tempNumCurseSorted;
  }

  Future<AllMedicineSeriesData> setMedCount(List<dynamic> rawData) async {
    List<MedicineSeriesData> tempMed = [];
    List<TypeMedicineSeriesData> tempTypeMed = [];
    await dotenv.load(fileName: ".env");
    String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";

    File dataTest = File(path.current + testEnv + "/json/myMed.json");
    String test = dataTest.readAsStringSync();
    Map<dynamic, List<dynamic>> medData =
        Map<dynamic, List<dynamic>>.from(jsonDecode(test));
    List<String> medRawData = [];
    int countMed = 0;
    int countOPD = 0;
    for (var element in rawData) {
      String input = element[15].toString();

      try {
        List<List<String>> resultList = [];

        List<String> elements =
            input.substring(1, input.length - 1).split(', ');

        for (var i = 0; i < elements.length; i += 3) {
          List<String> sublist = elements.sublist(i, i + 3);
          resultList.add(sublist);
        }

        for (var element1 in resultList) {
          element1[0] = element1[0].substring(1);

          String checkName = element1[1];
          String checkNameType = element1[0];

          String checkStrValue =
              element1[2].substring(0, element1[2].length - 1);
          int checkValue = int.parse(checkStrValue);
          if (medData.containsKey(element1[0].toString()) &&
              medData[element1[0].toString()] != null) {
            countMed = countMed + checkValue;
            countOPD = countOPD + 1;
            var matchingIndex =
                tempMed.indexWhere((element) => element.name == checkName);

            if (matchingIndex != -1) {
              tempMed[matchingIndex].opdUsaged += 1;
              tempMed[matchingIndex].usage += checkValue; // Add the value
            } else {
              tempMed.add(MedicineSeriesData(checkName, 1, checkValue, 1.0,
                  checkValue.toDouble())); // Add a new item
            }

            var matchingIndex2 = tempTypeMed
                .indexWhere((element) => element.name == checkNameType);

            if (matchingIndex2 != -1) {
              tempTypeMed[matchingIndex2].opdUsaged += 1;
              tempTypeMed[matchingIndex2].usage += checkValue;
            } else {
              tempTypeMed.add(TypeMedicineSeriesData(checkNameType, 1,
                  checkValue, 1.0, checkValue.toDouble())); // Add a new item
            }
          }
        }
      } catch (e) {}
    }

    tempMed.sort((a, b) => b.usage.compareTo(a.usage));

    tempTypeMed.sort((a, b) => b.usage.compareTo(a.usage));
    List<MedicineSeriesData> tempMedSorted = [];
    List<TypeMedicineSeriesData> tempTypeMedSorted = [];
    int maxCount = 5; // Set the maximum count of elements you want to include
    int inMedCount = 0;
    int inMedOPDCount = 0;
    for (var i = 0; i < tempMed.length && i < maxCount; i++) {
      inMedCount = inMedCount + tempMed[i].usage.toInt();
      inMedOPDCount = inMedOPDCount + tempMed[i].opdUsaged.toInt();
      tempMedSorted.add(MedicineSeriesData(
          tempMed[i].name,
          tempMed[i].opdUsaged,
          tempMed[i].usage,
          tempMed[i].opdUsaged / countOPD * 100,
          tempMed[i].usage / countMed * 100));
    }
    tempMedSorted.add(MedicineSeriesData(
        "อื่นๆ",
        countOPD - inMedOPDCount,
        countMed - inMedCount,
        (countOPD - inMedOPDCount) / countMed * 100,
        (countMed - inMedCount) / countMed * 100));

    for (var element in tempTypeMed) {
      tempTypeMedSorted.add(TypeMedicineSeriesData(
          element.name,
          element.opdUsaged,
          element.usage,
          element.opdUsaged / countOPD * 100,
          element.usage / countMed * 100));
    }

    return AllMedicineSeriesData(tempMedSorted, tempTypeMedSorted);
  }

  Future<List<RoleSeriesData>> setRoleCount(List<dynamic> rawData) async {
    await dotenv.load(fileName: ".env");
    String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";

    File dataTest = File(path.current + testEnv + "/json/myRole.json");
    List<RoleSeriesData> tempRole = [];
    String test = dataTest.readAsStringSync();
    List<String> roleData = List<String>.from(jsonDecode(test));
    List<String> roleRawData = [];
    int countRole = 0;
    for (var element in rawData) {
      roleRawData.add(element[2]);
      countRole++;
    }
    roleRawData.forEach((element) {
      final checkName = element;

      var matchingIndex =
          tempRole.indexWhere((element) => element.name == checkName);

      if (matchingIndex != -1) {
        tempRole[matchingIndex].value += 1.0;
        tempRole[matchingIndex].rawCount += 1; // Add the value
      } else {
        tempRole.add(RoleSeriesData(checkName, 1.0, 1)); // Add a new item
      }
    });
    List<RoleSeriesData> tempRoleSorted = [];

    tempRole.sort((a, b) => b.value.compareTo(a.value));

    int maxCount = 5; // Set the maximum count of elements you want to include
    int inRoleCount = 0;
    for (var i = 0; i < tempRole.length && i < maxCount; i++) {
      inRoleCount = inRoleCount + tempRole[i].value.toInt();

      tempRoleSorted.add(RoleSeriesData(tempRole[i].name,
          tempRole[i].value / countRole * 100, tempRole[i].rawCount));
    }

    tempRoleSorted.add(RoleSeriesData("อื่นๆ",
        (countRole - inRoleCount) / countRole * 100, countRole - inRoleCount));
    return tempRoleSorted;
  }

  Future<void> setOPDData() async {
    try {
      List<TimeSeriesData> testTemp = [];
      List<dynamic> rawData = [];
      List<String> tempTimeList = [];
      List<String> tempHandList = [];
      int countOPD = 0;
      List<String> tempTopUsageList = [];
      List<String> tempTopUsageListUUID = [];
      for (var element in widget.myPath) {
        await dotenv.load(fileName: ".env");
        String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";
        File dataTest = File(path.current + testEnv + "/" + element);
        String test = dataTest.readAsStringSync();
        List<List<dynamic>> _excelData =
            const CsvToListConverter().convert(test);
        for (var element1 in _excelData) {
          rawData.add(element1);
          countOPD = countOPD + 1;
          tempHandList.add(element1[12].toString());
          tempTimeList.add(element1[3]);
          tempTopUsageList.add(element1[1].toString());
          tempTopUsageListUUID.add(element1[0].toString());
          calSexCount(element1[1].toString());
        }
      }
      List<RoleSeriesData> tempRoleData = await setRoleCount(rawData);
      AllMedicineSeriesData tempAllMedData = await setMedCount(rawData);
      List<NumCurseSeriesData> tempNumCurseData =
          await setNumCurseCount(rawData);
      List<MedicineSeriesData> tempMedicineData = tempAllMedData.num1;
      List<TypeMedicineSeriesData> tempTypeMedicineData = tempAllMedData.num2;

      tempMedicineData.sort((a, b) => b.usage.compareTo(a.usage));
      tempTypeMedicineData.sort((a, b) => b.usage.compareTo(a.usage));

      tempTimeList.forEach((e) {
        final match = RegExp(r'(\d+):(\d+)').firstMatch(e);
        final hour = int.parse(match!.group(1)!);
        final minute = int.parse(match.group(2)!);
        final timeOfDay = TimeOfDay(hour: hour, minute: minute);
        final timeDouble = timeOfDayToMinutesSinceMidnight(timeOfDay);

        var matchingIndex = testTemp.indexWhere(
          (element) => element.minutesSinceMidnight == timeDouble.toInt(),
        );

        if (matchingIndex != -1) {
          testTemp[matchingIndex].value += 1.0; // Add the value
        } else {
          testTemp
              .add(TimeSeriesData(timeDouble.toInt(), 1.0)); // Add a new item
        }
      });

      testTemp.sort(
        (a, b) => a.minutesSinceMidnight.compareTo(b.minutesSinceMidnight),
      );

      List<UserSeriesUsageData> tempTopUsageReal = [];

      tempTopUsageList.forEach((element) {
        int index = tempTopUsageList.indexOf(element);
        final checkUser = element;
        final checkUUID = tempTopUsageListUUID[index];
        var matchingIndex =
            tempTopUsageReal.indexWhere((element) => element.name == checkUser);

        if (matchingIndex != -1) {
          tempTopUsageReal[matchingIndex].value += 1.0; // Add the value
        } else {
          tempTopUsageReal.add(
              UserSeriesUsageData(checkUUID, checkUser, 1.0)); // Add a new item
        }
      });
      if (tempTopUsageReal.length == 0) {
        setState(() {
          realTopUsaged = null;
        });
      }

      // setState(() {
      //   testTest = testTemp;
      //   print(testTest.toString());
      // });
      else {
        tempTopUsageReal.sort((a, b) => b.value.compareTo(a.value));
        setState(() {
          realCountOPD = countOPD;
          handList = tempHandList;
          data = testTemp;

          dataRole = tempRoleData;
          realTopUsaged = tempTopUsageReal[0];
          dataMedicine = tempMedicineData;
          dataTypeMedicine = tempTypeMedicineData;
          dataNumCurse = tempNumCurseData;
          SexPercentageData = {
            'Male':
                realManCount / (realManCount + realWomanCount).toDouble() * 100,
            'Female': (1 - realManCount / (realManCount + realWomanCount))
                    .toDouble() *
                100
          };
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // List<TimeSeriesData> generateSampleData() {
  //   return [
  //     TimeSeriesData(0, 5.0),
  //     TimeSeriesData(270, 12.0),
  //     TimeSeriesData(540, 8.0),
  //     TimeSeriesData(720, 15.0),
  //     TimeSeriesData(990, 7.0),
  //     TimeSeriesData(1200, 10.0),
  //     TimeSeriesData(1440, 3.0),
  //   ];
  // }

  int timeOfDayToMinutesSinceMidnight(TimeOfDay timeOfDay) {
    // return timeOfDay.hour * 60 + timeOfDay.minute;
    return timeOfDay.hour * 60;
  }

  TimeOfDay minutesSinceMidnightToTimeOfDay(int minutesSinceMidnight) {
    final hours = minutesSinceMidnight ~/ 60;
    final minutes = minutesSinceMidnight % 60;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grap Overview'),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          // Add your button click logic here
          testObject();
        },
        child: Text('Button'),
      ),
      body: ListView(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ระยะเวลาตั้งเเต่ " +
                    widget.startDate.toString() +
                    " ถึง " +
                    widget.endDate.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32),
              ),
              Wrap(
                children: [
                  Container(
                    width: 500,
                    height: 400,
                    color: Colors.blue,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              child: SizedBox(
                            child: Text(
                              "General",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 32),
                            ),
                          )),
                          Container(
                              child: SizedBox(
                            child: Text(
                              "จำนวนรายการ :" +
                                  realCountOPD.toString() +
                                  " รายการ",
                              style: TextStyle(fontSize: 24),
                            ),
                          )),
                          Container(
                            color: Color.fromARGB(255, 208, 207, 255),
                            margin: EdgeInsets.all(10.0),
                            height: 300,
                            child: LineChart(
                              LineChartData(
                                borderData: FlBorderData(show: true),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: SideTitles(
                                    showTitles: true,
                                    margin: 0,
                                    getTitles: (value) {
                                      // Convert value back to minutes since midnight
                                      final minutesSinceMidnight =
                                          (value * 60).toInt();
                                      final timeOfDay =
                                          minutesSinceMidnightToTimeOfDay(
                                              minutesSinceMidnight);
                                      return timeOfDay.format(
                                          context); // Format the TimeOfDay label
                                    },
                                  ),
                                ),
                                gridData: FlGridData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: data
                                        .map((entry) => FlSpot(
                                            entry.minutesSinceMidnight
                                                    .toDouble() /
                                                60,
                                            entry.value.toDouble()))
                                        .toList(),
                                    isCurved: true,
                                    colors: [
                                      const Color.fromARGB(255, 0, 0, 0)
                                    ],
                                    dotData: FlDotData(show: false),
                                  ),
                                ],
                                minX: 0,
                                maxX: 24,
                                minY: 0,
                              ),
                            ),
                          )
                        ]),
                  ),
                  HoverableContainer(
                    hoverColor: Colors.red,
                    child: Container(
                      width: 150,
                      height: 400,
                      color: Color.fromARGB(255, 154, 3, 242),
                      child: Center(
                        child: Text(
                          'คลิ๊กเพื่อเเสดงผลมากชึ้น',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Container(
                    color: Colors.green,
                    width: 500,
                    height: 400,
                    child: dataNumCurse == null
                        ? Center(
                            child: Text("Loading"),
                          )
                        : Container(
                            child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: SideTitles(
                                  showTitles: true,
                                  getTitles: (value) {
                                    if (dataNumCurse != null) {
                                      String test =
                                          dataNumCurse![value.toInt()].fullname;
                                      List<String> parts = test.split(",");
                                      String result =
                                          parts.isNotEmpty ? parts[0] : test;
                                      return result;
                                    }
                                    return "ไม่เเสดง";
                                    // return 'ไม่แสดง';
                                  },
                                ),
                              ),
                              maxY: 120.0,
                              borderData: FlBorderData(show: false),
                              barGroups: dataNumCurse!
                                  .asMap()
                                  .entries
                                  .map(
                                    (data) => BarChartGroupData(
                                      x: data.key,
                                      barRods: [
                                        BarChartRodData(
                                            y: double.parse(data.value.value
                                                .toStringAsFixed(2)),
                                            width: 22,
                                            colors: [Colors.black],
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            )),
                                      ],
                                    ),
                                  )
                                  .toList(),

                              // barGroups: dataNumCurse.asMap().entries.map((entry) {
                              //   final index = entry.key;
                              //   final value =
                              //       double.parse(entry.value.value.toStringAsFixed(2));

                              //   return BarChartGroupData(
                              //     x: index,
                              //     barRods: [
                              //       BarChartRodData(
                              //         y: value,
                              //         colors: [Colors.blue],
                              //       ),
                              //       // Add more BarChartRodData objects here
                              //       BarChartRodData(
                              //         y: value,
                              //         colors: [Colors.red],
                              //       ),
                              //     ],
                              //   );
                              // }).toList(),

                              // barGroups: dataNumCurse.asMap().entries.map((entry) {
                              //   final index = entry.key;
                              //   final value = double.tryParse(
                              //           entry.value.value.toStringAsFixed(2)) ??
                              //       0.0;

                              //   return BarChartGroupData(x: index, barRods: [
                              //     BarChartRodData(y: value, colors: [Colors.blue]),
                              //   ]);
                              // }).toList(),
                            ),
                          )),
                  ),
                  HoverableContainer(
                    hoverColor: Colors.red,
                    child: Container(
                      width: 150,
                      height: 400,
                      color: Color.fromARGB(255, 154, 3, 242),
                      child: Center(
                        child: Text(
                          'คลิ๊กเพื่อเเสดงผลมากชึ้น',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Wrap(
                children: [
                  Container(
                      color: Colors.orange,
                      width: 500,
                      height: 400,
                      child: Column(children: [
                        Container(
                            child: (realTopUsaged == null)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                        Text(
                                          "คนไข้",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(fontSize: 32),
                                        ),
                                        Text(
                                          "ผู้ใช้มากที่สุด :ไม่มีข้อมูล ",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ])
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                        Text(
                                          "คนไข้",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(fontSize: 32),
                                        ),
                                        Text(
                                          "ผู้ใช้มากที่สุด" +
                                              realTopUsaged!.uuid +
                                              ":" +
                                              realTopUsaged!.name +
                                              " จำนวน" +
                                              realTopUsaged!.value.toString() +
                                              " ครั้ง",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ])),
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                            child: Row(children: [
                          Expanded(
                              flex: 1,
                              child: Column(children: [
                                Text(
                                  "สัดส่วนช่าย-หญิง",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 24),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                AspectRatio(
                                  aspectRatio: 1.4,
                                  child: PieChart(
                                    PieChartData(
                                      sections: SexPercentageData.entries
                                          .map((entry) => PieChartSectionData(
                                                value: entry.value,
                                                title:
                                                    '${entry.key}\n${entry.value.toStringAsFixed(1)}%',
                                                color: Color(int.parse(
                                                    '0xFF${Colors.accents[SexPercentageData.keys.toList().indexOf(entry.key) % Colors.accents.length].value.toRadixString(16).padLeft(6, '0')}')),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                )
                              ])),
                          Expanded(
                              flex: 1,
                              child: Column(children: [
                                Text(
                                  "สัดส่วนตามตำเเหน่ง",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 24),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                AspectRatio(
                                    aspectRatio: 1.4,
                                    child: PieChart(PieChartData(
                                      sections: dataRole
                                          .map((entry) => PieChartSectionData(
                                                value: entry.value,
                                                titleStyle: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      const Color(0xffffffff),
                                                ),
                                                title:
                                                    '${entry.name}\n${entry.value.toStringAsFixed(1)}%(${entry.rawCount.toStringAsFixed(1)})',
                                                color: Color(int.parse(
                                                    '0xFF${Colors.accents[dataRole.toList().indexOf(entry) % Colors.accents.length].value.toRadixString(16).padLeft(6, '0')}')),
                                              ))
                                          .toList(),
                                    )))
                              ])),
                        ]))
                      ])),
                  HoverableContainer(
                    hoverColor: Colors.red,
                    child: Container(
                      width: 150,
                      height: 400,
                      color: Color.fromARGB(255, 154, 3, 242),
                      child: Center(
                        child: Text(
                          'คลิ๊กเพื่อเเสดงผลมากชึ้น',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Container(
                      color: Colors.purple,
                      width: 500,
                      height: 400,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                  "การจ่ายยา",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 32),
                                ),
                              ])),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Column(children: [
                                    Text(
                                      "สัดส่วนยาที่ถูกใช้",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    AspectRatio(
                                      aspectRatio: 1.5,
                                      child: PieChart(
                                        PieChartData(
                                          sections: dataMedicine
                                              .map((entry) =>
                                                  PieChartSectionData(
                                                    value:
                                                        entry.usage.toDouble(),
                                                    titleStyle: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: const Color(
                                                          0xffffffff),
                                                    ),
                                                    title:
                                                        '${entry.name}\n${entry.percentUsage.toStringAsFixed(1)}%(${entry.usage.toStringAsFixed(1)})',
                                                    color: Color(int.parse(
                                                        '0xFF${Colors.accents[dataMedicine.toList().indexOf(entry) % Colors.accents.length].value.toRadixString(16).padLeft(6, '0')}')),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    )
                                  ])),
                              Expanded(
                                  flex: 1,
                                  child: Column(children: [
                                    Text(
                                      "สัดส่วนประเภทยาที่ถูกใช้",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    AspectRatio(
                                      aspectRatio: 1.5,
                                      child: PieChart(
                                        PieChartData(
                                          sections: dataTypeMedicine
                                              .map((entry) =>
                                                  PieChartSectionData(
                                                    value:
                                                        entry.usage.toDouble(),
                                                    titleStyle: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: const Color(
                                                          0xffffffff),
                                                    ),
                                                    title:
                                                        '${entry.name}\n${entry.percentUsage.toStringAsFixed(1)}%(${entry.usage.toStringAsFixed(1)})',
                                                    color: Color(int.parse(
                                                        '0xFF${Colors.accents[dataTypeMedicine.toList().indexOf(entry) % Colors.accents.length].value.toRadixString(16).padLeft(6, '0')}')),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    )
                                  ])),
                            ],
                          )
                        ],
                      )),
                  HoverableContainer(
                    hoverColor: Colors.red,
                    child: Container(
                      width: 150,
                      height: 400,
                      color: Color.fromARGB(255, 154, 3, 242),
                      child: Center(
                        child: Text(
                          'คลิ๊กเพื่อเเสดงผลมากชึ้น',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class TimeSeriesData {
  final int minutesSinceMidnight;
  double value;

  TimeSeriesData(this.minutesSinceMidnight, this.value);
}

class RoleSeriesData {
  final String name;
  double value;
  int rawCount;
  RoleSeriesData(this.name, this.value, this.rawCount);
}

class MedicineSeriesData {
  final String name;
  int opdUsaged;
  int usage;
  double percentOPDUsaged;
  double percentUsage;
  MedicineSeriesData(this.name, this.opdUsaged, this.usage,
      this.percentOPDUsaged, this.percentUsage);
}

class TypeMedicineSeriesData {
  final String name;
  int opdUsaged;
  int usage;
  double percentOPDUsaged;
  double percentUsage;
  TypeMedicineSeriesData(this.name, this.opdUsaged, this.usage,
      this.percentOPDUsaged, this.percentUsage);
}

class AllMedicineSeriesData {
  final List<MedicineSeriesData> num1;
  final List<TypeMedicineSeriesData> num2;

  AllMedicineSeriesData(this.num1, this.num2);
}

class NumCurseSeriesData {
  final String name;
  final String fullname;
  double value;
  int count;
  NumCurseSeriesData(
    this.name,
    this.fullname,
    this.value,
    this.count,
  );
}

class UserSeriesUsageData {
  final String uuid;
  final String name;
  double value;

  UserSeriesUsageData(
    this.uuid,
    this.name,
    this.value,
  );
}

class HoverableContainer extends StatefulWidget {
  final Color hoverColor;
  final Widget child;

  const HoverableContainer({
    required this.hoverColor,
    required this.child,
  });

  @override
  _HoverableContainerState createState() => _HoverableContainerState();
}

class _HoverableContainerState extends State<HoverableContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHovered = true;
      }),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.hoverColor
              : const Color.fromARGB(0, 255, 5, 5),
        ),
        child: widget.child,
      ),
    );
  }
}
