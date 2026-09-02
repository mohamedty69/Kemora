import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../viewmodels/post_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/story_view_model.dart';
import '../../viewmodels/places_view_model.dart';

class CreatePostScreen extends StatefulWidget {
  final bool isStory;
  const CreatePostScreen({super.key, this.isStory = false});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImageFile;
  
  int? _selectedLocationId;
  String _locationName = 'Add Location';

  bool _isSubmitting = false;
  late bool _isCreatingStory;

  @override
  void initState() {
    super.initState();
    _isCreatingStory = widget.isStory;
    // Preload top places for location picker if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final placesVM = context.read<PlacesViewModel>();
      if (placesVM.topPlaces.isEmpty) {
        placesVM.loadTopPlaces();
      }
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageFile = image;
      });
    }
  }

  void _showLocationPicker() {
    final placesVM = context.read<PlacesViewModel>();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Location', style: AppTypography.titleMedium),
              const SizedBox(height: 16),
              if (placesVM.state == PlacesState.loading)
                const Center(child: CircularProgressIndicator())
              else if (placesVM.topPlaces.isEmpty)
                const Text('No locations available')
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: placesVM.topPlaces.length,
                    itemBuilder: (context, index) {
                      final place = placesVM.topPlaces[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on, color: AppColors.primary),
                        title: Text(place.name),
                        onTap: () {
                          setState(() {
                            _selectedLocationId = int.tryParse(place.id);
                            _locationName = place.name;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_isCreatingStory && _selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A photo or video is required for a Story.')),
      );
      return;
    }

    if (!_isCreatingStory && _captionController.text.trim().isEmpty && _selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an image or caption for your Post.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final authVM = context.read<AuthViewModel>();
    if (authVM.state != AuthState.authenticated) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to post.')),
      );
      return;
    }

    if (_isCreatingStory) {
      final storyVM = context.read<StoryViewModel>();
      await storyVM.createStory('Image', mediaFile: _selectedImageFile!, locationId: _selectedLocationId);
      
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (storyVM.state == StoryState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(storyVM.errorMessage ?? 'Could not create story.')),
        );
        return;
      }
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story added!')),
      );
    } else {
      final postVM = context.read<PostViewModel>();
      await postVM.createPost(_captionController.text.trim(), imageFile: _selectedImageFile, locationId: _selectedLocationId);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (postVM.state == PostState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(postVM.errorMessage ?? 'Could not create post. Please try again.')),
        );
        return;
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post shared to Kemora Community!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KemoraAppBar(
        showBack: true,
        trailing: GestureDetector(
          onTap: _submit,
          child: Text('Share', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryContainer)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Image Preview
            GestureDetector(
              onTap: _pickImage,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_selectedImageFile != null)
                        kIsWeb
                            ? Image.network(_selectedImageFile!.path, fit: BoxFit.cover)
                            : Image.file(File(_selectedImageFile!.path), fit: BoxFit.cover)
                      else
                        const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 64, color: AppColors.outlineVariant),
                              SizedBox(height: 8),
                              Text('Tap to pick image', style: TextStyle(color: AppColors.outlineVariant)),
                            ],
                          ),
                        ),
                      if (_selectedImageFile != null)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Row(
                            children: [
                              _buildOverlayBtn(Icons.crop),
                              const SizedBox(width: 8),
                              _buildOverlayBtn(Icons.tune),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Post type toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Post'),
                  selected: !_isCreatingStory,
                  onSelected: (val) {
                    if (val) setState(() => _isCreatingStory = false);
                  },
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Story'),
                  selected: _isCreatingStory,
                  onSelected: (val) {
                    if (val) setState(() => _isCreatingStory = true);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Caption
            if (!_isCreatingStory)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: AppColors.outlineVariant),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Write a caption...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Interaction List
            GestureDetector(
              onTap: _showLocationPicker,
              child: _buildInteractionRow(Icons.location_on, _locationName, null),
            ),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isCreatingStory ? 'Post to Story' : 'Post to Kemora Community'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildInteractionRow(IconData icon, String title, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryContainer.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryContainer, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium),
                if (subtitle != null)
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
        ],
      ),
    );
  }
}
