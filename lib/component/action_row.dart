import 'dart:io';

import 'package:desktop_lyric/component/foreground.dart';
import 'package:desktop_lyric/message.dart';
import 'package:desktop_lyric/desktop_lyric_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:win32/win32.dart' as win32;

class ActionRow extends StatelessWidget {
  const ActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeChangedMessage>();
    const spacer = SizedBox(width: 8);

    final textDisplayController = context.read<TextDisplayController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () async {
            hWnd = win32.GetForegroundWindow();

            if (hWnd != null) {
              final exStyle = win32.GetWindowLongPtr(
                hWnd!,
                win32.WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE,
              );

              win32.SetWindowLongPtr(
                hWnd!,
                win32.WINDOW_LONG_PTR_INDEX.GWL_EXSTYLE,
                exStyle |
                    win32.WINDOW_EX_STYLE.WS_EX_LAYERED |
                    win32.WINDOW_EX_STYLE.WS_EX_TRANSPARENT,
              );

              stdout.write(
                DesktopLyricMessageType.ControlEventMessage.buildMessageJson(
                  const ControlEventMessage(ControlEvent.lock),
                ),
              );
            }
          },
          color: Color(theme.onSurface),
          icon: const Icon(Icons.lock),
        ),
        spacer,
        IconButton(
          onPressed: textDisplayController.increaseLyricFontSize,
          color: Color(theme.onSurface),
          icon: const Icon(Icons.text_increase),
        ),
        spacer,
        IconButton(
          onPressed: textDisplayController.decreaseLyricFontSize,
          color: Color(theme.onSurface),
          icon: const Icon(Icons.text_decrease),
        ),
        spacer,
        IconButton(
          onPressed: () {
            stdout.write(
              DesktopLyricMessageType.ControlEventMessage.buildMessageJson(
                const ControlEventMessage(ControlEvent.previousAudio),
              ),
            );
          },
          color: Color(theme.onSurface),
          icon: const Icon(Icons.skip_previous),
        ),
        spacer,
        ValueListenableBuilder(
          valueListenable: DesktopLyricController.instance.isPlaying,
          builder: (context, isPlaying, _) => IconButton(
            onPressed: () {
              stdout.write(
                DesktopLyricMessageType.ControlEventMessage.buildMessageJson(
                  ControlEventMessage(
                    isPlaying ? ControlEvent.pause : ControlEvent.start,
                  ),
                ),
              );
            },
            color: Color(theme.onSurface),
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          ),
        ),
        spacer,
        IconButton(
          onPressed: () {
            stdout.write(
              DesktopLyricMessageType.ControlEventMessage.buildMessageJson(
                const ControlEventMessage(ControlEvent.nextAudio),
              ),
            );
          },
          color: Color(theme.onSurface),
          icon: const Icon(Icons.skip_next),
        ),
        spacer,
        const _ShowColorSelectorBtn(),
        spacer,
        IconButton(
          onPressed: () {
            stdout.write(
              DesktopLyricMessageType.ControlEventMessage.buildMessageJson(
                const ControlEventMessage(ControlEvent.close),
              ),
            );
          },
          color: Color(theme.onSurface),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

final _COLOR_SELECTOR_CONTROLLER = MenuController();

class _ShowColorSelectorBtn extends StatelessWidget {
  const _ShowColorSelectorBtn({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeChangedMessage>();
    return MenuAnchor(
      controller: _COLOR_SELECTOR_CONTROLLER,
      consumeOutsideTap: true,
      onOpen: () {
        ALWAYS_SHOW_ACTION_ROW = true;
      },
      onClose: () {
        ALWAYS_SHOW_ACTION_ROW = false;
      },
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Color(theme.surfaceContainer)),
        elevation: const WidgetStatePropertyAll(8),
      ),
      menuChildren: [
        Wrap(
          children: List.generate(
            Colors.primaries.length,
            (i) => _ColorTile(color: Colors.primaries[i]),
          ),
        )
      ],
      builder: (context, controller, _) => IconButton(
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open(position: const Offset(0, 44));
          }
        },
        color: Color(theme.onSurface),
        icon: const Icon(Icons.palette),
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final Color color;
  const _ColorTile({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    final textDisplayController = context.watch<TextDisplayController>();
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Ink(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: InkWell(
          onTap: () {
            if (textDisplayController.hasSpecifiedColor) {
              if (textDisplayController.specifiedColor == color) {
                textDisplayController.usePlayerTheme();
              } else {
                textDisplayController.spcifiyColor(color);
              }
            } else {
              textDisplayController.spcifiyColor(color);
            }

            _COLOR_SELECTOR_CONTROLLER.close();
          },
          child: textDisplayController.hasSpecifiedColor &&
                  textDisplayController.specifiedColor == color
              ? const Center(
                  child: Icon(Icons.check, color: Colors.white, size: 16))
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
