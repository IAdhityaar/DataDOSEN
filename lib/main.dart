import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Dosen>> fetchDosens(http.Client client) async {
  final response =
      await client.get('https://iadhityaranius.000webhostapp.com/readDatajson.php');

  // Use the compute function to run parseDosens in a separate isolate.
  return compute(parseDosens, response.body);
}

// A function that converts a response body into a List<Dosen>.
List<Dosen> parseDosens(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Dosen>((json) => Dosen.fromJson(json)).toList();
}

class Dosen {
  final String nidn;
  final String nama_dosen;
  final String jenjang_akademik;
  final String pendidikan_trakhir;
  final String home_base;

  Dosen({this.nidn, this.nama_dosen, this.jenjang_akademik, this.pendidikan_trakhir, this.home_base});

  factory Dosen.fromJson(Map<String, dynamic> json) {
    return Dosen(
      nidn: json['nidn'] as String,
      nama_dosen: json['nama_dosen'] as String,
      jenjang_akademik: json['jenjang_akademik'] as String,
      pendidikan_trakhir: json['pendidikan_trakhir'] as String,
      home_base: json['home_base'] as String,
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Sistem Data Dosen';

    return MaterialApp(
    initialRoute: '/',
    routes: {
      
      '/': (context) => MyHomePage(title: "Data Dosen"),
      '/add': (context) => InputData(),
            
    },
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add',
            onPressed: () {
              print("test");
              Navigator.pushNamed(context, '/add');
            },
          ),
          
        ],
      ),
      body: FutureBuilder<List<Dosen>>(
        future: fetchDosens(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? DosensList(DosenData: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class DosensList extends StatelessWidget {
  final List<Dosen> DosenData;

  DosensList({Key key, this.DosenData}) : super(key: key);



Widget viewData(var data,int index)
{
return Container(
    width: 200,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.green,
      elevation: 10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
            //ClipRRect(
              //      borderRadius: BorderRadius.only(
                //      topLeft: Radius.circular(8.0),
                  //    topRight: Radius.circular(8.0),
                   // ),
                   // child: Image.network(
                    //    "https://elearning.binadarma.ac.id/pluginfile.php/1/theme_lambda/logo/1602057627/ubd_logo.png"
                    //    width: 100,
                     //   height: 50,
                        //fit:BoxFit.fill

                   // ),
                 // ),
            
          ListTile(
           //leading: Image.network(
             //   "https://elearning.binadarma.ac.id/pluginfile.php/1/theme_lambda/logo/1602057627/ubd_logo.png",
             // ),
            title: Text(data[index].nidn, style: TextStyle(color: Colors.white)),
            subtitle: Text(data[index].nama_dosen, style: TextStyle(color: Colors.white)),
          ),
          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Text('Edit', style: TextStyle(color: Colors.white)),
                  onPressed: () {},
                ),
                FlatButton(
                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: DosenData.length,
      itemBuilder: (context, index) {
        return viewData(DosenData,index);
      },
    );
  }
}

Future saveData(BuildContext context,String nidn,String nama_dosen,String jenjang_akademik,String pendidikan_trakhir,String home_base) async{

// API URL
    var url = 'https://iadhityaranius.000webhostapp.com/saveData.php';

    // Store all data with Param Name.
    var data = {'nidn':nidn,'nama_dosen': nama_dosen,'jenjang_akademik':jenjang_akademik,'pendidikan_trakhir':pendidikan_trakhir, 'home_base': home_base};

    // Starting Web Call with data.
    var response = await http.post(url, body: json.encode(data));

    // Getting Server response into variable.
    var message = jsonDecode(response.body);

    
    if(response.statusCode == 200){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(message),
          actions: <Widget>[
            FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                //Navigator.pushNamed(context, '/');  //keluar
              },
            ),
          ],
        );
      },
    );
     
  
    }
    else
   
    // Showing Alert Dialog with Response JSON.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(message),
          actions: <Widget>[
            FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
     
  }

class InputData extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<InputData> {
  TextEditingController nama_dosenController = TextEditingController();
  TextEditingController nidnController = TextEditingController();
  TextEditingController jenjang_akademikController = TextEditingController();
  TextEditingController pendidikan_trakhirController = TextEditingController();
  TextEditingController home_baseController = TextEditingController();
  
  String nidnDOSEN = '';
  String nama_Dosen = '';
  String jenjang_Akademik = '';
  String pendidikan_Trakhir = '';
  String home_Base = '';
  
  Widget _inputNama_Dosen() {
    return Container(
        margin: EdgeInsets.all(20),
        child: TextField(
          controller: nama_dosenController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nama Lengkap Dosen",
          ),
          onChanged: (text) {
            setState(() {
              nama_Dosen = text;
              //you can access nameController in its scope to get
              // the value of text entered as shown below
              //nama_Dosen = nama_dosenController.text;
            });
          },
        ));
  }

  Widget _inputNIDN() {
    return Container(
        margin: EdgeInsets.all(20),
        child: TextField(
          controller: nidnController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nomor Induk Dosen Nasional",
          ),
          onChanged: (text) {
            setState(() {
              nidnDOSEN = text;
              //you can access nameController in its scope to get
              // the value of text entered as shown below
              //nimDOSEN = nameController.text;
            });
          },
        ));
  }


 Widget _inputJenjang_Akademik() {
    return Container(
        margin: EdgeInsets.all(20),
        child: TextField(
          controller: jenjang_akademikController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Jenjang Akademik",
          ),
          onChanged: (text) {
            setState(() {
              jenjang_Akademik = text;
             
            });
          },
        ));
  }

Widget _inputPendidikan_Trakhir() {
    return Container(
        margin: EdgeInsets.all(20),
        child: TextField(
          controller: pendidikan_trakhirController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Pendidikan Trakhir",
          ),
          onChanged: (text) {
            setState(() {
              pendidikan_Trakhir = text;
             
            });
          },
        ));
  }

Widget _inputHome_Base() {
    return Container(
        margin: EdgeInsets.all(20),
        child: TextField(
          controller: home_baseController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Home Base",
          ),
          onChanged: (text) {
            setState(() {
              home_Base = text;
             
            });
          },
        ));
  }

Widget _submit() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          // Validate will return true if the form is valid, or false if
          // the form is invalid.
          print(nidnDOSEN);
          print(nama_Dosen);
          if ((nidnDOSEN.isEmpty) || (nama_Dosen.isEmpty)) {
            print("NIDN atau Nama tidak boleh kosong !!");
          
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Thanks!'),
                content: Text('NIDN atau Nama tidak boleh kosong !!'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          }
          else
          {saveData(context,nidnDOSEN,nama_Dosen,jenjang_Akademik,pendidikan_Trakhir,home_Base );}  ///end if
        },
        child: Text('Submit'),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        
          appBar: AppBar(
            title: Text('Input Data Dosen'),
          ),
          body: Center(
              child: Column(children: <Widget>[
                _inputNIDN(),
            _inputNama_Dosen(),
            _inputJenjang_Akademik(),
            _inputPendidikan_Trakhir(),
            _inputHome_Base(),
                _submit(),
            
            Container(
              margin: EdgeInsets.all(20),
              child: Text(nama_Dosen),
            ),
          ])),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Close', // used by assistive technologies
            child: Icon(Icons.close),
            onPressed: () {
                Navigator.of(context).pop();
              //Navigator.pushNamed(context, '/');
            },
          )),
    );
  }
}