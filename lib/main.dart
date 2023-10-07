import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Player & Chewie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoPlayersScreen(),
    );
  }
}

class VideoPlayersScreen extends StatelessWidget {
  const VideoPlayersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Video Players'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            VideoPlayerView(
              url:
                  'https://firebasestorage.googleapis.com/v0/b/learningcourse-63cab.appspot.com/o/music.mp4?alt=media&token=efd38811-1909-4a81-ab0b-48f9b1b06903&_gl=1*18krubu*_ga*ODE1MjczOTEzLjE2OTY0MTIyNjY.*_ga_CW55HF8NVT*MTY5NjU2NjQwMy42LjEuMTY5NjU2NzYwMy43LjAuMA..',
              dataSourceType: DataSourceType.asset,
            ),
            SizedBox(height: 24),
            VideoPlayerView(
              url:
                  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
              dataSourceType: DataSourceType.network,
            ),
            SizedBox(height: 24),
            SelectVideo(),
          ],
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({
    super.key,
    required this.url,
    required this.dataSourceType,
  });

  final String url;
  final DataSourceType dataSourceType;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;

  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    switch (widget.dataSourceType) {
      case DataSourceType.asset:
        _videoPlayerController = VideoPlayerController.asset(widget.url);
        break;
      case DataSourceType.network:
        _videoPlayerController = VideoPlayerController.network(widget.url);
        break;
      case DataSourceType.file:
        _videoPlayerController = VideoPlayerController.file(File(widget.url));
        break;
      case DataSourceType.contentUri:
        _videoPlayerController =
            VideoPlayerController.contentUri(Uri.parse(widget.url));
        break;
    }

    _videoPlayerController.initialize().then(
          (_) => setState(
            () => _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController,
              aspectRatio: _videoPlayerController.value.aspectRatio,
            ),
          ),
        );
  }

//to avoid memory leak
  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.dataSourceType.name.toUpperCase(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        _videoPlayerController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Chewie(controller: _chewieController),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

class SelectVideo extends StatefulWidget {
  const SelectVideo({super.key});

  @override
  State<SelectVideo> createState() => _SelectVideoState();
}

class _SelectVideoState extends State<SelectVideo> {
  File? _file;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            final file =
                await ImagePicker().pickVideo(source: ImageSource.gallery);
            if (file != null) {
              setState(() => _file = File(file.path));
            }
          },
          child: const Text('Select Video'),
        ),
        if (_file != null)
          VideoPlayerView(
            url: _file!.path,
            dataSourceType: DataSourceType.file,
          ),
      ],
    );
  }
}
