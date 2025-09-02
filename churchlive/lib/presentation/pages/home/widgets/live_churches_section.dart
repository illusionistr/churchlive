import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../data/repositories/church_repository.dart';
import '../../../../data/repositories/favorites_repository.dart';
import '../../../../domain/entities/church.dart';
import '../../../../domain/entities/livestream.dart';
import '../../../../core/utils/member_count_formatter.dart';
import '../../../../core/utils/title_formatter.dart';
import '../../livestream/livestream_detail_page.dart';

class LiveChurchesSection extends StatefulWidget {
  final String? denominationFilter;

  const LiveChurchesSection({super.key, this.denominationFilter});

  @override
  State<LiveChurchesSection> createState() => _LiveChurchesSectionState();
}

class _LiveChurchesSectionState extends State<LiveChurchesSection> {
  final ChurchRepository _churchRepository = GetIt.instance<ChurchRepository>();

  List<Church> _liveChurches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLiveChurches();
  }

  Future<void> _loadLiveChurches() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final liveChurches = await _churchRepository.getLiveChurches(
        denominationFilter: widget.denominationFilter,
        limit: 10,
      );

      setState(() {
        _liveChurches = liveChurches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshLiveChurches() async {
    await _loadLiveChurches();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load live churches',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _refreshLiveChurches,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_liveChurches.isEmpty) {
      return Container(
        height: 160,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.live_tv_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No churches are live right now',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Check back later for live streams',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with live count and refresh button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_liveChurches.length} ${_liveChurches.length == 1 ? 'church' : 'churches'} streaming now',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                onPressed: _refreshLiveChurches,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh live status',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Live churches list
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _liveChurches.length,
            itemBuilder: (context, index) {
              final church = _liveChurches[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < _liveChurches.length - 1 ? 16 : 0,
                ),
                child: _LiveChurchCard(
                  church: church,
                  onTap: () => _openLiveStream(church),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openLiveStream(Church church) {
    // Navigate to livestream detail page if church has live stream URL
    if (church.liveStreamUrl != null) {
      // Create a mock livestream object from the church's live data
      final livestream = Livestream(
        id: 'live-${church.id}',
        churchId: church.id,
        title: church.liveStreamTitle != null
            ? TitleFormatter.shortenForHeader(church.liveStreamTitle!)
            : 'Live Stream',
        description: 'Live stream from ${church.name}',
        platform: StreamPlatform.youtube,
        streamUrl: church.liveStreamUrl!,
        isLive: church.isCurrentlyLive,
        status: StreamStatus.live,
        isFeatured: false,
        viewerCount: 0,
        maxViewers: 0,
        isRecurring: false,
        recurrencePattern: RecurrenceType.none,
        isChatEnabled: false,
        tags: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        thumbnailUrl: church.logoUrl,
        youtubeVideoId: _extractYouTubeVideoId(church.liveStreamUrl!),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LivestreamDetailPage(livestream: livestream),
        ),
      );
    } else {
      // Show a message that the stream is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stream not available at the moment')),
      );
    }
  }

  String? _extractYouTubeVideoId(String url) {
    final regex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)');
    final match = regex.firstMatch(url);
    return match?.group(1);
  }
}

class _LiveChurchCard extends StatefulWidget {
  final Church church;
  final VoidCallback onTap;

  const _LiveChurchCard({required this.church, required this.onTap});

  @override
  State<_LiveChurchCard> createState() => _LiveChurchCardState();
}

class _LiveChurchCardState extends State<_LiveChurchCard> {
  final FavoritesRepository _favoritesRepository =
      GetIt.instance<FavoritesRepository>();
  bool _isFavorited = false;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorited = await _favoritesRepository.isChurchFavorited(
      widget.church.id,
    );
    if (mounted) {
      setState(() {
        _isFavorited = isFavorited;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite) return;

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      await _favoritesRepository.toggleChurchFavorite(widget.church.id);
      if (mounted) {
        setState(() {
          _isFavorited = !_isFavorited;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating favorites: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 260,
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Church image/logo with live indicator
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    image: widget.church.logoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(widget.church.logoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      if (widget.church.logoUrl == null)
                        Center(
                          child: Icon(
                            Icons.church,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      // Live indicator
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Church info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.church.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        if (widget.church.liveStreamTitle != null) ...[
                          Text(
                            TitleFormatter.shortenForCard(
                              widget.church.liveStreamTitle!,
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                        ],
                        if (widget.church.city != null) ...[
                          Text(
                            widget.church.city!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                MemberCountFormatter.formatMemberCountShort(
                                  widget.church.memberCountRange,
                                ),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 11,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Favorite button
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _isTogglingFavorite ? null : _toggleFavorite,
                  icon: _isTogglingFavorite
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorited ? Colors.red : Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
