import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/repositories/livestream_repository.dart';
import '../../../../data/repositories/church_repository.dart';
import '../../../../data/repositories/favorites_repository.dart';
import '../../../../domain/entities/livestream.dart';
import '../../../../domain/entities/church.dart';
import '../../../../core/utils/member_count_formatter.dart';
import '../../../../core/utils/title_formatter.dart';
import '../../church_detail/church_detail_page.dart';

class LiveStreamsSection extends StatefulWidget {
  final String? denominationFilter;

  const LiveStreamsSection({super.key, this.denominationFilter});

  @override
  State<LiveStreamsSection> createState() => _LiveStreamsSectionState();
}

class _LiveStreamsSectionState extends State<LiveStreamsSection> {
  final LivestreamRepository _livestreamRepository =
      GetIt.instance<LivestreamRepository>();
  final ChurchRepository _churchRepository = GetIt.instance<ChurchRepository>();
  final FavoritesRepository _favoritesRepository =
      GetIt.instance<FavoritesRepository>();
  final Logger _logger = GetIt.instance<Logger>();

  List<Church> _liveChurches = [];
  List<Livestream> _liveStreams = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLiveContent();
  }

  Future<void> _loadLiveContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load both live churches and live streams
      final futures = await Future.wait([
        _churchRepository.getLiveChurches(
          denominationFilter: widget.denominationFilter,
          limit: 20, // Get more to allow for favorites prioritization
        ),
        _livestreamRepository.getLiveStreams(limit: 10),
        _favoritesRepository.getFavoriteChurchIds(),
      ]);

      final liveChurches = futures[0] as List<Church>;
      final liveStreams = futures[1] as List<Livestream>;
      final favoriteChurchIdsList = futures[2] as List<String>;
      final favoriteChurchIds = favoriteChurchIdsList.toSet();

      // Sort churches with favorites first
      final sortedChurches = _sortChurchesByFavorites(
        liveChurches,
        favoriteChurchIds,
      );

      if (mounted) {
        setState(() {
          _liveChurches = sortedChurches
              .take(10)
              .toList(); // Limit to 10 after sorting
          _liveStreams = liveStreams;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Error loading live content: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load live streams';
          _isLoading = false;
        });
      }
    }
  }

  /// Sort churches with favorites first, then by last live check time
  List<Church> _sortChurchesByFavorites(
    List<Church> churches,
    Set<String> favoriteIds,
  ) {
    final favoriteChurches = churches
        .where((church) => favoriteIds.contains(church.id))
        .toList();
    final nonFavoriteChurches = churches
        .where((church) => !favoriteIds.contains(church.id))
        .toList();

    // Sort favorites by last live check (most recent first)
    favoriteChurches.sort((a, b) {
      if (a.lastLiveCheck == null && b.lastLiveCheck == null) return 0;
      if (a.lastLiveCheck == null) return 1;
      if (b.lastLiveCheck == null) return -1;
      return b.lastLiveCheck!.compareTo(a.lastLiveCheck!);
    });

    // Sort non-favorites by last live check (most recent first)
    nonFavoriteChurches.sort((a, b) {
      if (a.lastLiveCheck == null && b.lastLiveCheck == null) return 0;
      if (a.lastLiveCheck == null) return 1;
      if (b.lastLiveCheck == null) return -1;
      return b.lastLiveCheck!.compareTo(a.lastLiveCheck!);
    });

    // Return favorites first, then non-favorites
    return [...favoriteChurches, ...nonFavoriteChurches];
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
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadLiveContent,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Combine live churches and streams
    final totalLiveContent = _liveChurches.length + _liveStreams.length;

    if (totalLiveContent == 0) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.live_tv_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No live streams at the moment',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for live services',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: totalLiveContent,
        itemBuilder: (context, index) {
          // Show live churches first, then streams
          if (index < _liveChurches.length) {
            final church = _liveChurches[index];
            return FutureBuilder<bool>(
              future: _favoritesRepository.isChurchFavorited(church.id),
              builder: (context, snapshot) {
                final isFavorite = snapshot.data ?? false;
                return _LiveChurchCard(church: church, isFavorite: isFavorite);
              },
            );
          } else {
            final streamIndex = index - _liveChurches.length;
            final stream = _liveStreams[streamIndex];
            return _LiveStreamCard(livestream: stream);
          }
        },
      ),
    );
  }
}

class _LiveStreamCard extends StatefulWidget {
  final Livestream livestream;

  const _LiveStreamCard({required this.livestream});

  @override
  State<_LiveStreamCard> createState() => _LiveStreamCardState();
}

class _LiveStreamCardState extends State<_LiveStreamCard> {
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
    final isFavorited = await _favoritesRepository.isLivestreamFavorited(
      widget.livestream.id,
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
      final newStatus = await _favoritesRepository.toggleLivestreamFavorite(
        widget.livestream.id,
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
                  ? 'Added ${widget.livestream.title} to favorites'
                  : 'Removed ${widget.livestream.title} from favorites',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
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

  Future<void> _openLiveStreamDirectly(BuildContext context) async {
    try {
      final url = Uri.parse(widget.livestream.streamUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try to open in browser
        await launchUrl(url, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open live stream: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => _openLiveStreamDirectly(context),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail placeholder with favorite button
              Stack(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.7),
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Live badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
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
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _isTogglingFavorite
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : Icon(
                                _isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorited
                                    ? Colors.red
                                    : Colors.grey.shade600,
                                size: 16,
                              ),
                      ),
                    ),
                  ),

                  // Viewer count
                  if (widget.livestream.viewerCount > 0)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.livestream.viewerCount} viewers',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Stream info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TitleFormatter.shortenForCard(widget.livestream.title),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.livestream.churchName ?? 'Unknown Church',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            _getPlatformIcon(widget.livestream.platform),
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPlatformName(widget.livestream.platform),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPlatformIcon(StreamPlatform platform) {
    switch (platform) {
      case StreamPlatform.youtube:
        return Icons.play_circle;
      case StreamPlatform.facebook:
        return Icons.facebook;
      case StreamPlatform.vimeo:
        return Icons.videocam;
      case StreamPlatform.custom:
        return Icons.live_tv;
      case StreamPlatform.twitch:
        return Icons.stream;
    }
  }

  String _getPlatformName(StreamPlatform platform) {
    switch (platform) {
      case StreamPlatform.youtube:
        return 'YouTube';
      case StreamPlatform.facebook:
        return 'Facebook';
      case StreamPlatform.vimeo:
        return 'Vimeo';
      case StreamPlatform.custom:
        return 'Live Stream';
      case StreamPlatform.twitch:
        return 'Twitch';
    }
  }
}

class _LiveChurchCard extends StatelessWidget {
  final Church church;
  final bool isFavorite;

  const _LiveChurchCard({required this.church, this.isFavorite = false});

  void _openChurchProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ChurchDetailPage(church: church)),
    );
  }

  void _openLiveStream(BuildContext context) async {
    if (church.liveStreamUrl != null && church.liveStreamUrl!.isNotEmpty) {
      try {
        final url = Uri.parse(church.liveStreamUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          // Fallback: try to open in browser
          await launchUrl(url, mode: LaunchMode.inAppWebView);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open live stream: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Live stream not available for ${church.name}. URL: ${church.liveStreamUrl ?? "null"}',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => _openLiveStream(context),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Church image/thumbnail with live badge
              Stack(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.7),
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: church.logoUrl != null
                        ? Image.network(
                            church.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.church,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.church,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                  ),

                  // Live badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
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
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Favorite star indicator
                  if (isFavorite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),

              // Church info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        church.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (church.liveStreamTitle != null) ...[
                        Text(
                          TitleFormatter.shortenForCard(
                            church.liveStreamTitle!,
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
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            MemberCountFormatter.formatMemberCountShort(
                              church.memberCountRange,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          // Church profile button
                          GestureDetector(
                            onTap: () => _openChurchProfile(context),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
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
        ),
      ),
    );
  }
}
