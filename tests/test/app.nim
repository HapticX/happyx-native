# Main native file
import happyx_native


callback:
  # HappyX Native helloWorld callback
  proc helloWorld() =
    echo "Hello from Nim"


nativeApp("/assets", resizeable = false, title = "test")
