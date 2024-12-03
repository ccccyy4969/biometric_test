import 'package:flutter/material.dart';
import 'package:biometric_storage/biometric_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biometric Storage Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BiometricStorageScreen(),
    );
  }
}

class BiometricStorageScreen extends StatefulWidget {
  const BiometricStorageScreen({Key? key}) : super(key: key);

  @override
  _BiometricStorageScreenState createState() => _BiometricStorageScreenState();
}

class _BiometricStorageScreenState extends State<BiometricStorageScreen> {
  final TextEditingController _textController = TextEditingController();
  String _status = '';
  String _storedData = '';

  Future<BiometricStorageFile> _getStorage() async {
    return await BiometricStorage().getStorage(
      'my_secure_storage',
      options: StorageFileInitOptions(
        authenticationRequired: true,
        authenticationValidityDurationSeconds: -1,
      ),
    );
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final authResponse = await BiometricStorage().canAuthenticate();
      setState(() {
        switch (authResponse) {
          case CanAuthenticateResponse.success:
            _status = 'Biometric authentication is available';
            break;
          case CanAuthenticateResponse.statusUnknown:
            _status = 'Unable to determine if biometrics are available';
            break;
          case CanAuthenticateResponse.errorHwUnavailable:
            _status = 'Biometric hardware is currently unavailable';
            break;
          case CanAuthenticateResponse.errorNoBiometricEnrolled:
            _status = 'No biometric credentials are enrolled';
            break;
          case CanAuthenticateResponse.errorNoHardware:
            _status = 'No biometric hardware available';
            break;
          case CanAuthenticateResponse.unsupported:
            _status = 'Biometric authentication is not supported';
            break;
          default:
            _status = 'Unknown biometric status';
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking biometric availability: $e';
      });
    }
  }

  Future<void> _saveData() async {
    try {
      final storage = await _getStorage();
      await storage.write(_textController.text);
      setState(() {
        _status = 'Data saved successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Error saving data: $e';
      });
    }
  }

  Future<void> _readData() async {
    try {
      final storage = await _getStorage();
      final data = await storage.read();
      setState(() {
        _storedData = data ?? 'No data stored';
        _status = 'Data read successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Error reading data: $e';
      });
    }
  }

  Future<void> _deleteData() async {
    try {
      final storage = await _getStorage();
      await storage.delete();
      setState(() {
        _storedData = '';
        _status = 'Data deleted successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Error deleting data: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Storage Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter data to store',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveData,
              child: const Text('Save Data (Requires Authentication)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _readData,
              child: const Text('Read Data (Requires Authentication)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _deleteData,
              child: const Text('Delete Data (Requires Authentication)'),
            ),
            const SizedBox(height: 16),
            Text('Status: $_status',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Stored Data:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_storedData),
          ],
        ),
      ),
    );
  }
}