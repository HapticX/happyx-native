import jsffi
export jsffi

var hpxNative* {.importc, nodecl.}: JsObject

hpxNative.callNim("helloWorld")
