import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TrailerPlayerScreen extends StatefulWidget {
  final String movieTitle;
  final String trailerUrl;

  const TrailerPlayerScreen({
    super.key,
    required this.movieTitle,
    required this.trailerUrl,
  });

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.trailerUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Trailer: ${widget.movieTitle}'),
          ),
          body: Center(
            child: player,
          ),
        );
      },
    );
  }
}
