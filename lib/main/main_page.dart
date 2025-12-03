import 'package:flutter/material.dart';
import 'package:iosmobileapp/core/widgets/custom_bottom_navbar.dart';
import 'package:iosmobileapp/features/calendar/presentation/reservation_page.dart';
import 'package:iosmobileapp/features/home/presentation/home_page.dart';
import 'package:iosmobileapp/features/profile/presentation/pages/profile_overview_page.dart';
import 'package:iosmobileapp/features/service/presentation/service_page.dart';
import 'package:iosmobileapp/features/team/presentation/team_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  List<Widget> get _pages => [
    HomePage(
      onNavigateToServices: () => setState(() => selectedIndex = 1),
      onNavigateToTeam: () => setState(() => selectedIndex = 2),
      onNavigateToCalendar: () => setState(() => selectedIndex = 3),
    ),
    const ServicePage(),
    const TeamPage(),
    const ReservationPage(),
    const ProfileOverviewPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
