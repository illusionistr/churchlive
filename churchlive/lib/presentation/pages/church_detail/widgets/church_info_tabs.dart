import 'package:flutter/material.dart';
import '../../../../domain/entities/church.dart';

class ChurchInfoTabs extends StatelessWidget {
  final Church church;
  final TabController tabController;

  const ChurchInfoTabs({
    super.key,
    required this.church,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: TabBar(
        controller: tabController,
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Services'),
          Tab(text: 'Streams'),
          Tab(text: 'Contact'),
        ],
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }
}
