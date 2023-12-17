import
  os,
  json,
  sugar,
  osproc,
  parsecfg,
  strutils,
  algorithm,
  strformat,
  terminal,
  streams,
  macros,
  regex


const CONFIG_FILE* = "happyx.native.cfg"


type
  NativeConfig* = object
    exists*: bool
    port*: int
    name*: string
    kind*: string
    androidSdk*: string
    androidPackage*: string
    appDirectory*: string
    version*: string


proc writeFileSe (file, text :string) {.compileTime.} =
  when defined(windows) or defined(macos) or defined(macosx):
    discard staticExec("echo %2 > %1" % [file, text])
  else:
    discard staticExec("cat > '$1' <<-END_MARKER\n$2\nEND_MARKER\n" % [file, text])


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
    result.kind = cfg.getSectionValue("Main", "kind", "SPA")
    result.androidSdk = cfg.getSectionValue("Main", "androidSdk", "")
    result.androidPackage = cfg.getSectionValue("Main", "androidPackage", "com.hapticx.tmpl")
    result.appDirectory = cfg.getSectionValue("Main", "appDirectory", "/assets")
    result.version = cfg.getSectionValue("Main", "version", "1.0.0")
    result.port = parseInt(cfg.getSectionValue("Main", "port", "5123"))
    result.port = parseInt(cfg.getSectionValue("Main", "port", "5123"))
    result.exists = true


proc readNativeConfigCompileTime*(): NativeConfig {.compileTime.} =
  result = NativeConfig(name: "", androidSdk: "", androidPackage: "",  exists: false)
  if fileExists(getProjectPath() / CONFIG_FILE):
    let cfg = loadConfig(newStringStream(staticRead(getProjectPath() / CONFIG_FILE)))
    result.name = cfg.getSectionValue("Main", "name", "")
    result.kind = cfg.getSectionValue("Main", "kind", "SPA")
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


proc compileHpx*(appDirectory: string) =
  let mainFile = appDirectory / "main.hpx"
  var componentNames: seq[string] = collect:
    for file in walkDirRec(appDirectory):
      if file.endsWith(".hpx"):
        file.replace(appDirectory / "", "")
  # Sort component dependencies
  var usages: seq[(string, string, int)] = @[]
  for currentComponent in componentNames:  # take one component
    var
      usage = 0
      currentComponentName = currentComponent.rsplit('.', 1)[0].rsplit({DirSep, AltSep}, 1)[1]
    for otherComponent in componentNames:  # find it in other components
      if otherComponent != currentComponent:
        when defined(export2android) or defined(buildAssets):
          var data = staticRead(appDirectory / otherComponent)
        else:
          var
            x = open(appDirectory / otherComponent)
            data = x.readAll()
          x.close()
        if re2(r"^\s*<\s*template\s*>[\s\S]+?<\s*" & currentComponentName) in data:
          inc usage
    usages.add((currentComponent, currentComponentName, usage))
  proc sortComp(x, y: (string, string, int)): int {.closure.} =
    cmp(x[2], y[2])
  usages.sort(sortComp, SortOrder.Descending)

  # Load router.json
  when defined(export2android) or defined(buildAssets):
    var routerData = parseJson(staticRead(appDirectory / "router.json"))
  else:
    var
      routerFile = open(appDirectory / "router.json")
      routerData = parseJson(routerFile.readAll())
    routerFile.close()

  # Write temporary nim file and compile it into JS
  var data = "import happyx\n\n"
  for (path, name, lvl) in usages:
    data &= fmt"""importComponent "{path.replace("\\", "\\\\")}" as {name}""" & "\n"
  data &= "\nappRoutes \"app\":\n"
  for key, val in routerData.pairs():
    data &= fmt"""  "{key}":"""
    var
      compName: string = ""
      args = newJObject()
    if val.kind == JString:
      compName = val.getStr
    elif val.kind == JObject:
      if not val.hasKey("component"):
        raise newException(ValueError, fmt"route `{key}` routes should have `component`")
      compName = val["component"].getStr
      args = val["args"]
    if compName.endsWith(".hpx"):
      compName = compName[0..^5]
    data &= "\n"
    data &= fmt"    component {compName}("
    for key, arg in args.pairs():
      case arg.kind
      of JString:
        data &= fmt"{key}={arg.getStr},"
      of JFloat, JBool, JInt:
        data &= fmt"{key}={arg},"
      of JObject:
        # detect keys is exists
        if not arg.hasKey("name"):
          raise newException(ValueError, fmt"route `{key}` component `{compName}` argument should have `name`")
        if not arg.hasKey("type"):
          raise newException(ValueError, fmt"route `{key}` component `{compName}` argument should have `type`")
        # type validation
        if arg["name"].kind != JString:
          raise newException(ValueError, fmt"route `{key}` component `{compName}` argument `name` should be string")
        if arg["type"].kind != JString:
          raise newException(ValueError, fmt"route `{key}` component `{compName}` argument `type` should be string")
        case arg["type"].getStr.toLower()
        of "pathparam", "path":
          data &= fmt"""{key}={arg["name"].getStr},"""
        of "query":
          data &= fmt"""{key}=query~{arg["name"].getStr},"""
        of "queryarr", "queryarray":
          data &= fmt"""{key}=queryArr~{arg["name"].getStr},"""
      else:
        raise newException(ValueError, fmt"Incorrect router.json structure at `{key}`")
    data &= ")\n\n"
  when defined(export2android) or defined(buildAssets):
    writeFileSe(appDirectory / "main.nim", data)
    echo staticExec("nim js -d:danger --opt:size " & appDirectory / "main.nim")
  else:
    var f = open(appDirectory / "main.nim", fmWrite)
    f.write(data)
    f.close()
    var d = execCmdEx("nim js -d:danger --opt:size " & appDirectory / "main.nim")
    echo d.output
    assert d.exitCode == 0
  discard tryRemoveFile(appDirectory / "main.nim")
