import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../models/video_model.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _service = FirebaseService();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _service.signInAnonymously();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<List<VideoModel>>(
        stream: _service.watchVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _EmptyFeedState(
              onRefresh: () async {},
            );
          }

          final videos = snapshot.data!;

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return VideoPlayerCard(video: videos[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB71C1C),
        child: const Icon(Icons.upload_rounded),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadScreen()),
          );

          if (result == true && mounted) {
            setState(() {});
          }
        },
      ),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyFeedState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter_rounded, color: Color(0xFFB71C1C), size: 56),
          SizedBox(height: 16),
          Text(
            'No drama episodes yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Upload your first scene to start the story.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerCard extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerCard({super.key, required this.video});

  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  VideoPlayerController? _controller;
  final FirebaseService _service = FirebaseService();
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
        _controller!.setVolume(_isMuted ? 0 : 1);
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Stack(
      children: [
        Positioned.fill(
          child: controller != null && controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                )
              : Container(
                  color: const Color(0xFF111111),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
                  ),
                ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 120,
          child: Column(
            children: [
              _ActionButton(
                icon: Icons.favorite_rounded,
                label: '${widget.video.likes}',
                onTap: () => _service.likeVideo(widget.video.id),
              ),
              const SizedBox(height: 16),
              _ActionButton(
                icon: Icons.comment_rounded,
                label: '${widget.video.comments}',
                onTap: () {
                  _service.addComment(widget.video.id, 'Nice twist!');
                },
              ),
              const SizedBox(height: 16),
              _ActionButton(
                icon: Icons.volume_up_rounded,
                label: _isMuted ? 'Muted' : 'Sound',
                onTap: () {
                  setState(() {
                    _isMuted = !_isMuted;
                    _controller?.setVolume(_isMuted ? 0 : 1);
                  });
                },
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 90,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.video.ownerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.video.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.white.withOpacity(0.08),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseService _service = FirebaseService();
  XFile? _pickedVideo;
  bool _isUploading = false;

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _pickedVideo = video;
      });
    }
  }

  Future<void> _upload() async {
    if (_pickedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a video first')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final url = await _service.uploadVideo(
      title: _titleController.text,
      description: _descriptionController.text,
      videoFile: _pickedVideo!,
    );

    setState(() {
      _isUploading = false;
    });

    if (url != null) {
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload video')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Upload Drama Scene'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  border: Border.all(color: const Color(0xFFB71C1C), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _pickedVideo == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_library_rounded, size: 52, color: Color(0xFFB71C1C)),
                          SizedBox(height: 8),
                          Text(
                            'Tap to choose a video',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          _pickedVideo!.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Episode title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFB71C1C))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Scene description',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFB71C1C))),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isUploading ? null : _upload,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Upload scene'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FirebaseUserStream extends StatelessWidget {
  const FirebaseUserStream({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
