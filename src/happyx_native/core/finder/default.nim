import
  std/strutils,
  std/os,
  std/osproc,
  ../exceptions,
  ../constants


when OS == "mac":
  import std/sequtils

  proc findMac: string =
    try:
      for path in ChromePaths:
        if path.absolutePath.fileExists:
          return path
      let alternateDirs = execProcess(
        "mdfind",
        args = ["Google Chrome.app"],
        options = {poUsePath}
      ).split("\n")
      alternateDirs.keepItIf(it.contains("Google Chrome.app"))
      if alternateDirs.len > 0:
        return alternateDirs[0] & "/Contents/MacOS/Google Chrome"
      raise newException(ChromeNotFound, "could not find Chrome using `mdfind`")
    except:
      raise newException(ChromeNotFound, "could not find Chrome in Applications directory")
elif OS == "win":
  import std/registry

  proc findWindows: string =
    for path in ChromePaths:
      if path.absolutePath.fileExists:
        return path
    for path in YandexPaths:
      if path.absolutePath.fileExists:
        return path
    for path in EdgePaths:
      if path.absolutePath.fileExists:
        return path
    result = getUnicodeValue(
      path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe",
      key = "", handle = HKEY_LOCAL_MACHINE
    )
    if result.len == 0:
      result = getUnicodeValue(
        path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe",
        key = "", handle = HKEY_LOCAL_MACHINE
      )
    if result.len == 0:
      raise newException(BrowserNotFound, "could not find Default browser")
elif OS == "unix":
  proc findLinux: string =
    for path in ChromePaths:
      if execCmd("which " & name) == 0:
        return path
    for path in YandexPaths:
      if execCmd("which " & name) == 0:
        return path
    for path in EdgePaths:
      if execCmd("which " & name) == 0:
        return path
    raise newException(BrowserNotFound, "could not find Default browser")


proc findPath: string =
  when OS == "mac":
    result = findMac()
  elif OS == "win":
    result = findWindows()
  elif OS == "unix":
    result = findLinux()
  else:
    raise newException(BrowserNotFound, "unsupported OS")


proc openDefault*(port: int, chromeFlags: openarray[string]) =
  var command = " --app=http://localhost:" & $port & "/ --disable-http-cache"
  for flag in chromeFlags:
    command = command & " " & flag.strip
  if execCmd(findPath() & command) != 0:
    raise newException(BrowserNotFound, "could not open Default browser")
