import strutils


const
  configFile* = """# HappyX Native config file
[Main]
name = r"{name}"
androidSdk = r"{ANDROID_SDK_ROOT}"
androidPackage = r"com.hapticx.tmpl"
appDirectory = r"/assets"
version = 1.0.0
"""
  nativeMain* = """# Main native file
import happyx_native


callback:
  # HappyX Native helloWorld callback
  proc helloWorld() =
    echo "Hello from Nim"


nativeApp("{appDirectory}", resizeable = false, title = "{name}")
"""
  happyxMain* = """import
  happyx,
  jsffi


# Object for working with HappyX Native
var hpxNative {{.importc, nodecl.}}: JsObject

var x = remember 0


appRoutes "app":
  "/":
    tDiv(class = "container"):
      tH1:
        "{name}"
      tDiv(class = "content"):
        "x is {{x}}"
        tButton:
          "increase"
          @click:
            # Call HappyX Native callback named helloWorld without arguments
            hpxNative.callNim("helloWorld")
            x->inc()
    tStyle: " " "
      body {{
        padding: 0;
        margin: 0;
      }}
      .container {{
        color: #efefef;
        width: 100vw;
        height: 100vh;
        display: flex;
        flex-direction: column;
        gap: 1rem;
        background-color: #0A0A0A;
        justify-content: center;
        align-items: center;
      }}
      .content {{
        gap: .2rem;
        display: flex;
        flex-direction: column;
        align-items: center;
      }}
      button {{
        padding: .4rem 1.2rem;
        font-weight: bold;
        transition: all;
        border: none;
        border-radius: 8px;
        transition-duration: .3s;
        background-color: #ecf;
      }}
      button:hover {{
        background-color: #cbe;
      }}
      button:active {{
        background-color: #bad;
      }}
    " " "
""".replace("\" \" \"", "\"\"\"")
  indexHtml* = """<!DOCTYPE html>
<html>
  <head>
    <title>{name}</title>
  </head>
  <body>
    <div id="app"></div>
    <script src="main.js"></script>
  </body>
</html>
"""
  readmeTemplate* = """# {name}
### made with HappyX Native with ❤

## Get Started 👨‍🔬

Main frontend file is `{appDirectory}/main.nim`. It compiles into JS.
This files includes into `{appDirectory}/index.html`.

Main file is `app.nim`. It compiles into C/C++.

"""
  gitignore* = """# Build
build/
*.apk
*.exe

# Android
.gradle/
.idea/

# Logs
*.log
*.lg

# Db
*.db
"""
