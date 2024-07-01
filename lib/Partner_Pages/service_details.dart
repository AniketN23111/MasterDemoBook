import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:postgres/postgres.dart';
import 'package:saloon/Constants/screen_utility.dart';
import 'package:saloon/GoogleApi/cloudApi.dart';
import 'dart:io';
import 'package:saloon/Models/mentor_service.dart';
import 'package:saloon/Services/database_service.dart';

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

  const ServiceDetails(this.name,this.address,this.number,this.email,this.pincode,this.country,this.state,this.city,this.area,this.license,this.workingDays,this.timeslot,{super.key});

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  TextEditingController employeeNameController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double turns = 0.0;
  String? selectedMainService;
  String? selectedSubService;
  List<String> selectedServices = [];
  List<MentorService> masterServices = [];
  List<XFile> selectedImages = [];
  MentorService? selectedMasterService;
  String? _downloadUrl;
  final ImagePicker _picker = ImagePicker();
  CloudApi? cloudApi;
  bool _uploading = false;
  Uint8List? _uploadedImageBytes;

  @override
  void initState() {
    super.initState();
    employeeNameController.text = widget.name;
    _fetchMasterServices();
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

  Future<void> _fetchMasterServices() async {
    DatabaseService dbService = DatabaseService();
    List<MentorService> services = await dbService.getMentorService();
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

  @override
  Widget build(BuildContext context) {
    List<String> mainServices = masterServices.map((e) => e.service).toSet().toList();
    List<String> subServices = selectedMainService != null
        ? masterServices
        .where((e) => e.service == selectedMainService)
        .map((e) => e.subService)
        .toList()
        : [];

    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                'Services',
                style: TextStyle(fontSize: 30, color: Colors.black),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xff1D1617).withOpacity(0.11),
                                blurRadius: 40,
                                spreadRadius: 0.0)
                          ],
                          color: const Color.fromRGBO(247, 247, 249, 1),
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: employeeNameController,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Name is Empty';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(15),
                              hintText: 'Employee',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset('assets/icons/employee.svg'),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            employeeNameController.clear();
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(microseconds: 200),
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[500]!,
                                offset: const Offset(4, 4),
                                blurRadius: 15,
                                spreadRadius: 1),
                            const BoxShadow(
                                color: Colors.white,
                                offset: Offset(-4, -4),
                                blurRadius: 15,
                                spreadRadius: 1),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/plus-svgrepo-com.svg',
                          width: 10,
                          height: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: DropdownButtonFormField<String>(
                  value: selectedMainService,
                  hint: const Text('Select Main Service'),
                  onChanged: (value) {
                    setState(() {
                      selectedMainService = value;
                      selectedSubService = null;
                      selectedMasterService = null;
                    });
                  },
                  items: mainServices
                      .map((service) => DropdownMenuItem(
                    value: service,
                    child: Text(service),
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: DropdownButtonFormField<String>(
                  value: selectedSubService,
                  hint: const Text('Select Sub Service'),
                  onChanged: (value) {
                    setState(() {
                      selectedSubService = value;
                      selectedMasterService = masterServices.firstWhere((e) => e.service == selectedMainService && e.subService == value);
                    });
                  },
                  items: subServices
                      .map((subService) => DropdownMenuItem(
                    value: subService,
                    child: Text(subService),
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xff1D1617).withOpacity(0.11),
                          blurRadius: 40,
                          spreadRadius: 0.0)
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: rateController,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Rate is Empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(15),
                        hintText: 'rate',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset('assets/icons/quantity.svg'),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xff1D1617).withOpacity(0.11),
                          blurRadius: 40,
                          spreadRadius: 0.0)
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: quantityController,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Quantity is Empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(15),
                        hintText: 'Quantity',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset('assets/icons/quantity.svg'),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xff1D1617).withOpacity(0.11),
                          blurRadius: 40,
                          spreadRadius: 0.0)
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: unitController,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Unit Of Measurement is Empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(15),
                        hintText: 'Unit Of Measurement',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset('assets/icons/shop.svg'),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: selectedServices.map((service) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      service,
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedMainService != null &&
                      selectedSubService != null &&
                      selectedMasterService != null) {
                    setState(() {
                      selectedServices.add(
                          '$selectedMainService - $selectedSubService');
                      selectedMainService = null;
                      selectedSubService = null;
                      selectedMasterService = null;
                    });
                  }
                },
                child: const Text('Add Service'),
              ),
              Column(
                children: selectedImages.map((image) {
                  return Image.file(File(image.path));
                }).toList(),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                    registerShopDetails(widget.name,widget.address,widget.number,widget.email,widget.pincode,widget.country,widget.state,widget.city,widget.area,widget.license,widget.workingDays,widget.timeslot,selectedServices.join(', '),int.parse(rateController.text),int.parse(quantityController.text),unitController.text,_downloadUrl!);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<bool> registerShopDetails(
      String name, String address,String mobile,String email,String pincode,String country,String state,String city,String area,String license,String workingDays,String timeslot,String services,int rate,int quantity,String unit,String imageUrl) async {
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

      connection.execute(
        'INSERT INTO ai.master_details(name,address,mobile,email,pincode,country,state,city,area,license,working_days,timeslot,services,rate,quantity,unit_measurement,image_url) '
            'VALUES (\$1, \$2, \$3, \$4,\$5, \$6, \$7, \$8,\$9, \$10, \$11, \$12,\$13, \$14, \$15, \$16, \$17)',
        parameters: [name,address,mobile,email,pincode,country,state,city,area,license,workingDays,timeslot,services,rate,quantity,unit,imageUrl],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    employeeNameController.dispose();
    super.dispose();
  }
}
