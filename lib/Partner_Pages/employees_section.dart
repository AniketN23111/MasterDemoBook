import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EmployeesSection extends StatefulWidget {
  final List<String> employees;

  EmployeesSection(this.employees);

  @override
  _EmployeesSectionState createState() => _EmployeesSectionState();
}

class _EmployeesSectionState extends State<EmployeesSection> {
  TextEditingController employeeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double turns = 0.0;
  List<String> mainServices = ['THREADING & WAX', 'Facials & Bleach', 'Cuttings', 'Manicure/Pedicure', 'Makeup',];
  Map<String, List<String>> subServices = {
    'THREADING & WAX': ['Eyebrowz', 'Upper Lips', 'Forehead', 'Chin', 'Full Face Threading', 'Full Face Wax', 'Full Arms Wax', 'Half Arms Wax', 'Full Legs Wax', 'Half Legs Wax', 'Under Arms Wax', 'Bikini Wax',],
    'Facials & Bleach': ['Whitening Bleach', 'Full Arms Bleach', 'Full Legs Bleach', 'Zafrani Bleach', 'Fruit Facial', 'Zafrani Whitening Facial', 'Derma Shine Facial', 'Glamorous Facial', 'Dermastation Facial', 'Normal Cleansing Face Polish', 'Whitening Facial', '(Golden Pearl, Arfa) Gold Facial', 'Zafrani Facial', 'Golden Zafrani',],
    'Cuttings': ['Trimming', 'Puff Cutting', 'Front Layer Cut Full Layer Cut', 'Full Step Cut', 'Half Step Cut', 'Bob Cut', 'Bangs Cut', 'Baby Cut', 'U Cut', 'V Cut',],
    'Manicure/Pedicure': ['Manicure', 'Pedicure', 'Zafrani Manicure', 'Zafrani Pedicure', 'Dermastation Manicure', 'Dermastation Pedicure',],
    'Makeup': ['Party Makeup', 'Model Makeup', 'Engagement Makeup', 'Mayoon Makeup', 'Bridal Package',]
  };
  String? selectedMainService;
  String? selectedSubService;
  List<String> selectedServices = [];

  // Create a list to store selected images
  List<XFile> selectedImages = [];

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedImages = await picker.pickMultiImage();

    setState(() {
      selectedImages = pickedImages;
    });
    }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            Column(
              children: widget.employees.map((employee) =>
                  Text(employee, style: const TextStyle(fontSize: 20, color: Colors.black),)).toList(),
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
                              child:
                              SvgPicture.asset('assets/icons/employee.svg'),
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
                          widget.employees.add(employeeNameController.text);
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
                              offset: const Offset(-4, -4),
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
            const SizedBox(height: 20), // Add spacing
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: selectedServices.map((service) {
                return Text(service, style: const TextStyle(fontSize: 20, color: Colors.white),);
              }).toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (selectedMainService != null && selectedSubService != null) {
                  setState(() {
                    selectedServices.add('$selectedMainService - $selectedSubService');
                    selectedMainService = null;
                    selectedSubService = null;
                  });
                }
              },
              child: const Text('Add Service'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                pickImages(); // Open the image picker
              },
              child: const Text('Pick Images'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {

              },
              child: const Text('Upload Images'),
            ),
            // Display the selected images
            Column(
              children: selectedImages.map((image) {
                return Image.file(File(image.path));
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
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