// [KEMORA-MIGRATION] Wired to PostViewModel for real-time posts from backend.
// Stories remain on CommunityProvider — no backend endpoint for stories exists yet.
// [KEMORA-TODO] Stories — wire to a real stories/stories endpoint when available.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/filter_chip_row.dart';
import '../../viewmodels/post_view_model.dart';
import '../../viewmodels/story_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import 'create_post_screen.dart';
import 'widgets/feed_post_card.dart';
import 'widgets/story_viewer_screen.dart';
import 'widgets/comment_bottom_sheet.dart';
import '../../widgets/fade_slide_in.dart';
import '../../../core/router/page_transitions.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {


  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postVm = context.read<PostViewModel>();
      if (postVm.state == PostState.initial) {
        postVm.loadFeed();
      }
      
      final storyVm = context.read<StoryViewModel>();
      if (storyVm.state == StoryState.initial) {
        storyVm.loadActiveStories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storyVm = context.watch<StoryViewModel>();
    final stories = storyVm.activeStories;
    final postVm = context.watch<PostViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final currentUserId = authVm.user?.id;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 100)),

          // Stories
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delayMs: 0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    if (storyVm.state == StoryState.loading)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      )
                    else
                      ...stories.map((group) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _buildStoryItem(
                              name: group.userName,
                              imageUrl: group.userProfilePicture ?? group.stories.first.mediaUrl,
                              userGroup: group,
                            ),
                          )),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),



          // [KEMORA-MIGRATION] Feed posts — from PostViewModel (real API)
          if (postVm.state == PostState.loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (postVm.state == PostState.error)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined,
                        color: AppColors.outline, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      postVm.errorMessage ?? 'Could not load posts.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => postVm.loadFeed(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (postVm.posts.isEmpty && postVm.state == PostState.loaded)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Text(
                    'No posts yet. Be the first to share!',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = postVm.posts[index];
                  return FadeSlideIn(
                    delayMs: 200 + (index * 60),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24)
                          .copyWith(bottom: 40),
                      child: FeedPostCard(
                        postId: post.id,
                        authorName: post.authorName,
                        authorProfilePicture: post.authorProfilePicture,
                        location: post.locationName ?? '',
                        timeAgo: _timeAgo(post.createdAt),
                        content: post.content,
                        hashtags: '',
                        imageUrl: post.imageUrl ??
                            'assets/images/mocked/CommunityPost.jpg',
                        initialLikes: post.likesCount,
                        isLiked: post.isLikedByMe,
                        initialComments: post.commentsCount,
                        isMyPost: post.authorId == currentUserId,
                        onDeleteTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Post'),
                              content: const Text('Are you sure you want to delete this post?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    postVm.deletePost(post.id);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        onEditTap: () {
                          // For simplicity, just an alert to enter new content
                          final txtController = TextEditingController(text: post.content);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Edit Post'),
                              content: TextField(
                                controller: txtController,
                                maxLines: 4,
                                decoration: const InputDecoration(border: OutlineInputBorder()),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    postVm.updatePost(post.id, txtController.text);
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
                        onLikeTap: () => postVm.toggleLike(post.id),
                        onCommentTap: () {
                          postVm.loadComments(post.id);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) =>
                                ChangeNotifierProvider<PostViewModel>.value(
                              value: postVm,
                              child: CommentBottomSheet(postId: post.id),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                childCount: postVm.posts.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(FadePageRoute(child: const CreatePostScreen()));
          },
          backgroundColor: AppColors.primaryContainer,
          elevation: 8,
          child: const Icon(Icons.add_a_photo, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStoryItem({
    bool isAdd = false,
    required String name,
    String? imageUrl,
    dynamic userGroup,
  }) {
    final fallbackImage = 'assets/images/mocked/CommunityStory.jpg';
    
    Widget imageWidget;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      imageWidget = Image.network(imageUrl, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surfaceContainerHigh,
          child: const Icon(Icons.person, color: AppColors.outlineVariant, size: 40),
        ),
      );
    } else {
      imageWidget = Image.asset(imageUrl ?? fallbackImage, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surfaceContainerHigh,
          child: const Icon(Icons.person, color: AppColors.outlineVariant, size: 40),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (!isAdd && userGroup != null) {
          Navigator.push(
              context, FadePageRoute(child: StoryViewerScreen(userGroup: userGroup)));
        } else if (isAdd) {
          // Routing to CreatePostScreen for creating a story
          Navigator.push(context, FadePageRoute(child: const CreatePostScreen(isStory: true)));
        }
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondaryContainer]),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerLowest,
                border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipOval(child: imageWidget),
                  if (isAdd)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.add, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(name,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
