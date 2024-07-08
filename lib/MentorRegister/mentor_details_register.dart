import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:saloon/MentorRegister/service_details.dart';

class MentorDetailsRegister extends StatefulWidget {
  const MentorDetailsRegister({super.key});
  @override
  State<MentorDetailsRegister> createState() => _MentorDetailsRegisterState();
}

class _MentorDetailsRegisterState extends State<MentorDetailsRegister> {
  final TextEditingController _shopname = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _pincode = TextEditingController();
  final TextEditingController _licence = TextEditingController();
  final TextEditingController _mNumber = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _area = TextEditingController();

  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _designation = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _gender;

  bool isEleveted = false;
  final _formKey = GlobalKey<FormState>();
  GlobalKey<AutoCompleteTextFieldState<String>> autoCompleteKey =
  GlobalKey<AutoCompleteTextFieldState<String>>();

  String selectedState = 'Maharashtra'; // Default state
  String selectedCountry = 'India'; // Default country
  String selectedCity = 'Pune';
  List<bool> workingDays = [false, false, false, false, false, false, false, false]; // Monday-Sunday
  String? countryValue = "";
  String? stateValue = "";
  String? cityValue = "";
  String address = "";

  List<String> timeSlots = [];
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);

  String _formatTime(TimeOfDay time) {
    final hours = time.hourOfPeriod;
    final minutes = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hours:$minutes $period';
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime, int? index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? startTime : endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _addSlot() {
    setState(() {
      String formattedSlot = '${_formatTime(startTime)} - ${_formatTime(endTime)}';
      timeSlots.add(formattedSlot);
    });
  }

  void _removeTimeSlot(int index) {
    setState(() {
      timeSlots.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Details'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      )
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
                              spreadRadius: 0.0,
                            )
                          ],
                          color: const Color.fromRGBO(247, 247, 249, 1),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: const CountryCodePicker(
                          onChanged: print,
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
                              spreadRadius: 0.0,
                            )
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
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _email,
                    validator: (text) {
                      if (text != null && !EmailValidator.validate(text)) {
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

              // Company Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _companyName,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Company Name is Empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Company Name',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset('assets/icons/company.svg'),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Designation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _designation,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Designation is Empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Designation',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset('assets/icons/designation.svg'),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Gender
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    onChanged: (String? newValue) {
                      setState(() {
                        _gender = newValue;
                      });
                    },
                    items: ['Male', 'Female', 'Other']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Gender',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset('assets/icons/gender.svg'),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Date of Birth
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(15),
                        hintText: 'Date of Birth',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset('assets/icons/birthdate.svg'),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_selectedDate.toLocal()}".split(' ')[0],
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.black54,
                          ),
                        ],
                      ),
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
                        spreadRadius: 0.0,
                      )
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
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _pincode,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Pin is Empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(15),
                        hintText: 'Pin',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(9),
                          child: SizedBox(
                            width: 10,
                            height: 10,
                            child: SvgPicture.asset(
                                'assets/icons/pin-code.svg'),
                          ),
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
                        spreadRadius: 0.0,
                      )
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
                          padding: const EdgeInsets.all(9),
                          child: SvgPicture.asset(
                              'assets/icons/license.svg'),
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
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: CSCPicker(
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
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _area,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Area is Empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(15),
                        hintText: 'Area',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(9),
                          child: SizedBox(
                            width: 10,
                            height: 10,
                            child: SvgPicture.asset(
                                'assets/icons/address.svg'),
                          ),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Choose Working Days:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDayToggleButton('Mon', 0),
                      _buildDayToggleButton('Tue', 1),
                      _buildDayToggleButton('Wed', 2),
                      _buildDayToggleButton('Thu', 3),
                      _buildDayToggleButton('Fri', 4),
                      _buildDayToggleButton('Sat', 5),
                      _buildDayToggleButton('Sun', 6),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Time Slots:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // Time slots selection
              const Text(
                'Select Time Slots',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(timeSlots[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeTimeSlot(index),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _selectTime(context, true, null),
                      child: Text('Start Time: ${_formatTime(startTime)}'),
                    ),
                    TextButton(
                      onPressed: () => _selectTime(context, false, null),
                      child: Text('End Time: ${_formatTime(endTime)}'),
                    ),
                  ],
                ),
              ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addSlot,
                      child: const Text('Add Slot'),
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: ElevatedButton(
                  onPressed: () {
                   // if (_formKey.currentState!.validate()) {
                     Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  ServiceDetails(_shopname.text,_address.text,_mNumber.text,_email.text,_pincode.text,countryValue.toString(),stateValue.toString(),cityValue.toString(),_area.text,_licence.text,workingDays.toString(),timeSlots.toString(),_companyName.text,_designation.text,_gender.toString(),_selectedDate)),
                      );
                 //   }
                  },
                  child: const Center(child: Text('Next')),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDayToggleButton(String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          workingDays[index] = !workingDays[index];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: workingDays[index] ? Colors.blue : Colors.grey,
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

String getDayName(int index) {
  return ['All', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
}
