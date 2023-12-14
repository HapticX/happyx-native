## # HappyX Native 🔥
## 
## .. Note::
##    HappyX web framework, but for native platforms
## 
## ## API Reference 📕
## 
## ### Core ⚙
## - [exceptions](happyx_native/core/exceptions.html) - list of all exceptions
## - [constants](happyx_native/core/constants.html) - list of constants
## - #### **f i n d e r**
##   .. Note::
##      provides some browsers finders
##   - [chrome](happyx_native/core/finder/chrome.html) - Chrome browser finder (this browser choosen by default)
##   - [edge](happyx_native/core/finder/edge.html) - Edge browser finder (compile with `-d:edge` to enable this browser)
##   - [yandex](happyx_native/core/finder/yandex.html) - Yandex browser finder <sup> (compile with `-d:yandex` to enable this browser) </sup>
## ### App 🎴
## - [app](happyx_native/app/app.html) - provides working with native application
## 

import
  happyx_native/core/[
    constants,
    exceptions
  ],
  happyx_native/app/app

when not defined(docgen):
  when defined(yandex):
    import happyx_native/core/finder/yandex
    export yandex
  elif defined(edge):
    import happyx_native/core/finder/edge
    export edge
  elif defined(chrome):
    import happyx_native/core/finder/chrome
    export chrome
  else:
    import happyx_native/core/finder/[default, chrome]
    export default, chrome
else:
  import happyx_native/core/finder/[chrome, yandex, edge, default]
  export chrome, yandex, edge, default

when defined(export2android):
  import happyx_native/android/core
  export core

export
  constants,
  exceptions,
  app
