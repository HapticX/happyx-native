import
  std/os,
  std/json,
  std/strutils,
  std/enumutils,
  ../app/app

export
  json


when defined(export2android):
  import
    ../android/core,
    ../android/autils


proc save*(filename: string, data: string) =
  ## Saves string in filename.
  ## 
  ## On Android it uses SharedPreferences to data saving
  ## 
  when defined(export2android):
    var sharedPreferences = appContext.getSharedPreferences(cfgAndroidPackageId(), MODE_PRIVATE)
    sharedPreferences.edit().putString(filename, data).apply()
  else:
    if not dirExists(getHomeDir() / "hpxnative"):
      createDir(getHomeDir() / "hpxnative")
    var
      userFolder = getHomeDir() / "hpxnative" / filename
      f = open(userFolder, fmWrite)
    f.write(data)
    f.close()


proc save*(filename: string, data: SomeNumber) =
  ## Saves number in filename.
  ## 
  ## On Android it uses SharedPreferences to data saving
  ## 
  filename.save($data)


proc save*(filename: string, data: JsonNode) =
  ## Saves JSON in filename.
  ## 
  ## On Android it uses SharedPreferences to data saving
  ## 
  filename.save($data)


proc save*(filename: string, data: bool) =
  ## Saves boolean in filename.
  ## 
  ## On Android it uses SharedPreferences to data saving
  ## 
  filename.save($data)


proc save*[T: enum](filename: string, data: T) =
  ## Saves Enum in filename.
  ## 
  ## On Android it uses SharedPreferences to data saving
  ## 
  filename.save(data.symbolName)


template loadImpl[T](filename: string, parseFunc: untyped): untyped =
  ## Loads string from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  when defined(export2android):
    var sharedPreferences = appContext.getSharedPreferences(cfgAndroidPackageId(), MODE_PRIVATE)
    when T is string:
      return $sharedPreferences.getString(filename, "")
    else:
      if ($sharedPreferences.getString(filename, "")).len == 0:
        return T.default
      return `parseFunc`($sharedPreferences.getString(filename, ""))
  else:
    if not dirExists(getHomeDir() / "hpxnative"):
      createDir(getHomeDir() / "hpxnative")
    if not fileExists(getHomeDir() / "hpxnative" / filename):
      return T.default
    var
      userFolder = getHomeDir() / "hpxnative" / filename
      f = open(userFolder, fmRead)
      data = f.readAll()
    f.close()
    when T is string:
      return data
    else:
      if ($data).len == 0:
        return T.default
      return `parseFunc`($data)


proc loadString*(filename: string): string =
  ## Loads JSON from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  loadImpl[string](filename, `$`)


proc loadJson*(filename: string): JsonNode =
  ## Loads JSON from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  loadImpl[JsonNode](filename, parseJson)


proc loadInt*(filename: string): int =
  ## Loads integer from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  loadImpl[int](filename, parseInt)


proc loadFloat*(filename: string): float =
  ## Loads float from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  loadImpl[float](filename, parseFloat)


proc loadBool*(filename: string): bool =
  ## Loads boolean from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  loadImpl[bool](filename, parseBool)


proc loadHexInt*(filename: string): int =
  ## Loads integer from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  loadImpl[int](filename, parseHexInt)


proc loadOctInt*(filename: string): int =
  ## Loads integer from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  loadImpl[int](filename, parseOctInt)


proc loadEnum*[T: enum](filename: string): T =
  ## Loads integer from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  loadImpl[T](filename, parseEnum[T])
