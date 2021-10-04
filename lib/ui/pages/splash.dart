import 'package:flutter/material.dart';

import '../constants.dart';

class Splash extends StatelessWidget {
  const Splash({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: Image.asset('assets/yogamates logo.png').image
                    )
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'YogaMates',
                style: TextStyle(color: Colors.blue, fontSize: size.width * 0.1),
              )
            ],
          ),
        ),
      ),
    );
  }
}
