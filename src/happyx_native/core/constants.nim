import os

const
  HpxNativeVersion* = "0.3.2"
  OS* =
    when defined(windows) or hostOS == "windows":
      "win"
    elif defined(linux) or defined(posix) or hostOS == "linux":
      "unix"
    elif defined(macosx) or hostOS == "mac":
      "mac"
    else:
      "unknown"
  ChromePaths* =
    when OS == "win":
      [
        r"\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        r"\Program Files\Google\Chrome\Application\chrome.exe",
        # for older versions
        r"\Documents and Settings\username\Local Settings\Application Data\Google\Chrome\Application\chrome.exe",
      ]
    elif OS == "unix":
      [
        "google-chrome",
        "google-chrome-stable",
        "chromium-browser",
        "chromium"
      ]
    elif OS == "mac":
      [
        r"/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome",
      ]
    else:
      [""]
  YandexPaths* =
    when OS == "win":
      [
        getHomeDir() / r"\AppData\Local\Yandex\YandexBrowser\Application\browser.exe",
      ]
    elif OS == "unix":
      [""]
    elif OS == "mac":
      [""]
    else:
      [""]
  EdgePaths* =
    when OS == "win":
      [
        r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
        r"D:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        r"D:\Program Files\Microsoft\Edge\Application\msedge.exe",
      ]
    elif OS == "unix":
      [""]
    elif OS == "mac":
      [
        r"/Applications/Microsoft\ Edge\ Beta/Contents/MacOS/Microsoft\ Edge\ Beta"
      ]
    else:
      [""]
