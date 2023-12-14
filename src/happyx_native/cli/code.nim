const
  configFile* = """# HappyX Native config file
[Main]
name = r"{name}"
androidSdk = r"{ANDROID_SDK_ROOT}"
androidPackage = r"com.hapticx.tmpl"
"""
  nativeMain* = """# Main native file
import happyx_native


callback:
  proc helloWorld() =
    echo "Hello from Nim"


nativeApp("{appDirectory}", resizeable = false, title = "HappyX Native!")
"""
  happyxMain* = """import
  happyx,
  jsffi


var hpxNative {{.importc, nodecl.}}: JsObject


appRoutes "app":
  "/":
    tH1:
      "{name}"
    tDiv:
      "Hello, world!"
      tButton:
        "Click me"
        @click:
          hpxNative.callNim("helloWorld")
          echo "Hello from HappyX client"
"""
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
