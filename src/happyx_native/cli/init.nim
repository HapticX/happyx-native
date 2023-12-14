import
  os,
  osproc,
  terminal,
  strformat,
  ./utils,
  ./code


proc initCommandAux*(name: string): int =
  if dirExists(name):
    styledEcho fgRed, name, " folder already exists"
    return QuitFailure
  styledEcho fgYellow, "Create project ..."
  var appDirectory = "/assets"
  createDir(name)
  createDir(name / appDirectory)
  let ANDROID_SDK_ROOT = getEnv("ANDROID_SDK_ROOT")
  withOpen(name / "happyx.native.cfg", fmWrite):
    fileVar.write(fmt(configFile))
  withOpen(name / "app.nim", fmWrite):
    fileVar.write(fmt(nativeMain))
  withOpen(name / appDirectory / "main.nim", fmWrite):
    fileVar.write(fmt(happyxMain))
  withOpen(name / appDirectory / "index.html", fmWrite):
    fileVar.write(fmt(indexHtml))
  withOpen(name / appDirectory / "README.md", fmWrite):
    fileVar.write(fmt(readmeTemplate))
  withOpen(name / appDirectory / ".gitignore", fmWrite):
    fileVar.write(gitignore)
  var favicon = getFavicon()
  if favicon != "":
    copyFileToDir(favicon, name / appDirectory)
  favicon = getFavicon(".png")
  if favicon != "":
    copyFileToDir(favicon, name / appDirectory)
  styledEcho fgGreen, "Project created!"
  QuitSuccess
