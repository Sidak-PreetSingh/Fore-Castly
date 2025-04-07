import 'package:flutter/material.dart';




class HourlyForecastItem extends StatelessWidget{
  final String time;
  final IconData icons;
  final String value;
  const HourlyForecastItem({super.key,
    required this.time,
    required this.icons,
    required this.value,
  });

  @override
  Widget build(BuildContext context){
    return  Card(
      elevation:6,
      child: Container (
          width:100,
          padding: const EdgeInsets.all(8.0),
          decoration:BoxDecoration(
            borderRadius:BorderRadius.circular(18),
          ),
          child: Column(
              children:[
                Text(time,
                    style:TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines:1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height:8),
                Icon(icons,size:32),
                SizedBox(height:8),
                Text(value),
              ]
          )
      ),
    );
  }
}

