import 'dart:async';
import 'package:flutter/material.dart';

class BitcoinCard extends StatefulWidget {
  @override
  _BitcoinCardState createState() => _BitcoinCardState();
}

class _BitcoinCardState extends State<BitcoinCard> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> newsList = [
    {
      "title": "Bitcoin reaches new all-time high!",
      "image": "https://www.cointribune.com/app/uploads/2024/02/bitcoin-proces-Australien-2.png",
    },
    {
      "title": "Major companies now accepting Bitcoin as payment",
      "image": "https://www.cointribune.com/app/uploads/2024/02/bitcoin-proces-Australien-2.png",
    },
    {
      "title": "Bitcoin price analysis: Is it the right time to invest?",
      "image": "https://www.cointribune.com/app/uploads/2024/02/bitcoin-proces-Australien-2.png",
    },
    {
      "title": "Government regulations shake up the Bitcoin market",
      "image": "https://www.cointribune.com/app/uploads/2024/02/bitcoin-proces-Australien-2.png",
    },
    {
      "title": "Top 5 Bitcoin wallets for secure storage",
      "image": "https://www.cointribune.com/app/uploads/2024/02/bitcoin-proces-Australien-2.png",
    },
  ];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_currentPage < newsList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _controller.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bitcoin News Carousel'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            newsList[index]['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16.0),
                              bottomRight: Radius.circular(16.0),
                            ),
                            color: Colors.black.withOpacity(0.6),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            newsList[index]['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}





