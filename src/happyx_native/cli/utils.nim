import
  os,
  osproc,
  parsecfg,
  strutils,
  strformat,
  terminal,
  streams,
  macros


const CONFIG_FILE* = "happyx.native.cfg"


type
  NativeConfig* = object
    exists*: bool
    port*: int
    name*: string
    androidSdk*: string
    androidPackage*: string
    appDirectory*: string
    version*: string


template withOpen*(filename: string, mode: FileMode, body: untyped) =
  when declared(fileVar):
    fileVar = open(filename, mode)
  else:
    var fileVar {.inject.} = open(filename, mode)
  `body`
  fileVar.close()


proc readNativeConfig*(): NativeConfig =
  result = NativeConfig(name: "", androidSdk: "", androidPackage: "", exists: false)
  if fileExists(getCurrentDir() / CONFIG_FILE):
    let cfg = loadConfig(getCurrentDir() / CONFIG_FILE)
    result.name = cfg.getSectionValue("Main", "name", "")
    result.androidSdk = cfg.getSectionValue("Main", "androidSdk", "")
    result.androidPackage = cfg.getSectionValue("Main", "androidPackage", "com.hapticx.tmpl")
    result.appDirectory = cfg.getSectionValue("Main", "appDirectory", "/assets")
    result.version = cfg.getSectionValue("Main", "version", "1.0.0")
    result.port = parseInt(cfg.getSectionValue("Main", "port", "5123"))
    result.exists = true


proc readNativeConfigCompileTime*(): NativeConfig {.compileTime.} =
  result = NativeConfig(name: "", androidSdk: "", androidPackage: "",  exists: false)
  if fileExists(getProjectPath() / CONFIG_FILE):
    let cfg = loadConfig(newStringStream(staticRead(getProjectPath() / CONFIG_FILE)))
    result.name = cfg.getSectionValue("Main", "name", "")
    result.androidSdk = cfg.getSectionValue("Main", "androidSdk", "")
    result.androidPackage = cfg.getSectionValue("Main", "androidPackage", "com.hapticx.tmpl")
    result.appDirectory = cfg.getSectionValue("Main", "appDirectory", "/assets")
    result.version = cfg.getSectionValue("Main", "version", "1.0.0")
    result.port = parseInt(cfg.getSectionValue("Main", "port", "5123"))
    result.exists = true


proc findClangBin*(androidSdk: string): string =
  var ndk =
    if dirExists(androidSdk / "ndk"):
      androidSdk / "ndk"
    elif dirExists(androidSdk / "ndk_bundle"):
      androidSdk / "ndk_bundle"
    else:
      androidSdk / "ndk-bundle"
  var latest = ""
  for kind, dir in ndk.walkDir:
    latest = dir / "toolchains" / "llvm" / "prebuilt"
  for kind, dir in latest.walkDir:
    latest = dir / "bin"
  return latest
  


proc findAndroidFolder(packagesFolder: string): string =
  for kind, dir in packagesFolder.walkDir:
    let package = dir.splitPath[1]
    if package.startsWith("happyx_native"):
      return dir / "happyx_native" / "android" / "tmpl"


proc getAndroidFolder*(): string =
  let
    packages2 = getHomeDir() / ".nimble" / "pkgs2"
    packages = getHomeDir() / ".nimble" / "pkgs"
  result = findAndroidFolder(packages2)
  if not result.existsDir:
    result = findAndroidFolder(packages)
  if not result.existsDir:
    styledEcho fgRed, "android folder was not found!"
    styledEcho fgRed, "android building will not support"
    styledEcho fgRed, "folder: ", result
    styledEcho fgYellow, "TIP: try to re-install happyx-native package"
    quit QuitFailure


proc getFavicon*(ext: string = ".ico"): string =
  let
    cfg = readNativeConfig()
    packages2 = getHomeDir() / ".nimble" / "pkgs2"
    packages = getHomeDir() / ".nimble" / "pkgs"
  var favicon = ""
  for kind, dir in packages2.walkDir:
    let package = dir.splitPath[1]
    if package.startsWith("happyx_native"):
      favicon = dir / "happyx_native" / "assets" / fmt"favicon{ext}"
  if not favicon.fileExists:
    for kind, dir in packages.walkDir:
      let package = dir.splitPath[1]
      if package.startsWith("happyx_native"):
        favicon = dir / "happyx_native" / "assets" / fmt"favicon{ext}"
  if favicon.fileExists:
    var f = open(favicon, fmRead)
    result = f.readAll()
    f.close()
