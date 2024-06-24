import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'employees_section.dart';
import 'owner.dart';
import 'shop_details.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class PartnerPage extends StatefulWidget {
  @override
  State<PartnerPage> createState() => _PartnerPage();
}

class _PartnerPage extends State<PartnerPage> {
  List<String> employees = [];

  PageController _pageController = PageController(initialPage: 0);

  int currentIndex = 0;
  void changePageIndex(int newIndex) {
    setState(() {
      currentIndex = newIndex;
      _pageController.jumpToPage(newIndex);
    });
  }

  void navigateToPage(int index) {
    setState(() {
      currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.grey.shade200,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index){
          navigateToPage(index);
        },
        index: currentIndex,
        items: [
          SvgPicture.asset('assets/icons/user-svgrepo-com.svg', width: 30, height: 30),
          SvgPicture.asset('assets/icons/shop.svg', width: 30, height: 30),
          SvgPicture.asset('assets/icons/employee.svg', width: 30, height: 30),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
         color: Colors.white70,
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ShopDetails(changePageIndex: changePageIndex);
                  } else if (index == 1) {

                    return Owner(changePageIndex: changePageIndex);
                  } else {
                    return EmployeesSection(employees);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
