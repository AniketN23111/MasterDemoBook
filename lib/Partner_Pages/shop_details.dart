import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'timepickerbutton.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopDetails extends StatefulWidget {
  final Function(int) changePageIndex;
  ShopDetails({required this.changePageIndex});
  @override
  _ShopDetailsState createState() => _ShopDetailsState();
}

class _ShopDetailsState extends State<ShopDetails> {

  @override
  void initState() {
    super.initState();

    // Set default values for state, city, and country
    stateValue = 'Maharashtra';
    cityValue = 'Pune';
    countryValue = 'India';
    final defaultPincode = '123456'; // Replace with the desired default pincode
    fetchLocationDetailsFromPincode(defaultPincode);

  }

  TextEditingController _shopname = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _pincode = TextEditingController();
  TextEditingController _licence = TextEditingController();
  bool isEleveted = false;
  final _formKey = GlobalKey<FormState>();
  GlobalKey<AutoCompleteTextFieldState<String>> autoCompleteKey =
  GlobalKey<AutoCompleteTextFieldState<String>>();

  String selectedArea = '';
  List<String> areas = [];

  String selectedState = 'Maharashtra'; // Default state
  String selectedCountry = 'India'; // Default country
  String selectedCity = 'Pune';
  List<bool> workingDays = [false, false, false, false, false, false, false, false]; // Monday-Sunday
  String? countryValue = "";
  String? stateValue = "";
  String? cityValue = "";
  String address = "";

  TimeOfDay startTime = TimeOfDay(hour: 9, minute: 0); // Default start time
  TimeOfDay endTime = TimeOfDay(hour: 18, minute: 0);

  Future<void> fetchLocationDetailsFromPincode(String pincode) async {
    final response = await http.get(
      Uri.parse('https://api.postalpincode.in/pincode/$pincode'),
    );


    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData is List) {
        if (responseData.isNotEmpty) {
          final result = responseData[0]['PostOffice'][0];

          final String state = result['State'];
          final String city = result['District'];
          final String country = result['Country'];
          print('State: $state, City: $city, Country: $country');

          setState(() {
              stateValue = state; // Update the state value if it's still the default
              cityValue = city;   // Update the city value if it's still the default
              countryValue = country; // Update the country value if it's still the default
          });
        } else {
          print('Empty response data');
        }
      } else {
        print('Invalid response data format');
      }
    } else {
      print('Failed to fetch location details');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 350),
            Text(
              "Shop Details",
              style: TextStyle(fontSize: 30,color: Colors.black),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0)
                  ],
                  color: Color.fromRGBO(247, 247, 249, 1),
                  borderRadius: BorderRadius.circular(32.0),
                ),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _shopname,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return "Shop Name is Empty";
                    }
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(15),
                      hintText: 'Shop Name',
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
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0)
                  ],
                  color: Color.fromRGBO(247, 247, 249, 1),
                  borderRadius: BorderRadius.circular(32.0),
                ),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _address,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return "Address Name is Empty";
                    }
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(15),
                      hintText: 'Address',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(9),
                        child: SvgPicture.asset(
                            'assets/icons/address-location-map-svgrepo-com (1).svg'),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none)),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0)
                  ],
                  color: Color.fromRGBO(247, 247, 249, 1),
                  borderRadius: BorderRadius.circular(32.0),
                ),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6)
                  ],
                  controller: _pincode,
                  onChanged: (pincode) {
                    if (pincode.length >= 6) {
                      fetchLocationDetailsFromPincode(pincode);
                    }
                  },
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return "Pin-code is Empty";
                    } else if (text.length <= 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Pin-Code is Not Valid"),
                        ),
                      );
                    }
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(15),
                      hintText: 'Pin code',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(9),
                        child: SvgPicture.asset(
                            'assets/icons/address-location-map-svgrepo-com (1).svg'),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none)),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  CSCPicker(
                    showCities: true,
                    showStates: true,
                    defaultCountry: CscCountry.India,
                    flagState: CountryFlag.ENABLE,
                    disabledDropdownDecoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Color(0xff1D1617).withOpacity(0.11),
                            blurRadius: 40,
                            spreadRadius: 0.0)
                      ],
                      color: Color.fromRGBO(247, 247, 249, 1),
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    countrySearchPlaceholder: "Country",
                    stateSearchPlaceholder: "State",
                    citySearchPlaceholder: "City",
                    countryDropdownLabel: "Country",
                    stateDropdownLabel: "State",
                    cityDropdownLabel: "City",
                    selectedItemStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    dropdownHeadingStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                    dropdownItemStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    dropdownDialogRadius: 20.0,
                    searchBarRadius: 10.0,
                    onCountryChanged: (value) {
                      setState(() {
                        countryValue = value;
                      });
                    },
                    onStateChanged: (value) {
                      setState(() {
                        stateValue = value;
                      });
                    },
                    onCityChanged: (value) {
                      setState(() {
                        cityValue = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32.0),
                ),
                child: AutoCompleteTextField(
                  key: autoCompleteKey,
                  controller: TextEditingController(text: selectedArea),
                  clearOnSubmit: false,
                  suggestions: areas,
                  itemBuilder: (context, suggestion) =>
                      ListTile(title: Text(suggestion)),
                  itemFilter: (suggestion, input) =>
                      suggestion.toLowerCase().startsWith(input.toLowerCase()),
                  itemSorter: (a, b) => a.compareTo(b),
                  itemSubmitted: (value) {
                    setState(() {
                      selectedArea = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Area',
                    prefixIcon: Icon(Icons.location_on),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0)
                  ],
                  color: Color.fromRGBO(247, 247, 249, 1),
                  borderRadius: BorderRadius.circular(32.0),
                ),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _licence,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                     return "Shop License is Empty";
                    }
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(15),
                      hintText: 'Shop License',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset('assets/icons/license.svg'),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none)),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Working Days:',
                      style: TextStyle(fontSize: 30,color: Colors.black),
                    ),
                  ),
                  Center(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 0.0,
                        crossAxisSpacing: 8.1,
                        childAspectRatio: 6.1,
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Checkbox(
                              value: workingDays[index],
                              onChanged: (value) {
                                setState(() {
                                  workingDays[index] = value!;
                                  if (index == 0) {
                                    for (int i = 1; i < 8; i++) {
                                      workingDays[i] = value;
                                    }
                                  }
                                });
                              },
                              activeColor: Colors.white,
                              checkColor: Colors.black,
                            ),
                            Text(getDayName(index),
                                style: TextStyle(color: Colors.black)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 120),
              child: Row(
                children: [
                  Expanded(
                    child: TimePickerButton(
                      label: 'Start Time',
                      selectedTime: startTime,
                      onChanged: (time) {
                        setState(() {
                          startTime = time;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TimePickerButton(
                      label: 'End Time',
                      selectedTime: endTime,
                      onChanged: (time) {
                        setState(() {
                          endTime = time;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {

                    final DatabaseReference databaseRef = FirebaseDatabase.instance.reference();
                    final Map<String, dynamic> shopData = {
                      "shopName": _shopname.text,
                      "address": _address.text,
                      "pincode": _pincode.text,
                      "license": _licence.text,
                      "country": countryValue,
                      "state": stateValue,
                      "city": cityValue,
                      "area": selectedArea,
                      "workingDays": workingDays,
                      "startTime": startTime.toString(),
                      "endTime": endTime.toString(),
                    };

                    // Push the data to Firebase
                    databaseRef.child(_shopname.text).push().set(shopData).then((_) {
                      // Data saved successfully
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Shop information saved to Firebase"),
                        ),
                      );
                      widget.changePageIndex(2);
                    }).catchError((error) {
                      print("Error saving data: $error");
                    });
                  }
                },
                child: Center(child: Text('Next')),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

String getDayName(int index) {
  return ['All', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
}
