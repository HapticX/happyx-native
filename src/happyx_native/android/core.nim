import
  jnim,
  jnim/private/[jni_wrapper, jni_api],
  jnim/java/[lang, util],
  macros,
  strutils,
  ../app/app


export
  jnim,
  jni_wrapper,
  jni_api,
  lang,
  util


macro nativeMethods*(class: untyped, body: untyped) =
  if class.kind != nnkInfix or class[0] != ident"~":
    return
  result = newStmtList()
  let package = (
    if class[1].kind != nnkStrLit:
      $class[1].toStrLit
    else:
      $class[1]
  ).replace(".", "_")
  for s in body:
    if s.kind != nnkProcDef:
      continue
    var p = newProc(
      postfix(ident("Java_" & package & "_" & $class[2] & "_" & $s[0]), "*"),
      [
        s.params[0],
        newIdentDefs(ident"env", ident"JNIEnvPtr"),
        newIdentDefs(ident"obj", ident"jobject"),
      ]
    )
    p.body = s.body
    if p.body[0].kind != nnkCommentStmt:
      # p.body.insert(0, newCall("initJNI", ident"env"))
      p.body.insert(0, newCall("setupForeignThreadGc"))
    else:
      # p.body.insert(1, newCall("initJNI", ident"env"))
      p.body.insert(1, newCall("setupForeignThreadGc"))
    for i in 1..s.params.len-1:
      p.params.add(s.params[i])
    # dynlib pragmas
    # p.addPragma(ident"cdecl")
    p.addPragma(ident"exportc")
    p.addPragma(ident"dynlib")
    for pragma in s[4]:
      p.addPragma(pragma)
    result.add(p)


macro nativeMethodsFor*(package: static[string], className: static[string], body: untyped) =
  result = newCall(
    "nativeMethods",
    newNimNode(nnkInfix).add(ident"~", parseExpr(package), ident(className)),
    body
  )


proc JNI_OnLoad*(vm: JavaVMPtr, reserved: pointer): jint {.cdecl, dynlib, exportc.} =
  if theEnv.isNil:
    initJNI(vm)
    checkInit()
  return JNI_VERSION_1_6
