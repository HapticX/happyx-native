# Main native file
import
  ../../src/happyx_native


var x = 0


callback:
  # working with SharedPreferences
  proc loadX() =
    x = loadInt("android_tests.save")
    callJs("loadX", x)
  
  proc storeX(val: int) =
    save("android_tests.save", val)
  
  proc showDialog(title: string, text: string) =
    when defined(export2android):
      Log.d("create dialog")
      runOnUiThread:
        # Experimental !!!
        # only global scope variables allowed
        var dialog = AlertDialogBuilder.new(
          appContext
        ).setTitle(
          cast[CharSequence](String.new("title"))
        ).setMessage(
          cast[CharSequence](String.new("text"))
        ).setCancelable(
          JVM_TRUE
        ).show()
        Log.d($dialog.toString())


nativeApp("/assets", resizeable = false, title = "android_tests")
