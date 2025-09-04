import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../../data/repositories/church_repository.dart';
import '../../../data/repositories/livestream_repository.dart';
import '../../../data/repositories/favorites_repository.dart';
import '../../../domain/entities/church.dart';
import '../../../domain/entities/livestream.dart';
import '../../../core/utils/member_count_formatter.dart';
import '../../../core/utils/title_formatter.dart';
import '../settings/denomination_settings_page.dart';
import '../livestream/livestream_detail_page.dart';
import '../settings/theme_settings_page.dart';
import '../settings/language_region_settings_page.dart';
import '../settings/notification_settings_page.dart';
import '../settings/about_page.dart';
import '../../../data/repositories/user_reports_repository.dart';
import '../church_detail/church_detail_page.dart';
import 'widgets/live_streams_section.dart';
import 'widgets/churches_section.dart';
import '../../widgets/simple_theme_toggle.dart';

class HomePage extends StatefulWidget {
  final String? denominationFilter;

  const HomePage({super.key, this.denominationFilter});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    DiscoverPage(denominationFilter: widget.denominationFilter),
    const SearchPage(),
    const FavoritesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DiscoverPage extends StatelessWidget {
  final String? denominationFilter;

  const DiscoverPage({super.key, this.denominationFilter});

  String _getDenominationDisplayName(String? denomination) {
    if (denomination == null) return 'All Churches';

    final denominationMap = {
      'catholic': 'Catholic',
      'baptist': 'Baptist',
      'methodist': 'Methodist',
      'presbyterian': 'Presbyterian',
      'lutheran': 'Lutheran',
      'pentecostal': 'Pentecostal',
      'anglican': 'Anglican/Episcopal',
      'orthodox': 'Orthodox',
      'non_denominational': 'Non-denominational',
      'evangelical': 'Evangelical',
      'assemblies_of_god': 'Assemblies of God',
      'seventh_day_adventist': 'Seventh-day Adventist',
    };

    return denominationMap[denomination] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          const SimpleThemeToggle(compact: true),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              _showDenominationDialog(context);
            },
            tooltip: 'Change denomination',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (denominationFilter != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.church,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Showing ${_getDenominationDisplayName(denominationFilter)} Churches',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find churches that match your faith tradition',
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
              const SizedBox(height: 24),
            ],

            // Live Streams Section (includes live churches)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Live Streams',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            LiveStreamsSection(denominationFilter: denominationFilter),
            const SizedBox(height: 32),

            // Churches Section
            ChurchesSection(
              denominationFilter: denominationFilter,
              title: denominationFilter != null
                  ? '${_getDenominationDisplayName(denominationFilter)} Churches'
                  : 'Featured Churches',
              showFeatured: denominationFilter == null,
            ),
          ],
        ),
      ),
    );
  }

  void _showDenominationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Denomination'),
          content: const Text(
            'Would you like to choose a different denomination or see all churches?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Clear denomination filter
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('selected_denomination');

                // Navigate to home with no filter
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                }
              },
              child: const Text('Show All'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Go back to denomination selection
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const DenominationSettingsPage(),
                  ),
                );
              },
              child: const Text('Choose Again'),
            ),
          ],
        );
      },
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ChurchRepository _churchRepository = GetIt.instance<ChurchRepository>();
  final LivestreamRepository _livestreamRepository =
      GetIt.instance<LivestreamRepository>();

  Timer? _debounceTimer;
  bool _isLoading = false;
  String _searchQuery = '';

  List<Church> _churchResults = [];
  List<Livestream> _livestreamResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query == _searchQuery) return;

    setState(() {
      _searchQuery = query;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _churchResults = [];
        _livestreamResults = [];
        _isLoading = false;
      });
      return;
    }

    // Debounce search by 300ms
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Parallel search across repositories
      final results = await Future.wait([
        _churchRepository.searchChurches(query),
        _livestreamRepository.searchStreams(query),
      ]);

      if (mounted) {
        setState(() {
          _churchResults = results[0] as List<Church>;
          _livestreamResults = results[1] as List<Livestream>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search churches, services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : const Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),

            const SizedBox(height: 24),

            // Search results
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalResults = _livestreamResults.length + _churchResults.length;

    if (totalResults == 0) {
      return _buildNoResultsState();
    }

    return _buildResultsList();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Search for churches and live streams',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching for "catholic", "live service", or a church name',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No results found for "$_searchQuery"',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or check your spelling',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView(
      children: [
        // Results summary
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Found ${_livestreamResults.length + _churchResults.length} results for "$_searchQuery"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),

        // Live Streams Section
        if (_livestreamResults.isNotEmpty) ...[
          _buildSectionHeader('🔴 Live Streams', _livestreamResults.length),
          const SizedBox(height: 12),
          ..._livestreamResults.map((stream) => _buildLivestreamCard(stream)),
          const SizedBox(height: 24),
        ],

        // Churches Section
        if (_churchResults.isNotEmpty) ...[
          _buildSectionHeader('⛪ Churches', _churchResults.length),
          const SizedBox(height: 12),
          ..._churchResults.map((church) => _buildChurchCard(church)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          '$title ($count)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLivestreamCard(Livestream stream) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: const Icon(Icons.play_arrow, color: Colors.white),
        ),
        title: Text(
          TitleFormatter.shortenForList(stream.title),
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stream.churchName ?? 'Unknown Church',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  'Live • ${stream.viewerCount} watching',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<bool>(
              future: GetIt.instance<FavoritesRepository>()
                  .isLivestreamFavorited(stream.id),
              builder: (context, snapshot) {
                final isFavorited = snapshot.data ?? false;
                return IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    try {
                      final newStatus =
                          await GetIt.instance<FavoritesRepository>()
                              .toggleLivestreamFavorite(stream.id);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              newStatus
                                  ? 'Added to favorites'
                                  : 'Removed from favorites',
                            ),
                          ),
                        );
                        // Trigger rebuild to update icon
                        (context as Element).markNeedsBuild();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update favorite: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LivestreamDetailPage(livestream: stream),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChurchCard(Church church) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<bool>(
              future: GetIt.instance<FavoritesRepository>().isChurchFavorited(
                church.id,
              ),
              builder: (context, snapshot) {
                final isFavorited = snapshot.data ?? false;
                return IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    try {
                      final newStatus =
                          await GetIt.instance<FavoritesRepository>()
                              .toggleChurchFavorite(church.id);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              newStatus
                                  ? 'Added to favorites'
                                  : 'Removed from favorites',
                            ),
                          ),
                        );
                        // Trigger rebuild to update icon
                        (context as Element).markNeedsBuild();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update favorite: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChurchDetailPage(church: church),
            ),
          );
        },
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesRepository _favoritesRepository =
      GetIt.instance<FavoritesRepository>();

  bool _isLoading = true;
  List<Church> _favoriteChurches = [];
  List<Livestream> _favoriteLivestreams = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _favoritesRepository.getFavoriteChurches(),
        _favoritesRepository.getFavoriteLivestreams(),
      ]);

      if (mounted) {
        setState(() {
          _favoriteChurches = results[0] as List<Church>;
          _favoriteLivestreams = results[1] as List<Livestream>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeChurchFromFavorites(Church church) async {
    try {
      await _favoritesRepository.removeChurchFromFavorites(church.id);
      setState(() {
        _favoriteChurches.removeWhere((c) => c.id == church.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${church.name} from favorites'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await _favoritesRepository.addChurchToFavorites(church.id);
                _loadFavorites(); // Reload to show the church again
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove favorite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeLivestreamFromFavorites(Livestream livestream) async {
    try {
      await _favoritesRepository.removeLivestreamFromFavorites(livestream.id);
      setState(() {
        _favoriteLivestreams.removeWhere((s) => s.id == livestream.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${livestream.title} from favorites'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await _favoritesRepository.addLivestreamToFavorites(
                  livestream.id,
                );
                _loadFavorites(); // Reload to show the livestream again
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove favorite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          if (_favoriteChurches.isNotEmpty || _favoriteLivestreams.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearAllDialog(),
              tooltip: 'Clear all favorites',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildFavoritesContent(),
    );
  }

  Widget _buildFavoritesContent() {
    final totalFavorites =
        _favoriteChurches.length + _favoriteLivestreams.length;

    if (totalFavorites == 0) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary
          Text(
            'You have ${_favoriteChurches.length} favorite churches and ${_favoriteLivestreams.length} favorite streams',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Favorite Livestreams Section
          if (_favoriteLivestreams.isNotEmpty) ...[
            _buildSectionHeader(
              '🔴 Favorite Streams',
              _favoriteLivestreams.length,
            ),
            const SizedBox(height: 12),
            ..._favoriteLivestreams.map(
              (stream) => _buildFavoriteLivestreamCard(stream),
            ),
            const SizedBox(height: 24),
          ],

          // Favorite Churches Section
          if (_favoriteChurches.isNotEmpty) ...[
            _buildSectionHeader(
              '⛪ Favorite Churches',
              _favoriteChurches.length,
            ),
            const SizedBox(height: 12),
            ..._favoriteChurches.map(
              (church) => _buildFavoriteChurchCard(church),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No favorites yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Churches and streams you favorite will appear here',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Switch to discover tab
              if (context.findAncestorStateOfType<_HomePageState>() != null) {
                context.findAncestorStateOfType<_HomePageState>()!.setState(() {
                  context
                          .findAncestorStateOfType<_HomePageState>()!
                          ._currentIndex =
                      0;
                });
              }
            },
            icon: const Icon(Icons.explore),
            label: const Text('Discover Churches'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          '$title ($count)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFavoriteLivestreamCard(Livestream stream) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: stream.status == StreamStatus.live
              ? Colors.red
              : Colors.grey,
          child: Icon(
            stream.status == StreamStatus.live
                ? Icons.play_arrow
                : Icons.schedule,
            color: Colors.white,
          ),
        ),
        title: Text(
          TitleFormatter.shortenForList(stream.title),
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stream.churchName ?? 'Unknown Church',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (stream.status == StreamStatus.live)
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    'Live • ${stream.viewerCount} watching',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            else if (stream.scheduledStart != null)
              Text(
                'Scheduled for ${_formatDateTime(stream.scheduledStart!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _removeLivestreamFromFavorites(stream),
              tooltip: 'Remove from favorites',
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LivestreamDetailPage(livestream: stream),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteChurchCard(Church church) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
            if (church.memberCountRange != null &&
                church.memberCountRange != 'unknown')
              Text(
                MemberCountFormatter.formatMemberCount(church.memberCountRange),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _removeChurchFromFavorites(church),
              tooltip: 'Remove from favorites',
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChurchDetailPage(church: church),
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes';
    } else {
      return 'Soon';
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Favorites'),
          content: const Text(
            'Are you sure you want to remove all your favorite churches and streams? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _favoritesRepository.clearAllFavorites();
                  setState(() {
                    _favoriteChurches = [];
                    _favoriteLivestreams = [];
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All favorites cleared')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to clear favorites: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Settings options
          _ProfileOption(
            icon: Icons.church,
            title: 'Change Denomination',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DenominationSettingsPage(),
                ),
              );
            },
          ),
          _ProfileOption(
            icon: Icons.language,
            title: 'Language & Region',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LanguageRegionSettingsPage(),
                ),
              );
            },
          ),
          _ProfileOption(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
          _ProfileOption(
            icon: Icons.palette,
            title: 'Theme',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ThemeSettingsPage(),
                ),
              );
            },
          ),
          _ProfileOption(
            icon: Icons.info,
            title: 'About',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Helper widgets

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ReportIssueDialog extends StatefulWidget {
  @override
  State<_ReportIssueDialog> createState() => _ReportIssueDialogState();
}

class _ReportIssueDialogState extends State<_ReportIssueDialog> {
  final TextEditingController _issueController = TextEditingController();
  final UserReportsRepository _reportsRepository =
      GetIt.instance<UserReportsRepository>();
  String _selectedCategory = 'Bug Report';
  bool _isSubmitting = false;
  final List<String> _categories = [
    'Bug Report',
    'Feature Request',
    'Performance Issue',
    'UI/UX Problem',
    'Other',
  ];

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report an Issue'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What went wrong?'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Category',
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _issueController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Describe the issue',
                hintText: 'Please provide as much detail as possible...',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _issueController.text.trim().isEmpty || _isSubmitting
              ? null
              : () {
                  _submitIssue(context);
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }

  Future<void> _submitIssue(BuildContext context) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _reportsRepository.submitReport(
        category: _selectedCategory,
        description: _issueController.text.trim(),
        userId: _reportsRepository.getCurrentUserId(),
        deviceInfo: _reportsRepository.getDeviceInfo(),
      );

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Issue submitted successfully!\nThank you for helping us improve!'
                  : 'Failed to submit issue. Please try again.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting issue: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
