import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/church_repository.dart';
import '../../../domain/entities/church.dart';

class ChurchSubscriptionPage extends StatefulWidget {
  const ChurchSubscriptionPage({super.key});

  @override
  State<ChurchSubscriptionPage> createState() => _ChurchSubscriptionPageState();
}

class _ChurchSubscriptionPageState extends State<ChurchSubscriptionPage> {
  final TextEditingController _searchController = TextEditingController();
  final ChurchRepository _churchRepository = GetIt.instance<ChurchRepository>();

  List<Church> _allChurches = [];
  List<Church> _filteredChurches = [];
  Set<String> _subscribedChurchIds = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Load user's denomination preference
      final prefs = await SharedPreferences.getInstance();
      final selectedDenomination = prefs.getString('selected_denomination');

      // Load churches filtered by user's denomination
      final churches = await _churchRepository.getChurches(
        denominationFilter: selectedDenomination,
        limit: 100,
      );

      // Load user's subscriptions
      final subscribedIds = prefs.getStringList('subscribed_church_ids') ?? [];

      setState(() {
        _allChurches = churches;
        _filteredChurches = churches;
        _subscribedChurchIds = subscribedIds.toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading churches: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredChurches = _allChurches;
      } else {
        _filteredChurches = _allChurches.where((church) {
          return church.name.toLowerCase().contains(query.toLowerCase()) ||
              (church.city?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              (church.denominationName?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false);
        }).toList();
      }
    });
  }

  Future<void> _toggleSubscription(Church church) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscribedIds = prefs.getStringList('subscribed_church_ids') ?? [];

      setState(() {
        if (_subscribedChurchIds.contains(church.id)) {
          _subscribedChurchIds.remove(church.id);
          subscribedIds.remove(church.id);
        } else {
          _subscribedChurchIds.add(church.id);
          subscribedIds.add(church.id);
        }
      });

      await prefs.setStringList('subscribed_church_ids', subscribedIds);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _subscribedChurchIds.contains(church.id)
                  ? 'Subscribed to ${church.name}'
                  : 'Unsubscribed from ${church.name}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating subscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildChurchCard(Church church) {
    final isSubscribed = _subscribedChurchIds.contains(church.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            Icons.church,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          church.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (church.denominationName != null)
              Text(
                church.denominationName!,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            if (church.city != null)
              Text(
                '${church.city}${church.countryName != null ? ', ${church.countryName}' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            if (church.isCurrentlyLive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'LIVE NOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSubscribed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Subscribed',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                isSubscribed
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                color: isSubscribed
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed: () => _toggleSubscription(church),
              tooltip: isSubscribed ? 'Unsubscribe' : 'Subscribe',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribedChurches() {
    final subscribedChurches = _allChurches
        .where((church) => _subscribedChurchIds.contains(church.id))
        .toList();

    if (subscribedChurches.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.notifications_none,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Subscriptions Yet',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Subscribe to churches to get notified when they go live',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.subscriptions,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Subscriptions (${subscribedChurches.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...subscribedChurches.map((church) => _buildChurchCard(church)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Church Subscriptions'),
        actions: [
          if (_subscribedChurchIds.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Subscriptions'),
                    content: const Text(
                      'Are you sure you want to unsubscribe from all churches?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('subscribed_church_ids');
                          setState(() {
                            _subscribedChurchIds.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cleared all subscriptions'),
                            ),
                          );
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search churches...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),

                // Denomination filter info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Showing churches from your selected denomination only',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Subscribed churches section
                      _buildSubscribedChurches(),
                      const SizedBox(height: 16),

                      // All churches section
                      if (_searchQuery.isEmpty) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.explore,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'All Churches (${_allChurches.length})',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ] else ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Search Results (${_filteredChurches.length})',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Churches list
                      if (_filteredChurches.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.church_outlined,
                                  size: 48,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Churches Found',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No churches found for your selected denomination. Try changing your denomination preference in Settings > Language & Region.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._filteredChurches.map(
                          (church) => _buildChurchCard(church),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
