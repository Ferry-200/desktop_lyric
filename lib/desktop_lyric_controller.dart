import 'dart:convert';
import 'dart:io';

import 'package:desktop_lyric/message.dart';
import 'package:flutter/material.dart';

import 'package:win32/win32.dart' as win32;

int? hWnd;

class DesktopLyricController {
  ValueNotifier<bool> isPlaying = ValueNotifier(false);
  ValueNotifier<bool> isDarkMode = ValueNotifier(false);
  ValueNotifier<ThemeChangedMessage> theme = ValueNotifier(
    ThemeChangedMessage(
      Colors.blue.value,
      Colors.white.value,
      Colors.black.value,
    ),
  );
  ValueNotifier<NowPlayingChangedMessage> nowPlaying = ValueNotifier(
    const NowPlayingChangedMessage("无", "无", "无"),
  );
  ValueNotifier<LyricLineChangedMessage> lyricLine = ValueNotifier(
    const LyricLineChangedMessage("无", Duration.zero, "无"),
  );

  static void initWithArgs(List<String> args) {
    if (args.length != 1) return;

    _instance = DesktopLyricController._();
    try {
      final initArgs = InitArgsMessage.fromJson(json.decode(args.first));
      _instance!.nowPlaying.value = NowPlayingChangedMessage(
        initArgs.title,
        initArgs.artist,
        initArgs.album,
      );

      _instance!.isDarkMode.value = initArgs.darkMode;
      _instance!.theme.value = ThemeChangedMessage(
        initArgs.primary,
        initArgs.surfaceContainer,
        initArgs.onSurface,
      );
    } catch (err, stack) {
      stderr.write(err);
      stderr.write(stack);
    }
  }

  static DesktopLyricController? _instance;
  static DesktopLyricController get instance {
    _instance ??= DesktopLyricController._();
    return _instance!;
  }

  DesktopLyricController._() {
    stdin.transform(utf8.decoder).listen((event) {
      try {
        final Map messageMap = json.decode(event);
        final String type = messageMap["type"];
        final content = messageMap["message"] as Map<String, dynamic>;

        if (type == DesktopLyricMessageType.PlayerStateChangedMessage.name) {
          final playerState = PlayerStateChangedMessage.fromJson(content);
          isPlaying.value = playerState.playing;
        } else if (type ==
            DesktopLyricMessageType.NowPlayingChangedMessage.name) {
          final nowPlayingMessage = NowPlayingChangedMessage.fromJson(content);
          nowPlaying.value = nowPlayingMessage;
          lyricLine.value = const LyricLineChangedMessage("", Duration.zero);
        } else if (type ==
            DesktopLyricMessageType.LyricLineChangedMessage.name) {
          final lyricLineMessage = LyricLineChangedMessage.fromJson(content);
          lyricLine.value = lyricLineMessage;
        } else if (type ==
            DesktopLyricMessageType.ThemeModeChangedMessage.name) {
          final themeMode = ThemeModeChangedMessage.fromJson(content);
          isDarkMode.value = themeMode.darkMode;
        } else if (type == DesktopLyricMessageType.ThemeChangedMessage.name) {
          final themeMessage = ThemeChangedMessage.fromJson(content);
          theme.value = themeMessage;
        } else if (type == DesktopLyricMessageType.UnlockMessage.name) {
          if (hWnd != null) {
            final exStyle = win32.GetWindowLongPtr(
              hWnd!,
              win32.WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE,
            );

            win32.SetWindowLongPtr(
              hWnd!,
              win32.WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE,
              exStyle &
                  ~win32.WINDOW_EX_STYLE.WS_EX_LAYERED &
                  ~win32.WINDOW_EX_STYLE.WS_EX_TRANSPARENT,
            );
          }
        }
      } catch (err, stack) {
        stderr.write(err);
        stderr.write(stack);
      }
    });
  }
}
