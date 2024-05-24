import 'dart:async';
import 'dart:ui';

import 'package:dbus/dbus.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'color_picker_backend.dart';

/// Concrete implementation of the "Awake" backend for the Gnome desktop environment.
class GnomeColorPickerBackend extends ColorPickerBackend {
  final _logger = Logger('GnomeColorPickerBackend');

  final StreamController<List<String>> _colorsHistoryController =
  StreamController<List<String>>.broadcast();
  List<String> _lastColorsHistory = [];

  @override
  Stream<List<String>> get colorsHistory => _colorsHistoryController.stream;

  @override
  List<String> get lastColorsHistory => _lastColorsHistory;

  final StreamController<bool> _automaticallyCopyController =
  StreamController<bool>.broadcast();
  bool _lastAutomaticallyCopy = false;

  @override
  Stream<bool> get automaticallyCopy => _automaticallyCopyController.stream;

  @override
  bool get lastAutomaticallyCopy => _lastAutomaticallyCopy;

  late final SharedPreferences prefs;

  /// Constructs a new instance of [GnomeColorPickerBackend].
  GnomeColorPickerBackend() {
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      _queryColorsHistory();
      _queryAutomaticallyCopy();
    });
  }

  @override
  void dispose() {

  }

  @override
  Future<bool> isEnabled() async {
    return true;
  }

  @override
  Future<bool> enable(bool newValue) async {
    return true;
  }

  @override
  Future<bool> isInstalled() async {
    return true;
  }

  @override
  Future<bool> install() async {
    return true;
  }

  @override
  Future<void> uninstall() async {
    return;
  }

  @override
  setColorsHistory(List<String> newValue) {
    prefs.setStringList("color-picker/colors-history", newValue)
        .then((value) => _queryColorsHistory());
  }

  void _queryColorsHistory() async {
    try {
      _lastColorsHistory = prefs.getStringList("color-picker/colors-history") ?? [];
      _colorsHistoryController.add(_lastColorsHistory);
    } catch (e) {
      _logger.severe("Failed to get 'colors-history' setting", e);
    }
  }

  void _queryAutomaticallyCopy() async {
    try {
      _lastAutomaticallyCopy = prefs.getBool("color-picker/auto-copy") ?? true;
      _automaticallyCopyController.add(_lastAutomaticallyCopy);
    } catch (e) {
      _logger.severe("Failed to get 'auto-copy' setting", e);
    }
  }

  @override
  setAutomaticallyCopy(bool newValue) {
    prefs.setBool("color-picker/auto-copy", newValue)
        .then((value) => _queryAutomaticallyCopy());
  }

  @override
  Future<Color?> pickColor() {
    // gdbus call --session --dest org.gnome.Shell.Screenshot --object-path /org/gnome/Shell/Screenshot --method org.gnome.Shell.Screenshot.PickColor
    var dBusClient = DBusClient.session();
    return dBusClient.callMethod(
        destination: "org.gnome.Shell.Screenshot",
        path: DBusObjectPath("/org/gnome/Shell/Screenshot"),
        name: "PickColor",
        interface: "org.gnome.Shell.Screenshot",
        noReplyExpected: false
    ).then((reply) async {
      var dbusValues = reply.returnValues.first.asDict()[const DBusString("color")]?.asVariant().asStruct();
      if (dbusValues == null || dbusValues.length < 3) return null;
      Color color = Color.fromARGB(
          255,
          (dbusValues[0].asDouble() * 255).floor(),
          (dbusValues[1].asDouble() * 255).floor(),
          (dbusValues[2].asDouble() * 255).floor()
      );
      var hex = '#${(color.value & 0xFFFFFF | 0x1000000).toRadixString(16).substring(1).toUpperCase()}';
      if (_lastColorsHistory.length == 1 && _lastColorsHistory[0] == '') {
        _lastColorsHistory.clear();
      }
      _lastColorsHistory.add(hex);
      await setColorsHistory(_lastColorsHistory);
      return color;
    }).onError((DBusMethodResponseException error, stackTrace) {
      _logger.info(error.response.values);
      return null;
    });
  }
}
