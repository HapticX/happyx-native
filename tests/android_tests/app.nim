# Main native file
import
  ../../src/happyx_native


var x = 0


callback:
  # working with SharedPreferences
  proc loadX() =
    var sharedPreferences = appContext.getSharedPreferences("com.happyx.tmpl", MODE_PRIVATE)
    x = sharedPreferences.getInt("x", 0).int
    callJs("loadX", x)
  
  proc storeX(val: int) =
    var sharedPreferences = appContext.getSharedPreferences("com.happyx.tmpl", MODE_PRIVATE)
    sharedPreferences.edit().putInt("x", val.jint).apply()
  
  proc showDialog(title: string, text: string) =
    Log.d("create dialog")
    try:
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
    except:
      Log.e(getCurrentExceptionMsg())


nativeApp("/assets", resizeable = false, title = "android_tests")
