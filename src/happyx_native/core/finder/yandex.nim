import
  std/strutils,
  std/os,
  std/osproc,
  ../exceptions,
  ../constants


when OS == "mac":
  proc findMac: string =
    try:
      for path in YandexPaths:
        if path.absolutePath.fileExists:
          return path
      raise newException(YandexNotFound, "could not find Yandex Browser using `mdfind`")
    except:
      raise newException(YandexNotFound, "could not find Yandex Browser in Applications directory")
elif OS == "win":
  proc findWindows: string =
    for path in YandexPaths:
      echo path.absolutePath
      if path.absolutePath.fileExists:
        return path
    raise newException(YandexNotFound, "could not find Yandex Browser")
elif OS == "unix":
  proc findLinux: string =
    for name in YandexPaths:
      if execCmd("which " & name) == 0:
        return name
    raise newException(YandexNotFound, "could not find Yandex Browser")


proc findPath: string =
  when OS == "mac":
    result = findMac()
  elif OS == "win":
    result = findWindows()
  elif OS == "unix":
    result = findLinux()
  else:
    raise newException(YandexNotFound, "unsupported OS")


proc openYandex*(port: int, chromeFlags: openarray[string]) =
  var command = " --new-window --app=http://localhost:" & $port & "/ --disable-http-cache"
  for flag in chromeFlags:
    command = command & " " & flag.strip
  if execCmd(findPath() & command) != 0:
    raise newException(YandexNotFound, "could not open Yandex Browser browser")
