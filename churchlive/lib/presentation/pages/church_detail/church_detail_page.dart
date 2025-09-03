import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/favorites_repository.dart';
import '../../../data/repositories/livestream_repository.dart';
import '../../../domain/entities/church.dart';
import '../../../domain/entities/livestream.dart';
import '../../../domain/entities/service_time.dart';
import '../../../core/utils/member_count_formatter.dart';
import '../../../core/utils/service_time_formatter.dart';
import '../../../core/utils/title_formatter.dart';
import '../livestream/livestream_detail_page.dart';
import 'widgets/church_hero_section.dart';
import 'widgets/previous_streams_tab.dart';
import 'widgets/church_action_buttons.dart';

class ChurchDetailPage extends StatefulWidget {
  final Church church;

  const ChurchDetailPage({super.key, required this.church});

  @override
  State<ChurchDetailPage> createState() => _ChurchDetailPageState();
}

class _ChurchDetailPageState extends State<ChurchDetailPage>
    with TickerProviderStateMixin {
  final Logger _logger = GetIt.instance<Logger>();

  final FavoritesRepository _favoritesRepository =
      GetIt.instance<FavoritesRepository>();
  final LivestreamRepository _livestreamRepository =
      GetIt.instance<LivestreamRepository>();

  late TabController _tabController;
  late Church _church;
  bool _isFavorited = false;
  bool _isTogglingFavorite = false;
  bool _isLoading = false;
  List<Livestream> _upcomingStreams = [];
  List<Livestream> _pastStreams = [];
  List<ServiceTime> _serviceTimes = [];

  @override
  void initState() {
    super.initState();
    _church = widget.church;
    _tabController = TabController(length: 5, vsync: this);
    _checkFavoriteStatus();
    _loadChurchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFavorited = await _favoritesRepository.isChurchFavorited(
        _church.id,
      );
      if (mounted) {
        setState(() {
          _isFavorited = isFavorited;
        });
      }
    } catch (e) {
      _logger.e('Error checking favorite status: $e');
    }
  }

  Future<void> _loadChurchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load additional church data in parallel
      final futures = await Future.wait([
        _livestreamRepository.getStreamsByChurch(_church.id),
        _livestreamRepository.getRecentStreams(),
        _loadServiceTimes(),
      ]);

      if (mounted) {
        setState(() {
          final churchStreams = futures[0] as List<Livestream>;
          _upcomingStreams = churchStreams
              .where((s) => s.status == StreamStatus.scheduled)
              .toList();
          _pastStreams = (futures[1] as List<Livestream>)
              .where((s) => s.churchId == _church.id)
              .take(10)
              .toList();
          _serviceTimes = futures[2] as List<ServiceTime>;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Error loading church data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<ServiceTime>> _loadServiceTimes() async {
    // For now, create mock service times from streaming schedule
    // In a real app, you'd load this from a separate service_times table
    final serviceTimes = <ServiceTime>[];

    if (_church.streamingSchedule != null) {
      final schedule = _church.streamingSchedule!;
      var id = 0;

      schedule.forEach((day, times) {
        if (times is List) {
          for (final time in times) {
            serviceTimes.add(
              ServiceTime(
                id: '${_church.id}_service_${id++}',
                churchId: _church.id,
                name: 'Service',
                dayOfWeek: day,
                time: time.toString(),
              ),
            );
          }
        } else if (times is String) {
          serviceTimes.add(
            ServiceTime(
              id: '${_church.id}_service_${id++}',
              churchId: _church.id,
              name: 'Service',
              dayOfWeek: day,
              time: times,
            ),
          );
        }
      });
    }

    return serviceTimes;
  }

  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite) return;

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      final newStatus = await _favoritesRepository.toggleChurchFavorite(
        _church.id,
      );

      if (mounted) {
        setState(() {
          _isFavorited = newStatus;
          _isTogglingFavorite = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? 'Added ${_church.name} to favorites'
                  : 'Removed ${_church.name} from favorites',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _logger.e('Error toggling favorite: $e');
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareChurch() async {
    try {
      final text =
          'Check out ${_church.name}${_church.city != null ? ' in ${_church.city}' : ''}';
      final url = _church.websiteUrl ?? '';

      await Share.share(
        '$text${url.isNotEmpty ? '\n$url' : ''}',
        subject: _church.name,
      );
    } catch (e) {
      _logger.e('Error sharing church: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openWebsite() async {
    if (_church.websiteUrl == null) return;

    try {
      final uri = Uri.parse(_church.websiteUrl!);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch ${_church.websiteUrl}';
      }
    } catch (e) {
      _logger.e('Error opening website: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open website: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getDirections() async {
    if (_church.latitude == null || _church.longitude == null) {
      if (_church.address != null) {
        // Use address for directions
        final query = Uri.encodeComponent(_church.address!);
        final uri = Uri.parse('https://maps.google.com/?q=$query');

        try {
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            throw 'Could not launch directions';
          }
        } catch (e) {
          _logger.e('Error opening directions: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to open directions: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No address available for directions')),
        );
      }
      return;
    }

    try {
      final lat = _church.latitude!;
      final lng = _church.longitude!;
      final uri = Uri.parse('https://maps.google.com/?q=$lat,$lng');

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch directions';
      }
    } catch (e) {
      _logger.e('Error opening directions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open directions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _contactChurch() async {
    if (_church.phoneNumber == null && _church.contactEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No contact information available')),
      );
      return;
    }

    final options = <String>[];
    if (_church.phoneNumber != null) options.add('Call');
    if (_church.contactEmail != null) options.add('Email');

    if (options.length == 1) {
      if (options.first == 'Call') {
        await _makePhoneCall();
      } else {
        await _sendEmail();
      }
    } else {
      // Show options dialog
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Contact Church',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (_church.phoneNumber != null)
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text('Call ${_church.phoneNumber}'),
                  onTap: () {
                    Navigator.pop(context);
                    _makePhoneCall();
                  },
                ),
              if (_church.contactEmail != null)
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text('Email ${_church.contactEmail}'),
                  onTap: () {
                    Navigator.pop(context);
                    _sendEmail();
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _makePhoneCall() async {
    if (_church.phoneNumber == null) return;

    try {
      final uri = Uri.parse('tel:${_church.phoneNumber}');
      if (!await launchUrl(uri)) {
        throw 'Could not make phone call';
      }
    } catch (e) {
      _logger.e('Error making phone call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to make call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail() async {
    if (_church.contactEmail == null) return;

    try {
      final uri = Uri.parse(
        'mailto:${_church.contactEmail}?subject=Inquiry about ${_church.name}',
      );
      if (!await launchUrl(uri)) {
        throw 'Could not send email';
      }
    } catch (e) {
      _logger.e('Error sending email: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _watchLive() async {
    if (!_church.isCurrentlyLive || _church.liveStreamUrl == null) return;

    try {
      // Navigate to livestream detail page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LivestreamDetailPage(
            livestream: Livestream(
              id: '${_church.id}_live',
              churchId: _church.id,
              churchName: _church.name,
              title: TitleFormatter.shortenForHeader(
                _church.liveStreamTitle ?? 'Live Stream',
              ),
              description: 'Live from ${_church.name}',
              platform: StreamPlatform.youtube,
              status: StreamStatus.live,
              streamUrl: _church.liveStreamUrl!,
              scheduledStart: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isFeatured: false,
              viewerCount: 0,
              maxViewers: 0,
              isRecurring: false,
              recurrencePattern: RecurrenceType.none,
              isChatEnabled: false,
              tags: const [],
            ),
          ),
        ),
      );
    } catch (e) {
      _logger.e('Error opening live stream: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero section with church image and basic info
          ChurchHeroSection(
            church: _church,
            isFavorited: _isFavorited,
            isTogglingFavorite: _isTogglingFavorite,
            onToggleFavorite: _toggleFavorite,
            onShare: _shareChurch,
            onWebsite: _church.websiteUrl != null ? _openWebsite : null,
            onWatchLive: _church.isCurrentlyLive ? _watchLive : null,
          ),

          // Action buttons
          SliverToBoxAdapter(
            child: ChurchActionButtons(
              church: _church,
              onGetDirections: _getDirections,
              onContactChurch: _contactChurch,
              onVisitWebsite: _church.websiteUrl != null ? _openWebsite : null,
            ),
          ),

          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Services'),
                  Tab(text: 'Live'),
                  Tab(text: 'Previous'),
                  Tab(text: 'Contact'),
                ],
              ),
            ),
          ),

          // Tab view content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // About tab
                _buildAboutTab(),

                // Services tab
                _buildServicesTab(),

                // Live Streams tab
                _buildStreamsTab(),

                // Previous Streams tab
                PreviousStreamsTab(church: _church),

                // Contact tab
                _buildContactTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick stats
          _buildQuickStats(),

          const SizedBox(height: 24),

          // Description
          if (_church.description != null) ...[
            Text(
              'About',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _church.description!,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),
          ],

          // Additional info
          _buildAdditionalInfo(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.people,
                    label: 'Members',
                    value: MemberCountFormatter.formatMemberCount(
                      _church.memberCountRange,
                    ),
                  ),
                ),
                if (_church.averageRating > 0) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.star,
                      label: 'Rating',
                      value:
                          '${_church.averageRating.toStringAsFixed(1)} (${_church.reviewCount})',
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_church.foundedYear != null) ...[
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.calendar_today,
                      label: 'Founded',
                      value: _church.foundedYear.toString(),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.language,
                    label: 'Language',
                    value: _church.primaryLanguageName ?? 'English',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    final infoItems = <MapEntry<String, String>>[];

    if (_church.denominationName != null) {
      infoItems.add(MapEntry('Denomination', _church.denominationName!));
    }

    if (_church.city != null && _church.countryName != null) {
      infoItems.add(
        MapEntry('Location', '${_church.city}, ${_church.countryName}'),
      );
    } else if (_church.city != null) {
      infoItems.add(MapEntry('Location', _church.city!));
    }

    if (_church.verificationStatus.isVerified) {
      infoItems.add(const MapEntry('Status', 'Verified Church'));
    }

    if (infoItems.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Church Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...infoItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        item.key,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_serviceTimes.isEmpty && !_isLoading)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Icon(
                    Icons.schedule,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No service times available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact the church for service times',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          else if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            )
          else
            _buildServiceTimesList(),
        ],
      ),
    );
  }

  Widget _buildServiceTimesList() {
    final grouped = ServiceTimeFormatter.groupAndSortServiceTimes(
      _serviceTimes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Times',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        ...grouped.entries.map(
          (entry) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ServiceTimeFormatter.capitalizeFirst(entry.key),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...entry.value.map(
                    (serviceTime) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ServiceTimeFormatter.formatServiceTime(serviceTime),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (serviceTime.description != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• ${serviceTime.description}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreamsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current live stream
          if (_church.isCurrentlyLive) ...[
            Text(
              '🔴 Live Now',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _watchLive,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TitleFormatter.shortenForCard(
                                _church.liveStreamTitle ?? 'Live Stream',
                              ),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Streaming live from ${_church.name}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Upcoming streams
          if (_upcomingStreams.isNotEmpty) ...[
            Text(
              'Upcoming Streams',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._upcomingStreams.map((stream) => _buildStreamCard(stream)),
            const SizedBox(height: 24),
          ],

          // Past streams
          if (_pastStreams.isNotEmpty) ...[
            Text(
              'Recent Streams',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._pastStreams.map((stream) => _buildStreamCard(stream)),
          ],

          // No streams message
          if (!_church.isCurrentlyLive &&
              _upcomingStreams.isEmpty &&
              _pastStreams.isEmpty &&
              !_isLoading)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Icon(
                    Icons.videocam_off,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No streams available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for live streams',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStreamCard(Livestream stream) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LivestreamDetailPage(livestream: stream),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: stream.status == StreamStatus.live
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  stream.status == StreamStatus.live
                      ? Icons.play_arrow
                      : stream.status == StreamStatus.scheduled
                      ? Icons.schedule
                      : Icons.play_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TitleFormatter.shortenForCard(stream.title),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stream.status == StreamStatus.scheduled
                          ? 'Scheduled for ${stream.scheduledStart != null ? _formatDateTime(stream.scheduledStart!) : 'TBD'}'
                          : stream.status == StreamStatus.live
                          ? 'Live now'
                          : 'Ended ${stream.actualEnd != null ? _formatDateTime(stream.actualEnd!) : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Contact methods
          if (_church.phoneNumber != null)
            _buildContactItem(
              icon: Icons.phone,
              label: 'Phone',
              value: _church.phoneNumber!,
              onTap: _makePhoneCall,
            ),

          if (_church.contactEmail != null)
            _buildContactItem(
              icon: Icons.email,
              label: 'Email',
              value: _church.contactEmail!,
              onTap: _sendEmail,
            ),

          if (_church.websiteUrl != null)
            _buildContactItem(
              icon: Icons.language,
              label: 'Website',
              value: _church.websiteUrl!,
              onTap: _openWebsite,
            ),

          // Address
          if (_church.address != null || _church.city != null) ...[
            const SizedBox(height: 8),
            _buildContactItem(
              icon: Icons.location_on,
              label: 'Address',
              value: _buildAddressString(),
              onTap: _getDirections,
            ),
          ],

          // Social links
          if (_church.socialLinks != null &&
              _church.socialLinks!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Follow Us',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSocialLinks(),
          ],

          // No contact info message
          if (_church.phoneNumber == null &&
              _church.contactEmail == null &&
              _church.websiteUrl == null &&
              _church.address == null &&
              _church.city == null) ...[
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Icon(
                    Icons.contact_phone,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No contact information available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLinks() {
    final socialLinks = _church.socialLinks!;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: socialLinks.entries.map((entry) {
        return _buildSocialLinkButton(entry.key, entry.value.toString());
      }).toList(),
    );
  }

  Widget _buildSocialLinkButton(String platform, String url) {
    IconData icon;
    Color color;

    switch (platform.toLowerCase()) {
      case 'facebook':
        icon = Icons.facebook;
        color = const Color(0xFF1877F2);
        break;
      case 'twitter':
        icon = Icons.alternate_email;
        color = const Color(0xFF1DA1F2);
        break;
      case 'instagram':
        icon = Icons.camera_alt;
        color = const Color(0xFFE4405F);
        break;
      case 'youtube':
        icon = Icons.play_circle_filled;
        color = const Color(0xFFFF0000);
        break;
      default:
        icon = Icons.link;
        color = Theme.of(context).colorScheme.primary;
    }

    return InkWell(
      onTap: () async {
        try {
          final uri = Uri.parse(url);
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            throw 'Could not launch $url';
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to open link: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              platform,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  String _buildAddressString() {
    final parts = <String>[];

    if (_church.address != null) {
      parts.add(_church.address!);
    }

    if (_church.city != null) {
      parts.add(_church.city!);
    }

    if (_church.countryName != null) {
      parts.add(_church.countryName!);
    }

    return parts.join(', ');
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
      return 'Just now';
    }
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
