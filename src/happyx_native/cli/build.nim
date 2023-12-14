import
  os,
  osproc,
  terminal,
  strutils,
  strformat,
  xmlparser,
  xmltree,
  ../core/constants,
  ./utils


proc buildCommandAux*(target: string = OS, release: bool = false, opt: string = "size",
                      no_x86_64: bool = false, no_x86: bool = false, no_armeabi_v7a: bool = false,
                      no_arm64_v8a: bool = false): int =
  let
    mode =
      if release:
        "-d:release"
      else:
        "-d:debug"
    opt =
      case opt
      of "size":
        "--opt:size"
      of "speed":
        "--opt:speed"
      of "none", "":
        "--opt:none"
      else:
        styledEcho fgRed, "unknown opt: ", opt
        return QuitFailure
        ""
    cfg = readNativeConfig()
  if not cfg.exists:
    styledEcho fgRed, "Current directory is not HappyX Native project!"
    quit QuitFailure
  # Copy assets
  if not dirExists("build"):
    createDir("build")
  if not dirExists("build" / cfg.appDirectory):
    copyDir(getCurrentDir() / cfg.appDirectory, "build")
  case target
  of "win", "windows":
    discard execCmd(fmt"nim c {mode} {opt} -d:mingw --os:windows --outDir:build app.nim")
  of "linux", "unix":
    discard execCmd(fmt"nim c {mode} {opt} --os:linux --outDir:build app.nim")
  of "mac", "macos", "macosx":
    discard execCmd(fmt"nim c {mode} {opt} --os:macosx --outDir:build app.nim")
  of "android":
    if not dirExists("android"):
      copyDir(getAndroidFolder(), getCurrentDir() / cfg.appDirectory)
      createDir("android" / "app" / "src" / "main" / "res" / "drawable")
    
    # Setup app data
    var img: string
    withOpen(getCurrentDir() / cfg.appDirectory / "favicon.png", fmRead):
      img = fileVar.readAll()
    discard tryRemoveFile("android" / "app" / "src" / "main" / "res" / "drawable" / "ic_launcher.png")
    withOpen("android" / "app" / "src" / "main" / "res" / "drawable" / "ic_launcher.png", fmWrite):
      fileVar.write(img)
    
    var strings = loadXml("android" / "app" / "src" / "main" / "res" / "values" / "strings.xml")

    for str in strings.mitems:
      if str.attr("name") == "app_name":
        str[0].text = cfg.name
    withOpen("android" / "app" / "src" / "main" / "res" / "values" / "strings.xml", fmWrite):
      fileVar.write($strings)

    # compile .so libraries
    var
      clangPath = findClangBin(cfg.androidSdk)
      minSdk = 24
      extension =
        if OS == "win":
          ".cmd"
        else:
          ""
    var archs: seq[tuple[arch, cpu, linker: string]] = @[]
    if not no_x86:
      archs.add ("x86", "i386", fmt"i686-linux-android{minSdk}-clang{extension}")
    if not no_x86_64:
      archs.add ("x86_64", "amd64", fmt"x86_64-linux-android{minSdk}-clang{extension}")
    if not no_armeabi_v7a:
      archs.add ("armeabi-v7a", "arm", fmt"armv7a-linux-androideabi{minSdk}-clang{extension}")
    if not no_arm64_v8a:
      archs.add ("arm64-v8a", "arm64", fmt"aarch64-linux-android{minSdk}-clang{extension}")
    for data in archs:
      let (arch, cpu, linker) = data
      discard execCmd(
        fmt"""nim c {mode} {opt} -d:export2android -d:noSignalHandler --app:lib """ &
        fmt"""--os:android --cpu:{cpu} --hint[CC]:on -d:httpxSendServerDate=false -d:httpx """ &
        fmt"""--clang.path:"{clangPath}" --clang.exe:"{linker}" --clang.linkerexe:"{linker}" """ &
        fmt"""-o:android/app/src/main/jniLibs/{arch}/libhpx-native.so app.nim"""
      )
    styledEcho fgGreen, "Success build native libraries"
    styledEcho fgYellow, "Setup gradle ..."
    discard execCmdEx("gradle", workingDir = getCurrentDir() / "android")
    styledEcho fgYellow, "Building gradle ..."
    discard execCmdEx("gradle build", workingDir = getCurrentDir() / "android")
    styledEcho fgGreen, "Success"
    if not dirExists("build" / "android"):
      createDir("build" / "android")
    if not dirExists("build" / "android" / "debug"):
      createDir("build" / "android" / "debug")
    if fileExists("build" / "android" / "debug" / "app-debug.apk"):
      removeFile("build" / "android" / "debug" / "app-debug.apk")
      removeFile("build" / "android" / "debug" / "output-metadata.json")
    moveFile(getCurrentDir() / "android" / "app" / "build" / "outputs" / "apk" / "debug" / "app-debug.apk", "build" / "android" / "debug" / "app-debug.apk")
    moveFile(getCurrentDir() / "android" / "app" / "build" / "outputs" / "apk" / "debug" / "output-metadata.json", "build" / "android" / "debug" / "output-metadata.json")
  else:
    styledEcho fgRed, "unsupported target platform for building"
    return QuitFailure
  styledEcho fgGreen, "builded!"
  QuitSuccess
