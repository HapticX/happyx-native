# Package

description = "Macro-oriented web-framework compiles to native written with ♥"
author = "HapticX"
version = "0.1.0"
license = "MIT"
srcDir = "src"
installExt = @["nim", "gradle", "properties", "ico"]
installFiles = @["happyx_native/android/tmpl/gradlew"]
installDirs = @[
  "happyx_native/android/",
]
namedBin["happyx_native/hpxnative"] = "hpx-native"

# Deps

requires "nim >= 1.6.14"
# CLI
requires "cligen >= 1.6.14"
requires "illwill#2fe96f5c5a6e216e84554d92090ce3d47460667a"
# HappyX
requires "happyx#head"
# JVM, Android
requires "jnim#head"
