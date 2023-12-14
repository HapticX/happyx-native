# Package

description = "Macro-oriented web-framework compiles to native written with ♥"
author = "HapticX"
version = "0.3.0"
license = "MIT"
srcDir = "src"
installExt = @["nim", "gradle", "properties"]
installFiles = @["happyx_native/android/tmpl/gradlew"]
installDirs = @[
  "happyx_native/android/",
  "happyx_native/assets/",
]
namedBin["happyx_native/hpxnative"] = "hpx-native"

# Deps

requires "nim >= 1.6.14"
# CLI
requires "cligen >= 1.6.14"
# HappyX
requires "happyx#head"
# JVM, Android
requires "jnim#head"
# windows executable
requires "rcedit"
