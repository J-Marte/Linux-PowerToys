# Generated code do not commit.
file(TO_CMAKE_PATH "/usr/bin/flutter" FLUTTER_ROOT)
file(TO_CMAKE_PATH "/mnt/Data/github/Linux-PowerToys" PROJECT_DIR)

set(FLUTTER_VERSION "0.8.1" PARENT_SCOPE)
set(FLUTTER_VERSION_MAJOR 0 PARENT_SCOPE)
set(FLUTTER_VERSION_MINOR 8 PARENT_SCOPE)
set(FLUTTER_VERSION_PATCH 1 PARENT_SCOPE)
set(FLUTTER_VERSION_BUILD 0 PARENT_SCOPE)

# Environment variables to pass to tool_backend.sh
list(APPEND FLUTTER_TOOL_ENVIRONMENT
  "FLUTTER_ROOT=/usr/bin/flutter"
  "PROJECT_DIR=/mnt/Data/github/Linux-PowerToys"
  "DART_OBFUSCATION=false"
  "TRACK_WIDGET_CREATION=true"
  "TREE_SHAKE_ICONS=true"
  "PACKAGE_CONFIG=/mnt/Data/github/Linux-PowerToys/.dart_tool/package_config.json"
  "FLUTTER_TARGET=lib/main.dart"
)
