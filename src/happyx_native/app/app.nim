## # App
## 
## Provides main app loop
## 
import
  std/[
    macros, os, sequtils, strformat,
    osproc, json, threadpool, browsers,
    uri, tables, terminal
  ],
  happyx

export
  happyx,
  osproc,
  threadpool,
  sequtils,
  terminal,
  browsers


macro callback*(body: untyped) =
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


macro callJs*(funcName: string, params: varargs[untyped]) =
  quote do:
    {.gcsafe.}:
      websocketClient.send($(%*{"funcName":`funcName`,"params":[`params`]}))


macro onExit*(body: untyped) =
  newProc(
    postfix(ident"nativeAppExitHandler", "*"),
    [newEmptyNode()],
    body
  )


template nativeApp*(appDirectory: string = "/assets", port: int = 5000,
                    x: int = 512, y: int = 128, w: int = 720, h: int = 320,
                    appMode: bool = true, title: string = "",
                    resizeable: bool = true, establish: bool = true
) {.dirty.} =
  # Compile main
  discard execCmdEx("nim js " & getCurrentDir() / appDirectory & "/main.nim")

  # Application
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
    else:
      spawn openChrome(port, arguments)
  else:
    spawn openDefaultBrowser("http://127.0.0.1:" & $port & "/#/")
  
  # Server
  serve "127.0.0.1", port:
    setup:
      var websocketClient: WebSocket
      proc handleWebSocketErr() {.async.} =
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
      let f = openAsync(getCurrentDir() / appDirectory / "index.html")
      var data = await f.readAll()
      f.close()
      data = data.replace(
        "<body>",
        """<body><script>
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
        </script>"""
      )
      req.answerHtml(data)
    
    wsConnect:
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
        callNim(procName, params)
      except:
        echo "Error from Javascript call to Nim."
        echo "Function: " & procName
        echo "Parameters: " & $params
        echo fmt"ERROR [{getCurrentException().name}]"
        echo fmt"Message: " & getCurrentExceptionMsg()
    
    get "/{f:path}":
      let filepath = getCurrentDir() / appDirectory / f
      if fileExists(filepath):
        await req.answerFile(filepath, forceResponse = true)
