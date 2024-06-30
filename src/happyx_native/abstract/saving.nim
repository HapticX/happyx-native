import
  std/os,
  std/json,
  std/strformat,
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


proc loadImpl[T](filename: string): string =
  ## Loads string from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  when defined(export2android):
    var sharedPreferences = appContext.getSharedPreferences(cfgAndroidPackageId(), MODE_PRIVATE)
    return $sharedPreferences.getString(filename, "")
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
    return data


proc loadString*(filename: string): JsonNode =
  ## Loads JSON from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  return loadImpl[string](filename)


proc loadJson*(filename: string): JsonNode =
  ## Loads JSON from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  return parseJson(loadImpl[JsonNode](filename))


proc loadInt*(filename: string): int =
  ## Loads integer from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  return parseInt(loadImpl[int](filename))


proc loadFloat*(filename: string): float =
  ## Loads float from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  return parseFloat(loadImpl[float](filename))


proc loadBool*(filename: string): bool =
  ## Loads boolean from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  return parseBool(loadImpl[bool](filename))


proc loadHexInt*(filename: string): int =
  ## Loads integer from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  return parseHexInt(loadImpl[int](filename))


proc loadOctInt*(filename: string): int =
  ## Loads integer from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  return parseOctInt(loadImpl[int](filename))


proc loadEnum*[T: enum](filename: string): T =
  ## Loads integer from filename
  ## 
  ## On Android it uses SharedPreferences to data loading
  ## 
  return parseEnum[T](loadImpl[T](filename))
