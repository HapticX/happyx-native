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


nativeApp("/assets", resizeable = false, title = "android_tests")
