import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class TimePicker extends StatelessWidget {
  final DateTime time;
  final VoidCallback onTimeChanged;
  final String title;
  final String? subtitle;

  const TimePicker({
    super.key,
    required this.time,
    required this.onTimeChanged,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Row(
              children: [
                       Container(
              padding: EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color.fromARGB(43, 19, 91, 236),
                borderRadius: BorderRadius.circular(8)
              ),
              
              child: Icon(Icons.access_time, color: AppColors.primary,)),

            SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
                    ],
                  ),
              ],
            )
,
     

             GestureDetector(
              onTap: () async {
                final timeOfDay = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: time.hour,
                    minute: time.minute,
                  ),
                );
                if (timeOfDay != null) {
                  final newTime = DateTime(
                    time.year,
                    time.month,
                    time.day,
                    timeOfDay.hour,
                    timeOfDay.minute,
                  );
                  onTimeChanged();
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
                    '${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                           ),
             ),

          ],
        ),
        

        Row(
          children: [
         
            const SizedBox(width: 8),
            // IconButton(
            //   icon: const Icon(Icons.access_time, color: Colors.grey, size: 0,),
            //   onPressed: () 
            // ),
          ],
        ),
      ],
    );
  }
}