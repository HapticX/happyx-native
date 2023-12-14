## # App
## 
## Provides main app loop
## 
import
  std/[
    macros, os, sequtils, strformat,
    osproc, json, threadpool, browsers,
    uri, tables, terminal, parsecfg
  ],
  happyx

when defined(export2android):
  import
    mimetypes,
    ../cli/utils,
    ../android/core
  export
    macros, mimetypes

export
  happyx,
  osproc,
  threadpool,
  sequtils,
  terminal,
  browsers


var websocketClient*: WebSocket


macro callback*(body: untyped) =
  ## Creates callbacks for JS side
  ## 
  ## ## Example
  ## 
  ## ```nim
  ## import happyx_native
  ## 
  ## 
  ## callback:
  ##   proc test(x: int) =
  ##     callJs("test", x * x)
  ## 
  ## nativeApp("/assets")
  ## ```
  var caseProcStmt = newNimNode(nnkCaseStmt).add(ident"name")
  for statement in body:
    if statement.kind notin {nnkProcDef}:
      continue
    caseProcStmt.add(newNimNode(nnkOfBranch).add(
      newLit($statement.name),
      block:
        var call = newCall(statement.name)
        for i in 1..statement.params.len-1:
          let paramType = statement.params[i]
          call.add(newCall(
            "jsonTo",
            newCall("[]", ident"args", newLit(i)),
            paramType
          ))
        var isAsync = false
        for i in statement[4]:
          if i == ident"async":
            isAsync = true
        if isAsync:
          newCall("await", call)
        else:
          call
    ))
  result = newStmtList(
    body,
    newProc(
      ident"callNim",
      [
        newEmptyNode(),
        newIdentDefs(ident"name", ident"string"),
        newIdentDefs(ident"args", newNimNode(nnkBracketExpr).add(ident"seq", ident"JsonNode")),
      ],
      caseProcStmt
    )
  )
  result[^1].addPragma(ident"async")


macro callJsAsync*(funcName: string, params: varargs[untyped]) =
  quote do:
    {.gcsafe.}:
      await websocketClient.send($(%*{"funcName":`funcName`,"params":[`params`]}))


macro callJs*(funcName: string, params: varargs[untyped]) =
  quote do:
    {.gcsafe.}:
      waitFor websocketClient.send($(%*{"funcName":`funcName`,"params":[`params`]}))


macro onExit*(body: untyped) =
  newProc(
    postfix(ident"nativeAppExitHandler", "*"),
    [newEmptyNode()],
    body
  )


proc cfgAndroidPackageId*(): string {.compileTime.} =
  var cfg = readNativeConfigCompileTime()
  cfg.androidPackage


proc cfgAndroidSdk*(): string {.compileTime.} =
  var cfg = readNativeConfigCompileTime()
  cfg.androidSdk


proc cfgName*(): string {.compileTime.}=
  var cfg = readNativeConfigCompileTime()
  cfg.name


proc cfgAppDirectory*(): string {.compileTime.}=
  var cfg = readNativeConfigCompileTime()
  cfg.appDirectory


macro getIndexHtml*(directory: static[string]): untyped =
  result = newLit(
    staticRead(getProjectPath() / directory / "index.html")
  )

macro fetchFiles*(directory: static[string]): untyped =
  var files: seq[string] = @[]
  for file in directory.walkDirRec:
    files.add(file)
  result = newStmtList(
    newVarStmt(
      ident"_files",
      newCall(
        newNimNode(nnkBracketExpr).add(ident"newTable", ident"string", ident"string")
      )
    )
  )
  for file in files:
    result.add(newCall(
      "[]=",
      ident"_files",
      newLit(file.replace(directory, "")),
      newLit(staticRead(file))
    ))
  result.add(ident"_files")


template nativeAppImpl*(appDirectory: string = "/assets", port: int = 5000,
                        x: int = 512, y: int = 128, w: int = 720, h: int = 320,
                        appMode: bool = true, title: string = "",
                        resizeable: bool = true, establish: bool = true
) {.dirty.} =
  ## Compiles main happyx file, opens browser in `appMode` and
  ## starts serving at localhost with `port`
  ## 
  ## Your project should have this structure:
  ## 
  ## ```
  ## assets/
  ## ├─ index.html
  ## ├─ main.nim
  ## app.nim
  ## ```

  # Application
  when defined(export2android):
    static:
      # Compile main
      echo staticExec(
        "nim js -d:danger --opt:size " & getScriptDir() / appDirectory / "main.nim"
      )
  else:
    # Compile main
    echo execCmdEx(
      "nim js -d:danger --opt:size " & getCurrentDir() / appDirectory / "main.nim"
    )
    when appMode:
      var arguments: seq[string] = @[]
      arguments.add "--enable-gpu"
      arguments.add "--window-size=\"" & $w & "," & $h & "\""
      arguments.add "--window-position=\"" & $x & "," & $y & "\""
      if title.len > 0:
        arguments.add "--window-name=\"" & title & "\""
      when defined(yandex):
        spawn openYandex(port, arguments)
      elif defined(edge):
        spawn openEdge(port, arguments)
      elif defined(chrome):
        spawn openChrome(port, arguments)
      else:
        spawn openDefaultBrowserApp(port, arguments)
    else:
      spawn openDefaultBrowser("http://127.0.0.1:" & $port & "/#/")
  
  # Server
  serve "127.0.0.1", port:
    setup:
      proc handleWebSocketErr() {.async.} =
        {.gcsafe.}:
          websocketClient = nil
          styledEcho fgRed, "Connection was closed"
          when establish:
            for i in 0..3:
              styledEcho fgYellow, fmt"Trying to establish connection ... {i}/3"
              await sleepAsync(500)
              if i < 3:
                eraseLine()
                cursorUp()
            if websocketClient.isNil:
              styledEcho fgRed, "failed to establish connection"
              when declared(nativeAppExitHandler):
                nativeAppExitHandler()
              styledEcho fgRed, "exit ..."
              quit QuitSuccess
          else:
            when declared(nativeAppExitHandler):
              nativeAppExitHandler()
            styledEcho fgRed, "exit ..."
            quit QuitSuccess

    get "/":
      outHeaders["Cache-Control"] = "no-store"
      when defined(export2android):
        var data = getIndexHtml(appDirectory)
      else:
        let f = openAsync(getCurrentDir() / appDirectory / "index.html")
        var data = await f.readAll()
        f.close()
      data = data.replace(
        "</head>", (
          when defined(export2android):
            """<script>var ws = new WebSocket("ws://127.0.0.1:""" & $port & """/ws");"""
          else:
            """<script>
            window.moveTo(""" & $x & """,""" & $y & """);
            window.resizeTo(""" & $w & """, """ & $h & """);
            var ws = new WebSocket("ws://127.0.0.1:""" & $port & """/ws");""" & (
              when not resizeable:
                """
                window.addEventListener('resize', () => {
                  window.resizeTo(""" & $w & """, """ & $h & """);
                });"""
              else:
                ""
            )
        ) & """
        var connected = false;
        ws.onmessage = (data) => {
          let v = Object.values(
            data.data !== undefined ? JSON.parse(data.data) : x = JSON.parse(data)
          );
          hpxNative.callJs(v[0], v[1]);
        }
        var hpxNative = {
          callJs: function (func, arr) {
            window[func].apply(null, arr);
          },
          callNim: function (func, ...args) {
            if (!connected) {
              function check(func, ...args) {
                if (ws.readyState === 1) {
                  connected = true;
                  hpxNative.callNim(func, ...args);
                  clearInterval(myInterval);
                }
              }
              var myInterval = setInterval(check, 15, func, ...args);
            } else {
              ws.send(JSON.stringify({
                "procedure": func,
                "params": [...args]
              }));
            }
          }
        }
        </script></head>"""
      )
      req.answerHtml(data)
    
    wsConnect:
      {.gcsafe.}:
        websocketClient = wsClient
    
    wsClosed:
      await handleWebSocketErr()
    
    wsMismatchProtocol:
      await handleWebSocketErr()
    
    wsError:
      await handleWebSocketErr()
    
    ws "/ws":
      let
        data = wsData.parseJson()
        procName = data["procedure"].getStr
        params = data["params"].getElems
      try:
        await callNim(procName, params)
      except:
        echo "Error from Javascript call to Nim."
        echo "Function: " & procName
        echo "Parameters: " & $params
        echo fmt"ERROR [{getCurrentException().name}]"
        echo fmt"Message: " & getCurrentExceptionMsg()
    
    get "/{f:path}":
      when defined(export2android):
        var
          files = fetchFiles(getProjectPath() / appDirectory)
          splitted = f.split('.')
          extension = if splitted.len > 1: splitted[^1] else: ""
          contentType = newMimetypes().getMimetype(extension)
          headers = @[
            ("Content-Type", fmt"{contentType}; charset=utf-8"),
          ]
        if files.hasKey(f):
          req.answer(files[f], headers = newHttpHeaders(headers))
        elif files.hasKey($DirSep & f):
          req.answer(files[$DirSep & f], headers = newHttpHeaders(headers))
      else:
        # Export to other platforms
        let filepath = getCurrentDir() / appDirectory / f
        if fileExists(filepath):
          await req.answerFile(filepath, forceResponse = true)


template nativeApp*(appDirectory: string = "/assets", port: int = 5123,
                        x: int = 512, y: int = 128, w: int = 720, h: int = 320,
                        appMode: bool = true, title: string = "",
                        resizeable: bool = true, establish: bool = true
) {.dirty.} =
  when defined(export2android):
    proc startAndroidApp*() =
      nativeAppImpl(appDirectory, port, x, y, w, h, appMode, title, resizeable, establish)

    proc startAndroidApp*(servePort: int) =
      nativeAppImpl(appDirectory, servePort, x, y, w, h, appMode, title, resizeable, establish)

    nativeMethodsFor cfgAndroidPackageId(), "Native":
      proc start() =
        initJNI(env)
        startAndroidApp()
  else:
    nativeAppImpl(appDirectory, port, x, y, w, h, appMode, title, resizeable, establish)
