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
    result = getUnicodeValue(
      path = r"SOFTWARE\Clients\StartMenuInternet",
      key = "", handle = HKEY_LOCAL_MACHINE
    )
    if result.len == 0:
      result = getUnicodeValue(
        path = r"SOFTWARE\Clients\StartMenuInternet",
        key = "", handle = HKEY_CURRENT_USER
      )
    if result.len == 0:
      raise newException(BrowserNotFound, "could not find default browser")
elif OS == "unix":
  proc findLinux: string =
    for name in ChromePaths:
      if execCmd("which " & name) == 0:
        return name
    raise newException(ChromeNotFound, "could not find Chrome")


proc findPath: string =
  when OS == "mac":
    result = findMac()
  elif OS == "win":
    result = findWindows()
  elif OS == "unix":
    result = findLinux()
  else:
    raise newException(ChromeNotFound, "unsupported OS")


proc openDefaultBrowserApp*(port: int, chromeFlags: openarray[string]) =
  var command = " --app=http://localhost:" & $port & "/ --disable-http-cache"
  for flag in chromeFlags:
    command = command & " " & flag.strip
  if execCmd(findPath() & command) != 0:
    raise newException(ChromeNotFound, "could not open Chrome browser")
