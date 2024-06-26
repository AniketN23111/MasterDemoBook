import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'timepickerbutton.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopDetails extends StatefulWidget {
  final Function(int) changePageIndex;
  const ShopDetails({super.key, required this.changePageIndex});
  @override
  State<ShopDetails> createState() => _ShopDetailsState();
}

class _ShopDetailsState extends State<ShopDetails> {

  @override
  void initState() {
    super.initState();

    // Set default values for state, city, and country
    stateValue = 'Maharashtra';
    cityValue = 'Pune';
    countryValue = 'India';
    const defaultPincode = '123456'; // Replace with the desired default pincode
    fetchLocationDetailsFromPincode(defaultPincode);

  }

  final TextEditingController _shopname = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _pincode = TextEditingController();
  final TextEditingController _licence = TextEditingController();
  final TextEditingController _mNumber = TextEditingController();
  final TextEditingController _email = TextEditingController();
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

  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0); // Default start time
  TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);

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
            const SizedBox(height: 100),
            const Text(
              "Details",
              style: TextStyle(fontSize: 30,color: Colors.black),
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
                  controller: _shopname,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return "Name is Empty";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Name',
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xff1D1617).withOpacity(0.11),
                              blurRadius: 40,
                              spreadRadius: 0.0)
                        ],
                        color: const Color.fromRGBO(247, 247, 249, 1),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: const CountryCodePicker(
                        initialSelection: 'IN',
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        favorite: ['IN'],
                        enabled: true,
                        hideMainText: false,
                        showFlagMain: true,
                        showFlag: true,
                        hideSearch: false,
                        showFlagDialog: true,
                        alignLeft: true,
                        padding: EdgeInsets.all(1.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 2,
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
                        keyboardType: TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10)
                        ],
                        controller: _mNumber,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "Number is Empty";
                          } else if (text.length <= 9) {
                            return "Put the 10 Digit Number";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,

                            hintText: 'Mobile Number',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SvgPicture.asset(
                                  'assets/icons/phone-svgrepo-com.svg'),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                //width: 50,
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
                  controller: _email,
                  validator: (text) {
                    if(text != null && !EmailValidator.validate(text))
                    {
                      return "Enter Valid Mail";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Email',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(9),
                        child: SvgPicture.asset(
                            'assets/icons/email-1-svgrepo-com.svg'),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none)),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                  controller: _address,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return "Address is Empty";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
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
            const SizedBox(height: 10),
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
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: _pincode,
                  onChanged: (pincode) {
                      fetchLocationDetailsFromPincode(pincode);

                  },
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return "Pin-code is Empty";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  CSCPicker(
                    key: ValueKey('$countryValue$stateValue$cityValue'),
                    showCities: true,
                    showStates: true,
                    defaultCountry: CscCountry.India,
                    flagState: CountryFlag.ENABLE,
                    disabledDropdownDecoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xff1D1617).withOpacity(0.11),
                            blurRadius: 40,
                            spreadRadius: 0.0)
                      ],
                      color: const Color.fromRGBO(247, 247, 249, 1),
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    countrySearchPlaceholder: "Country",
                    stateSearchPlaceholder: "State",
                    citySearchPlaceholder: "City",
                    countryDropdownLabel: "Country",
                    stateDropdownLabel: "State",
                    cityDropdownLabel: "City",
                    selectedItemStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    dropdownHeadingStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                    dropdownItemStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    dropdownDialogRadius: 20.0,
                    searchBarRadius: 10.0,
                    currentCountry: countryValue,
                    currentState: stateValue,
                    currentCity: cityValue,
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
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
                  decoration: const InputDecoration(
                    labelText: 'Area',
                    prefixIcon: Icon(Icons.location_on),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                  controller: _licence,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                     return "License is Empty";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'License',
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Working Days:',
                      style: TextStyle(fontSize: 30,color: Colors.black),
                    ),
                  ),
                  Center(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                style: const TextStyle(color: Colors.black)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120),
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
                  const SizedBox(width: 10),
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                  }
                },
                child: const Center(child: Text('Next')),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

String getDayName(int index) {
  return ['All', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
}
