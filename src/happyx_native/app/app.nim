## # App
## 
## Provides main app loop
## 
import
  std/[
    macros, os, sequtils, strformat,
    osproc, json, threadpool, browsers,
    uri, tables, terminal, parsecfg,
    jsonutils, sugar, tables, cgi, uri
  ],
  happyx/core/constants,
  happyx/ssr/server,
  happyx/routing/routing,
  ../cli/utils


when enableApiDoc:
  import happyx/tmpl_engine/engine
  export engine
else:
  template getScriptDir*(): string =
    ## Helper for staticRead.
    ##
    ## returns the absolute path to your project, on compile time.
    instantiationInfo(-1, true).filename.parentDir() 


import happyx/ssr/utils as hpx_ssr_utils
export hpx_ssr_utils


when defined(webview):
  webview

when defined(export2android):
  import
    mimetypes,
    ../android/core,
    ../android/autils
  export
    macros, mimetypes, autils, cgi

when defined(buildAssets):
  import mimetypes
  export macros, mimetypes, cgi

export
  server,
  routing,
  tables,
  sugar,
  osproc,
  json,
  jsonutils,
  threadpool,
  sequtils,
  terminal,
  browsers,
  utils,
  uri


var websocketClient*: WebSocket

when defined(export2android):
  var
    appContext*: Activity


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
  var
    caseProcStmt = newNimNode(nnkCaseStmt).add(ident"name")
    statements = newStmtList()
  for statement in body:
    if statement.kind notin {nnkProcDef}:
      continue
    var params: seq[NimNode] = @[]
    for param in statement.params:
      params.add(param)
    var prc = newProc(
      statement.name,
      params,
      newNimNode(nnkPragmaBlock).add(
        newNimNode(nnkPragma).add(ident"gcsafe"),
        statement.body
      ),
      nnkTemplateDef,
      statement[4]
    )
    statements.add(prc)
    caseProcStmt.add(newNimNode(nnkOfBranch).add(
      newLit($statement.name),
      block:
        var call = newCall(statement.name)
        for i in 1..statement.params.len-1:
          let param = statement.params[i]
          call.add(newCall(
            "jsonTo",
            newCall("[]", ident"args", newLit(i-1)),
            param[1]
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
    statements,
    newProc(
      ident"callNim",
      [
        newEmptyNode(),
        newIdentDefs(ident"name", ident"string"),
        newIdentDefs(ident"args", newNimNode(nnkBracketExpr).add(ident"seq", ident"JsonNode")),
      ],
      newStmtList(
        caseProcStmt
      ),
      nnkTemplateDef
    )
  )

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


proc cfgKind*(): string {.compileTime.} =
  readNativeConfigCompileTime().kind
proc cfgAndroidPackageId*(): string {.compileTime.} =
  readNativeConfigCompileTime().androidPackage
proc cfgAndroidSdk*(): string {.compileTime.} =
  readNativeConfigCompileTime().androidSdk
proc cfgName*(): string {.compileTime.} =
  readNativeConfigCompileTime().name
proc cfgPort*(): int {.compileTime.} =
  readNativeConfigCompileTime().port
proc cfgAppDirectory*(): string {.compileTime.} =
  readNativeConfigCompileTime().appDirectory


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
    if file.endsWith(".nim"):
      continue
    result.add(newCall(
      "[]=",
      ident"_files",
      newLit(file.replace(directory, "")),
      newLit(staticRead(file))
    ))
  result.add(ident"_files")

when defined(webview):
  proc createHpxWebview*(w, h: int, port: int, resizeable: bool) = 
    let 
      wv = newWebview()
      hint =
        if resizeable: WebviewHintNone
        else: WebviewHintFixed

    wv.setSize(w, h, hint)
    wv.setTitle(cfgName())
    # no positioning?
    wv.navigate(cstring("http://127.0.0.1:" & $port))

    wv.run()
    wv.destroy()


proc optimizeJs*(filepath: string) {.compileTime.} =
  discard staticExec(
    fmt"""uglifyjs "{filepath}" -c toplevel=false -m toplevel=false --mangle-props regex=/N[ST]I\w+/ -O semicolons -o "{filepath}" """
  )
  discard staticExec(
    fmt"""terser "{filepath}" -c -m -o "{filepath}" """
  )
  discard staticExec(
    fmt"""cmd /c uglifyjs "{filepath}" -c toplevel=false -m toplevel=false --mangle-props regex=/N[ST]I\w+/ -O semicolons -o "{filepath}" """
  )
  discard staticExec(
    fmt"""cmd /c terser "{filepath}" -c -m -o "{filepath}" """
  )


template nativeAppImpl*(appDirectory: string = "/assets", port: int = 5123,
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
      if cfgKind() == "HPX":
        compileHpx(getScriptDir() / appDirectory)
      else:
        echo staticExec(
          "nim js -d:danger --opt:size --warnings:off --checks:off --assertions:off --stackTrace:off --lineTrace:off " & getScriptDir() / appDirectory / "main.nim"
        )
        when not defined(disableMinify):
          optimizeJs(getProjectPath() / appDirectory / "main.js")
  else:
    when defined(buildAssets):
      static:
        if cfgKind() == "HPX":
          compileHpx(getScriptDir() / appDirectory)
        # Compile main
        else:
          echo staticExec(
            "nim js -d:danger --opt:size --warnings:off --checks:off --assertions:off --stackTrace:off --lineTrace:off " & getScriptDir() / appDirectory / "main.nim"
          )
          when not defined(disableMinify):
            optimizeJs(getProjectPath() / appDirectory / "main.js")
    else:
      # Compile main
      if cfgKind() == "HPX":
        compileHpx(getCurrentDir() / appDirectory)
      else:
        var data = execCmdEx(
          "nim js -d:danger --opt:size " & getCurrentDir() / appDirectory / "main.nim"
        )
        echo data.output
        assert data.exitCode == 0
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
      elif defined(webview):        
        spawn createHpxWebview(w, h, port, resizeable)
      else:
        spawn openDefault(port, arguments)
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
      when defined(export2android) or defined(buildAssets):
        var data = getIndexHtml(appDirectory)
      else:
        let f = openAsync(getCurrentDir() / appDirectory / "index.html")
        var data = await f.readAll()
        f.close()
      data = data.replace(
        "</head>", (
          when defined(export2android):
            """<script>var wsHpxNim = new WebSocket("ws://127.0.0.1:""" & $port & """/ws");"""
          else:
            """<script>
            window.moveTo(""" & $x & """,""" & $y & """);
            window.resizeTo(""" & $w & """, """ & $h & """);
            var wsHpxNim = new WebSocket("ws://127.0.0.1:""" & $port & """/ws");""" & (
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
        wsHpxNim.onmessage = (data) => {
          let v = Object.values(
            data.data !== undefined ? JSON.parse(data.data) : x = JSON.parse(data)
          );
          hpxNative.callJs(v[0], v[1]);
        }
        wsHpxNim.onopen = () => {connected = true};
        var hpxNative = {
          callJs: function (func, arr) {
            window[func].apply(null, arr);
          },
          callNim: function (func, ...args) {
            if (!connected) {
              function check(func, ...args) {
                if (wsHpxNim.readyState === 1) {
                  connected = true;
                  hpxNative.callNim(func, ...args);
                  clearInterval(myInterval);
                }
              }
              var myInterval = setInterval(check, 15, func, ...args);
            } else {
              wsHpxNim.send(JSON.stringify({
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
      when not defined(guiApp):
        await handleWebSocketErr()
      else:
        quit(QuitSuccess)
    
    wsMismatchProtocol:
      when not defined(guiApp):
        await handleWebSocketErr()
      else:
        quit(QuitSuccess)
    
    wsError:
      when not defined(guiApp):
        await handleWebSocketErr()
      else:
        quit(QuitSuccess)
    
    ws "/ws":
      var
        data = wsData.parseJson()
        procName = data["procedure"].getStr
        params = data["params"].getElems
      try:
        when declared(callNim):
          {.gcsafe.}:
            callNim(procName, params)
        else:
          discard
      except:
        when not defined(guiApp):
          echo "Error from Javascript call to Nim."
          echo "Function: " & procName
          echo "Parameters: " & $params
          echo fmt"ERROR [{getCurrentException().name}]"
          echo fmt"Message: " & getCurrentExceptionMsg()
        discard
    
    get "/{f:path}":
      when defined(export2android) or defined(buildAssets):
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
    nativeMethodsFor cfgAndroidPackageId(), "Native":
      proc start(ctx: jobject) =
        appContext = cast[Activity](newJVMObject(ctx))
        nativeAppImpl(appDirectory, cfgPort(), x, y, w, h, appMode, title, resizeable, establish)
      proc runOnUi(ctx: jobject) =
        appContext = cast[Activity](newJVMObject(ctx))
        runOnUiThreadAll()
    declareRunOnUiAll()
  else:
    nativeAppImpl(appDirectory, port, x, y, w, h, appMode, title, resizeable, establish)
