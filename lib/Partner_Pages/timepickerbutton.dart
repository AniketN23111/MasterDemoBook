import 'package:flutter/material.dart';

class TimePickerButton extends StatefulWidget {
  final String label;
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onChanged;
  bool isEleveted = false;

  TimePickerButton({
    required this.label,
    required this.selectedTime,
    required this.onChanged,
  });

  @override
  _TimePickerButtonState createState() => _TimePickerButtonState();
}

class _TimePickerButtonState extends State<TimePickerButton> {
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.selectedTime,
    );
    if (picked != null) {
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectTime,
      child: AnimatedContainer(
        duration: const Duration(microseconds: 200),
        height: 50,
        width: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.white,
                offset: const Offset(4, 4),
                blurRadius: 15,
                spreadRadius: 1),
          ],
        ),
        child: Center(
          child: Text(
            '${widget.label}: ${widget.selectedTime.format(context)}',
            style: TextStyle(
              color: Colors.black,
            ), // Set text color to white
          ),
        ),
      ),
    );
  }
}