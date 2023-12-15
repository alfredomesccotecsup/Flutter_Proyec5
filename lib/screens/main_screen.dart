import 'package:flutter/material.dart';
import 'package:food_example/constants.dart';
import 'package:food_example/screens/home_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmpresaScreen extends StatefulWidget {
  @override
  _EmpresaScreenState createState() => _EmpresaScreenState();
}

class _EmpresaScreenState extends State<EmpresaScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<Company> companies = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:9000/api/empresa'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          companies =
              responseData.map((json) => Company.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Parking App'),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: fetchData,
        child: companies.isNotEmpty
            ? ListView.builder(
                itemCount: companies.length,
                itemBuilder: (context, index) {
                  return CompanyCard(
                      company: companies[index],
                      onTap: () => showNiveles(context, companies[index].id));
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  Future<void> showNiveles(BuildContext context, String empresaId) async {
    final nivelesResponse = await http
        .get(Uri.parse('http://localhost:9000/api/nivel?empresaId=$empresaId'));
    if (nivelesResponse.statusCode == 200) {
      final List<dynamic> nivelesData = json.decode(nivelesResponse.body);
      List<Nivel> niveles =
          nivelesData.map((json) => Nivel.fromJson(json)).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NivelesPage(
                  niveles: niveles,
                  onUpdate: fetchData,
                )),
      );
    } else {
      print('Failed to load niveles');
    }
  }
}

class NivelesPage extends StatelessWidget {
  final List<Nivel> niveles;
  final VoidCallback onUpdate;

  NivelesPage({required this.niveles, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Niveles de la empresa'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          onUpdate();
          await Future.delayed(Duration(seconds: 2));
        },
        child: ListView.builder(
          itemCount: niveles.length,
          itemBuilder: (context, index) {
            return NivelCard(nivel: niveles[index]);
          },
        ),
      ),
    );
  }
}

class Company {
  final String id;
  final String nombre;
  final String email;
  final int telefono;
  final String imagen;

  Company({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.imagen,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? 0,
      imagen: json['imagen'] ?? '',
    );
  }
}

class Nivel {
  final String id;
  final String nivel;
  final String imagen;
  final Company empresa;

  Nivel({
    required this.id,
    required this.nivel,
    required this.imagen,
    required this.empresa,
  });

  factory Nivel.fromJson(Map<String, dynamic> json) {
    return Nivel(
      id: json['_id'] ?? '',
      nivel: json['nivel'] ?? '',
      imagen: json['imagen'] ?? '',
      empresa: Company.fromJson(json['empresa'] ?? {}),
    );
  }
}

class CompanyCard extends StatelessWidget {
  final Company company;
  final VoidCallback onTap;

  CompanyCard({required this.company, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: 'http://localhost:9000/${company.imagen}',
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) {
                print('Error loading image: $error');
                return CachedNetworkImage(
                  imageUrl:
                      'https://circontrol.com/wp-content/uploads/2023/10/180125-Circontrol-BAIXA-80-1.jpg',
                  width: 100,
                  height: 100,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                );
              },
            ),
            ListTile(
              title: Text(company.nombre),
              subtitle: Text(company.email),
              trailing: Text('Teléfono: ${company.telefono}'),
            ),
          ],
        ),
      ),
    );
  }
}

class NivelCard extends StatelessWidget {
  final Nivel nivel;

  NivelCard({required this.nivel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: nivel.imagen,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) {
              print('Error loading image: $error');
              return CachedNetworkImage(
                imageUrl:
                    'https://circontrol.com/wp-content/uploads/2023/10/180125-Circontrol-BAIXA-80-1.jpg',
                width: 100,
                height: 100,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              );
            },
          ),
          ListTile(
            title: Text(nivel.nivel),
            subtitle: Text('Empresa: ${nivel.empresa.nombre}'),
            trailing: ElevatedButton(
              onPressed: () => showParking(context, nivel.id),
              child: Text('Mostrar Parking'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showParking(BuildContext context, String nivelId) async {
    final parkingResponse = await http
        .get(Uri.parse('http://localhost:9000/api/parking?nivelId=$nivelId'));
    if (parkingResponse.statusCode == 200) {
      final List<dynamic> parkingData = json.decode(parkingResponse.body);
      List<Parking> parkingList =
          parkingData.map((json) => Parking.fromJson(json)).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParkingPage(
            parkingList: parkingList,
            onUpdate: onUpdate,
          ),
        ),
      );
    } else {
      print('Failed to load parking');
    }
  }

  Future<void> onUpdate() async {
    // Puedes agregar aquí cualquier lógica necesaria al actualizar
    print('Actualizado');
  }
}

class ParkingPage extends StatelessWidget {
  final List<Parking> parkingList;
  final VoidCallback onUpdate;

  ParkingPage({required this.parkingList, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lugares de estacionamiento'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          onUpdate();
          await Future.delayed(Duration(seconds: 2));
        },
        child: ListView.builder(
          itemCount: parkingList.length,
          itemBuilder: (context, index) {
            return ParkingCard(parking: parkingList[index]);
          },
        ),
      ),
    );
  }
}

class Parking {
  final String id;
  final String lugar;
  final Nivel nivel;
  final bool estado;

  Parking({
    required this.id,
    required this.lugar,
    required this.nivel,
    required this.estado,
  });

  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['_id'] ?? '',
      lugar: json['lugar'] ?? '',
      nivel: Nivel.fromJson(json['nivel'] ?? {}),
      estado: json['estado'] ?? false,
    );
  }
}

class ParkingCard extends StatelessWidget {
  final Parking parking;

  ParkingCard({required this.parking});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('Lugar: ${parking.lugar}'),
            subtitle: Text('Estado: ${parking.estado ? 'Ocupado' : 'Libre'}'),
          ),
        ],
      ),
    );
  }
}





class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool darkModeEnabled = false;
  int fontSize = 16;
  String language = 'English';
  bool notificationsEnabled = true;
  bool autoPlayVideos = true;
  String defaultThemeColor = 'Blue';
  int maxItemCount = 10;
  bool showImages = true;
  bool enableBiometrics = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      darkModeEnabled = _prefs.getBool('darkMode') ?? false;
      fontSize = _prefs.getInt('fontSize') ?? 16;
      language = _prefs.getString('language') ?? 'English';
      notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
      autoPlayVideos = _prefs.getBool('autoPlayVideos') ?? true;
      defaultThemeColor = _prefs.getString('defaultThemeColor') ?? 'Blue';
      maxItemCount = _prefs.getInt('maxItemCount') ?? 10;
      showImages = _prefs.getBool('showImages') ?? true;
      enableBiometrics = _prefs.getBool('enableBiometrics') ?? false;
    });
  }

  _saveSettings() {
    _prefs.setBool('darkMode', darkModeEnabled);
    _prefs.setInt('fontSize', fontSize);
    _prefs.setString('language', language);
    _prefs.setBool('notificationsEnabled', notificationsEnabled);
    _prefs.setBool('autoPlayVideos', autoPlayVideos);
    _prefs.setString('defaultThemeColor', defaultThemeColor);
    _prefs.setInt('maxItemCount', maxItemCount);
    _prefs.setBool('showImages', showImages);
    _prefs.setBool('enableBiometrics', enableBiometrics);
    // Puedes guardar más configuraciones aquí
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración de tema',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text('Modo oscuro'),
              value: darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  darkModeEnabled = value;
                  _saveSettings(); // Guardar configuración
                  // Cambiar el tema aquí según el valor de darkModeEnabled
                  // Puedes usar ThemeData.dark() o ThemeData.light() según sea necesario
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Configuración de texto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: fontSize.toDouble(),
              min: 12,
              max: 24,
              divisions: 12,
              label: fontSize.toString(),
              onChanged: (value) {
                setState(() {
                  fontSize = value.toInt();
                  _saveSettings(); // Guardar configuración
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Configuración de idioma',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: language,
              onChanged: (value) {
                setState(() {
                  language = value!;
                  _saveSettings(); // Guardar configuración
                });
              },
              items: ['English', 'Spanish', 'French']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Configuración de notificaciones',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text('Notificaciones'),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                  _saveSettings(); // Guardar configuración
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Configuración de videos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text('Reproducción automática de videos'),
              value: autoPlayVideos,
              onChanged: (value) {
                setState(() {
                  autoPlayVideos = value;
                  _saveSettings(); // Guardar configuración
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Configuración de colores',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: defaultThemeColor,
              onChanged: (value) {
                setState(() {
                  defaultThemeColor = value!;
                  _saveSettings(); // Guardar configuración
                });
              },
              items: ['Blue', 'Red', 'Green', 'Yellow']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
                
        
            SizedBox(height: 16),
            Text(
              'Configuración de seguridad',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text('Habilitar biometría'),
              value: enableBiometrics,
              onChanged: (value) {
                setState(() {
                  enableBiometrics = value;
                  _saveSettings(); // Guardar configuración
                });
              },
            ),
            
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentTab = 0;
  List screens = [
    HomeScreen(),
    EmpresaScreen(), // Aquí no debe haber coma al final
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => setState(() {
                currentTab = 0;
              }),
              child: Column(
                children: [
                  Icon(
                    currentTab == 0 ? Iconsax.home5 : Iconsax.home,
                    color: currentTab == 0 ? kprimaryColor : Colors.grey,
                  ),
                  Text(
                    "Home",
                    style: TextStyle(
                      fontSize: 14,
                      color: currentTab == 0 ? kprimaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                currentTab = 1;
              }),
              child: Column(
                children: [
                  Icon(
                    currentTab == 1 ? Iconsax.car5 : Icons.directions_car,
                    color: currentTab == 1 ? kprimaryColor : Colors.grey,
                  ),
                  Text(
                    "Parking",
                    style: TextStyle(
                      fontSize: 14,
                      color: currentTab == 1 ? kprimaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            GestureDetector(
              onTap: () => setState(() {
                currentTab = 2;
              }),
              child: Column(
                children: [
                  Icon(
                    currentTab == 3 ? Iconsax.setting5 : Iconsax.setting,
                    color: currentTab == 3 ? kprimaryColor : Colors.grey,
                  ),
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 14,
                      color: currentTab == 3 ? kprimaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: screens[currentTab],
    );
  }
}
