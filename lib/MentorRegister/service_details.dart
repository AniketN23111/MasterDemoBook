import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:passionHub/GoogleApi/cloud_api.dart'; // Replace with your import paths
import 'package:passionHub/Models/admin_service.dart'; // Replace with your import paths
import 'package:passionHub/Services/database_service.dart'; // Replace with your import paths
import 'package:http/http.dart' as http;

class ServiceDetails extends StatefulWidget {
  final String name;
  final String address;
  final String number;
  final String email;
  final String pincode;
  final String country;
  final String state;
  final String city;
  final String area;
  final String license;
  final String workingDays;
  final String timeslot;
  final String companyName;
  final String designation;
  final String gender;
  final DateTime dateOfBirth;
  final String password;

  const ServiceDetails(
    this.name,
    this.address,
    this.number,
    this.email,
    this.pincode,
    this.country,
    this.state,
    this.city,
    this.area,
    this.license,
    this.workingDays,
    this.timeslot,
    this.companyName,
    this.designation,
    this.gender,
    this.dateOfBirth,
    this.password, {
    super.key,
  });

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  TextEditingController rateController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String selectedMainServices = '';
  String selectedSubServices = '';
  List<String> selectedServices = [];
  List<AdminService> masterServices = [];
  List<XFile> selectedImages = [];
  CloudApi? cloudApi;
  bool _uploading = false;
  String? _downloadUrl;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _fetchMasterServices();
    _loadCloudApi();
    _requestPermissions();
  }

  Future<void> _loadCloudApi() async {
    String jsonCredentials = await rootBundle
        .loadString('assets/GoogleJson/clean-emblem-394910-8dd84a4022c3.json');
    setState(() {
      cloudApi = CloudApi(jsonCredentials);
    });
  }

  Future<void> _requestPermissions() async {
    if (await Permission.photos.request().isGranted) {
    } else {}
  }

  Future<void> _pickAndUploadImage() async {
    setState(() {
      _uploading = true; // Start uploading, show progress indicator
    });

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
    String fileName = pickedFile.name; // Provide a default name

    try {
      await cloudApi!.save(fileName, imageBytes);
      final downloadUrl = await cloudApi!.getDownloadUrl(fileName);

      // Store the image bytes to display it
      setState(() {
        _downloadUrl = downloadUrl;
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

  Future<void> _fetchMasterServices() async {
    DatabaseService dbService = DatabaseService();
    List<AdminService> services = await dbService.getAdminService();
    setState(() {
      masterServices = services;
    });
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage();
    setState(() {
      selectedImages = pickedImages;
    });
  }

  void addService() {
    if (selectedMainServices.isNotEmpty && selectedSubServices.isNotEmpty) {
      setState(() {
        selectedServices.add(
            'Main: $selectedMainServices - Sub: $selectedSubServices - Rate: ${rateController.text} - Quantity: ${quantityController.text} - Unit: ${unitController.text}');
        rateController.clear();
        quantityController.clear();
        unitController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> mainServices =
        masterServices.map((e) => e.service).toSet().toList();
    List<String> subServices = selectedMainServices.isNotEmpty
        ? masterServices
            .where((e) => selectedMainServices.contains(e.service))
            .map((e) => e.subService)
            .toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
      ),
      body: _isRegistering
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Services',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  widget.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _uploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Upload Image',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_downloadUrl != null)
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Uploaded Image:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Image.network(
                        _downloadUrl!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButtonFormField<String>(
                  value: selectedMainServices.isNotEmpty ? selectedMainServices : null,
                  onChanged: (value) {
                    setState(() {
                      selectedMainServices = '';
                      selectedMainServices = value!;
                      selectedSubServices = '';
                    });
                  },
                  items: mainServices
                      .map((service) => DropdownMenuItem(
                            value: service,
                            child: Text(service),
                          ))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Select Main Service',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButtonFormField<String>(
                  value: selectedSubServices.isNotEmpty ? selectedSubServices : null,
                  onChanged: (value) {
                    setState(() {
                      selectedSubServices='';
                      selectedSubServices=value!;
                    });
                  },
                  items: subServices
                      .map((subService) => DropdownMenuItem(
                            value: subService,
                            child: Text(subService),
                          ))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Select Sub Service',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: rateController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Rate',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Rate cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: Icon(Icons.add_box),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Quantity cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit of Measurement',
                    prefixIcon: Icon(Icons.linear_scale),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Unit cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: addService,
                  child: const Text('Add Service'),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Selected Services:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children:
                      selectedServices.map((service) => Text(service)).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: _isRegistering
                      ? null // Disable the button when registration is ongoing
                      : () async {
                    // Start registration
                    setState(() {
                      _isRegistering = true;
                    });
                    try {
                      if(selectedServices.isNotEmpty && _downloadUrl!=null)
                        {
                          // Register the mentor details
                          await registerMentorDetailsRegister();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Details registered successfully'),
                            backgroundColor: Colors.green,),
                          );
                          // If registration is successful, show success message and navigate to login
                          Navigator.pushReplacementNamed(context, 'loginScreen');
                        }
                      else if(_downloadUrl==null){
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Upload Photo'),
                            backgroundColor: Colors.red,),
                        );
                      }
                      else
                        {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Select At Least 1 Service'),
                              backgroundColor: Colors.red,),
                          );
                        }
                    } catch (e) {
                      // On error, stay on the current page and show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to register: $e')),
                      );
                    } finally {
                      // Reset the registering state
                      setState(() {
                        _isRegistering = false;
                      });
                    }
                  },
                  child: _isRegistering
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : const Text('Register'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> registerMentorDetailsRegister() async {
    _downloadUrl ??= 'https://storage.googleapis.com/imagestore_camera/CategoryIcon/1000035239.png';
    try {
      final response = await http.post(
        Uri.parse('https://mentor.passionit.com/mentor-api/registerMentor'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': widget.name,
          'address': widget.address,
          'mobile': widget.number,
          'email': widget.email,
          'pincode': widget.pincode,
          'country': widget.country,
          'state': widget.state,
          'city': widget.city,
          'area': widget.area,
          'license': widget.license,
          'workingDays': widget.workingDays,
          'timeslot': widget.timeslot,
          'imageUrl': _downloadUrl,
          'company_name': widget.companyName,
          'designation': widget.designation,
          'gender': widget.gender,
          'date_of_birth': widget.dateOfBirth.toIso8601String(),
          'password': widget.password,
          'selectedServices': selectedServices,
        }),
      );

      if(!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details registered successfully')),
        );
      } else {
        throw Exception('Failed to register mentor details.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register mentor details: $e')),
      );
    }
  }
}
