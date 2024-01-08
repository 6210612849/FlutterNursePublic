import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_app/home/popupUserAdd.dart';
import 'package:my_app/home/popupUserEdit.dart';
import 'package:path/path.dart' as path;

class viewUser extends StatefulWidget {
  final String tablePath;
  final String tableName;
  final String factoryIndex;
  final List<List<dynamic>> tableData;

  const viewUser({
    Key? key,
    required this.tableData,
    required this.tableName,
    required this.tablePath,
    required this.factoryIndex,
  }) : super(key: key);

  @override
  State<viewUser> createState() => _viewUserState();
}

class _viewUserState extends State<viewUser> {
  List<String> header = ['หมายเลข', 'ชื่อ-นามสกุล', "ตำเเหน่ง", "", "", ""];
  ValueNotifier<String?> _selectedValueName = ValueNotifier<String?>(null);
  ValueNotifier<String?> _selectedValueUUID = ValueNotifier<String?>(null);
  late List<List<dynamic>> showTableData;
  late List<List<dynamic>> realTableData;
  late List<List<dynamic>> yTableData;
  List<String> uuidData = [];
  List<String> nameData = [];
  List<String> roleData = [];
  String showUUID = "";
  String showName = "";
  String showRole = "";
  String showindex = "";
  String? realUUID;
  String? realName;
  String? realRole;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  String errorMessage = "ไม่มี";
  String myTablePath = "";
  @override
  Future<bool> updateOPD(String myTemped, List<dynamic> myUpdated) async {
    try {
      List<dynamic> myTempedList = realTableData[int.parse(myTemped)];
      final manifestJson =
          await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
      String myIndex = widget.factoryIndex.toString();
      final assetKeys = json
          .decode(manifestJson)
          .keys
          .where((String key) => key.startsWith('history/' + myIndex));
      List<String> opdList = assetKeys.toList();

      for (var element in opdList) {
        String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";
        File dataTest = File(path.current + testEnv + "/" + element);
        String test = dataTest.readAsStringSync();
        List<List<dynamic>> _excelData =
            const CsvToListConverter().convert(test);
        bool isChanged = false;
        int countIndex = 0;
        for (var element in _excelData) {
          if (element[0] == myTempedList[0] || element[1] == myTempedList[1]) {
            isChanged = true;
            _excelData[countIndex][0] = myUpdated[0];
            _excelData[countIndex][1] = myUpdated[1];
            _excelData[countIndex][2] = myUpdated[2];
          }
          countIndex = countIndex + 1;
        }
        if (isChanged) {
          String updatedCSV = const ListToCsvConverter().convert(_excelData);
          dataTest.writeAsStringSync(updatedCSV);
        }
      }
      return true;
    } catch (e) {
      errorMessage = "updateOpd" + e.toString();
      return false;
    }
  }

  void refreshShowTable() async {
    for (var row in realTableData) {
      showTableData.add(List.from(row));
      setState(() {
        try {
          for (int rowIndex = 0;
              rowIndex < widget.tableData.length;
              rowIndex++) {
            List<dynamic> temp = showTableData[rowIndex];
            temp.add(rowIndex);
            showTableData[rowIndex] = temp;
          }

          // });
        } catch (e) {
          print("chilldude" + e.toString());
        }
      });
    }
  }

  @override
  void initState() {
    // setState(() {
    myTablePath = widget.tablePath;
    print(widget.tablePath + "fixbug");
    realTableData = [];
    showTableData = [];

    for (var row in widget.tableData) {
      realTableData.add(List.from(row));
      showTableData.add(List.from(row));
    }
    setState(() {
      try {
        for (int rowIndex = 0; rowIndex < widget.tableData.length; rowIndex++) {
          List<dynamic> temp = showTableData[rowIndex];
          temp.add(rowIndex);
          showTableData[rowIndex] = temp;
        }

        // });
      } catch (e) {
        print("chilldude" + e.toString());
      }
    }); // Initialize the lists here
    setSerach();
  }

  void setSerach() {
    setState(() {
      for (var element in realTableData) {
        uuidData.add(element[0].toString());
        nameData.add(element[1].toString());
        roleData.add(element[2].toString());
      }
    });
  }

  void setRefresh() {
    List<String> tempUUID = [];
    List<String> tempName = [];
    List<String> tempRole = [];

    for (var element in realTableData) {
      tempUUID.add(element[0].toString());
      tempName.add(element[1].toString());
      tempRole.add(element[2].toString());
    }
    setState(() {
      uuidData = tempUUID;
      nameData = tempName;
      roleData = tempRole;
      showUUID = "";
      showName = "";
      showRole = "";
      showindex = "";
      _selectedValueName = ValueNotifier<String?>(null);
      _selectedValueUUID = ValueNotifier<String?>(null);
    });

    ;
  }

  void handleUserToUUID(int data) {
    setState(() {
      _selectedValueUUID.value = uuidData[data];
      showUUID = uuidData[data];

      showName = nameData[data];

      showRole = roleData[data];
      showindex = data.toString();
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
      showindex = data.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table List'),
      ),
      body: SingleChildScrollView(
          child: Wrap(children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Text("myEroor :" + errorMessage.toString()),
        ),
        Container(
            width: 500,
            color: Colors.amber,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "ระบบค้นหาข้อมูล",
                    style: TextStyle(fontSize: 46),
                    textAlign: TextAlign.center,
                  ),
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
                  ]),
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
                        ),
                        Flexible(
                            child: showindex == ""
                                ? SizedBox(
                                    height: 20,
                                  )
                                : Row(children: [
                                    ElevatedButton(
                                        child: (Text(
                                            "แสดง" + showindex.toString())),
                                        onPressed: (() async {
                                          List<dynamic> forUpdateOPD =
                                              realTableData[
                                                  int.parse(showindex)];
                                          print("test setstatete" +
                                              forUpdateOPD.toString());
                                          List<String> myResult =
                                              await editData(
                                                  context,
                                                  int.parse(
                                                      showindex.toString()));
                                          if (myResult != []) {
                                            String testEnv =
                                                dotenv.env['historyPath'] ??
                                                    "/data/flutter_assets";

                                            File file = File(path.current +
                                                testEnv +
                                                "/" +
                                                widget.tablePath);
                                            await updateOPD(
                                                showindex, myResult);
                                            myResult.add('');
                                            realTableData[
                                                    int.parse(showindex)] =
                                                myResult;
                                            dynamic csv =
                                                const ListToCsvConverter()
                                                    .convert(realTableData);
                                            file.writeAsStringSync(csv);

                                            setState(() {
                                              int tempIndex = showTableData[
                                                  int.parse(showindex)][4];
                                              showTableData[
                                                  int.parse(showindex)] = [
                                                myResult[0],
                                                myResult[1],
                                                myResult[2],
                                                "",
                                                tempIndex
                                              ];
                                            });

                                            setRefresh();
                                            // setState(() {
                                            //   showTableData[rowIndex] = [
                                            //     myResult[0],
                                            //     myResult[1],
                                            //     myResult[2],
                                            //     "",
                                            //     rowIndex.toString()
                                            //   ];
                                            // });
                                          }
                                        })),
                                    SizedBox(width: 4.0),
                                    InkWell(
                                      child: const Icon(
                                        Icons.cancel,
                                        size: 14.0,
                                        color: Color.fromARGB(255, 255, 0, 0),
                                      ),
                                      onTap: () async {
                                        bool test =
                                            await _showConfirmationDialog(
                                                context);
                                        if (test) {
                                          int tempIndex = showTableData[
                                              int.parse(showindex)][4];
                                          print(
                                              "deleted" + tempIndex.toString());
                                          String testEnv =
                                              dotenv.env['historyPath'] ??
                                                  "/data/flutter_assets";
                                          print(path.current);
                                          print(widget.tablePath);
                                          File file10 = File(path.current +
                                              "/" +
                                              widget.tablePath
                                                  .replaceAll(testEnv, ""));

                                          realTableData.removeAt(tempIndex);

                                          dynamic csv =
                                              const ListToCsvConverter()
                                                  .convert(realTableData);
                                          file10.writeAsStringSync(csv);
                                          setState(() {
                                            showTableData
                                                .removeAt(int.parse(showindex));
                                          });
                                          setRefresh();
                                        }
                                      },
                                    )
                                  ]))
                      ])),
                  ElevatedButton(
                      child: (Text("add data")),
                      onPressed: (() => {
                            addUser(context),
                          }))

                  // ])
                  // child: Text(
                  //   "โรงงาน" + widget.tableName,
                  //   style: TextStyle(fontSize: 46),
                  //   textAlign: TextAlign.start,
                  // )
                ])),
        Container(
            color: Colors.amberAccent,
            child: Column(children: [
              Text(
                "โรงงาน" + widget.tableName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 46),
              ),
              DataTable(
                sortAscending: _sortAscending,
                sortColumnIndex: _sortColumnIndex,
                columns: _generateTableHeader(),
                rows: _generateTableRows(),
              ),
            ])),
      ])),
    );
  }

  List<DataColumn> _generateTableHeader() {
    return header.asMap().entries.map((entry) {
      int index = entry.key;
      String headerText = entry.value;
      return DataColumn(
        label: Text(headerText),
        onSort: (columnIndex, ascending) {
          _sortTable(index, ascending);
        },
      );
    }).toList();
  }

  List<DataRow> _generateTableRows() {
    try {
      List<DataRow> dataRows = [];

      for (int rowIndex = 0; rowIndex < showTableData.length; rowIndex++) {
        List<dynamic> rowData = showTableData[rowIndex];
        List<DataCell> dataCells = rowData.map((data) {
          return DataCell(
            Text(data.toString()),
          );
        }).toList();

        dataCells.add(DataCell(
          Row(children: [
            ElevatedButton(
                child: (Text(
                    "แสดง" + rowIndex.toString() + rowData[4].toString())),
                onPressed: (() async {
                  try {
                    print("dafyq" + rowData[3]);
                    List<String> myResult = await editData(context, rowData[4]);
                    if (myResult != []) {
                      String testEnv =
                          dotenv.env['historyPath'] ?? "/data/flutter_assets";

                      File file2 = File(path.current +
                          "/" +
                          widget.tablePath.replaceAll(testEnv, ""));
                      // File file = File(widget.tablePath);
                      await updateOPD(rowData[4].toString(), myResult);
                      myResult.add('');
                      realTableData[rowData[4]] = myResult;
                      dynamic csv =
                          const ListToCsvConverter().convert(realTableData);
                      file2.writeAsStringSync(csv);
                      setState(() {
                        showTableData[rowIndex] = [
                          myResult[0],
                          myResult[1],
                          myResult[2],
                          "",
                          rowData[4]
                        ];
                      });
                      setRefresh();
                    }
                  } catch (e) {
                    String testEnv =
                        dotenv.env['historyPath'] ?? "/data/flutter_assets";
                    File file = File(path.current +
                        testEnv +
                        "/" +
                        widget.tablePath.replaceAll(testEnv, ""));
                    setState(() {
                      errorMessage = widget.tablePath.replaceAll(testEnv, "");
                      // widget.tablePath.toString() + ":" + e.toString()+ file.path;
                    });
                  }
                })),
            SizedBox(width: 4.0),
            InkWell(
              child: const Icon(
                Icons.cancel,
                size: 14.0,
                color: Color.fromARGB(255, 255, 0, 0),
              ),
              onTap: () async {
                bool test = await _showConfirmationDialog(context);
                if (test) {
                  print("deleted" + rowData[4].toString());
                  String testEnv =
                      dotenv.env['historyPath'] ?? "/data/flutter_assets";

                  File file = File(path.current + "/" + widget.tablePath);

                  realTableData.removeAt(rowData[4]);

                  dynamic csv =
                      const ListToCsvConverter().convert(realTableData);
                  file.writeAsStringSync(csv);
                  setState(() {
                    showTableData.removeAt(rowIndex);
                  });
                  setRefresh();
                }
              },
            )
          ]),
        ));
        dataRows.add(DataRow(cells: dataCells));
      }

      return dataRows;
    } catch (e) {
      print(e);
      setState(() {
        errorMessage = e.toString();
      });
      return [];
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    Completer<bool> completer = Completer<bool>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Action'),
          content: Text('Are you sure?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                completer.complete(false); // Complete with false
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                completer.complete(true); // Complete with true
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );

    return completer.future;
  }

  void _sortTable(int columnIndex, bool ascending) {
    setState(
      () {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;

        showTableData.sort((a, b) {
          var aValue = a[columnIndex];
          var bValue = b[columnIndex];
          if (aValue is String && bValue is String) {
            return ascending
                ? aValue.compareTo(bValue)
                : bValue.compareTo(aValue);
          } else if (aValue is num && bValue is num) {
            return ascending
                ? aValue.compareTo(bValue)
                : bValue.compareTo(aValue);
          } else {
            return 0;
          }
        });
      },
    );
  }

  Future<void> addUser(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AddDataDialog(
          initialAlldData: realTableData,
        );
      },
    );

    if (result != null) {
      print(
          'Field 1: ${result[0]}, Field 2: ${result[1]},Field 2: ${result[2]}');

      String testEnv = dotenv.env['historyPath'] ?? "/data/flutter_assets";

      File file = File(path.current + "/" + widget.tablePath);
      String test = file.readAsStringSync();
      List<List<dynamic>> _tempListAdd =
          const CsvToListConverter().convert(test);
      List<dynamic> tempList = [result[0], result[1], result[2], ''];
      List<dynamic> tempList2 = [
        result[0],
        result[1],
        result[2],
        "",
        showTableData.length
      ];
      _tempListAdd.add(tempList);
      dynamic csv = const ListToCsvConverter().convert(_tempListAdd);
      file.writeAsStringSync(csv);
      List<dynamic> listForReal = [
        result[0],
        result[1],
        result[2],
      ];
      setState(() {
        realTableData.add(listForReal);
        showTableData.add(tempList2);
      });
      setRefresh();

      // updateOPDByAdd(showTableData.length.toString(), tempList2);
    } else {
      print("isnull");
    }
  }

  // Future<void> updateOPDByAdd(String myTemped, List<dynamic> myUpdated) async {
  //   try {
  //     List<dynamic> myTempedList = realTableData[int.parse(myTemped)];

  //   } catch (e) {}
  // }

  Future<List<String>> editData(BuildContext context, int rowIndex) async {
    print(rowIndex);
    List<String> editDataTemp = [];
    List<dynamic> temp = realTableData[rowIndex];
    try {
      final result = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return EditDataDialog(
            initialData: temp,
            initialAlldData: showTableData,
          );
        },
      );

      if (result != null) {
        print(
            'Field 1: ${result[0]}, Field 2: ${result[1]},Field 2: ${result[2]}');
        return [result[0], result[1], result[2]];
      } else {
        return [];
      }
    } catch (e) {
      print("nani" + e.toString());
      setState(() {
        errorMessage = e.toString() + "weird";
      });
      return [];
    }
  }
}
