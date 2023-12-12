import happyx_native


callback:
  proc testCallback() =
    echo "Hello from Nim"


onExit:
  echo "bye"


nativeApp("/assets1", resizeable = false, title = "HappyX Native!")
