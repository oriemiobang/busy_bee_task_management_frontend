import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatelessWidget {
  final DateTime date;
  final VoidCallback onDateChanged;
  final String title;
  final String? subtitle;
  final bool isToday;

  const DatePicker({
    super.key,
    required this.date,
    required this.onDateChanged,
    required this.title,
    this.subtitle,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
    
        Row(
          children: [
         
            Container(
          padding: EdgeInsets.all(9),
          decoration: BoxDecoration(
            color:  const Color.fromARGB(57, 104, 58, 183),
            borderRadius: BorderRadius.circular(8)
          ),
              
              child: Icon(Icons.calendar_today,color:  Colors.deepPurple, ),),
    
              SizedBox(width: 10,),
                  Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
          ],
          
        ),
        GestureDetector(
          onTap:() async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              onDateChanged();
            }
          },
          child: Container(
            width: 100,
            height: 40,
          
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Center(
              child: Text(
                DateFormat('MMM d, yyyy').format(date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
  
        // IconButton(
        //   icon: const Icon(Icons.calendar_today, color: Colors.grey),
        //   onPressed: () 
        // ),
      ],
    );
  }
}