import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            backgroundColor: Colors.purple,
            elevation: 20,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("About me"),
              background: Image.asset("assets/merry.jpg", fit: BoxFit.cover),
            ),
          ),
          SliverFillRemaining(
            child: (SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
                    child: Text(
                      "Hello, my name is Apostle Merry Jane King your personal inspirational speaker and mindset mentor. I’m married to my amazing husband Apostle Derrick King. I’m a mother of 6 amazing children. I was born in a small town called Dawson Ga which helped in molding my change of mindset and my views. It was in this small town that I grew up in a small church surrounded by love and learning about Christ with led me to later develop a deeper understanding and realize that I needed a relationship with Christ and not just to know of him. My purpose is to help you fulfill the will of God for your life by helping you overcome any obstacles that may try to stand in your way. I’m here to help you get past YOU one push at a time.",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }
}
