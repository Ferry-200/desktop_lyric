import 'package:desktop_lyric/component/foreground.dart';
import 'package:desktop_lyric/message.dart';
import 'package:desktop_lyric/desktop_lyric_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NowPlayingInfo extends StatelessWidget {
  const NowPlayingInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final textDisplayController = context.watch<TextDisplayController>();
    final theme = context.watch<ThemeChangedMessage>();

    final textColor = textDisplayController.hasSpecifiedColor
        ? textDisplayController.specifiedColor
        : Color(theme.primary);
    final textStyle = TextStyle(color: textColor);

    return ValueListenableBuilder(
      valueListenable: DesktopLyricController.instance.nowPlaying,
      builder: (context, nowPlaying, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(nowPlaying.title, style: textStyle),
            Text(
              "${nowPlaying.artist} - ${nowPlaying.album}",
              style: textStyle,
            ),
          ],
        );
      },
    );
  }
}
