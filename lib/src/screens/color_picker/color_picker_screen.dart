import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:linuxpowertoys/src/common_widgets/credits.dart';
import 'package:linuxpowertoys/src/common_widgets/screen_layout.dart';
import 'package:linuxpowertoys/src/common_widgets/setting_wrapper.dart';
import 'package:linuxpowertoys/src/common_widgets/stream_listenable_builder.dart';
import 'package:logging/logging.dart';
import 'package:colornames/colornames.dart';

import '../../backend_api/utilities/color_picker/color_picker_backend.dart';
import '../../backend_api/utilities/color_picker/gnome_color_picker_backend.dart';
import '../../common_widgets/uninstall_setting.dart';

final _logger = Logger('ColorPickerScreen');

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({
    super.key,
  });

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  final ColorPickerBackend backend = GnomeColorPickerBackend();
  bool isInstalled = true;
  bool isEnabled = false;

  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    backend.dispose();
  }

  Future<void> asyncInitState() async {
    var extensionInstalled =
        await backend.isInstalled().onError((error, stackTrace) {
      _logger.severe(
          "Cannot check if ColorPicker utility is installed", error, stackTrace);
      return isInstalled;
    });

    if (!extensionInstalled) {
      setState(() {
        isInstalled = false;
      });
      return;
    }
    var utilityIsEnabled =
        await backend.isEnabled().onError((error, stackTrace) {
      _logger.severe(
          "Cannot check if ColorPicker utility is enabled", error, stackTrace);
      return isEnabled;
    });

    setState(() {
      isEnabled = utilityIsEnabled;
      isInstalled = true;
    });
  }

  Future<void> handleInstallPressed() async {
    backend.install().then((success) => asyncInitState());
  }

  Future<void> handleEnableChange(bool newValue) async {
    var enableResult = await backend
        .enable(newValue)
        .then((_) => newValue)
        .onError((error, stackTrace) {
      _logger.severe(
          "Cannot ${newValue ? 'enable' : 'disable'} Color Picker utility",
          error,
          stackTrace);
      return isEnabled;
    });

    setState(() {
      isEnabled = enableResult;
    });
  }

  void handleUninstallPressed() {
    backend.uninstall().then((_) => asyncInitState());
  }

  @override
  Widget build(BuildContext context) {
    _logger.finest("build() _ColorPickerScreenState");

    return ScreenLayout(
      title: "Color Picker",
      description:
          "A system-wide color picking utility for Linux to pick colors from any screen and copy it to the clipboard.",
      image: Image.network(
        "https://images.unsplash.com/photo-1550859492-d5da9d8e45f3?q=80&w=800&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        fit: BoxFit.cover,
        errorBuilder: (ctx, error, stackTrace) {
          _logger.severe(
              "Cannot load asset image assets/images/ColorPicker.png", error);
          return const SizedBox();
        },
      ),
      isInstalled: isInstalled,
      handleInstallPressed: handleInstallPressed,
      children: isInstalled
          ? [
              _AutomaticallyCopy(
                enabled: isEnabled,
                backend: backend,
              ),
              _ColorsHistory(
                enabled: isEnabled,
                backend: backend,
              ),
            ]
          : [],
    );
  }
}

class _AutomaticallyCopy extends StatelessWidget {
  const _AutomaticallyCopy({
    required this.enabled,
    required this.backend,
  });

  final bool enabled;
  final ColorPickerBackend backend;

  @override
  Widget build(BuildContext context) {
    _logger.finest("build() _AutomaticallyCopy");

    var textColor = enabled
        ? Theme.of(context).textTheme.bodyMedium?.color
        : Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(90);

    return SettingWrapper(
        title: 'Settings',
        enabled: enabled,
        child: Row(
          children: [
            Text(
              'Copy HEX value to clipboard after picking a color.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: textColor),
            ),
            const Expanded(child: SizedBox()),
            StreamListenableBuilder<bool>(
              initialValue: backend.lastAutomaticallyCopy,
              stream: backend.automaticallyCopy,
              builder: (BuildContext context, bool newValue, Widget? child) {
                return Switch(
                  value: newValue,
                  onChanged: enabled ? backend.setAutomaticallyCopy : null,
                );
              },
            ),
          ],
        ));
  }
}

class _ActivationShortcut extends StatelessWidget {
  const _ActivationShortcut({
    required this.enabled,
    required this.backend,
  });

  final bool enabled;
  final ColorPickerBackend backend;

  @override
  Widget build(BuildContext context) {
    _logger.finest("build() _ActivationShortcut");

    var textColor = enabled
        ? Theme.of(context).textTheme.bodyMedium?.color
        : Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(90);

    return SettingWrapper(
        enabled: enabled,
        child: Row(
          children: [
            Text(
              'Activation shortcut',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: textColor),
            ),
            const Expanded(child: SizedBox()),
            _KeyboardButton(name: "WIN", enabled: enabled),
            const SizedBox(width: 8),
            _KeyboardButton(name: "SHIFT", enabled: enabled),
            const SizedBox(width: 8),
            _KeyboardButton(name: "C", enabled: enabled),
          ],
        ));
  }
}

class _KeyboardButton extends StatelessWidget {
  const _KeyboardButton({
    super.key,
    required this.enabled,
    required this.name
  });

  final bool enabled;
  final String name;

  @override
  Widget build(BuildContext context) {
    var textColor = enabled
        ? Theme.of(context).textTheme.bodyMedium?.color
        : Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(90);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Theme.of(context)
            .colorScheme
            .secondaryContainer
            .withAlpha(enabled ? 255 : 96),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withAlpha(48),
            spreadRadius: 0,
            blurRadius: 0,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          )
      ),
    );
  }
}

class _ColorsHistory extends StatefulWidget {
  const _ColorsHistory({
    required this.enabled,
    required this.backend,
  });

  final bool enabled;
  final ColorPickerBackend backend;

  @override
  State<_ColorsHistory> createState() => _ColorsHistoryState();
}

class _ColorsHistoryState extends State<_ColorsHistory> {
  int selectedIndex = 0;

  void onDelete(int index) {
    if (index < 0 || index >= widget.backend.lastColorsHistory.length) return;

    widget.backend.lastColorsHistory.removeAt(selectedIndex);
    setState(() {
      selectedIndex = selectedIndex > 0 ? selectedIndex-1:selectedIndex;
    });
    widget.backend.setColorsHistory(widget.backend.lastColorsHistory);
  }

  void onPickColor() {
    widget.backend.pickColor().then((color) {
      setState(() {
        selectedIndex = widget.backend.lastColorsHistory.length - 1;
      });
      if (!widget.backend.lastAutomaticallyCopy || color == null) return;

      var hex = '#${(color.value & 0xFFFFFF | 0x1000000).toRadixString(16).substring(1).toUpperCase()}';
      Clipboard.setData(ClipboardData(text: hex)).then((e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Copied $hex to clipboard'),
          duration: Durations.extralong4,
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _logger.finest("build() _ColorsHistory");

    return SettingWrapper(
        title: "Colors History",
        enabled: widget.enabled,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: StreamListenableBuilder<List<String>>(
                initialValue: widget.backend.lastColorsHistory,
                stream: widget.backend.colorsHistory,
                builder: (BuildContext context, List<String> history, Widget? child) {
                  var selectedColor = selectedIndex < history.length ? Color(int.parse(history[selectedIndex].substring(1, 7), radix: 16) + 0xFF000000):Colors.white;
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                              onPressed: widget.enabled ? onPickColor:null,
                              icon: const Icon(Icons.colorize_rounded),
                              label: const Text("Pick")
                          ),
                          const SizedBox(width: 64),
                          history.isEmpty ?
                          const SizedBox(width: 0): Expanded(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 16.0,
                              runSpacing: 8.0,
                              children: buildCircleButtons(history, onDelete)
                            ),
                          ),
                          const SizedBox(width: 64),
                          /*history.isEmpty ? const SizedBox(width: 0):
                          OutlinedButton.icon(
                              onPressed: widget.enabled ? onDelete:null,
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              label: const Text("Delete Selected",
                                  style: TextStyle(color: Colors.red)
                              ),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black, side: const BorderSide(color: Colors.red)
                              ),
                          )*/
                        ],
                      ),
                      SizedBox(height: selectedIndex < history.length ? 32:0),
                      selectedIndex < history.length ? _ColorInfo(color: selectedColor, enabled: widget.enabled):const SizedBox(height: 0),
                    ],
                  );
                },
              ),
            ),
          ],
        )
    );
  }

  List<Widget> buildCircleButtons(List<String> history, void Function(int index) onDelete) {
    return history.mapIndexed((index, colorHex) => _CircleButton(
      enabled: widget.enabled,
      color: Color(int.parse(colorHex.substring(1, 7), radix: 16) + 0xFF000000),
      onTap: widget.enabled ? () { setState(() {
        selectedIndex = index;
      }); }:null,
      selected: index == selectedIndex,
      onDelete: () => onDelete(index),
    )).toList();
  }
}

const double circleSize = 36;

class _CircleButton extends StatelessWidget {
  const _CircleButton({ super.key, required this.color, required this.onTap, required this.selected, required this.enabled, this.onDelete });

  final GestureTapCallback? onTap;
  final void Function()? onDelete;
  final Color color;
  final bool selected;
  final bool enabled;

  void _showPopupMenu(BuildContext context) async {
    var offset = (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx + (circleSize/2),
          offset.dy + (circleSize/2), offset.dx + (circleSize/2), offset.dy + (circleSize/2)),
      items: [
        const PopupMenuItem(
          value: 0,
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Remove'),
          ),
        )
      ],
      elevation: 8.0,
    ).then((value){
      if (value != null && value == 0) {
        onDelete!();
      }
    });
  }

  void onRightClick(BuildContext context) {
    _showPopupMenu(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(width: 2, color: selected ? (enabled ? color:color.withAlpha(120)):Colors.transparent)
      ),
      child: Center(
        child: SizedBox(
          width: circleSize - 8,
          height: circleSize - 8,
          child: InkWell(
            onTap: onTap,
            onSecondaryTap: onDelete != null ? () => onRightClick(context):null,
            customBorder: const CircleBorder(),
            child: Ink(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled ? color:color.withAlpha(120),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorInfo extends StatelessWidget {
  const _ColorInfo({ super.key, required this.color, required this.enabled });
  final Color color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    var hex = '#${(color.value & 0xFFFFFF | 0x1000000).toRadixString(16).substring(1).toUpperCase()}';
    var rgb = 'RGB(${color.red}, ${color.green}, ${color.blue})';
    var hsl = 'HSL(${HSLColor.fromColor(color).hue.toStringAsFixed(0)},  ${(HSLColor.fromColor(color).saturation * 100).toStringAsFixed(0)}%, ${(HSLColor.fromColor(color).lightness * 100).toStringAsFixed(0)}%)';

    return Row(
      children: [
        _buildColorDetails(context, "Color Name", ColorNames.guess(color)),
        _buildColorDetails(context, "HEX", hex),
        _buildColorDetails(context, "RGB", rgb),
        _buildColorDetails(context, "HSL", hsl),
      ],
    );
  }

  Widget _buildColorDetails(BuildContext context, String title, String colorValue) {
    var textColor = enabled
        ? Theme.of(context).textTheme.bodyMedium?.color
        : Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(90);
    return Expanded(
      child: Row(
          children: [
            const Expanded(child: SizedBox(width: 0)),
            Column(
              children: [
                Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor)),
                const SizedBox(height: 6),
                SelectableText(
                  colorValue,
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                  textAlign: TextAlign.center,
                )
              ],
            ),
            const SizedBox(width: 6),
            Ink(
              decoration: const ShapeDecoration(
                shape: CircleBorder(),
              ),
              child: IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: enabled ? () {
                  Clipboard.setData(ClipboardData(text: colorValue)).then((e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Copied $colorValue to clipboard'),
                      duration: Durations.extralong4,
                    ));
                  });
                }: null,
              ),
            ),
            const Expanded(child: SizedBox(width: 0)),
          ],
        ),
    );
  }
}
