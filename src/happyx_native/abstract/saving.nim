import
  os,
  json,
  strformat,
  strutils,
  ../app/app

export
  json


when defined(export2android):
  import
    ../android/core,
    ../android/utils


template saveAndLoad[T](saveFunc, loadFunc, parseFunc: untyped, tdesc: typedesc[T],
                        genLoad: bool = true, genSave: bool = true) =
  when genSave:
    proc `saveFunc`*(filename: string, data: `tdesc`) =
      when defined(export2android):
        var sharedPreferences = appContext.getSharedPreferences(cfgAndroidPackageId(), MODE_PRIVATE)
        sharedPreferences.edit().putString(filename, $data).apply()
      else:
        if not dirExists(getHomeDir() / "hpxnative"):
          createDir(getHomeDir() / "hpxnative")
        var
          userFolder = getHomeDir() / "hpxnative" / filename
          f = open(userFolder, fmWrite)
        f.write($data)
        f.close()
  when genLoad:
    proc `loadFunc`*(filename: string): `tdesc` =
      when defined(export2android):
        var sharedPreferences = appContext.getSharedPreferences(cfgAndroidPackageId(), MODE_PRIVATE)
        return `parseFunc`(sharedPreferences.getString(filename, ""))
      else:
        if not dirExists(getHomeDir() / "hpxnative"):
          createDir(getHomeDir() / "hpxnative")
        if not fileExists(getHomeDir() / "hpxnative" / filename):
          return `tdesc`.default
        var
          userFolder = getHomeDir() / "hpxnative" / filename
          f = open(userFolder, fmRead)
          data = f.readAll()
        f.close()
        return `parseFunc`(data)


saveAndLoad(save, loadJson, parseJson, JsonNode)
saveAndLoad(save, loadString, `$`, string)
saveAndLoad(save, loadInt, parseInt, int)
saveAndLoad(save, loadFloat, parseFloat, float)
saveAndLoad(save, loadBool, parseBool, bool)
saveAndLoad(save, loadHexInt, parseHexInt, int, genSave = false)
saveAndLoad(save, loadHexInt, parseHexInt, int, genSave = false)
saveAndLoad(save, loadOctInt, parseOctInt, int, genSave = false)
