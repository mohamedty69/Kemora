import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../data/models/story_model.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/viewmodels/auth_view_model.dart';
import '../../../../presentation/viewmodels/story_view_model.dart';

class StoryViewerScreen extends StatefulWidget {
  final UserStoriesGroup userGroup;

  const StoryViewerScreen({super.key, required this.userGroup});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  double _progress = 0.0;
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.01;
      });
      if (_progress >= 1.0) {
        _timer?.cancel();
        _nextStory();
      }
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.userGroup.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _progress = 0.0;
      });
      _startTimer();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _progress = 0.0;
      });
      _startTimer();
    } else {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userGroup.stories.isEmpty) return const SizedBox.shrink();
    final story = widget.userGroup.stories[_currentIndex];
    final currentUserId = context.read<AuthViewModel>().user?.id;
    final isMyStory = story.authorId == currentUserId;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapDown: (details) {
            _timer?.cancel();
            final screenWidth = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx < screenWidth / 3) {
              _previousStory();
            } else {
              _nextStory();
            }
          },
          onTapUp: (_) => _startTimer(),
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
              Navigator.pop(context);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                story.mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image, color: Colors.white, size: 64)),
              ),
              // Progress bar
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: List.generate(widget.userGroup.stories.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: LinearProgressIndicator(
                          value: index < _currentIndex
                              ? 1.0
                              : (index == _currentIndex ? _progress : 0.0),
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // User info
              Positioned(
                top: 30,
                left: 16,
                right: 50,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      backgroundImage: widget.userGroup.userProfilePicture != null
                          ? NetworkImage(widget.userGroup.userProfilePicture!)
                          : null,
                      child: widget.userGroup.userProfilePicture == null
                          ? Text(widget.userGroup.userName[0],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold))
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(widget.userGroup.userName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(color: Colors.black54, blurRadius: 4)
                                      ])),
                              const SizedBox(width: 8),
                              Text(_timeAgo(story.createdAt),
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      shadows: [
                                        Shadow(color: Colors.black54, blurRadius: 4)
                                      ])),
                            ],
                          ),
                          if (story.locationName != null && story.locationName!.isNotEmpty)
                            Text(story.locationName!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    shadows: [
                                      Shadow(color: Colors.black54, blurRadius: 4)
                                    ])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Close button
              Positioned(
                top: 30,
                right: 10,
                child: Row(
                  children: [
                    if (isMyStory)
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                        onPressed: () {
                          _timer?.cancel();
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Story'),
                              content: const Text('Are you sure you want to delete this story?'),
                              actions: [
                                TextButton(onPressed: () {
                                  Navigator.pop(ctx);
                                  _startTimer();
                                }, child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () async {
                                    final vm = context.read<StoryViewModel>();
                                    Navigator.pop(ctx); // Close dialog
                                    
                                    // Optimistically remove from local group so UI updates
                                    setState(() {
                                      widget.userGroup.stories.removeAt(_currentIndex);
                                    });
                                    
                                    // Call the backend to delete
                                    await vm.deleteStory(story.id);

                                    if (!mounted) return;

                                    if (widget.userGroup.stories.isEmpty) {
                                      Navigator.pop(context); // Close viewer if empty
                                    } else {
                                      // Adjust index if we deleted the last remaining story
                                      if (_currentIndex >= widget.userGroup.stories.length) {
                                        _currentIndex = widget.userGroup.stories.length - 1;
                                      }
                                      _startTimer();
                                    }
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
