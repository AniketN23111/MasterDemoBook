import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:saloon/Models/master_service.dart';
import 'package:saloon/Services/database_service.dart';

class ServiceDetails extends StatefulWidget {
  final String shopName;

  const ServiceDetails(this.shopName, {super.key});

  @override
  State<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  TextEditingController employeeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double turns = 0.0;
  String? selectedMainService;
  String? selectedSubService;
  List<String> selectedServices = [];
  List<MasterService> masterServices = [];
  List<XFile> selectedImages = [];
  MasterService? selectedMasterService;

  @override
  void initState() {
    super.initState();
    employeeNameController.text = widget.shopName;
    _fetchMasterServices();
  }

  Future<void> _fetchMasterServices() async {
    DatabaseService dbService = DatabaseService();
    List<MasterService> services = await dbService.getMasterService();
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                'Employees',
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
                      selectedMasterService = masterServices.firstWhere(
                              (e) =>
                          e.service == selectedMainService &&
                              e.subService == value);
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
              if (selectedMasterService != null) ...[
                Text('Rate: ${selectedMasterService!.rate}'),
                Text('Quantity: ${selectedMasterService!.quantity}'),
                const SizedBox(height: 20),
              ],
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
                          '$selectedMainService - $selectedSubService - Rate: ${selectedMasterService!.rate}, Quantity: ${selectedMasterService!.quantity}');
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
              ElevatedButton(
                onPressed: pickImages,
                child: const Text('Pick Images'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Upload Images'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    employeeNameController.dispose();
    super.dispose();
  }
}
