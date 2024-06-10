<div align="center">

# HappyX Native

### macro-oriented web-framework compiles to native

[![API Reference](https://img.shields.io/badge/Reference-2b2e3b?style=for-the-badge&logo=data:image/svg%2bxml;base64,PHN2ZyB3aWR0aD0iODAwcHgiIGhlaWdodD0iODAwcHgiIHZpZXdCb3g9IjAgMCAyNCAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4NCjxwYXRoIGQ9Im05IDExYy0wLjU1MjI4IDAtMSAwLjQ0NzctMSAxczAuNDQ3NzIgMSAxIDFoNmMwLjU1MjMgMCAxLTAuNDQ3NyAxLTFzLTAuNDQ3Ny0xLTEtMWgtNnptMCAzYy0wLjU1MjI4IDAtMSAwLjQ0NzctMSAxczAuNDQ3NzIgMSAxIDFoNmMwLjU1MjMgMCAxLTAuNDQ3NyAxLTFzLTAuNDQ3Ny0xLTEtMWgtNnptMy40ODItMTJjMC42Nzg4LTAuMDAxMDQgMS4yODEyLTAuMDAxOTYgMS44Mzc2IDAuMjI4NTFzMC45ODE4IDAuNjU3MTEgMS40NjEgMS4xMzc4YzAuOTQ5NiAwLjk1MjUxIDEuOTAwNyAxLjkwMzYgMi44NTMyIDIuODUzMiAwLjQ4MDcgMC40NzkyNSAwLjkwNzQgMC45MDQ1OSAxLjEzNzggMS40NjEgMC4yMzA1IDAuNTU2NDEgMC4yMjk2IDEuMTU4OCAwLjIyODUgMS44Mzc3LTAuMDAzOCAyLjUxNTktMWUtNCA1LjAzMTgtMWUtNCA3LjU0NzggMWUtNCAwLjg4NjUgMWUtNCAxLjY1MDMtMC4wODIxIDIuMjYxOS0wLjA4ODIgMC42NTU1LTAuMjg2OSAxLjI4MzktMC43OTY2IDEuNzkzNi0wLjUwOTYgMC41MDk2LTEuMTM4IDAuNzA4NC0xLjc5MzUgMC43OTY1LTAuNjExNyAwLjA4MjItMS4zNzU1IDAuMDgyMi0yLjI2MiAwLjA4MjFoLTYuMTMxNmMtMC44ODY1IDFlLTQgLTEuNjUwMyAxZS00IC0yLjI2Mi0wLjA4MjEtMC42NTU1MS0wLjA4ODEtMS4yODM5LTAuMjg2OS0xLjc5MzUtMC43OTY1LTAuNTA5NjYtMC41MDk3LTAuNzA4NC0xLjEzODEtMC43OTY1My0xLjc5MzYtMC4wODIyNC0wLjYxMTYtMC4wODIyLTEuMzc1NC0wLjA4MjE1LTIuMjYxOWwxZS01IC0xMC4wNjZjMC0wLjAyMjAyLTFlLTUgLTAuMDQzOTctMWUtNSAtMC4wNjU4My01ZS01IC0wLjg4NjQ5LTllLTUgLTEuNjUwMyAwLjA4MjE1LTIuMjYyIDAuMDg4MTMtMC42NTU1MSAwLjI4Njg3LTEuMjgzOSAwLjc5NjU0LTEuNzkzNSAwLjUwOTY2LTAuNTA5NjcgMS4xMzgtMC43MDg0MSAxLjc5MzUtMC43OTY1NCAwLjYxMTY2LTAuMDgyMjQgMS4zNzU1LTAuMDgyMiAyLjI2Mi0wLjA4MjE1IDEuMTgyNiA3ZS01IDIuMzY1MiAwLjAwMTY4IDMuNTQ3OC0xLjRlLTR6IiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGZpbGw9IiNmMWZhOGMiIGZpbGwtcnVsZT0iZXZlbm9kZCIvPg0KPC9zdmc+DQo=&label=API&labelColor=3b3e4b)](https://hapticx.github.io/happyx-native/happyx_native.html)

</div>


## Install

```shell
nimble install happyx-native
```

or via GitHub:
```shell
nimble install https://github.com/HapticX/happyx-native
```


## Features

- Support for Chrome/Yandex/Edge browsers & Webview
- Support for Android


## Project Initialization

To init project you should use this command:
```shell
hpx-native init --name ProjectName
```

This command will automatically initialize your project.

It also fetches `ANDROID_SDK_ROOT` from environment (need for android compilation).

## Building

To build your project you should move into project folder
```shell
cd ProjectName
```

and just build it!
```shell
hpx-native build
```
This automatically builds your project for your OS as target platform.

### Cross-Compilation

To compile for other OS use
```shell
hpx-native build --target linux
```

Possible values:
| OS      | value   | aliases    |
| :--     | :--:    | :--:       |
| Windows | windows | win        |
| Linux   | linux   | unix       |
| MacOS   | macosx  | mac, macos |
| Android | android | -          |

### Android compilation

You should have:
- Android Studio with SDK and NDK;
- Gradle >= 7.5;
- Nim >= 2.0.0;

By default `hpx-native build --target android` supports all android architectures.
If you want to disable some architectures then use:
```shell
hpx-native build --target android --no-x86_64
```

Possible architectures
| Architecture | Disable Argument   |
| :--          | :--:               |
| x86          | `--no-x86`         |
| x86_64       | `--no-x86_64`      |
| armeabi-v7a  | `--no-armeabi-v7a` |
| arm64-v8a    | `--no-arm64-v8a`   |

If you doesn't want to use gradle building then use
```shell
hpx-native build --target android --no-gradle
```
This command will build only `.so` libraries.

### Building Assets

HappyX Native supports "building" assets - all resources from app directory (by default `/assets`) and all subdirectories are "sewn" into executable file.

This way you can distribute your application over the network with only one executable file.

> This option can be disabled via `--no-build-assets`

### Webview Notes

When building with `-d:webview`, on Windows, you may notice that the window icon is not set
for you. This is due to a limitation within Happyx Native, that will be resolved in the
future. Currently, you may manually link in your desired window icon, like how is done in
<https://github.com/neroist/webview/tree/main/examples/example_application/windows>.

In addition, Webview does not currently support window positioning
(see <https://github.com/webview/webview/issues/642>), so the `x` and `y` arguments passed to
`nativeApp` will be ignored.

## Browsers

If you want choose other browser instead of default - use these flags:

| browser         | flag            |
| :-----:         | :-------------: |
| Default browser | uses by default |
| Chrome          | `-d:chrome`     |
| Edge            | `-d:edge`       |
| Yandex          | `-d:yandex`     |
| Webview         | `-d:webview`    |
