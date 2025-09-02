import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../domain/entities/livestream.dart';
import '../../../data/repositories/favorites_repository.dart';
import '../../widgets/livestream_player.dart';

class LivestreamDetailPage extends StatefulWidget {
  final Livestream livestream;

  const LivestreamDetailPage({super.key, required this.livestream});

  @override
  State<LivestreamDetailPage> createState() => _LivestreamDetailPageState();
}

class _LivestreamDetailPageState extends State<LivestreamDetailPage> {
  final FavoritesRepository _favoritesRepository =
      GetIt.instance<FavoritesRepository>();
  late Livestream _currentLivestream;
  bool _isLoading = false;
  bool _isFavorited = false;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _currentLivestream = widget.livestream;
    _trackStreamView();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorited = await _favoritesRepository.isLivestreamFavorited(
      _currentLivestream.id,
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
        _currentLivestream.id,
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
                  ? 'Added ${_currentLivestream.title} to favorites'
                  : 'Removed ${_currentLivestream.title} from favorites',
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

  Future<void> _trackStreamView() async {
    // Track that user started viewing this stream
    // This would typically send analytics to your backend
    try {
      // In a real implementation, you'd track the view here
      debugPrint('Started viewing stream: ${_currentLivestream.title}');
    } catch (e) {
      debugPrint('Error tracking stream view: $e');
    }
  }

  void _onViewingStarted() {
    debugPrint('User started watching: ${_currentLivestream.title}');
    // Track viewing started event
  }

  void _onViewingEnded(Duration watchTime) {
    debugPrint('User watched for: ${watchTime.inSeconds} seconds');
    // Track viewing duration
  }

  Future<void> _refreshStream() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you'd fetch updated stream info
      // For now, we'll just simulate a refresh
      await Future.delayed(const Duration(seconds: 1));

      // Here you would call:
      // final updatedStream = await _livestreamRepository.getStreamById(_currentLivestream.id);
      // setState(() { _currentLivestream = updatedStream; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh stream: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentLivestream.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Favorite button
          IconButton(
            onPressed: _isTogglingFavorite ? null : _toggleFavorite,
            icon: _isTogglingFavorite
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )
                : Icon(
                    _isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorited ? Colors.red : null,
                  ),
            tooltip: _isFavorited
                ? 'Remove from favorites'
                : 'Add to favorites',
          ),

          // Refresh button
          IconButton(
            onPressed: _isLoading ? null : _refreshStream,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  )
                : const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => _showMoreOptions(),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Video Player
            LivestreamPlayer(
              livestream: _currentLivestream,
              onViewingStarted: _onViewingStarted,
              onViewingEnded: _onViewingEnded,
            ),

            const SizedBox(height: 16),

            // Stream Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stream Status Card
                  _buildStatusCard(),

                  const SizedBox(height: 16),

                  // Schedule Information
                  if (_currentLivestream.scheduledStart != null)
                    _buildScheduleCard(),

                  const SizedBox(height: 16),

                  // Church Information
                  if (_currentLivestream.churchName != null) _buildChurchCard(),

                  const SizedBox(height: 16),

                  // Stream Details
                  _buildDetailsCard(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor()),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            if (_currentLivestream.isLive &&
                _currentLivestream.liveViewerCount > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.visibility,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentLivestream.liveViewerCount} people watching',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],

            if (_currentLivestream.totalViews > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentLivestream.totalViews} total views',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: 8),
                Text(
                  'Schedule',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_currentLivestream.scheduledStart != null) ...[
              _buildScheduleRow(
                'Starts',
                _formatDateTime(_currentLivestream.scheduledStart!),
                Icons.play_arrow,
              ),
            ],

            if (_currentLivestream.scheduledEnd != null) ...[
              const SizedBox(height: 8),
              _buildScheduleRow(
                'Ends',
                _formatDateTime(_currentLivestream.scheduledEnd!),
                Icons.stop,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String label, String time, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(time, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildChurchCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.church),
                const SizedBox(width: 8),
                Text(
                  'Church Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              _currentLivestream.churchName!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            if (_currentLivestream.churchCity != null ||
                _currentLivestream.churchCountry != null) ...[
              const SizedBox(height: 4),
              Text(
                [
                  _currentLivestream.churchCity,
                  _currentLivestream.churchCountry,
                ].where((e) => e != null).join(', '),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 8),
                Text(
                  'Stream Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildDetailRow('Platform', _getPlatformName()),

            if (_currentLivestream.languageName != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Language', _currentLivestream.languageName!),
            ],

            if (_currentLivestream.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Tags',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _currentLivestream.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (_currentLivestream.status) {
      case StreamStatus.live:
        return Icons.radio_button_checked;
      case StreamStatus.scheduled:
        return Icons.schedule;
      case StreamStatus.ended:
        return Icons.stop_circle;
      case StreamStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor() {
    switch (_currentLivestream.status) {
      case StreamStatus.live:
        return Colors.red;
      case StreamStatus.scheduled:
        return Colors.orange;
      case StreamStatus.ended:
        return Colors.grey;
      case StreamStatus.cancelled:
        return Colors.red.withOpacity(0.7);
    }
  }

  String _getStatusText() {
    switch (_currentLivestream.status) {
      case StreamStatus.live:
        return 'Live Now';
      case StreamStatus.scheduled:
        return 'Scheduled';
      case StreamStatus.ended:
        return 'Ended';
      case StreamStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getPlatformName() {
    switch (_currentLivestream.platform) {
      case StreamPlatform.youtube:
        return 'YouTube';
      case StreamPlatform.vimeo:
        return 'Vimeo';
      case StreamPlatform.facebook:
        return 'Facebook';
      case StreamPlatform.twitch:
        return 'Twitch';
      case StreamPlatform.custom:
        return 'Custom Platform';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
    } else if (difference.inHours > 0) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minutes';
    } else if (difference.inMinutes > -60) {
      return 'Started ${(-difference.inMinutes)} minutes ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Stream'),
            onTap: () {
              Navigator.pop(context);
              // Implement share functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Report Issue'),
            onTap: () {
              Navigator.pop(context);
              // Implement report functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Stream Info'),
            onTap: () {
              Navigator.pop(context);
              // Show detailed stream info
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
