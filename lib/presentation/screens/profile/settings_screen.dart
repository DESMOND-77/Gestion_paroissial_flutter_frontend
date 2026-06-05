// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   final StorageService _storage = StorageService();
//   PackageInfo _packageInfo = PackageInfo(
//     appName: 'Unknown',
//     packageName: 'Unknown',
//     version: 'Unknown',
//     buildNumber: 'Unknown',
//     buildSignature: 'Unknown',
//   );

//   bool _scannerVibrate = true;
//   bool _scannerSound = true;
//   bool _scannerAutoScan = true;
//   bool _darkMode = false;
//   String? _apiBaseUrl;

//   @override
//   void initState() {
//     super.initState();
//     _initPackageInfo();
//     _loadSettings();
//   }

//   Future<void> _initPackageInfo() async {
//     final info = await PackageInfo.fromPlatform();
//     setState(() => _packageInfo = info);
//   }

//   Future<void> _loadSettings() async {
//     final settings = await _storage.getScannerSettings();
//     setState(() {
//       _scannerVibrate = settings['vibrate'] ?? true;
//       _scannerSound = settings['sound'] ?? true;
//       _scannerAutoScan = settings['auto_scan'] ?? true;
//     });

//     final baseUrl = await _storage.getBaseUrl();
//     setState(() => _apiBaseUrl = baseUrl);
//   }


//   Future<void> _saveBaseUrl() async {
//     if (_apiBaseUrl != null && _apiBaseUrl!.isNotEmpty) {
//       await _storage.saveBaseUrl(_apiBaseUrl!);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('URL API mise à jour')),
//       );
//     }
//   }

//   void _resetSettings() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Réinitialiser les paramètres'),
//         content: Text(
//           'Voulez-vous vraiment réinitialiser tous les paramètres à leurs valeurs par défaut ?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Annuler'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _storage.clear();
//               // Recharger les paramètres par défaut
//               await _loadSettings();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Paramètres réinitialisés'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             },
//             child: Text('Réinitialiser', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSection({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Card(
//       elevation: 2,
//       margin: EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Paramètres'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: () async {
//               await _saveScannerSettings();
//               await _saveBaseUrl();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Paramètres sauvegardés'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Scanner
          
//             // Apparence
//             _buildSection(
//               title: 'Apparence',
//               children: [
//                 SwitchListTile(
//                   title: Text('Mode sombre'),
//                   subtitle: Text('Activer le thème sombre'),
//                   value: _darkMode,
//                   onChanged: (value) {
//                     setState(() => _darkMode = value);
//                     // TODO: Implémenter le changement de thème
//                   },
//                 ),
//               ],
//             ),

//             // Connexion
//             _buildSection(
//               title: 'Connexion',
//               children: [
//                 TextField(
//                   onChanged: (value) => _apiBaseUrl = value,
//                   decoration: InputDecoration(
//                     labelText: 'URL de l\'API',
//                     hintText: 'http://192.168.1.100:8000',
//                     border: OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: Icon(Icons.info),
//                       onPressed: () {
//                         showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: Text('URL API'),
//                             content: Text(
//                               'Saisissez l\'adresse IP de votre serveur Django '
//                               'suivie du port 8000.\n\n'
//                               'Exemple: http://192.168.1.100:8000',
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 child: Text('OK'),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   controller: TextEditingController(text: _apiBaseUrl),
//                 ),
//                 SizedBox(height: 16),
//                 ListTile(
//                   leading: Icon(Icons.wifi, color: Colors.grey),
//                   title: Text('État de la connexion'),
//                   subtitle: Text('Connecté'), // TODO: Vérifier la connexion
//                   trailing: Icon(Icons.check_circle, color: Colors.green),
//                 ),
//               ],
//             ),

//             // Compte
//             _buildSection(
//               title: 'Compte',
//               children: [
//                 ListTile(
//                   leading: Icon(Icons.person, color: Colors.grey),
//                   title: Text('Nom d\'utilisateur'),
//                   subtitle: Text(authProvider.user?.username ?? 'Non connecté'),
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.email, color: Colors.grey),
//                   title: Text('Email'),
//                   subtitle: Text(authProvider.user?.email ?? 'Non disponible'),
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.security, color: Colors.grey),
//                   title: Text('Changer le mot de passe'),
//                   onTap: () {
//                     // TODO: Changer mot de passe
//                   },
//                 ),
//               ],
//             ),

//             // À propos et aide
//             _buildSection(
//               title: 'À propos',
//               children: [
//                 ListTile(
//                   leading: Icon(Icons.info, color: Colors.grey),
//                   title: Text('Version'),
//                   subtitle: Text('${_packageInfo.version} (${_packageInfo.buildNumber})'),
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.help, color: Colors.grey),
//                   title: Text('Aide et support'),
//                   onTap: () async {
//                     const url = 'mailto:support@ticketqr.com';
//                     if (await canLaunch(url)) {
//                       await launch(url);
//                     }
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.privacy_tip, color: Colors.grey),
//                   title: Text('Politique de confidentialité'),
//                   onTap: () async {
//                     const url = 'https://votredomaine.com/privacy';
//                     if (await canLaunch(url)) {
//                       await launch(url);
//                     }
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.description, color: Colors.grey),
//                   title: Text('Conditions d\'utilisation'),
//                   onTap: () async {
//                     const url = 'https://votredomaine.com/terms';
//                     if (await canLaunch(url)) {
//                       await launch(url);
//                     }
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.bug_report, color: Colors.grey),
//                   title: Text('Signaler un problème'),
//                   onTap: () async {
//                     const url = 'https://github.com/votre-repo/issues';
//                     if (await canLaunch(url)) {
//                       await launch(url);
//                     }
//                   },
//                 ),
//               ],
//             ),

//             // Actions avancées
//             _buildSection(
//               title: 'Avancé',
//               children: [
//                 ListTile(
//                   leading: Icon(Icons.backup, color: Colors.grey),
//                   title: Text('Exporter les données'),
//                   onTap: () {
//                     // TODO: Exporter données
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.restore, color: Colors.grey),
//                   title: Text('Importer les données'),
//                   onTap: () {
//                     // TODO: Importer données
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.delete, color: Colors.red),
//                   title: Text(
//                     'Effacer le cache',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                   onTap: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: Text('Effacer le cache'),
//                         content: Text(
//                           'Voulez-vous vraiment effacer le cache de l\'application ? '
//                           'Cela peut améliorer les performances.',
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: Text('Annuler'),
//                           ),
//                           TextButton(
//                             onPressed: () async {
//                               Navigator.pop(context);
//                               // TODO: Effacer le cache
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Cache effacé')),
//                               );
//                             },
//                             child: Text('Effacer'),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.restore_page, color: Colors.red),
//                   title: Text(
//                     'Réinitialiser les paramètres',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                   onTap: _resetSettings,
//                 ),
//               ],
//             ),

//             // Déconnexion
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton.icon(
//                 icon: Icon(Icons.logout),
//                 label: Padding(
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   child: Text(
//                     'Se déconnecter',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//                 onPressed: () async {
//                   await authProvider.logout();
//                   Navigator.pushReplacementNamed(context, '/login');
//                 },
//                 style: OutlinedButton.styleFrom(
//                   side: BorderSide(color: Colors.red),
//                 ),
//               ),
//             ),

//             SizedBox(height: 40),

//             // Copyright
//             Center(
//               child: Column(
//                 children: [
//                   Text(
//                     'Ticket QR System',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   Text(
//                     '© ${DateTime.now().year} Tous droits réservés',
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: Colors.grey.shade400,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }