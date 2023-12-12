import
  happyx,
  jsffi


var hpxNative {.importc, nodecl.}: JsObject


appRoutes "app":
  "/":
    "Hello, world!"
    tButton:
      "Click me"
      @click:
        hpxNative.callNim("testCallback")
        echo "Hello from HappyX client"
