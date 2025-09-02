import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/livestream.dart';

class LivestreamPlayer extends StatefulWidget {
  final Livestream livestream;
  final VoidCallback? onViewingStarted;
  final Function(Duration)? onViewingEnded;

  const LivestreamPlayer({
    super.key,
    required this.livestream,
    this.onViewingStarted,
    this.onViewingEnded,
  });

  @override
  State<LivestreamPlayer> createState() => _LivestreamPlayerState();
}

class _LivestreamPlayerState extends State<LivestreamPlayer> {
  YoutubePlayerController? _youtubeController;
  WebViewController? _webViewController;
  DateTime? _viewingStartTime;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _viewingStartTime = DateTime.now();
    widget.onViewingStarted?.call();
  }

  @override
  void dispose() {
    if (_viewingStartTime != null) {
      final duration = DateTime.now().difference(_viewingStartTime!);
      widget.onViewingEnded?.call(duration);
    }
    _youtubeController?.dispose();
    super.dispose();
  }

  void _initializePlayer() {
    switch (widget.livestream.platform) {
      case StreamPlatform.youtube:
        _initializeYouTubePlayer();
        break;
      case StreamPlatform.vimeo:
      case StreamPlatform.facebook:
      case StreamPlatform.twitch:
      case StreamPlatform.custom:
        _initializeWebViewPlayer();
        break;
    }
  }

  void _initializeYouTubePlayer() {
    if (widget.livestream.youtubeVideoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: widget.livestream.youtubeVideoId!,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          captionLanguage: 'en',
          forceHD: false,
          loop: false,
          isLive: widget.livestream.isLive,
        ),
      );
    }
  }

  void _initializeWebViewPlayer() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar if needed
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      );

    String embedUrl = '';
    switch (widget.livestream.platform) {
      case StreamPlatform.vimeo:
        if (widget.livestream.vimeoVideoId != null) {
          embedUrl =
              'https://player.vimeo.com/video/${widget.livestream.vimeoVideoId}';
        }
        break;
      case StreamPlatform.facebook:
        if (widget.livestream.facebookVideoId != null) {
          embedUrl =
              'https://www.facebook.com/plugins/video.php?href=${Uri.encodeComponent(widget.livestream.streamUrl)}';
        }
        break;
      case StreamPlatform.twitch:
        embedUrl = widget.livestream.streamUrl;
        break;
      case StreamPlatform.custom:
        embedUrl =
            widget.livestream.customEmbedUrl ?? widget.livestream.streamUrl;
        break;
      default:
        embedUrl = widget.livestream.streamUrl;
    }

    if (embedUrl.isNotEmpty) {
      _webViewController!.loadRequest(Uri.parse(embedUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player
          _buildVideoPlayer(),

          // Stream Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Live Badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.livestream.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.livestream.isLive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Church Info
                if (widget.livestream.churchName != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.church,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.livestream.churchName!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],

                // Viewer Count
                if (widget.livestream.isLive &&
                    widget.livestream.liveViewerCount > 0) ...[
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
                        '${widget.livestream.liveViewerCount} watching',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Description
                if (widget.livestream.description != null) ...[
                  Text(
                    widget.livestream.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],

                // Action Buttons
                Row(
                  children: [
                    // External Link Button
                    OutlinedButton.icon(
                      onPressed: () => _launchExternalUrl(),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Watch on Platform'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Share Button
                    OutlinedButton.icon(
                      onPressed: () => _shareStream(),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (widget.livestream.platform == StreamPlatform.youtube &&
        _youtubeController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Theme.of(context).colorScheme.primary,
          onReady: () {
            debugPrint('YouTube player ready');
          },
          onEnded: (metaData) {
            debugPrint('YouTube video ended');
          },
        ),
      );
    } else if (_webViewController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: WebViewWidget(controller: _webViewController!),
      );
    } else {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load video player',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _launchExternalUrl(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.7)),
                  ),
                  child: Text(
                    'Watch Externally',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _launchExternalUrl() async {
    final url = Uri.parse(widget.livestream.streamUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open stream URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareStream() async {
    // For now, we'll just copy to clipboard or show share dialog
    // In a real app, you'd use share_plus package
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Share Stream'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share this livestream:'),
              const SizedBox(height: 8),
              SelectableText(
                '${widget.livestream.title}\n${widget.livestream.streamUrl}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
