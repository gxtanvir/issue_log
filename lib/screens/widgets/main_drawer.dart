import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            padding: EdgeInsets.all(20),decoration: BoxDecoration(
            gradient: LinearGradient(colors: 
            [Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .8),],
            begin: AlignmentGeometry.topLeft,
            end: AlignmentGeometry.bottomRight,),
          ),
          child: Text('Hello User'),),
          ListTile(title: const Text("Profile"),
          onTap: (){},),
          ListTile(title: const Text('About'),
          onTap: (){},)
        ],
      ),
    );
  }
}
