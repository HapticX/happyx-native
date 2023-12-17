import
  macros,
  strformat,
  tables,
  ../cli/utils,
  ./core


proc android_log_print(prio: cint, tag: cstring, fmt: cstring) {.
  header: "<android/log.h>",
  importc: "__android_log_print",
  varargs
.}

# type CodeBlockArgument* = pointer

var
  uniqueCodeBlocks*: seq[uint64] = @[]
  # argumentsCodeBlocks* = newTable[int, seq[CodeBlockArgument]]()



const
  MODE_PRIVATE*: jint = 0
  ASSERT*: jint = 7
  DEBUG*: jint = 3
  ERROR*: jint = 6
  INFO*: jint = 4
  VERBOSE*: jint = 2
  WARN*: jint = 5


jclass java.lang.CharSequence* of Object:
  proc charAt*(idx: jint): jchar
  proc length*: jint


jClass java.lang.StackTraceElement* of Object:
  proc new*(declaringClass: string, methodName: string, fileName: string, lineNumber: int)
  proc equals*(obj: Object): jboolean
  proc getClassName*: string
  proc getFileName*: string
  proc getLineNumber*: jint
  proc getMethodName*: string
  proc hashCode*: jint
  proc isNativeMethod*: jboolean
  proc toString*: string


jClass java.io.Writer* of Object:
  proc new*
  proc new*(lock: Object)
  proc append*(c: jchar): Writer
  proc close*
  proc flush*
  proc nullWriter*: Writer {.static.}
  proc write*(s: string)
  proc write*(c: jint)
  proc write*(s: string, off: jint, len: jint)


jClass java.lang.Throwable* of Object:
  proc new*
  proc new*(message: string)
  proc new*(message: string, cause: Throwable)
  proc new*(cause: Throwable)
  proc addSuspend*(exception: Throwable)
  proc fillInStackTrace*: Throwable
  proc getCause*: Throwable
  proc getLocalizedMessage*: string
  proc getMessage*: string
  proc getStackTrace*: seq[StackTraceElement]
  proc getSuppressed*: seq[Throwable]
  proc initCause*(cause: Throwable): Throwable
  proc printStackTrace*
  proc setStackTrace*(stackTrace: seq[StackTraceElement])
  proc toString*: string


jClass java.io.FileDescriptor* of Object:
  proc new*
  proc sync*
  proc valid*: jboolean


jclassDef java.lang.Thread* of Object


jClass java.lang.ThreadGroup* of Object:
  proc new*(name: string)
  proc new*(parent: ThreadGroup, name: string)
  proc activeCount*: jint
  proc activeGroupCount*: jint
  proc allowThreadSuspension*(b: jboolean): jboolean
  proc checkAccess*
  proc destroy*
  proc enumerate*(list: seq[ThreadGroup]): jint
  proc enumerate*(list: seq[ThreadGroup], recurse: jboolean): jint
  proc enumerate*(list: seq[Thread]): jint
  proc enumerate*(list: seq[Thread], recurse: jboolean): jint
  proc getMaxPriority*: jint
  proc getName*: string
  proc getParent*: ThreadGroup
  proc interrupt*
  proc isDaemon*: jboolean
  proc isDestroyed*: jboolean
  proc list*
  proc parentOf*(g: ThreadGroup): jboolean
  proc resume*
  proc setDaemon*(daemon: jboolean)
  proc setMaxPriority*(pri: jint)
  proc stop*
  proc suspend*
  proc toString*: string
  proc uncaughtException*(t: Thread, e: Throwable)


jClassImpl java.lang.Thread* of Object:
  proc new*
  proc new*(target: Runnable)
  proc new*(group: ThreadGroup, target: Runnable)
  proc new*(name: string)
  proc new*(group: ThreadGroup, name: string)
  proc new*(target: Runnable, name: string)
  proc new*(group: ThreadGroup, target: Runnable, name: string)
  proc activeCount*: jint {.static.}
  proc checkAccess*
  proc countStackFrames*: jint
  proc currentThread*: Thread {.static.}
  proc destroy*
  proc dumpStack* {.static.}
  proc enumerate*(tarray: seq[Thread]): jint {.static.}
  proc getId*: jlong
  proc getName*: string
  proc getPriority*: string
  proc getStackTrace*: seq[StackTraceElement]


jClass android.content.SharedPreferences$Editor as SharedPreferencesEditor* of Object:
  proc new*
  proc apply*
  proc clear*: SharedPreferencesEditor
  proc commit*: jboolean
  proc putBoolean*(key: string, value: jboolean): SharedPreferencesEditor
  proc putFloat*(key: string, value: jfloat): SharedPreferencesEditor
  proc putInt*(key: string, value: jint): SharedPreferencesEditor
  proc putLong*(key: string, value: jlong): SharedPreferencesEditor
  proc putString*(key: string, value: string): SharedPreferencesEditor
  proc putStringSet*(key: string, value: Set[string]): SharedPreferencesEditor
  proc remove*(key: string): SharedPreferencesEditor


jClass android.content.SharedPreferences of Object:
  proc new*
  proc contains*(key: string): jboolean
  proc edit*: SharedPreferencesEditor
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


jClass android.os.MessageQueue$IdleHandler* of Object:
  proc queueIdle*: jboolean


jClass android.os.MessageQueue$OnFileDescriptorEventListener* of Object:
  proc onFileDescriptorEvents*(fd: FileDescriptor, events: jint): jint


jClass android.os.MessageQueue* of Object:
  proc addIdleHandler*(handler: IdleHandler)
  proc addOnFileDescriptorEventListener*(
    fd: FileDescriptor, events: jint,
    listener: OnFileDescriptorEventListener
  )
  proc isIdle*: jboolean
  proc removeHandler*(handler: IdleHandler)
  proc removeOnFileDescriptorEventListener*(fd: FileDescriptor)


jClass android.os.Looper* of Object:
  proc new*
  proc getMainLooper*: Looper {.static.}
  proc getQueue*: MessageQueue
  proc getThread*: Thread
  proc isCurrentThread*: jboolean
  proc loop* {.static.}
  proc myLooper*: Looper {.static.}
  proc myQueue*: MessageQueue {.static.}
  proc prepare* {.static.}
  proc prepareMainLooper* {.static.}
  proc quit*
  proc quitSafely*
  proc toString*: string


jClass android.os.Handler* of Object:
  proc new*


jClass android.os.Message* of Object:
  proc new*
  proc copyFrom*(o: Message)
  proc describeContents*: jint
  proc getCallback*: Runnable
  proc getTarget*: Handler
  proc getWhen*: jlong
  proc isAsynchronous*: jboolean
  proc obtain*(h: Handler): Message {.static.}
  proc obtain*(h: Handler, what: jint): Message {.static.}
  proc obtain*(h: Handler, callback: Runnable): Message {.static.}
  proc obtain*(orig: Message): Message {.static.}
  proc obtain*: Message {.static.}


jClass android.app.Dialog* of Object:
  proc new*(ctx: Context)
  proc new*(ctx: Context, themeResId: jint)
  proc cancel*
  proc closeOptionsMenu*
  proc create*
  proc dismiss*
  proc getContext*: Context
  proc getVolumeControlStream*: jint
  proc hide*
  proc invalidateOptionsMenu*
  proc isShowing*: jboolean
  proc onAttachedToWindow*
  proc onBackPressed*
  proc onContentChanged*
  proc onDetachedFromWindow*
  proc onSearchRequested*: jboolean
  proc onWindowFocusChanged*(hasFocus: jboolean)
  proc openOptionsMenu*
  proc requestWindowFeature*(featureId: jint): jboolean
  proc setCancelable*(flag: jboolean)
  proc setCanceledOnTouchOutside*(cancel: jboolean)
  proc setContentView*(layoutResId: jint)
  proc setTitle*(title: CharSequence)
  proc setTitle*(titleId: jint)
  proc setVolumeControlStream*(streamType: jint)
  proc show*


jClass android.app.AlertDialog* of Dialog:
  proc setIcon*(icon: Drawable)
  proc setIcon*(resId: jint)
  proc setIconAttribute*(attrId: jint)
  proc setInverseBackgroundForced*(forceInverseBackground: jboolean)
  proc setTitle*(title: CharSequence)


jClass android.app.AlertDialog$Builder as AlertDialogBuilder* of Dialog:
  proc new*(context: Context)
  proc new*(context: Context, themeResId: jint)
  proc create*: AlertDialog
  proc getContext*: Context
  proc setCancelable*(cancelable: jboolean): AlertDialogBuilder
  proc setTitle*(title: CharSequence): AlertDialogBuilder
  proc setMessage*(message: CharSequence): AlertDialogBuilder
  proc show*: AlertDialog


var
  runOnUiThreadEvents {.compileTime.}: seq[NimNode] = @[]
  argumentNames {.compileTime.} = newTable[int, seq[NimNode]]()


proc fetchAllIdents(node: var NimNode, list: var seq[NimNode], reserved: var seq[NimNode], root: NimNode = nil) =
  for i in 0..<node.len:
    var child = node[i]
    if child.kind in AtomicNodes:
      if child.kind == nnkIdent and ($child)[0] in ({'a'..'z'} + {'A'..'Z'}):
        if root.kind notin [nnkVarSection, nnkLetSection, nnkProcDef, nnkConstSection] and child notin list:
          if child notin reserved:
            list.add(child)
        else:
          reserved.add(child)
      if child.kind == nnkSym and $child in ["params"]:
        if root.kind notin [nnkVarSection, nnkLetSection, nnkProcDef, nnkConstSection]:
          if child notin reserved:
            if child notin list:
              list.add(child.copy())
            node[i] = ident($child & "___")
        else:
          reserved.add(child)
    else:
      fetchAllIdents(child, list, reserved, node)


macro runOnUiThread*(body: untyped) =
  var
    statements = body
    # list: seq[NimNode] = @[]
    # reserved: seq[NimNode] = @[]
    index = runOnUiThreadEvents.len
    # codeBlocksTable = newCall(
    #   "[]=",
    #   ident"argumentsCodeBlocks",
    #   newLit(index),
    #   newCall("@", newNimNode(nnkBracket))
    # )
  # argumentNames[index] = newSeq[NimNode]()
  # fetchAllIdents(statements, list, reserved)
  runOnUiThreadEvents.add(statements)
  result = newStmtList()
  # for i in list:
  #   codeBlocksTable[^1][^1].add(newNimNode(nnkCast).add(ident"pointer", newCall("addr", i)))
  #   argumentNames[index].add(ident($i & "___"))
  result.add(
    # codeBlocksTable,
    newCall("inc", newCall("[]", ident"uniqueCodeBlocks", newLit(runOnUiThreadEvents.len - 1)))
  )


macro runOnUiThreadAll*() =
  result = newStmtList()
  for i in runOnUiThreadEvents.low..runOnUiThreadEvents.high:
    # var variables = newNimNode(nnkVarSection)
    # for j in 0..<argumentNames[i].len:
    #   variables.add(newIdentDefs(
    #     argumentNames[i][j],
    #     newEmptyNode(),
    #     newNimNode(nnkBracketExpr).add(ident"argumentsCodeBlocks", newLit(j))
    #   ))
    result.add(newNimNode(nnkWhileStmt).add(
      newCall(">", newNimNode(nnkBracketExpr).add(ident"uniqueCodeBlocks", newLit(i)), newLit(0)),
      newStmtList(
        # variables,
        runOnUiThreadEvents[i],
        newCall("dec", newNimNode(nnkBracketExpr).add(ident"uniqueCodeBlocks", newLit(i)))
      )
    ))


macro declareRunOnUiAll*() =
  result = newStmtList()

  for i in runOnUiThreadEvents.low..runOnUiThreadEvents.high:
    result.add(newCall("add", ident"uniqueCodeBlocks", newLit(0)))


type Log* = object


template logFunc(funcName: untyped, level: untyped) =
  proc `funcName`*(log: typedesc[Log], tag: cstring, msg: cstring) =
    android_log_print(`level`, tag, msg)
  proc `funcName`*(log: typedesc[Log], msg: cstring) =
    android_log_print(`level`, "HAPPYX-NATIVE", msg)
  proc `funcName`*(log: typedesc[Log], tag: string, msg: string) =
    android_log_print(`level`, cstring tag, cstring msg)
  proc `funcName`*(log: typedesc[Log], msg: string) =
    android_log_print(`level`, "HAPPYX-NATIVE", cstring msg)

logFunc(i, INFO)
logFunc(d, DEBUG)
logFunc(e, ERROR)
