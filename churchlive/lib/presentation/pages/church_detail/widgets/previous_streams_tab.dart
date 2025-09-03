import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../domain/entities/church.dart';
import '../../../../domain/entities/previous_stream.dart';
import '../../../../data/repositories/youtube_repository.dart';

class PreviousStreamsTab extends StatefulWidget {
  final Church church;

  const PreviousStreamsTab({super.key, required this.church});

  @override
  State<PreviousStreamsTab> createState() => _PreviousStreamsTabState();
}

class _PreviousStreamsTabState extends State<PreviousStreamsTab>
    with AutomaticKeepAliveClientMixin {
  final _youtubeRepository = GetIt.instance.get<YouTubeRepository>();
  final _logger = GetIt.instance.get<Logger>();

  List<PreviousStream> _streams = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String _selectedFilter = 'All';
  bool _isGridView = true;

  final List<String> _filterOptions = [
    'All',
    'Last Month',
    'Last 3 Months',
    'This Year',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPreviousStreams();
  }

  Future<void> _loadPreviousStreams() async {
    if (widget.church.youtubeChannelId == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'No YouTube channel configured for this church';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final publishedAfter = _getFilterDate();
      final streams = await _youtubeRepository.getChannelPreviousStreams(
        widget.church.id,
        widget.church.youtubeChannelId!,
        publishedAfter: publishedAfter,
      );

      setState(() {
        _streams = streams;
        _isLoading = false;
      });
    } catch (e) {
      _logger.e('Error loading previous streams: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load previous streams. Please try again.';
      });
    }
  }

  DateTime? _getFilterDate() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Last Month':
        return DateTime(now.year, now.month - 1, now.day);
      case 'Last 3 Months':
        return DateTime(now.year, now.month - 3, now.day);
      case 'This Year':
        return DateTime(now.year, 1, 1);
      default:
        return null; // Show all streams
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                          _loadPreviousStreams();
                        }
                      },
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      checkmarkColor: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView
                ? 'Switch to list view'
                : 'Switch to grid view',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_streams.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadPreviousStreams,
      child: _isGridView ? _buildGridView() : _buildListView(),
    );
  }

  Widget _buildLoadingState() {
    return _isGridView ? _buildGridLoadingState() : _buildListLoadingState();
  }

  Widget _buildGridLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildStreamCardSkeleton();
      },
    );
  }

  Widget _buildListLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildStreamListSkeleton();
      },
    );
  }

  Widget _buildStreamCardSkeleton() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamListSkeleton() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 120,
              height: 68,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Streams',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong. Please try again.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPreviousStreams,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Previous Streams',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This church hasn\'t streamed any services yet, or their streams aren\'t publicly available.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (widget.church.isCurrentlyLive)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to live streams tab (index 2)
                      try {
                        DefaultTabController.of(context).animateTo(2);
                      } catch (e) {
                        // Handle case where DefaultTabController is not found
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to navigate to live streams'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.live_tv),
                    label: const Text('Watch Live Now'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _streams.length,
      itemBuilder: (context, index) {
        return _buildStreamCard(_streams[index]);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _streams.length,
      itemBuilder: (context, index) {
        return _buildStreamListItem(_streams[index]);
      },
    );
  }

  Widget _buildStreamCard(PreviousStream stream) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _launchStream(stream),
        onLongPress: () => _showStreamOptions(stream),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: stream.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Icon(Icons.video_library_outlined),
                    ),
                  ),
                  // Duration overlay
                  if (stream.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stream.formattedDuration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  // YouTube icon
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stream.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stream.formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (stream.formattedViewCount.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        stream.formattedViewCount,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    );
  }

  Widget _buildStreamListItem(PreviousStream stream) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _launchStream(stream),
        onLongPress: () => _showStreamOptions(stream),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 120,
                height: 68,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: stream.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: const Icon(Icons.video_library_outlined),
                      ),
                    ),
                    // Duration overlay
                    if (stream.formattedDuration.isNotEmpty)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            stream.formattedDuration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stream.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stream.formattedDate} • ${stream.formattedDuration}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (stream.formattedViewCount.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        stream.formattedViewCount,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (stream.description != null &&
                        stream.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        stream.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Play icon
              const Icon(Icons.play_circle_outline, size: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _launchStream(PreviousStream stream) async {
    try {
      final uri = Uri.parse(stream.videoUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to in-app browser
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      _logger.e('Error launching stream: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open stream: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showStreamOptions(PreviousStream stream) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Watch Now'),
            onTap: () {
              Navigator.pop(context);
              _launchStream(stream);
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Copy Link'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement copy to clipboard
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
    );
  }
}
