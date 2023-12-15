import
  happyx,
  jsffi


# Object for working with HappyX Native
var hpxNative {.importc, nodecl.}: JsObject

var x = remember 0


proc loadX(value: int) {.exportc.} =
  echo value
  x.set(value)
hpxNative.callNim("loadX")


appRoutes "app":
  "/":
    tDiv(class = "container"):
      tH1:
        "android_tests"
      tDiv(class = "content"):
        "x is {x} stored?"
        tButton:
          "increase"
          @click:
            x->inc()
            # Call HappyX Native callback named helloWorld without arguments
            hpxNative.callNim("storeX", x.val)
    tStyle: """
      body {
        padding: 0;
        margin: 0;
      }
      .container {
        color: #efefef;
        width: 100vw;
        height: 100vh;
        display: flex;
        flex-direction: column;
        gap: 1rem;
        background-color: #0A0A0A;
        justify-content: center;
        align-items: center;
      }
      .content {
        gap: .2rem;
        display: flex;
        flex-direction: column;
        align-items: center;
      }
      button {
        padding: .4rem 1.2rem;
        font-weight: bold;
        transition: all;
        border: none;
        border-radius: 8px;
        transition-duration: .3s;
        background-color: #ecf;
      }
      button:hover {
        background-color: #cbe;
      }
      button:active {
        background-color: #bad;
      }
    """
