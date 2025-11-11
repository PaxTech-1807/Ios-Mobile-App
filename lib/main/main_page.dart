import 'package:flutter/material.dart';
import 'package:iosmobileapp/features/calendar/presentation/reservation_page.dart';
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

  final List<Widget> _pages = const [
    TeamPage(),
    ServicePage(),
    ReservationPage(),
    ProfileOverviewPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: selectedIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Equipo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.content_cut),
            label: 'Servicios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
