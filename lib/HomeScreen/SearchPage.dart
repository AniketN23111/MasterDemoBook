import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  Widget listItem({required Map shops}){
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 110,
      color: Colors.yellow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(shops['shopName'],
          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),
          ),
          Text(shops['address'],
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),
          ),Text(shops['license'],
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),
          ),Text(shops['pincode'],
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Search'),
      ),
    );
  }
}