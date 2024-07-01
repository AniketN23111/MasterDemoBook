import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:postgres/postgres.dart';
import 'package:saloon/Constants/screen_utility.dart';
import 'package:saloon/GoogleApi/cloudApi.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _subServiceController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  Uint8List? _uploadedImageBytes;
  String? _downloadUrl;
  final ImagePicker _picker = ImagePicker();
  CloudApi? cloudApi;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadCloudApi();
    _requestPermissions();
  }

  Future<void> _loadCloudApi() async {
    String jsonCredentials =
    await rootBundle.loadString('assets/GoogleJson/clean-emblem-394910-905637ad42b3.json');
    setState(() {
      cloudApi = CloudApi(jsonCredentials);
    });
  }

  Future<void> _requestPermissions() async {
    if (await Permission.photos.request().isGranted) {
      print("Gallery access granted");
    } else {
      print("Gallery access denied");
    }
  }

  Future<void> _pickAndUploadImage() async {
    setState(() {
      _uploading = true; // Start uploading, show progress indicator
    });

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file picked')),
      );
      setState(() {
        _uploading = false; // Cancel upload, hide progress indicator
      });
      return;
    }

    if (cloudApi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud API not initialized')),
      );
      setState(() {
        _uploading = false; // Cancel upload, hide progress indicator
      });
      return;
    }

    Uint8List imageBytes = await pickedFile.readAsBytes();
    String fileName = pickedFile.name;

    try {
      // Upload the image to the bucket
      final response = await cloudApi!.save(fileName, imageBytes);
      final downloadUrl = await cloudApi!.getDownloadUrl(fileName);
      print(downloadUrl);

      // Store the image bytes to display it
      setState(() {
        _uploadedImageBytes = imageBytes;
        _downloadUrl = downloadUrl;
        _uploading = false; // Upload finished, hide progress indicator
      });
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      setState(() {
        _uploading = false; // Error in upload, hide progress indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _serviceController,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return "Service is Empty";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(15),
                    hintText: 'Service',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset('assets/icons/shop.svg'),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none)),
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _subServiceController,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return "SubService is Empty";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(15),
                    hintText: 'SubService',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset('assets/icons/shop.svg'),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: ScreenUtility.screenHeight * 0.4,
                width: ScreenUtility.screenWidth * 0.8,
                child: _downloadUrl != null
                    ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.network(_downloadUrl!),
                )
                    : _uploading
                    ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )
                    : Container(),
              ),
              ElevatedButton(
                onPressed: _uploading ? null : _pickAndUploadImage,
                child: _uploading
                    ? const CircularProgressIndicator()
                    : const Text("Upload Icon"),
              ),
              ElevatedButton(
                onPressed: () {
                  registerService(_serviceController.text, _subServiceController.text,
                      _rateController.text, _quantityController.text, _downloadUrl ?? '');
                },
                child: const Text("Add Services"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> registerService(String service, String subService, String rate, String quantity,
      String imageUrl) async {
    try {
      final connection = await Connection.open(
        Endpoint(
          host: '34.71.87.187',
          port: 5432,
          database: 'airegulation_dev',
          username: 'postgres',
          password: 'India@5555',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      // Insert into database
      await connection.execute(Sql.named('INSERT INTO ai.service_master(service, sub_service, rate, quantity, icon_url) '
          'VALUES (@service, @subService, @rate, @quantity, @imageUrl)'),
        parameters: {
          'service': service,
          'subService': subService,
          'rate': rate,
          'quantity': quantity,
          'imageUrl': imageUrl,
        },
      );

      // If successful, close the connection
      await connection.close();

      return true;
    } catch (e) {
      print("Error registering service: $e");
      return false;
    }
  }
}