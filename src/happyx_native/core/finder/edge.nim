import
  std/strutils,
  std/os,
  std/osproc,
  ../exceptions,
  ../constants


when OS == "mac":
  proc findMac: string =
    try:
      for path in EdgePaths:
        if path.absolutePath.fileExists:
          return path
      raise newException(EdgeNotFound, "could not find Edge using `mdfind`")
    except:
      raise newException(EdgeNotFound, "could not find Edge in Applications directory")
elif OS == "win":
  import std/registry

  proc findWindows: string =
    for path in EdgePaths:
      if path.absolutePath.fileExists:
        return path
    result = getUnicodeValue(
      path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe",
      key = "", handle = HKEY_LOCAL_MACHINE
    )
    if result.len == 0:
      raise newException(ChromeNotFound, "could not find Chrome")
elif OS == "unix":
  proc findLinux: string =
    for name in EdgePaths:
      if execCmd("which " & name) == 0:
        return name
    raise newException(EdgeNotFound, "could not find Edge")


proc findPath: string =
  when OS == "mac":
    result = findMac()
  elif OS == "win":
    result = findWindows()
  elif OS == "unix":
    result = findLinux()
  else:
    raise newException(EdgeNotFound, "unsupported OS")


proc openEdge*(port: int, chromeFlags: openarray[string]) =
  var command = " --new-window --app=http://localhost:" & $port & "/ --disable-http-cache"
  for flag in chromeFlags:
    command = command & " " & flag.strip
  if execCmd(findPath() & command) != 0:
    raise newException(EdgeNotFound, "could not open Edge browser")
