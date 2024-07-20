import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:postgres/postgres.dart';
import 'package:saloon/Constants/screen_utility.dart';
import 'package:saloon/GoogleApi/cloud_api.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _subServiceController = TextEditingController();

  final TextEditingController _programNameController = TextEditingController();
  final TextEditingController _programDescriptionController = TextEditingController();
  final TextEditingController _organizationNameController = TextEditingController();
  final TextEditingController _coordinatorNameController = TextEditingController();
  final TextEditingController _coordinatorEmailController = TextEditingController();
  final TextEditingController _coordinatorNumberController = TextEditingController();

  String? _serviceURl;
  String? _programInitializerURl;
  final ImagePicker _picker = ImagePicker();
  CloudApi? cloudApi;
  bool _uploading = false;
  bool _showServiceForm = false;

  @override
  void initState() {
    super.initState();
    _loadCloudApi();
    _requestPermissions();
  }

  Future<void> _loadCloudApi() async {
    String jsonCredentials =
    await rootBundle.loadString('assets/GoogleJson/clean-emblem-394910-8dd84a4022c3.json');
    setState(() {
      cloudApi = CloudApi(jsonCredentials);
    });
  }

  Future<void> _requestPermissions() async {
    if (await Permission.photos.request().isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery access granted')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery access denied')),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    setState(() {
      _uploading = true; // Start uploading, show progress indicator
    });

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file picked')),
      );
      setState(() {
        _uploading = false; // Cancel upload, hide progress indicator
      });
      return;
    }

    if (cloudApi == null) {
      if (!mounted) return;
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
      await cloudApi!.save(fileName, imageBytes);
      final downloadUrl = await cloudApi!.getDownloadUrl(fileName);

      // Store the image bytes to display it
      setState(() {
        _serviceURl = downloadUrl;
        _programInitializerURl = downloadUrl;
        _uploading = false; // Upload finished, hide progress indicator
      });
    } catch (e) {
      if (!mounted) return;
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
        title: const Text('Admin Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showServiceForm = true;
                      });
                    },
                    child: const Text('Service'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showServiceForm = false;
                      });
                    },
                    child: const Text('Program Initializers'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _showServiceForm ? _buildServiceForm() : _buildInitializerForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceForm() {
    return Column(
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
              child: SvgPicture.asset('assets/icons/license.svg'),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),
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
              child: SvgPicture.asset('assets/icons/license.svg'),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: ScreenUtility.screenHeight * 0.4,
          width: ScreenUtility.screenWidth * 0.8,
          child: _serviceURl != null
              ? Padding(
            padding: const EdgeInsets.all(20),
            child: Image.network(_serviceURl!),
          )
              : _uploading
              ? const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          )
              : Container(),
        ),
        ElevatedButton(
          onPressed: _uploading ? null : _pickAndUploadImage,
          child: _uploading
              ? const CircularProgressIndicator(
            color: Colors.blue,
          )
              : const Text("Upload Icon"),
        ),
        ElevatedButton(
          onPressed: () {
            registerService(
              _serviceController.text,
              _subServiceController.text,
              _serviceURl ?? '',
            );
          },
          child: const Text("Add Services"),
        ),
      ],
    );
  }

  Widget _buildInitializerForm() {
    return Column(
      children: [
        TextFormField(
          keyboardType: TextInputType.text,
          controller: _programNameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            hintText: 'Program Name',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          keyboardType: TextInputType.text,
          controller: _programDescriptionController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            hintText: 'Program Description',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          keyboardType: TextInputType.text,
          controller: _organizationNameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            hintText: 'Organization Name',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          keyboardType: TextInputType.text,
          controller: _coordinatorNameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            hintText: 'Program Coordinator Name',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: _coordinatorEmailController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            hintText: 'Program Coordinator Email',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          keyboardType: TextInputType.phone,
          controller: _coordinatorNumberController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            hintText: 'Program Coordinator Number',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: ScreenUtility.screenHeight * 0.2,
          width: ScreenUtility.screenWidth * 0.8,
          child: _programInitializerURl != null
              ? Padding(
            padding: const EdgeInsets.all(20),
            child: Image.network(_programInitializerURl!),
          )
              : _uploading
              ? const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          )
              : Container(),
        ),
        ElevatedButton(
          onPressed: _uploading ? null : _pickAndUploadImage,
          child: _uploading
              ? const CircularProgressIndicator(
            color: Colors.blue,
          )
              : const Text("Upload Icon"),
        ),
        ElevatedButton(
          onPressed: () {
            registerProgramInitializer(
              _programNameController.text,
              _programDescriptionController.text,
              _organizationNameController.text,
              _programInitializerURl ?? '',
              _coordinatorNameController.text,
              _coordinatorEmailController.text,
              _coordinatorNumberController.text,
            );
          },
          child: const Text("Add Program Initializer"),
        ),
      ],
    );
  }

  Future<bool> registerService(
      String service, String subService, String imageUrl) async {
    try {
      final connection = await Connection.open(
        Endpoint(
          host: '34.71.87.187',
          port: 5432,
          database: 'datagovernance',
          username: 'postgres',
          password: 'India@5555',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      await connection.execute(
        'INSERT INTO public.service_master(service, sub_service, icon_url) VALUES (@service, @subService, @icon)',
        parameters: {
          'service': service,
          'subService': subService,
          'icon': imageUrl,
        },
      );

      await connection.close();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service registered successfully')),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error registering service')),
      );
      return false;
    }
  }

  Future<bool> registerProgramInitializer(
      String programName,
      String programDescription,
      String organizationName,
      String imageUrl,
      String coordinatorName,
      String coordinatorEmail,
      String coordinatorNumber,
      ) async {
    try {
      final connection = await Connection.open(
        Endpoint(
          host: '34.71.87.187',
          port: 5432,
          database: 'datagovernance',
          username: 'postgres',
          password: 'India@5555',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      await connection.execute(Sql.named('INSERT INTO public.program_initializer(program_name, program_description, organization_name, icon_url, coordinator_name, coordinator_email, coordinator_number) '
          'VALUES (@programName, @programDescription, @organizationName, @iconUrl, @coordinatorName, @coordinatorEmail, @coordinatorNumber)'),
        parameters: {
          'programName': programName,
          'programDescription': programDescription,
          'organizationName': organizationName,
          'iconUrl': imageUrl,
          'coordinatorName': coordinatorName,
          'coordinatorEmail': coordinatorEmail,
          'coordinatorNumber': coordinatorNumber,
        },
      );

      await connection.close();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program initializer registered successfully')),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error registering program initializer')),
      );
      return false;
    }
  }
}
