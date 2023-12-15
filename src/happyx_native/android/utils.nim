import
  ../cli/utils,
  ./core


proc android_log_print(prio: cint, tag: cstring, fmt: cstring) {.
  header: "<android/log.h>",
  importc: "__android_log_print",
  varargs
.}


const
  MODE_PRIVATE*: jint = 0
  ASSERT*: jint = 7
  DEBUG*: jint = 3
  ERROR*: jint = 6
  INFO*: jint = 4
  VERBOSE*: jint = 2
  WARN*: jint = 5


jClass android.content.SharedPreferences$Editor* of Object:
  proc new*
  proc apply*
  proc clear*: Editor
  proc commit*: jboolean
  proc putBoolean*(key: string, value: jboolean): Editor
  proc putFloat*(key: string, value: jfloat): Editor
  proc putInt*(key: string, value: jint): Editor
  proc putLong*(key: string, value: jlong): Editor
  proc putString*(key: string, value: string): Editor
  proc putStringSet*(key: string, value: Set[string]): Editor
  proc remove*(key: string): Editor


jClass android.content.SharedPreferences of Object:
  proc new*
  proc contains*(key: string): jboolean
  proc edit*: Editor
  proc getBoolean*(key: string, defValue: jboolean): jboolean
  proc getFloat*(key: string, defValue: jfloat): jfloat
  proc getInt*(key: string, defValue: jint): jint
  proc getLong*(key: string, defValue: jlong): jlong
  proc getString*(key: string, defValue: string): string
  proc getStringSet*(key: string, defValue: Set[string]): Set[string]


jClass android.graphics.Rect* of Object:
  proc new*
  proc new*(left, top, right, bottom: jint)
  proc new*(r: Rect)
  proc centerX*: jint
  proc centerY*: jint
  proc contains*(left, top, right, bottom: jint): jboolean
  proc contains*(r: Rect): jboolean
  proc contains*(x, y: jint): jboolean
  proc describeContents*: jint
  proc equals*(o: Object): jboolean
  proc exactCenterX*: jfloat
  proc exactCenterY*: jfloat
  proc flattenToString*: string
  proc hashCode*: jint
  proc height*: jint
  proc inset*(left, top, right, bottom: jint)
  proc inset*(dx, dy: jint)
  proc intersect*(left, top, right, bottom: jint): jboolean
  proc intersect*(r: Rect): jboolean
  proc intersects*(left, top, right, bottom: jint): jboolean
  proc intersects*(a, b: Rect): jboolean {.static.}
  proc isEmpty*: jboolean
  proc offset*(dx, dy: jint)
  proc offsetTo*(newLeft, newTop: jint)
  proc set*(left, top, right, bottom: jint)
  proc set*(src: Rect)
  proc setEmpty*
  proc setIntersect*(a, b: Rect): jboolean
  proc sort*
  proc toShortString*: string
  proc toString*: string
  proc unflattenFromString*(src: string): Rect {.static.}
  proc union*(left, top, right, bottom: jint)
  proc union*(r: Rect)
  proc union*(x, y: jint)
  proc width*: jint


jClass android.graphics.drawable.Drawable* of Object:
  proc new*
  proc canApplyFilter*: jboolean
  proc clearColorFilter*
  proc getAlpha*: jint
  proc getChangingConfigurations*: jint
  proc getIntrinsicHeight*: jint
  proc getIntrinsicWidth*: jint
  proc getLayoutDirection*: jint
  proc getLevel*: jint
  proc getMinimumHeight*: jint
  proc getMinimumWidth*: jint
  proc getOpacity*: jint
  proc getState*: seq[jint]
  proc hasFocusStateSpecified*: jboolean
  proc invalidateSelf*
  proc isAutoMirrored*: jboolean
  proc isFilterBitmap*: jboolean
  proc isProjected*: jboolean
  proc isStateful*: jboolean
  proc isVisible*: jboolean
  proc jumpToCurrentState*
  proc mutate*: Drawable
  proc onLayoutDirectionChanged*(layoutDirection: jint): jboolean
  proc resolveOpacity*(op1: jint, op2: jint): jint {.static.}
  proc setAlpha*(alpha: jint): jboolean
  proc setAutoMirrored*(mirrored: jboolean)
  proc setBounds*(left, top, right, bottom: jint)
  proc setChangingConfigurations*(configs: jint)
  proc setDither*(dither: jboolean)
  proc setFilterBitmap*(filter: jboolean)
  proc setHotspot*(x, y: jfloat)
  proc setHotspotBounds*(left, top, right, bottom: jint)
  proc setLayoutDirection*(layoutDirection: jint): jboolean
  proc setLevel*(level: jint): jboolean
  proc setState*(stateSet: seq[jint]): jboolean
  proc setTint*(tintColor: jint)
  proc setVisible*(visible, restart: jboolean)


jClass android.content.Context* of Object:
  proc new*
  proc getSharedPreferences*(name: string, mode: jint): SharedPreferences
  proc getString*(resId: jint): string


type Log* = object


proc d*(log: typedesc[Log], tag: cstring, msg: cstring) =
  android_log_print(DEBUG, tag, msg)

proc i*(log: typedesc[Log], tag: cstring, msg: cstring) =
  android_log_print(INFO, tag, msg)

proc e*(log: typedesc[Log], tag: cstring, msg: cstring) =
  android_log_print(ERROR, tag, msg)
