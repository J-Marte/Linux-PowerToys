import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:gsettings/gsettings.dart';
import 'package:linuxpowertoys/src/backend_api/gnome/gnome_extension_utils.dart';
import 'package:logging/logging.dart';

import 'awake_backend.dart';

/// Concrete implementation of the "Awake" backend for the Gnome desktop environment.
class GnomeAwakeBackend extends AwakeBackend {
  final _logger = Logger('GnomeAwakeBackend');

  final StreamController<bool> _keepAwakeController =
      StreamController<bool>.broadcast();
  bool _lastKeepAwake = false;

  @override
  Stream<bool> get keepAwake => _keepAwakeController.stream;

  @override
  bool get lastKeepAwake => _lastKeepAwake;

  late final GSettings _caffeineSettings;

  /// Constructs a new instance of [GnomeAwakeBackend].
  GnomeAwakeBackend() {
    var homeDir = Platform.environment["HOME"];
    _caffeineSettings = GSettings(
      'org.gnome.shell.extensions.caffeine',
      schemaDirs: [
        '$homeDir/.local/share/gnome-shell/extensions/caffeine@patapon.info/schemas/'
      ],
    );

    _queryKeepAwakeValue();
    _caffeineSettings.keysChanged.listen(_handleKeysChanged);
  }

  @override
  void dispose() {
    _caffeineSettings.close();
  }

  @override
  Future<bool> isEnabled() async {
    var settings = GSettings('org.gnome.shell');
    var result = await settings
        .get('enabled-extensions')
        .then((res) => res.asStringArray().contains('caffeine@patapon.info'));
    settings.close();
    return result;
  }

  @override
  Future<bool> enable(bool newValue) async {
    return GnomeExtensionUtils.enableDisableExtension(
            'caffeine@patapon.info', newValue)
        .then((value) => true);
  }

  @override
  Future<bool> isInstalled() async {
    return _caffeineSettings.get('user-enabled').then((value) => true).onError(
        (error, stackTrace) => false,
        test: (e) => e is GSettingsSchemaNotInstalledException);
  }

  @override
  Future<bool> install() async {
    return GnomeExtensionUtils.installRemoteExtension('caffeine@patapon.info')
        .then((_) {
      var elapsed = 0;
      final completer = Completer<bool>();
      Timer.periodic(const Duration(milliseconds: 600), (timer) async {
        if (await isInstalled()) {
          timer.cancel();
          completer.complete(true);
          return;
        }
        elapsed += 5;
        if (elapsed >= 60) {
          timer.cancel();
          completer.complete(false);
        }
      });
      return completer.future;
    });
  }

  @override
  Future<void> uninstall() async {
    return GnomeExtensionUtils.uninstallExtension(
        'caffeine@patapon.info')
        .then((value) => true);
  }

  @override
  setKeepAwake(bool newValue) {
    // set the setting to <newValue>
    _setSetting('user-enabled', DBusBoolean(newValue));
    _setSetting('toggle-state', DBusBoolean(newValue));
  }

  void _setSetting(final String name, final DBusValue newValue) {
    _caffeineSettings
        .set(name, newValue)
        .then((value) => _logger.info("Set '$name' setting to $newValue"))
        .onError((err, st) {
      _logger.severe("Cannot SET setting '$name'", err, st);
    });
  }

  void _handleKeysChanged(List<String> keys) async {
    for (var changedKey in keys) {
      _logger.info('Caffeine extension. Changed key: $changedKey');
      switch (changedKey) {
        case 'toggle-state':
          _queryKeepAwakeValue();
          break;
      }
    }
  }

  void _queryKeepAwakeValue() async {
    try {
      var res = await _caffeineSettings.get('toggle-state');
      _lastKeepAwake = res.asBoolean();
      _keepAwakeController.add(_lastKeepAwake);
    } catch (e) {
      _logger.severe("Failed to get 'toggle-state' setting", e);
    }
  }
}
