import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:postgres/postgres.dart';
import 'package:saloon/GoogleApi/cloud_api.dart'; // Replace with your import paths
import 'package:saloon/Models/admin_service.dart'; // Replace with your import paths
import 'package:saloon/Services/database_service.dart'; // Replace with your import paths

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
  List<String> selectedMainServices = [];
  List<String> selectedSubServices = [];
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
            'Main: ${selectedMainServices.join(',')} - Sub: ${selectedSubServices.join(',')} - Rate: ${rateController.text} - Quantity: ${quantityController.text} - Unit: ${unitController.text}');
        selectedMainServices.clear();
        selectedSubServices.clear();
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
                  value: null,
                  onChanged: (value) {
                    setState(() {
                      selectedMainServices.add(value!);
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
                  value: null,
                  onChanged: (value) {
                    setState(() {
                      selectedSubServices.add(value!);
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
                      ? null
                      : () async {
                      setState(() {
                        _isRegistering = true;
                      });
                      try {
                        // Register the shop details
                         registerMentorDetailsRegister();
                        // Navigate to the login page after registration
                        Navigator.pushReplacementNamed(
                            context, '/login');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                              Text('Failed to register: $e')),
                        );
                      } finally {
                        setState(() {
                          _isRegistering = false;
                        });
                      }
                  },
                  child: const Text('Register'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void registerMentorDetailsRegister() async {
    late Connection connection;

    try {
      // Open the database connection
      connection = await Connection.open(
        Endpoint(
          host: '34.71.87.187',
          port: 5432,
          database: 'datagovernance',
          username: 'postgres',
          password: 'India@5555',
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );

      // Insert into public.master_details table and get the generated advisor_id
      final result = await connection.execute(Sql.named('''
      INSERT INTO public.advisor_details (
        name, address, mobile, email, pincode, country, state, city, area, license, working_days, timeslot, image_url ,company_name,designation,gender,date_of_birth,password
      ) VALUES (
        @name, @address, @mobile, @email, @pincode, @country, @state, @city, @area, @license, @workingDays, @timeslot, @imageUrl, @company_name, @designation, @gender,@date_of_birth, @password
      ) RETURNING advisor_id;
    '''), parameters: {
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
        'date_of_birth': widget.dateOfBirth,
        'password':widget.password,
      });
      if (result.isEmpty) {
        throw Exception("Failed to retrieve shop ID.");
      }

      final advisorID = result.first[0];

      // Insert service details into service table
      for (String service in selectedServices) {
        List<String> parts = service.split(' - ');

        if (parts.length != 5) {
          continue; // Skip this invalid service string
        }

        String mainService = parts[0].split(': ').last.trim();
        String subService = parts[1].split(': ').last.trim();
        String rate = parts[2].split(': ').last.trim();
        String quantity = parts[3].split(': ').last.trim();
        String unit = parts[4].split(': ').last.trim();

        await connection.execute(Sql.named('''
        INSERT INTO public.advisor_service_details (
          advisor_id, main_service, sub_service, rate, quantity, unit_of_measurement
        ) VALUES (
          @advisorID, @mainService, @subService, @rate, @quantity, @unit
        );
      '''), parameters: {
          'advisorID': advisorID,
          'mainService': mainService,
          'subService': subService,
          'rate': rate,
          'quantity': quantity,
          'unit': unit,
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details registered successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register shop details: $e')),
      );
    } finally {
      // Close the connection
      await connection.close();
    }
  }
}
