import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:passionHub/LoginScreens/login_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:passionHub/Admin/dashboard_screen.dart';
import 'package:passionHub/Constants/screen_utility.dart';
import 'package:passionHub/GoogleApi/cloud_api.dart';
import 'package:passionHub/Services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _submitting = false; // Flag for showing CircularProgressIndicator
  DatabaseService dbService = DatabaseService();

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
      _uploading = true;
    });

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file picked')),
      );
      setState(() {
        _uploading = false;
      });
      return;
    }

    if (cloudApi == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud API not initialized')),
      );
      setState(() {
        _uploading = false;
      });
      return;
    }

    Uint8List imageBytes = await pickedFile.readAsBytes();
    String fileName = pickedFile.name;

    try {
      await cloudApi!.save(fileName, imageBytes);
      final downloadUrl = await cloudApi!.getDownloadUrl(fileName);

      setState(() {
        _serviceURl = downloadUrl;
        _programInitializerURl = downloadUrl;
        _uploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      setState(() {
        _uploading = false;
      });
    }
  }

  Future<void> _addService() async {
    setState(() {
      _submitting = true;
    });

    await dbService.registerService(
      _serviceController.text,
      _subServiceController.text,
      _serviceURl ?? '',
    );

    setState(() {
      _submitting = false;
      _serviceController.clear();
      _subServiceController.clear();
      _serviceURl = null;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service added successfully')),
    );
  }

  Future<void> _addProgramInitializer() async {
    setState(() {
      _submitting = true;
    });

    await dbService.registerProgramInitializer(
      _programNameController.text,
      _programDescriptionController.text,
      _organizationNameController.text,
      _programInitializerURl ?? '',
      _coordinatorNameController.text,
      _coordinatorEmailController.text,
      _coordinatorNumberController.text,
    );

    setState(() {
      _submitting = false;
      _programNameController.clear();
      _programDescriptionController.clear();
      _organizationNameController.clear();
      _coordinatorNameController.clear();
      _coordinatorEmailController.clear();
      _coordinatorNumberController.clear();
      _programInitializerURl = null;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Program initializer added successfully')),
    );
  }
  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/icons/admin.svg'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Admin",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap:  logout,
            ),
            // Add other drawer items here
          ],
        ),
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
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const DashboardScreen()));
                      });
                    },
                    child: const Text('DashBoard'),
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
          onPressed: _submitting ? null : _addService,
          child: _submitting
              ? const CircularProgressIndicator(
            color: Colors.white,
          )
              : const Text("Add Services"),
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
            hintText: 'Coordinator Name',
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
            hintText: 'Coordinator Email',
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
            hintText: 'Coordinator Number',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: ScreenUtility.screenHeight * 0.4,
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
          onPressed: _submitting ? null : _addProgramInitializer,
          child: _submitting
              ? const CircularProgressIndicator(
            color: Colors.white,
          )
              : const Text("Add Program Initializer"),
        ),
      ],
    );
  }
}
