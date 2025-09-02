import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../../data/repositories/church_repository.dart';
import '../../../../data/repositories/favorites_repository.dart';
import '../../../../domain/entities/church.dart';
import '../../../../core/utils/member_count_formatter.dart';
import '../../church_submission/church_submission_page.dart';
import '../../church_detail/church_detail_page.dart';

class ChurchesSection extends StatefulWidget {
  final String? denominationFilter;
  final String title;
  final bool showFeatured;

  const ChurchesSection({
    super.key,
    this.denominationFilter,
    this.title = 'Featured Churches',
    this.showFeatured = true,
  });

  @override
  State<ChurchesSection> createState() => _ChurchesSectionState();
}

class _ChurchesSectionState extends State<ChurchesSection> {
  final ChurchRepository _churchRepository = GetIt.instance<ChurchRepository>();
  final Logger _logger = GetIt.instance<Logger>();

  List<Church> _churches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChurches();
  }

  @override
  void didUpdateWidget(ChurchesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.denominationFilter != widget.denominationFilter ||
        oldWidget.showFeatured != widget.showFeatured) {
      _loadChurches();
    }
  }

  Future<void> _loadChurches() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<Church> churches;
      if (widget.showFeatured) {
        churches = await _churchRepository.getFeaturedChurches();
      } else {
        churches = await _churchRepository.getChurches(
          denominationFilter: widget.denominationFilter,
          limit: 10,
        );
      }

      if (mounted) {
        setState(() {
          _churches = churches;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Error loading churches: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load churches';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          SizedBox(
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
                    onPressed: _loadChurches,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (_churches.isEmpty)
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    'No churches found',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount:
                  _churches.length +
                  1, // +1 for the "Don't see your church?" card
              itemBuilder: (context, index) {
                if (index < _churches.length) {
                  final church = _churches[index];
                  return _ChurchCard(church: church);
                } else {
                  // Last item - "Don't see your church?" prompt
                  return _AddChurchPromptCard();
                }
              },
            ),
          ),
      ],
    );
  }
}

class _ChurchCard extends StatefulWidget {
  final Church church;

  const _ChurchCard({required this.church});

  @override
  State<_ChurchCard> createState() => _ChurchCardState();
}

class _ChurchCardState extends State<_ChurchCard> {
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
      final newStatus = await _favoritesRepository.toggleChurchFavorite(
        widget.church.id,
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
                  ? 'Added ${widget.church.name} to favorites'
                  : 'Removed ${widget.church.name} from favorites',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChurchDetailPage(church: widget.church),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Church image or placeholder with favorite button
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: widget.church.logoUrl != null
                        ? Image.network(
                            widget.church.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder(context);
                            },
                          )
                        : _buildPlaceholder(context),
                  ),

                  // Live indicator
                  if (widget.church.isCurrentlyLive)
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

                  // Favorite button overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: _isTogglingFavorite
                            ? SizedBox(
                                width: 20,
                                height: 20,
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
                                size: 20,
                              ),
                        onPressed: _isTogglingFavorite ? null : _toggleFavorite,
                        tooltip: _isFavorited
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Church info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.church.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (widget.church.city != null)
                        Text(
                          widget.church.city!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            MemberCountFormatter.formatMemberCountShort(
                              widget.church.memberCountRange,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      if (widget.church.verificationStatus ==
                          ChurchVerificationStatus.verified)
                        Row(
                          children: [
                            Icon(Icons.verified, size: 14, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.blue),
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

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.church,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _AddChurchPromptCard extends StatelessWidget {
  const _AddChurchPromptCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showChurchSubmissionForm(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.church,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Don't see your church?",
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to suggest a church',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Suggest',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChurchSubmissionForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ChurchSubmissionPage()),
    );
  }
}
