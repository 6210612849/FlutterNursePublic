import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:textfield_tags/textfield_tags.dart';

class SearchMainScreen extends StatefulWidget {
  @override
  _SearchMainScreenState createState() => _SearchMainScreenState();
}

class _SearchMainScreenState extends State<SearchMainScreen> {
  TextEditingController dateController = TextEditingController();
  TextEditingController dataController = TextEditingController();
  TextEditingController patientController = TextEditingController();
  TextEditingController CursedController = TextEditingController();
  TextEditingController MedicineController = TextEditingController();

  String showFactoryData = "ไม่ได้เลือก";
  String? realFactoryData;
  HashMap<int, List<dynamic>> myHashMap = HashMap<int, List<dynamic>>();
  List<String> uuidData = [];
  List<String> nameData = [];
  List<String> roleData = [];

  List<List<dynamic>> excelData = [];
  String showUUID = "";
  String showName = "";
  String showRole = "";
  String? realUUID;
  String? realName;
  String? realRole;
  String? curseSelectedValue;

  SearchFilter mySearchFilter = SearchFilter();

  AllFilesSeriesData? showAllFilesSeriesData;
  AllFilesSeriesData? realAllFilesSeriesData;
  List<OPDSeriesData>? forShowExcelData;
  List<OPDSeriesData>? realShowExcelData;
  String? med1SelectedValue;
  String? med2SelectedValue;
  List<String>? med2RealSelectedValue;
  TextEditingController numMedController = TextEditingController();
  TextEditingController medController = TextEditingController();
  ValueNotifier<String?> _selectedValueName = ValueNotifier<String?>(null);
  ValueNotifier<String?> _selectedValueUUID = ValueNotifier<String?>(null);
  ValueNotifier<String?> _selectedValueCursed = ValueNotifier<String?>(null);
  ValueNotifier<String?> _selectedValueTypeMed = ValueNotifier<String?>(null);
  MedSelectedValues<List<String>> _selectedValueMed =
      MedSelectedValues<List<String>>([]);
  String testPath = "";
  // ValueNotifier<List<String>?> _selectedValueMedList =
  // ValueNotifier<List<String>?>(null);
  List<List<String>> ListMedController = [];

  void setRefresh() {
    setState(() {
      print("from deart" + forShowExcelData!.toString());
    });
  }

  void setMyObject(int myInt) async {
    dynamic testPathaa = '';
    try {
      // final manifestJson =
      //     await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
      // final assetKeys = json
      //     .decode(manifestJson)
      //     .keys
      //     .where((String key) => key.startsWith('history/' + myInt.toString()));

      // List<String> opdData = assetKeys.toList();
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
        if (numberPart == myInt.toString()) {
          assetKeys.add("history/" + fileName);
        }
      }

      List<String> opdData = assetKeys;
      List<PathSeriesData> tempPathSeriesList = [];
      List<OPDSeriesData> tempForShowExcel = [];
      for (var element in opdData) {
        String date = element
            .replaceAll("history/" + myInt.toString() + "_", "")
            .replaceAll(".csv", "");
        String timeString = element[3].toString();

// Convert the hour and minute strings to integers
        await dotenv.load(fileName: ".env");
        String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";

        List<OPDSeriesData> tempOPDSeriesData = [];
        File dataTest = File(path.current + testEnv + "/" + element);

        String test = dataTest.readAsStringSync();
        setState(() {
          testPath = test;
        });
        List<List<dynamic>> _excelData =
            const CsvToListConverter().convert(test);
        int countCsvIndex = 0;
        for (var element in _excelData) {
          // print("16 > :" + element[16]);
          OPDSeriesData tempOPD = OPDSeriesData(
              element[0].toString(),
              element[1].toString(),
              element[2].toString(),
              element[3].toString(),
              element[4].toString(),
              element[5].toString(),
              element[6].toString(),
              element[7].toString(),
              element[8].toString(),
              element[9].toString(),
              element[10].toString(),
              element[11].toString(),
              element[12].toString(),
              element[13].toString(),
              element[14].toString(),
              element[15].toString(),
              bool.parse(element[16].toString()),
              bool.parse(element[17].toString()),
              bool.parse(element[18].toString()),
              bool.parse(element[19].toString()),
              date.toString(),
              countCsvIndex.toString(),
              myInt.toString(),
              date.toString());
          tempOPDSeriesData.add(tempOPD);
          tempForShowExcel.add(tempOPD);
          countCsvIndex = countCsvIndex + 1;
        }

        PathSeriesData tempPathSeries = PathSeriesData(
            tempOPDSeriesData, path.current + "/" + element, _excelData.length);
        tempPathSeriesList.add(tempPathSeries);
      }

      int tempCount = 0;
      for (var element in tempPathSeriesList) {
        tempCount = tempCount + element.OPDCount;
      }
      AllFilesSeriesData tempAllSeries =
          AllFilesSeriesData(tempPathSeriesList, myInt.toString(), tempCount);
      setState(() {
        showAllFilesSeriesData = tempAllSeries;
        realAllFilesSeriesData = tempAllSeries;
        forShowExcelData = tempForShowExcel;
        testPath = (tempForShowExcel != []).toString();
        realShowExcelData = List.from(tempForShowExcel);
      });
    } catch (e) {
      setState(() {
        testPath = testPathaa.toString();
      });
    }
  }

  void testObject() {
    setState(() {
      forShowExcelData = List.from(realShowExcelData!);
      mySearchFilter = SearchFilter();
      dateController = TextEditingController();
      patientController = TextEditingController();
      CursedController = TextEditingController();
      MedicineController = TextEditingController();
      dataController = TextEditingController();
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

  void createMedOPD(List<String> myList) {
    String tempMed = "";
    setState(() {
      ListMedController.add(myList);
      for (var element in ListMedController) {
        tempMed = tempMed + element.toString();
      }
      medController.text = tempMed;
    });
  }

  void fillteringData() async {
    if (forShowExcelData != null) {
      List<OPDSeriesData> filteredList = List.from(forShowExcelData!);
      List<OPDSeriesData> tempList = List.from(realShowExcelData!);
      DateRangePickerSelectionChangedArgs? search1 = mySearchFilter.timeRange;
      String? search2 = mySearchFilter.name;
      String? search3 = mySearchFilter.uuid;
      String? search4 = mySearchFilter.cursed;
      String? search6 = mySearchFilter.medicine;
      String? search5 = mySearchFilter.medicineType;

      if (search1 != null) {
        DateTime startDate = search1.value.startDate;
        DateTime endDate = search1.value.endDate ?? search1.value.startDate;
        endDate = endDate.add(Duration(days: 1));
        startDate = startDate.subtract(Duration(days: 1));

        filteredList = filteredList.where((element) {
          // Replace with your date string
          String? dateString = element.date;
          if (dateString != null && dateString.isNotEmpty) {
            DateTime? dateTime = DateFormat('dd-MM-yyyy').parse(dateString);

            bool testBull =
                startDate.isBefore(dateTime) && endDate.isAfter(dateTime);

            return (startDate.isBefore(dateTime) && endDate.isAfter(dateTime));
          }

          return false;
        }).toList();
      }

      if (search3 != null) {
        filteredList = filteredList.where((element) {
          // Replace with your date string

          if ((element.uuid != null) && (element.uuid != "")) {
            return element.uuid == search3;
          }

          return false;
        }).toList();
      }

      if (search4 != null) {
        Map<String, dynamic> testCursed = await getCurseJson();

        filteredList = filteredList.where((element) {
          if (testCursed.containsKey(element.curseSelected) ||
              (element.curseSelected != "")) {
            return (element.curseSelected == search4.toString());
          }
          return false;
        }).toList();
      }

      if (search5 != null) {
        Map<String, List<String>> testMed = await getMedJson();
        filteredList = filteredList.where((element) {
          try {
            String input = element.ListMedSelected;
            List<List<String>> resultList = [];

            List<String> elements =
                input.substring(1, input.length - 1).split(', ');

            for (var i = 0; i < elements.length; i += 3) {
              List<String> sublist = elements.sublist(i, i + 3);
              resultList.add(sublist);
            }

            for (var element2 in resultList) {
              String medType = element2[0].substring(1);

              if (testMed.containsKey(medType) || medType != "") {
                return (medType == search5.toString());
              }
              return false;
            }
            return false;
          } catch (e) {
            return false;
          }
        }).toList();
      }

      if (search6 != null) {
        Map<String, List<String>> testMed = await getMedJson();
        filteredList = filteredList.where((element) {
          try {
            String input = element.ListMedSelected;
            List<List<String>> resultList = [];

            List<String> elements =
                input.substring(1, input.length - 1).split(', ');

            for (var i = 0; i < elements.length; i += 3) {
              List<String> sublist = elements.sublist(i, i + 3);
              resultList.add(sublist);
            }

            for (var element2 in resultList) {
              String med = element2[1];

              if (testMed.containsValue(med) || med != "") {
                return (med == search6.toString());
              }
              return false;
            }
            return false;
          } catch (e) {
            return false;
          }
        }).toList();
      }

      setState(() {
        forShowExcelData = filteredList;
      });
    }
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

  Future<Map<String, dynamic>> getCurseJson() async {
    String jsonString = await rootBundle.loadString('json/myCursed.json');
    Map<String, dynamic> dataJson = json.decode(jsonString);

    return dataJson;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel Data'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ElevatedButton(
        onPressed: () {
          // Add your button click logic here
          testObject();
        },
        child: Text('Reset'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'โหมดค้นหารายการ OPD',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 10),
            Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                  fillColor:
                                      const Color.fromARGB(255, 229, 229, 229),
                                  filled: true),
                              readOnly: true,
                              controller: dateController,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10.0),
                              child: Row(children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _showDateRangePickerDialog(context);
                                  },
                                  child: Text('Open Date Range Picker'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    forShowExcelData =
                                        List.from(realShowExcelData!);
                                    setState(() {
                                      mySearchFilter.timeRange = null;
                                    });
                                    dateController = TextEditingController();
                                    fillteringData();
                                  },
                                  child: Text('reset'),
                                )
                              ]),
                            ),
                          ],
                        )),
                    Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                  fillColor:
                                      const Color.fromARGB(255, 229, 229, 229),
                                  filled: true),
                              readOnly: true,
                              controller: patientController,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10.0),
                              child: Row(children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _showPatientPickerDialog(context);
                                  },
                                  child: Text('Open Patient Picker'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      mySearchFilter.name = null;
                                      mySearchFilter.uuid = null;
                                    });
                                    forShowExcelData =
                                        List.from(realShowExcelData!);
                                    fillteringData();
                                    patientController = TextEditingController();
                                  },
                                  child: Text('reset'),
                                )
                              ]),
                            ),
                          ],
                        )),
                    Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                  fillColor:
                                      const Color.fromARGB(255, 229, 229, 229),
                                  filled: true),
                              readOnly: true,
                              controller: CursedController,
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 10.0),
                                child: Row(children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _showCursedPickerDialog(context);
                                    },
                                    child: Text('Open Cursed Picker'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        mySearchFilter.cursed = null;
                                      });
                                      forShowExcelData =
                                          List.from(realShowExcelData!);
                                      fillteringData();
                                      CursedController =
                                          TextEditingController();
                                    },
                                    child: Text('reset'),
                                  )
                                ])),
                          ],
                        )),
                    Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                  fillColor:
                                      const Color.fromARGB(255, 229, 229, 229),
                                  filled: true),
                              readOnly: true,
                              controller: MedicineController,
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 10.0),
                                child: Row(children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _showMedicinePickerDialog(context);
                                    },
                                    child: Text('Open Medicine Picker'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        mySearchFilter.medicine = null;
                                        mySearchFilter.medicineType = null;
                                      });
                                      forShowExcelData =
                                          List.from(realShowExcelData!);
                                      fillteringData();
                                      MedicineController =
                                          TextEditingController();
                                    },
                                    child: Text('reset'),
                                  )
                                ])),
                          ],
                        )),
                    Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            TextField(
                              readOnly: true,
                              controller: dataController,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showDataSelect(context);
                              },
                              child: Text('Select Factory'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  mySearchFilter.medicine = null;
                                  mySearchFilter.medicineType = null;
                                  mySearchFilter.cursed = null;
                                  mySearchFilter.name = null;
                                  mySearchFilter.timeRange = null;
                                  mySearchFilter.timeRange = null;
                                  mySearchFilter.uuid = null;
                                });
                                forShowExcelData =
                                    List.from(realShowExcelData!);
                                fillteringData();
                                dataController = TextEditingController();
                              },
                              child: Text('reset Tag'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                try {
                                  setState(() {
                                    mySearchFilter.medicine = null;
                                    mySearchFilter.medicineType = null;
                                    mySearchFilter.cursed = null;
                                    mySearchFilter.name = null;
                                    mySearchFilter.timeRange = null;
                                    mySearchFilter.timeRange = null;
                                    mySearchFilter.uuid = null;
                                    forShowExcelData = [];
                                  });

                                  fillteringData();
                                  dataController = TextEditingController();
                                } catch (e) {
                                  print("reset All" + e.toString());
                                }
                              },
                              child: Text('reset All'),
                            )
                          ],
                        )),
                  ],
                )),

            // Enable vertical scrolling
            Expanded(child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: forShowExcelData == null &&
                              realAllFilesSeriesData == null
                          ? Center(
                              child: Text("ไม่มีข้อมูล"),
                            )
                          : Center(
                              child: Column(children: [
                                PaginatedDataTable(
                                  columnSpacing: 10,
                                  dataRowMaxHeight: 100,
                                  header: Text('Items'),
                                  columns: generateColumn(),
                                  source: _DataSource(
                                      forShowExcelData!,
                                      MediaQuery.of(context).size.width,
                                      realAllFilesSeriesData!,
                                      context,
                                      [uuidData, nameData, roleData],
                                      function: setRefresh),
                                )
                              ]),
                            )));
            })),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePickerDialog(BuildContext context) async {
    DateRangePickerSelectionChangedArgs? tempArgs;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: 500,
            height: 500,
            child: SfDateRangePicker(
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                setState(() {
                  tempArgs = args;
                });
              },
              selectionMode: DateRangePickerSelectionMode.range,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                if (tempArgs != null) {
                  mySearchFilter.timeRange = tempArgs;

                  fillteringData();
                  DateTime startDate = tempArgs!.value.startDate;
                  DateTime endDate =
                      tempArgs!.value.endDate ?? tempArgs!.value.startDate;

                  String showTimeRange =
                      DateFormat('dd-MM-yyyy').format(startDate) +
                          ":" +
                          DateFormat('dd-MM-yyyy').format(endDate);
                  dateController.text = showTimeRange;
                }
                Navigator.of(context).pop();
              },
              child: Text('Confrim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCursedPickerDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: FutureBuilder<Map<String, dynamic>>(
              future: getCurseJson(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                      'Loading...'); // Display a loading message while waiting for the data
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  Map<String, dynamic> curseCount =
                      snapshot.data ?? Map<String, dynamic>();
                  String? CursedString;

                  return ValueListenableBuilder(
                      valueListenable: _selectedValueCursed,
                      builder: (context, value, child) {
                        return Padding(
                          padding: EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            itemHeight: 100.0,
                            iconSize: 24,
                            elevation: 16,
                            isExpanded: true,
                            style: TextStyle(
                                color: Colors.deepPurple, fontSize: 20.0),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            value: _selectedValueCursed.value,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedValueCursed.value = newValue;

                                CursedString = curseCount[newValue];
                              });
                            },
                            items: curseCount.entries.map((entry) {
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
                      });
                }
              }),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                if (_selectedValueCursed.value != null) {
                  setState(() {
                    mySearchFilter.cursed =
                        _selectedValueCursed.value.toString();
                  });
                  fillteringData();
                  Map<String, dynamic> test = await getCurseJson();
                  String tempString = _selectedValueCursed.value.toString() +
                      ":" +
                      test[_selectedValueCursed.value].toString();
                  CursedController.text = tempString;
                }
                Navigator.of(context).pop();
              },
              child: Text('Confrim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPatientPickerDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
              width: 500,
              height: 500,
              child: Row(children: [
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
                                      MediaQuery.of(context).size.height * 0.5,
                                  selectedItem: _selectedValueName.value,
                                  showSelectedItems: true,
                                  items: nameData,
                                  dropdownSearchDecoration: InputDecoration(
                                      labelText: "Name", hintText: "name"),
                                  showSearchBox: true,
                                  searchFieldProps:
                                      TextFieldProps(cursorColor: Colors.blue),
                                  onChanged: (String? data) => {
                                    setState(() {
                                      _selectedValueName.value = data;
                                      handleUserToUUID(nameData.indexOf(data!));
                                    })
                                  },
                                )))
                              ])));
                        }))
              ])),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                if (_selectedValueUUID.value != null &&
                    _selectedValueName.value != null) {
                  setState(() {
                    mySearchFilter.uuid = _selectedValueUUID.value!;
                    mySearchFilter.name = _selectedValueName.value!;
                  });

                  patientController.text = _selectedValueUUID.value.toString() +
                      " > " +
                      _selectedValueName.value.toString();
                }
                fillteringData();
                Navigator.of(context).pop();
              },
              child: Text('Confrim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMedicinePickerDialog(BuildContext context) async {
    List<String> testmed = [];
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Container(
            width: 500,
            height: 500,
            child: FutureBuilder<Map<String, List<String>>>(
                future: getMedJson(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                    List<String> testmed = [];
                    String? testmedString = null;

                    ValueNotifier<String?> selectedItem =
                        ValueNotifier<String?>(null);

                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(children: [
                            Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: ValueListenableBuilder(
                                      valueListenable: _selectedValueTypeMed,
                                      builder: (context, value, child) {
                                        return DropdownButton<String>(
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
                                          value: _selectedValueTypeMed.value,
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedValueTypeMed.value =
                                                  newValue;

                                              testmed = medCount[newValue]!;

                                              if (testmedString != null) {
                                                testmedString = null;
                                              }
                                            });
                                          },
                                          items: medCount.entries.map((entry) {
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
                                                    ],
                                                  )),
                                            );
                                          }).toList(),
                                        );
                                      }),
                                )),
                            ValueListenableBuilder(
                                valueListenable: _selectedValueTypeMed,
                                builder: (context, value, child) {
                                  return ValueListenableBuilder(
                                      valueListenable: selectedItem,
                                      builder: (context, value, child) {
                                        return Expanded(
                                            flex: 2,
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
                                                    color:
                                                        Colors.deepPurpleAccent,
                                                  ),
                                                  value: selectedItem.value,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      selectedItem.value =
                                                          newValue!;
                                                    });
                                                  },
                                                  items: testmed.map((entry) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: entry,
                                                      child: Container(
                                                        alignment: Alignment
                                                            .centerLeft,
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
                                                )));
                                      });
                                }),
                          ]),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                ListMedController = [];
                                medController.text = "";
                              });
                            },
                            child: Text('Reset'),
                          ),
                          TextButton(
                            onPressed: () {
                              String temp1 = "";
                              String temp2 = "";
                              setState(() {
                                if (_selectedValueTypeMed.value != null) {
                                  mySearchFilter.medicineType =
                                      _selectedValueTypeMed.value;
                                  temp1 =
                                      _selectedValueTypeMed.value.toString();
                                }
                                if (selectedItem.value != null) {
                                  mySearchFilter.medicine = selectedItem.value;
                                  temp2 = selectedItem.value.toString();
                                }
                              });
                              MedicineController.text = temp1 + " " + temp2;
                              fillteringData();
                              Navigator.of(context).pop();
                            },
                            child: Text('Confrim'),
                          ),
                        ]);
                  }
                }),
          ));
        });
  }

  Future<void> _showDataSelect(BuildContext context) async {
    await dotenv.load(fileName: ".env");

    String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";
    Directory directory = Directory(path.current + testEnv + "/assets");
    List<FileSystemEntity> filesDir = directory.listSync();
    List<String> assetKeys = [];
    File dataTest = File(path.current + testEnv + "/json/myFactory.json");
    final jsonString = dataTest.readAsStringSync();
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
                        onPressed: (() async => {
                              await loadExcelData(assetList[index]),
                              setState(() {
                                showFactoryData = myName[index];
                                realFactoryData = index.toString();
                                dataController.text = myName[index];
                              }),
                              setMyObject(index),
                              Navigator.pop(context)
                            }),
                        child: Text("เลือก"))
                  ]);
                },
              ),
            ),
          ));
        });
  }

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

  List<DataColumn> generateColumn() {
    return [
      DataColumn(
        label: Text("วัน"),
        onSort: (columnIndex, ascending) {
          _sortTable(0, ascending);
        },
      ),
      DataColumn(
        label: Text("เวลา"),
        onSort: (columnIndex, ascending) {
          _sortTable(1, ascending);
        },
      ),
      DataColumn(
        label: Text("uuid"),
        onSort: (columnIndex, ascending) {
          _sortTable(2, ascending);
        },
      ),
      DataColumn(
        label: Text("ชื่อ"),
        onSort: (columnIndex, ascending) {
          _sortTable(3, ascending);
        },
      ),
      DataColumn(
        label: Text("ตำเเหน่ง"),
        onSort: (columnIndex, ascending) {
          _sortTable(4, ascending);
        },
      ),
      DataColumn(
        label: Text("โรค"),
        onSort: (columnIndex, ascending) {
          _sortTable(5, ascending);
        },
      ),
      DataColumn(
        label: Text("ยา"),
        onSort: (columnIndex, ascending) {
          _sortTable(6, ascending);
        },
      ),
      DataColumn(
        label: Text("ต่อได้"),
        onSort: (columnIndex, ascending) {
          _sortTable(7, ascending);
        },
      ),
      DataColumn(
        label: Text("พัก"),
        onSort: (columnIndex, ascending) {
          _sortTable(8, ascending);
        },
      ),
      DataColumn(
        label: Text("ส่งต่อ"),
        onSort: (columnIndex, ascending) {
          _sortTable(9, ascending);
        },
      ),
      DataColumn(
        label: Text("กลับบ้าน"),
        onSort: (columnIndex, ascending) {
          _sortTable(10, ascending);
        },
      ),
      DataColumn(
        label: Text("รายละเอียด"),
        onSort: (columnIndex, ascending) {
          _sortTable(11, ascending);
        },
      ),
    ];
  }

  void _sortTable(int columnIndex, bool ascending) {
    // setState(
    //   () {
    //     _sortColumnIndex = columnIndex;
    //     _sortAscending = ascending;

    //     showTableData.sort((a, b) {
    //       var aValue = a[columnIndex];
    //       var bValue = b[columnIndex];
    //       if (aValue is String && bValue is String) {
    //         return ascending
    //             ? aValue.compareTo(bValue)
    //             : bValue.compareTo(aValue);
    //       } else if (aValue is num && bValue is num) {
    //         return ascending
    //             ? aValue.compareTo(bValue)
    //             : bValue.compareTo(aValue);
    //       } else {
    //         return 0;
    //       }
    //     });
    //   },
    // );
  }
}

class OPDSeriesData {
  String uuid; //0
  String name; //1
  String role; //2
  String time; //3
  String illWrite; //4
  String loseWrite; //5
  String tempWirte; //6
  String BPWrite; //7
  String heartWrite; //8
  String DTXWrite; //9
  String curseWrite; //10
  String curseSelected; //11
  String handWrite; //12
  String headWrite; //13
  String ETCWrite; //14
  String ListMedSelected; //15
  bool isResume; //16
  bool isSleep; //17
  bool isSent; //18
  bool isBackHome; //19
  String date; //19
  String csvIndex;
  String factoryIndex;
  String changedDate;
  OPDSeriesData(
      this.uuid,
      this.name,
      this.role,
      this.time,
      this.illWrite,
      this.loseWrite,
      this.tempWirte,
      this.BPWrite,
      this.heartWrite,
      this.DTXWrite,
      this.curseWrite,
      this.curseSelected,
      this.handWrite,
      this.headWrite,
      this.ETCWrite,
      this.ListMedSelected,
      this.isResume,
      this.isSleep,
      this.isSent,
      this.isBackHome,
      this.date,
      this.csvIndex,
      this.factoryIndex,
      this.changedDate);

  List<dynamic> forShowExcel1() {
    return [
      this.date,
      this.time,
      this.uuid,
      this.name,
      this.role,
      this.curseSelected,
      this.ListMedSelected,
    ];
  }

  List<dynamic> forShowExcel2() {
    return [this.isResume, this.isSleep, this.isSent, this.isBackHome];
  }

  String getChangedDate() {
    return this.changedDate;
  }

  List<String> getAll() {
    return [
      this.uuid.toString(), //0
      this.name.toString(), //1
      this.role.toString(), //2
      this.time.toString(), //3
      this.illWrite.toString(), //4
      this.loseWrite.toString(), //5
      this.tempWirte.toString(), //6
      this.BPWrite.toString(), //7
      this.heartWrite.toString(), //8
      this.DTXWrite.toString(), //9
      this.curseWrite.toString(), //10
      this.curseSelected.toString(), //11
      this.handWrite.toString(), //12
      this.headWrite.toString(), //13
      this.ETCWrite.toString(), //14
      this.ListMedSelected.toString(), //15
      this.isResume.toString(), //16
      this.isSleep.toString(), //17
      this.isSent.toString(), //18
      this.isBackHome.toString(), //19
    ];
  }

  List<String> getCSVIndex() {
    return [this.csvIndex, this.factoryIndex];
  }

  List<List<dynamic>> getAllWithFormat() {
    return [
      ["วันที่", this.date],
      ["uuid", this.uuid],
      ["ชื่อ-นามสกุล", this.name],
      ["ตำเเหน่ง", this.role],
      ["เวลา", this.time],
      ["โรคประจำตัว", this.illWrite],
      ["อาการเเพ้ยา", this.loseWrite],
      ["อุณหภูมิ", this.tempWirte],
      ["BP", this.BPWrite],
      ["อัตราหัวใจ", this.heartWrite],
      ["DTX", this.DTXWrite],
      ["รายละเอียดการเจ็บป่วย", this.curseWrite],
      ["รหัสโรค", this.curseSelected],
      ["หัตถาการ", this.handWrite],
      ["หัวหน้างาน", this.headWrite],
      ["หมายเหตุ", this.ETCWrite],
      ["การจ่ายา", this.ListMedSelected],
      ["ทำงานได้", this.isResume],
      ["นอนพัก", this.isSleep],
      ["ส่งต่อ", this.isSent],
      ["กลับบ้าน", this.isBackHome],
    ];
  }
}

class MedSelectedValues<T> extends ValueNotifier<T> {
  T? stringValue;
  List<T>? listValue;
  MedSelectedValues(T initialValue) : super(initialValue);
}

class SearchFilter {
  DateRangePickerSelectionChangedArgs? timeRange;
  String? name;
  String? uuid;
  String? cursed;
  String? medicineType;
  String? medicine;

  SearchFilter({
    this.timeRange,
    this.name,
    this.uuid,
    this.cursed,
    this.medicineType,
    this.medicine,
  });
}

class PathSeriesData {
  final List<OPDSeriesData> fileInOPD;
  final String pathName;
  final int OPDCount;
  PathSeriesData(this.fileInOPD, this.pathName, this.OPDCount);
}

class AllFilesSeriesData {
  final List<PathSeriesData> AllPath;
  final String factoryIndex;
  final int OPDCount;

  AllFilesSeriesData(this.AllPath, this.factoryIndex, this.OPDCount);
}

class _DataSource extends DataTableSource {
  final List<OPDSeriesData> items;
  final double myWitdth;
  final AllFilesSeriesData myAllFiles;
  final BuildContext myContext;
  final List<List<String>> myDataTransfer1;
  Function function;

  _DataSource(this.items, this.myWitdth, this.myAllFiles, this.myContext,
      this.myDataTransfer1,
      {required this.function});

  @override
  DataRow? getRow(int index) {
    List<dynamic> test1 = items[index].forShowExcel1();
    List<dynamic> test2 = items[index].forShowExcel2();
    List<List<dynamic>> testGetAll = items[index].getAllWithFormat();
    List<String> myIndex = items[index].getCSVIndex();
    List<DataCell> myRow = test1.map((e) {
      return DataCell(
          Container(width: myWitdth / 25, child: Text(e.toString())));
    }).toList();
    test2.map((e) {
      return myRow.add(
          DataCell(Container(width: myWitdth / 60, child: Text(e.toString()))));
    }).toList();
    myRow.add(DataCell(Container(
      width: myWitdth / 20,
      child: ElevatedButton(
        onPressed: () {
          _showOPDData(myContext, testGetAll, myDataTransfer1, myAllFiles,
              myIndex, function);
        },
        child: Text('Click'),
      ),
    )));

    return DataRow(cells: myRow);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => items.length;

  @override
  int get selectedRowCount => 0;

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

  Future<bool> assetExists(String assetPath) async {
    try {
      return File(assetPath).exists();
    } catch (_) {
      print("yoyoyoy");
      print(_.toString());
      return false;
    }
  }

  Future<void> _showOPDData(
      BuildContext context,
      List<List<dynamic>> myOPD,
      List<List<String>> myDataTransfer1,
      AllFilesSeriesData myAllFiles,
      List<String> myIndex,
      Function myFunction) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          bool isViewMode = true;

          return StatefulBuilder(builder: (context, setState) {
            try {
              print("nani");
              OPDSeriesData tempOPD = OPDSeriesData(
                myOPD[1][1],
                myOPD[2][1],
                myOPD[3][1],
                myOPD[4][1],
                myOPD[5][1],
                myOPD[6][1],
                myOPD[7][1],
                myOPD[8][1],
                myOPD[9][1],
                myOPD[10][1],
                myOPD[11][1],
                myOPD[12][1],
                myOPD[13][1],
                myOPD[14][1],
                myOPD[15][1],
                myOPD[16][1],
                myOPD[17][1],
                myOPD[18][1],
                myOPD[19][1],
                myOPD[20][1],
                myOPD[0][1],
                myIndex[0],
                myIndex[1],
                myOPD[0][1],
              );
              // List<List<dynamic>> excelData = myDataTransfer1[0];
              HashMap<int, List<dynamic>> myHashMap =
                  HashMap<int, List<dynamic>>();
              List<TextEditingController> controllers = [];

              List<String> uuidData = myDataTransfer1[0];
              List<String> nameData = myDataTransfer1[1];
              List<String> roleData = myDataTransfer1[2];

              ValueNotifier<String?> _selectedTempValueUUID =
                  ValueNotifier<String?>(null);
              ValueNotifier<String?> _selectedTempValueName =
                  ValueNotifier<String?>(null);

              TextEditingController tempForUUID = TextEditingController();
              TextEditingController tempForName = TextEditingController();
              TextEditingController temp1 = TextEditingController();
              TextEditingController temp2 = TextEditingController();
              TextEditingController temp3 = TextEditingController();
              TextEditingController temp4 = TextEditingController();
              TextEditingController temp0 = TextEditingController();
              TextEditingController temp5 = TextEditingController();
              TextEditingController temp6 = TextEditingController();
              TextEditingController temp7 = TextEditingController();
              TextEditingController temp8 = TextEditingController();
              TextEditingController temp9 = TextEditingController();
              TextEditingController temp10 = TextEditingController();
              TextEditingController temp11 = TextEditingController();
              TextEditingController temp12 = TextEditingController();
              TextEditingController temp13 = TextEditingController();
              TextEditingController temp14 = TextEditingController();
              TextEditingController temp15 = TextEditingController();
              ValueNotifier<String?> _selectedValueCursed =
                  ValueNotifier<String?>(null);
              print("kkkkkkk" + _selectedValueCursed.value.toString());
              temp0.text = myOPD[0][1].toString();
              temp1.text = myOPD[1][1].toString();
              temp2.text = myOPD[2][1].toString();
              temp3.text = myOPD[3][1].toString();
              temp4.text = myOPD[4][1].toString();
              temp5.text = myOPD[5][1].toString();
              temp6.text = myOPD[6][1].toString();
              temp7.text = myOPD[7][1].toString();
              temp8.text = myOPD[8][1].toString();
              temp9.text = myOPD[9][1].toString();
              temp10.text = myOPD[10][1].toString();
              temp11.text = myOPD[11][1].toString();
              temp12.text = myOPD[12][1].toString();
              temp13.text = myOPD[13][1].toString();
              temp14.text = myOPD[14][1].toString();
              temp15.text = myOPD[15][1].toString();
              List<String> resultList = [];

              String input = myOPD[16][1].toString();
              if (input.length > 2) {
                List<String> testmedicine =
                    input.substring(1, input.length - 1).split(', ');

                for (var i = 0; i < testmedicine.length; i += 3) {
                  List<String> sublist = testmedicine.sublist(i, i + 3);
                  resultList.add(sublist.toString());
                }
              }

              for (var testindex = 0; testindex < 21; testindex += 1) {
                TextEditingController temp = TextEditingController();
                print("gg" + myOPD[testindex][1].toString());
                temp.text = myOPD[testindex][1].toString();

                controllers.add(temp);
              }

              List<String> listTags = resultList;
              // myOPD[4][1].toString();
              // myOPD[5][1].toString();
              // myOPD[6][1].toString();
              // myOPD[7][1].toString();
              // myOPD[8][1].toString();
              // myOPD[9][1].toString();
              // myOPD[10][1].toString();

              TextEditingController numMedController = TextEditingController();

              List<String>? med2RealSelectedValue;

              List<List<String>> ListMedController = [];
              TextEditingController medController = TextEditingController();
              ValueNotifier<String?> _selectedValueMed =
                  ValueNotifier<String?>(null);
              ValueNotifier<String?> _selectedValueType =
                  ValueNotifier<String?>(null);

              return AlertDialog(
                  content: Container(
                      width: 500,
                      height: 500,
                      child: Column(children: [
                        SizedBox(
                          width: 500,
                          height: 450,
                          child: ListView.builder(
                            itemCount: myOPD.length,
                            itemBuilder: (context, index) {
                              // print(index);
                              // print("dafqqq" + myOPD.length.toString());
                              // print("length" + controllers.length.toString());
                              // print(
                              //     "data" + controllers[index].text.toString());
                              // return
                              //  ListTile(
                              //     title: Wrap(
                              //         children:
                              //             List<Widget>.generate(10, (index2) {
                              // int testIndex = index2;
                              // print("what" + index2.toString());
                              if (isViewMode) {
                                print("ddaaaa" + controllers[index].text);
                                return TextField(
                                  readOnly: true,
                                  autofocus: true,
                                  controller: controllers[index],
                                  decoration: InputDecoration(
                                      labelText: myOPD[index][0].toString()),
                                );
                              } else {
                                Widget contentWidget;
                                print(index);
                                switch (index) {
                                  case 0:
                                    return contentWidget = Container(
                                        child: Row(children: [
                                      Expanded(
                                          flex: 1,
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                print("aaaaaaaa");
                                                DateTime? newDate =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime(1900),
                                                        lastDate:
                                                            DateTime(2100));
                                                var nullSelect =
                                                    newDate ?? DateTime.now();
                                                print(nullSelect);
                                                // setState2(
                                                //   () {},
                                                // );
                                                temp0.text =
                                                    DateFormat('dd-MM-yyyy')
                                                        .format(nullSelect)
                                                        .toString();
                                                tempOPD.changedDate =
                                                    DateFormat('dd-MM-yyyy')
                                                        .format(nullSelect)
                                                        .toString()
                                                        .substring(0, 10);
                                                print(temp0.text);
                                              },
                                              child: Text("Select Date"))),
                                      Expanded(
                                          flex: 2,
                                          child: TextField(
                                            readOnly: true,
                                            autofocus: true,
                                            controller: temp0,
                                            decoration: InputDecoration(
                                                labelText:
                                                    myOPD[index][0].toString()),
                                          ))
                                    ]));

                                  case 1:
                                    return StatefulBuilder(
                                        builder: (context, setState2) {
                                      return contentWidget = Container(
                                          child: Row(children: [
                                        Expanded(
                                            flex: 1,
                                            child: (Container(
                                                alignment: Alignment.centerLeft,
                                                child: Row(children: [
                                                  Expanded(
                                                      child: Container(
                                                          child: DropdownSearch<
                                                              String>(
                                                    mode: Mode.MENU,
                                                    maxHeight:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                    selectedItem: temp1.text,
                                                    showSelectedItems: true,
                                                    items: uuidData,
                                                    dropdownSearchDecoration:
                                                        InputDecoration(
                                                            labelText: "ID",
                                                            hintText: "uuid"),
                                                    showSearchBox: true,
                                                    searchFieldProps:
                                                        TextFieldProps(
                                                            cursorColor:
                                                                Colors.blue),
                                                    onChanged:
                                                        (String? data) async {
                                                      int onChangedIndex =
                                                          uuidData
                                                              .indexOf(data!);
                                                      tempOPD.name = nameData[
                                                              onChangedIndex]
                                                          .toString();

                                                      temp2.text = tempOPD.name;

                                                      tempOPD.uuid =
                                                          data.toString();
                                                      temp1.text =
                                                          data.toString();
                                                      temp3.text = roleData[
                                                          onChangedIndex];
                                                      tempOPD.role = temp3.text;
                                                    },
                                                  )))
                                                ])))
                                            //       },
                                            //     ),
                                            //   ),

                                            ),
                                        Expanded(
                                            flex: 1,
                                            child: TextField(
                                              readOnly: true,
                                              autofocus: true,
                                              controller: temp1,
                                              decoration: InputDecoration(
                                                  labelText: myOPD[index][0]
                                                      .toString()),
                                            ))
                                      ]));
                                    });

                                  case 2:
                                    return StatefulBuilder(
                                        builder: (context, setState2) {
                                      return contentWidget = Container(
                                          child: Row(children: [
                                        Expanded(
                                            flex: 1,
                                            child: (Container(
                                                alignment: Alignment.centerLeft,
                                                child: Row(children: [
                                                  Expanded(
                                                      child: Container(
                                                          child: DropdownSearch<
                                                              String>(
                                                    mode: Mode.MENU,
                                                    maxHeight:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                    selectedItem: temp2.text,
                                                    showSelectedItems: true,
                                                    items: nameData,
                                                    dropdownSearchDecoration:
                                                        InputDecoration(
                                                            labelText: "ID",
                                                            hintText: "uuid"),
                                                    showSearchBox: true,
                                                    searchFieldProps:
                                                        TextFieldProps(
                                                            cursorColor:
                                                                Colors.blue),
                                                    onChanged:
                                                        (String? data) async {
                                                      int onChangedIndex =
                                                          nameData
                                                              .indexOf(data!);
                                                      tempOPD.uuid = uuidData[
                                                              onChangedIndex]
                                                          .toString();
                                                      temp1.text = tempOPD.uuid;
                                                      tempOPD.name =
                                                          data.toString();
                                                      temp2.text =
                                                          data.toString();
                                                      temp3.text = roleData[
                                                          onChangedIndex];
                                                      tempOPD.role = temp3.text;
                                                    },
                                                  )))
                                                ])))
                                            //       },
                                            //     ),
                                            //   ),

                                            ),
                                        Expanded(
                                            flex: 1,
                                            child: TextField(
                                              readOnly: true,
                                              autofocus: true,
                                              controller: temp2,
                                              decoration: InputDecoration(
                                                  labelText: myOPD[index][0]
                                                      .toString()),
                                            ))
                                      ]));
                                    });

                                  case 3:
                                    return StatefulBuilder(
                                        builder: (context, setState2) {
                                      return contentWidget = Container(
                                          child: Row(children: [
                                        Expanded(
                                            flex: 1,
                                            child: TextField(
                                              readOnly: true,
                                              autofocus: true,
                                              controller: temp3,
                                              decoration: InputDecoration(
                                                  labelText: myOPD[index][0]
                                                      .toString()),
                                            ))
                                      ]));
                                    });
                                  case 4:
                                    return contentWidget = Container(
                                        child: Row(children: [
                                      Expanded(
                                          flex: 1,
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                TimeOfDay? selectedTime =
                                                    await showTimePicker(
                                                  initialTime: TimeOfDay.now(),
                                                  context: context,
                                                );
                                                var nullSelect = selectedTime ??
                                                    TimeOfDay.now();

                                                // setState2(
                                                //   () {},
                                                // );
                                                temp4.text =
                                                    nullSelect.toString();
                                                tempOPD.time =
                                                    nullSelect.toString();
                                              },
                                              child: Text("Select Time"))),
                                      Expanded(
                                          flex: 2,
                                          child: TextField(
                                            readOnly: true,
                                            autofocus: true,
                                            controller: temp4,
                                            decoration: InputDecoration(
                                                labelText:
                                                    myOPD[index][0].toString()),
                                          ))
                                    ]));

                                  case 5:
                                    return contentWidget = Container(
                                        child: TextField(
                                      autofocus: true,
                                      onChanged: (value) async {
                                        tempOPD.illWrite = value;
                                      },
                                      controller: temp5,
                                      decoration: InputDecoration(
                                          labelText:
                                              myOPD[index][0].toString()),
                                    ));

                                  case 6:
                                    return contentWidget = Container(
                                        child: TextField(
                                      autofocus: true,
                                      onChanged: (value) async {
                                        tempOPD.loseWrite = value;
                                      },
                                      controller: temp6,
                                      decoration: InputDecoration(
                                          labelText:
                                              myOPD[index][0].toString()),
                                    ));

                                  case 7:
                                    return contentWidget = Container(
                                        child: TextField(
                                      autofocus: true,
                                      onChanged: (value) async {
                                        tempOPD.tempWirte = value;
                                      },
                                      controller: temp7,
                                      decoration: InputDecoration(
                                          labelText:
                                              myOPD[index][0].toString()),
                                    ));

                                  case 8:
                                    return contentWidget = Container(
                                        child: TextField(
                                      autofocus: true,
                                      onChanged: (value) async {
                                        tempOPD.BPWrite = value;
                                      },
                                      controller: temp8,
                                      decoration: InputDecoration(
                                          labelText:
                                              myOPD[index][0].toString()),
                                    ));
                                  case 9:
                                    return contentWidget = Container(
                                        child: TextField(
                                      autofocus: true,
                                      onChanged: (value) async {
                                        tempOPD.heartWrite = value;
                                      },
                                      controller: temp9,
                                      decoration: InputDecoration(
                                          labelText:
                                              myOPD[index][0].toString()),
                                    ));
                                  case 10:
                                    return contentWidget = Container(
                                        child: TextField(
                                      autofocus: true,
                                      onChanged: (value) async {
                                        tempOPD.DTXWrite = value;
                                      },
                                      controller: temp10,
                                      decoration: InputDecoration(
                                          labelText:
                                              myOPD[index][0].toString()),
                                    ));
                                  case 11:
                                    return contentWidget = Container(
                                        child: TextField(
                                      autofocus: true,
                                      onChanged: (value) async {
                                        tempOPD.curseWrite = value;
                                      },
                                      controller: temp11,
                                      decoration: InputDecoration(
                                          labelText:
                                              myOPD[index][0].toString()),
                                    ));
                                  case 12:
                                    contentWidget =
                                        FutureBuilder<Map<String, dynamic>>(
                                            future: getCurseJson(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Text(
                                                    'Loading...'); // Display a loading message while waiting for the data
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else {
                                                Map<String, dynamic>
                                                    curseCount =
                                                    snapshot.data ??
                                                        Map<String, dynamic>();
                                                String? CursedString;

                                                return Row(children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child:
                                                          ValueListenableBuilder(
                                                              valueListenable:
                                                                  _selectedValueCursed,
                                                              builder: (context,
                                                                  value,
                                                                  child) {
                                                                return Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                                    itemHeight:
                                                                        100.0,
                                                                    iconSize:
                                                                        24,
                                                                    elevation:
                                                                        16,
                                                                    isExpanded:
                                                                        true,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .deepPurple,
                                                                        fontSize:
                                                                            20.0),
                                                                    underline:
                                                                        Container(
                                                                      height: 2,
                                                                      color: Colors
                                                                          .deepPurpleAccent,
                                                                    ),
                                                                    value: _selectedValueCursed
                                                                        .value,
                                                                    onChanged:
                                                                        (newValue) {
                                                                      try {
                                                                        _selectedValueCursed.value =
                                                                            newValue;

                                                                        CursedString =
                                                                            curseCount[newValue];
                                                                        temp12.text =
                                                                            newValue.toString();
                                                                        tempOPD.curseSelected =
                                                                            newValue.toString();
                                                                      } catch (e) {
                                                                        print(
                                                                            e);
                                                                      }
                                                                    },
                                                                    items: curseCount
                                                                        .entries
                                                                        .map(
                                                                            (entry) {
                                                                      return DropdownMenuItem<
                                                                          String>(
                                                                        value: entry
                                                                            .key,
                                                                        child: Container(
                                                                            alignment: Alignment.centerLeft,
                                                                            height: 100,
                                                                            child: Wrap(
                                                                              children: [
                                                                                Text(
                                                                                  entry.key,
                                                                                  style: TextStyle(
                                                                                    fontSize: 18, // Adjust the font size
                                                                                    color: Colors.black, // Customize text color
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  entry.value,
                                                                                  style: TextStyle(
                                                                                    fontSize: 18, // Adjust the font size
                                                                                    color: Colors.black, // Customize text color
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            )),
                                                                      );
                                                                    }).toList(),
                                                                  ),
                                                                );
                                                              })),
                                                  Expanded(
                                                      flex: 1,
                                                      child: TextField(
                                                        readOnly: true,
                                                        autofocus: true,
                                                        controller: temp12,
                                                        decoration:
                                                            InputDecoration(
                                                                labelText: myOPD[
                                                                        index][0]
                                                                    .toString()),
                                                      ))
                                                ]);
                                              }
                                            });
                                  case 13:
                                    return contentWidget = Container(
                                        child: TextField(
                                      autofocus: true,
                                      onChanged: (value) async {
                                        tempOPD.handWrite = value;
                                      },
                                      controller: temp13,
                                      decoration: InputDecoration(
                                          labelText:
                                              myOPD[index][0].toString()),
                                    ));
                                  case 14:
                                    return contentWidget = Container(
                                        child: TextField(
                                      autofocus: true,
                                      onChanged: (value) async {
                                        tempOPD.headWrite = value;
                                      },
                                      controller: temp14,
                                      decoration: InputDecoration(
                                          labelText:
                                              myOPD[index][0].toString()),
                                    ));

                                  case 15:
                                    return contentWidget = Container(
                                        child: TextField(
                                      autofocus: true,
                                      onChanged: (value) async {
                                        tempOPD.ETCWrite = value;
                                      },
                                      controller: temp15,
                                      decoration: InputDecoration(
                                          labelText:
                                              myOPD[index][0].toString()),
                                    ));

                                  case 16:
                                    try {} catch (e) {}
                                    TextfieldTagsController _controller =
                                        TextfieldTagsController();
                                    ;

                                    TextEditingController? temp16;

                                    return contentWidget = StatefulBuilder(
                                        builder: (context, setState16) {
                                      return Container(
                                          child: TextFieldTags(
                                        textfieldTagsController: _controller,
                                        // initialTags: resultList,
                                        inputfieldBuilder: (context, tec, fn,
                                            error, onChanged, onSubmitted) {
                                          return ((context, sc, tags,
                                              onTagDelete) {
                                            // if (tempOPD.ListMedSelected !=
                                            //     "") {}
                                            void createMedOPD(
                                                List<String> myList) {
                                              String tempMed = "";
                                              List<String> tempList = [];
                                              ListMedController.add(myList);
                                              for (var element
                                                  in ListMedController) {
                                                tempMed = tempMed +
                                                    element.toString();
                                                tempList
                                                    .add(element.toString());
                                              }
                                              medController.text = tempMed;
                                              String tempMedFormat = '';
                                              for (var element in tempList) {
                                                tempMedFormat = tempMedFormat +
                                                    element.toString();
                                              }
                                              setState16(
                                                () {
                                                  listTags.add(tempMedFormat);
                                                },
                                              );
                                              ListMedController = [];
                                              tempOPD.ListMedSelected =
                                                  listTags.toString();
                                              print(tags.toString());
                                            }

                                            return Column(children: [
                                              Container(
                                                  child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: TextField(
                                                  readOnly: true,
                                                  controller: tec,
                                                  maxLines: null,
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  focusNode: fn,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    border:
                                                        const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color.fromARGB(
                                                            255, 74, 137, 92),
                                                        width: 3.0,
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color.fromARGB(
                                                            255, 74, 137, 92),
                                                        width: 3.0,
                                                      ),
                                                    ),
                                                    helperText: 'ใส่ยา...',
                                                    helperStyle:
                                                        const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 74, 137, 92),
                                                    ),
                                                    hintText:
                                                        _controller.hasTags
                                                            ? ''
                                                            : "Enter tag...",
                                                    errorText: error,
                                                    prefixIconConstraints:
                                                        BoxConstraints(),
                                                    prefixIcon: listTags
                                                            .isNotEmpty
                                                        ? SingleChildScrollView(
                                                            controller: sc,
                                                            // scrollDirection:
                                                            //     Axis.horizontal,
                                                            child: Column(
                                                                children: listTags
                                                                    .map((String
                                                                        tag) {
                                                              return Container(
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius.circular(
                                                                        20.0),
                                                                  ),
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          74,
                                                                          137,
                                                                          92),
                                                                ),
                                                                margin: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        5.0),
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10.0,
                                                                    vertical:
                                                                        5.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    InkWell(
                                                                      child:
                                                                          Text(
                                                                        '#$tag',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        print(
                                                                            "$tag selected");
                                                                      },
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            4.0),
                                                                    InkWell(
                                                                      child:
                                                                          const Icon(
                                                                        Icons
                                                                            .cancel,
                                                                        size:
                                                                            14.0,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            233,
                                                                            233,
                                                                            233),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        setState16(
                                                                          () {
                                                                            listTags.remove(tag);
                                                                            tempOPD.ListMedSelected =
                                                                                listTags.toString();
                                                                          },
                                                                        );
                                                                      },
                                                                    )
                                                                  ],
                                                                ),
                                                              );
                                                            }).toList()),
                                                          )
                                                        : null,
                                                  ),
                                                  onChanged: onChanged,
                                                  onSubmitted: onSubmitted,
                                                ),
                                              )),
                                              FutureBuilder<
                                                      Map<String,
                                                          List<String>>>(
                                                  future: getMedJson(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return SkeletonAnimation(
                                                        shimmerColor:
                                                            Colors.grey,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        shimmerDuration: 1000,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[300],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 40),
                                                        ),
                                                      );
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Text(
                                                          'Error: ${snapshot.error}');
                                                    } else {
                                                      Map<String, List<String>>
                                                          medCount =
                                                          snapshot.data ??
                                                              Map<
                                                                  String,
                                                                  List<
                                                                      String>>();

                                                      return ValueListenableBuilder(
                                                          valueListenable:
                                                              _selectedValueMed,
                                                          builder: (context,
                                                              value, child) {
                                                            return Column(
                                                                children: [
                                                                  Row(
                                                                      children: [
                                                                        Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.all(8.0),
                                                                              child: DropdownButton<String>(
                                                                                itemHeight: 100.0,
                                                                                iconSize: 24,
                                                                                elevation: 16,
                                                                                isExpanded: true,
                                                                                style: TextStyle(color: Colors.deepPurple, fontSize: 20.0),
                                                                                underline: Container(
                                                                                  height: 2,
                                                                                  color: Colors.deepPurpleAccent,
                                                                                ),
                                                                                value: _selectedValueMed.value,
                                                                                onChanged: (newValue) {
                                                                                  print(newValue.toString() + "text");

                                                                                  _selectedValueMed.value = newValue!;
                                                                                  med2RealSelectedValue = medCount[newValue]!;

                                                                                  if (_selectedValueType.value != null) {
                                                                                    _selectedValueType.value = null;
                                                                                  }
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
                                                                                                fontSize: 18, // Adjust the font size
                                                                                                color: Colors.black, // Customize text color
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
                                                                        ValueListenableBuilder(
                                                                            valueListenable:
                                                                                _selectedValueType,
                                                                            builder: (context,
                                                                                value,
                                                                                child) {
                                                                              return Expanded(
                                                                                  flex: 2,
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(8.0),
                                                                                    child: DropdownButton<String>(
                                                                                      itemHeight: 100.0,
                                                                                      iconSize: 24,
                                                                                      elevation: 16,
                                                                                      isExpanded: true,
                                                                                      style: TextStyle(color: Colors.deepPurple, fontSize: 20.0),
                                                                                      underline: Container(
                                                                                        height: 2,
                                                                                        color: Colors.deepPurpleAccent,
                                                                                      ),
                                                                                      value: _selectedValueType.value,
                                                                                      onChanged: (newValue) {
                                                                                        _selectedValueType.value = newValue;
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
                                                                                  ));
                                                                            }),
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              TextField(
                                                                            controller:
                                                                                numMedController,
                                                                            keyboardType:
                                                                                TextInputType.number,
                                                                            inputFormatters: [
                                                                              FilteringTextInputFormatter.digitsOnly
                                                                            ],
                                                                            decoration:
                                                                                InputDecoration(
                                                                              labelText: 'Enter a number',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                  Container(
                                                                      height:
                                                                          100,
                                                                      child: Row(
                                                                          children: [
                                                                            ElevatedButton(
                                                                              onPressed: () {
                                                                                if (_selectedValueMed.value != null && _selectedValueType.value != null && numMedController.value.text != "") {
                                                                                  createMedOPD([
                                                                                    _selectedValueMed.value.toString(),
                                                                                    _selectedValueType.value.toString(),
                                                                                    numMedController.value.text
                                                                                  ]);
                                                                                }
                                                                              },
                                                                              child: Text('add'),
                                                                            ),
                                                                            ElevatedButton(
                                                                              onPressed: () {
                                                                                setState16(() {
                                                                                  ListMedController = [];
                                                                                  medController.text = "";
                                                                                });
                                                                              },
                                                                              child: Text('Reset'),
                                                                            ),
                                                                          ]))
                                                                ]);
                                                          });
                                                    }
                                                  }),
                                            ]);
                                          });
                                        },
                                      ));
                                    });
                                  case 17:
                                    bool isResume =
                                        (controllers[17].text != "false");
                                    ValueNotifier<bool> _selectedValueIsResume =
                                        ValueNotifier<bool>(isResume);
                                    return contentWidget =
                                        ValueListenableBuilder(
                                            valueListenable:
                                                _selectedValueIsResume,
                                            builder: (context, value, child) {
                                              return Row(children: [
                                                Expanded(
                                                    child: Text("ทำงานต่อได้")),
                                                Expanded(
                                                    flex: 1,
                                                    child: Checkbox(
                                                        value:
                                                            _selectedValueIsResume
                                                                .value,
                                                        activeColor:
                                                            Colors.green,
                                                        onChanged:
                                                            (newbool) async {
                                                          _selectedValueIsResume
                                                                  .value =
                                                              newbool ?? false;
                                                          tempOPD.isResume =
                                                              newbool ?? false;
                                                        }))
                                              ]);
                                            });
                                  case 18:
                                    bool isSleep =
                                        (controllers[18].text != "false");
                                    ValueNotifier<bool> _selectedValueIsSleep =
                                        ValueNotifier<bool>(isSleep);
                                    return contentWidget =
                                        ValueListenableBuilder(
                                            valueListenable:
                                                _selectedValueIsSleep,
                                            builder: (context, value, child) {
                                              return Row(children: [
                                                Expanded(
                                                    child: Text("พักฟื้น")),
                                                Expanded(
                                                    flex: 1,
                                                    child: Checkbox(
                                                        value:
                                                            _selectedValueIsSleep
                                                                .value,
                                                        activeColor:
                                                            Colors.green,
                                                        onChanged:
                                                            (newbool) async {
                                                          _selectedValueIsSleep
                                                                  .value =
                                                              newbool ?? false;
                                                          tempOPD.isSleep =
                                                              newbool ?? false;
                                                        }))
                                              ]);
                                            });
                                  case 19:
                                    bool isSent =
                                        (controllers[19].text != "false");
                                    ValueNotifier<bool> _selectedValueIsSent =
                                        ValueNotifier<bool>(isSent);
                                    return contentWidget =
                                        ValueListenableBuilder(
                                            valueListenable:
                                                _selectedValueIsSent,
                                            builder: (context, value, child) {
                                              return Row(children: [
                                                Expanded(child: Text("ส่งตัว")),
                                                Expanded(
                                                    flex: 1,
                                                    child: Checkbox(
                                                        value:
                                                            _selectedValueIsSent
                                                                .value,
                                                        activeColor:
                                                            Colors.green,
                                                        onChanged:
                                                            (newbool) async {
                                                          _selectedValueIsSent
                                                                  .value =
                                                              newbool ?? false;
                                                          tempOPD.isSent =
                                                              newbool ?? false;
                                                        }))
                                              ]);
                                            });
                                  case 20:
                                    bool isBackHome =
                                        (controllers[20].text != "false");
                                    ValueNotifier<bool>
                                        _selectedValueIsBackhome =
                                        ValueNotifier<bool>(isBackHome);
                                    return contentWidget =
                                        ValueListenableBuilder(
                                            valueListenable:
                                                _selectedValueIsBackhome,
                                            builder: (context, value, child) {
                                              return Row(children: [
                                                Expanded(
                                                    child: Text("กลับบ้าน")),
                                                Expanded(
                                                    flex: 1,
                                                    child: Checkbox(
                                                        value:
                                                            _selectedValueIsBackhome
                                                                .value,
                                                        activeColor:
                                                            Colors.green,
                                                        onChanged:
                                                            (newbool) async {
                                                          _selectedValueIsBackhome
                                                                  .value =
                                                              newbool ?? false;
                                                          tempOPD.isBackHome =
                                                              newbool ?? false;
                                                        }))
                                              ]);
                                            });

                                  default:
                                    contentWidget = TextField(
                                      readOnly: false,
                                      autofocus: true,
                                      controller: controllers[index],
                                      decoration: InputDecoration(
                                          labelText:
                                              myOPD[index][0].toString() +
                                                  index.toString()),
                                    );
                                }
                                return contentWidget;
                              }

                              // })),
                              // onTap: () => print(
                              //       "its work",
                              //     ));
                            },
                          ),
                        ),
                        Expanded(
                            child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Future.delayed(
                                  //     const Duration(milliseconds: 1000), () {
                                  setState(() {
                                    isViewMode = !isViewMode;
                                  });
                                  // });
                                },
                                child: isViewMode
                                    ? Text('Edit Mode')
                                    : Text('View Mode'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    List<String> ListCreating =
                                        tempOPD.getAll();
                                    String changeDate =
                                        tempOPD.getChangedDate();

                                    await dotenv.load(fileName: ".env");
                                    String testEnv =
                                        dotenv.env['historyPath'] ??
                                            "/data/flutter_assets";
                                    String fileDate =
                                        tempOPD.date.substring(0, 10);
                                    print(fileDate);
                                    // DateTime originalDate =
                                    //     DateTime.parse(fileDate);

                                    // String formattedDate =
                                    //     DateFormat('dd-MM-yyyy')
                                    //         .format(originalDate);
                                    print("bruhhหหหห" +
                                        tempOPD.date +
                                        "dddddd" +
                                        tempOPD.changedDate);
                                    print("bool" +
                                        (tempOPD.date == tempOPD.changedDate)
                                            .toString());
                                    String checkExits = path.current +
                                        testEnv +
                                        "/" +
                                        'history/' +
                                        tempOPD.factoryIndex.toString() +
                                        "_" +
                                        fileDate +
                                        ".csv";

                                    // String csv = const ListToCsvConverter()
                                    //     .convert([test]);
                                    if (tempOPD.date == tempOPD.changedDate) {
                                      if (await assetExists(checkExits)) {
                                        print("dafuq");
                                        File file0 = File(checkExits);
                                        String csvData0 =
                                            await file0.readAsString();
                                        List<List<dynamic>> csvRows0 =
                                            CsvToListConverter()
                                                .convert(csvData0);
                                        csvRows0[int.parse(tempOPD.csvIndex)] =
                                            ListCreating;
                                        String updatedCSV0 =
                                            const ListToCsvConverter()
                                                .convert(csvRows0);
                                        file0.writeAsStringSync(updatedCSV0);
                                      } else {
                                        print("out" + checkExits);
                                        File file = File(checkExits);
                                        String csv = const ListToCsvConverter()
                                            .convert([ListCreating]);

                                        // Write the CSV data to the file
                                        file.writeAsStringSync(csv);
                                      }
                                    } else {
                                      String checkExits2 = path.current +
                                          testEnv +
                                          "/" +
                                          'history/' +
                                          tempOPD.factoryIndex.toString() +
                                          "_" +
                                          tempOPD.changedDate +
                                          ".csv";
                                      bool testBool2 =
                                          await assetExists(checkExits2);
                                      print(
                                          "out inside" + testBool2.toString());
                                      if (await assetExists(checkExits)) {
                                        print("dafuq");
                                        File file1 = File(checkExits);
                                        String csvData1 =
                                            await file1.readAsString();
                                        List<List<dynamic>> csvRows1 =
                                            CsvToListConverter()
                                                .convert(csvData1);
                                        csvRows1.removeAt(
                                            int.parse(tempOPD.csvIndex));

                                        String updatedCSV1 =
                                            const ListToCsvConverter()
                                                .convert(csvRows1);
                                        file1.writeAsStringSync(updatedCSV1);
                                        if (await assetExists(checkExits2)) {
                                          File file2 = File(checkExits2);
                                          String csvData2 =
                                              await file2.readAsString();
                                          List<List<dynamic>> csvRows2 =
                                              CsvToListConverter()
                                                  .convert(csvData2);
                                          csvRows2.add(ListCreating);

                                          String updatedCSV2 =
                                              const ListToCsvConverter()
                                                  .convert(csvRows2);
                                          file2.writeAsStringSync(updatedCSV2);
                                        } else {
                                          print("nice logic");
                                          File file3 = File(checkExits2);
                                          String csv3 =
                                              const ListToCsvConverter()
                                                  .convert([ListCreating]);
                                          file3.writeAsStringSync(csv3);
                                        }
                                      } else {
                                        if (await assetExists(checkExits2)) {
                                          File file4 = File(checkExits2);
                                          String csvData4 =
                                              await file4.readAsString();
                                          List<List<dynamic>> csvRows4 =
                                              CsvToListConverter()
                                                  .convert(csvData4);
                                          csvRows4.add(ListCreating);

                                          String updatedCSV4 =
                                              const ListToCsvConverter()
                                                  .convert(csvRows4);
                                          file4.writeAsStringSync(updatedCSV4);
                                        } else {
                                          File file5 = File(checkExits2);
                                          String csv5 =
                                              const ListToCsvConverter()
                                                  .convert([ListCreating]);
                                          file5.writeAsStringSync(csv5);
                                        }
                                      }
                                    }
                                  } catch (e) {
                                    print(e.toString() + "whyyy");
                                  }
                                  print("finsihed");
                                  myFunction();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Ok'),
                              ),
                            ]))
                      ])));
            } catch (e) {
              print("finderiir" + e.toString());
              return (Text(e.toString()));
            }
          });
        });
  }
}

Future<List<List<dynamic>>> readExcelData(String pathExcel) async {
  // Replace 'assets/sample.xlsx' with the path to your Excel file
  await dotenv.load(fileName: ".env");
  String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";
  File files = File(path.current + testEnv + "/" + pathExcel);
  String data = files.readAsStringSync();
  List<List<dynamic>> _excelData = const CsvToListConverter().convert(data);

  return _excelData;
}


  //  header.asMap().entries.map((entry) {
  //   int index = entry.key;
  //   String headerText = entry.value;
  //   return DataColumn(
  //     label: Text(headerText),
  //     onSort: (columnIndex, ascending) {
  //       _sortTable(index, ascending);
  //     },
  //   );
  // }).toList();
