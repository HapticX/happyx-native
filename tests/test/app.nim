# Main native file
import happyx_native

var
  lastPage = "/"
  readedStories: JsonNode = newJArray()

callback:
  # HappyX Native helloWorld callback
  proc helloWorld() =
    echo 1
    lastPage = loadString("hapticx.ktc_hpx.lastPage")
    echo 1
    readedStories = loadJson("hapticx.ktc_hpx.readedStories")
    echo 1

nativeApp("/assets", resizeable = false, title = "test")
