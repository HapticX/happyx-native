import
  os,
  osproc,
  macros,
  cligen,
  terminal,
  strutils,
  strformat,
  ./core/constants,
  ./cli/[
    utils, build, init, help, configure
  ],
  happyx/core/constants


proc mainCommand(version = false): int =
  if version:
    styledEcho "HappyX ", fgGreen, "v", HpxVersion
    styledEcho "HappyX Native ", fgGreen, "v", HpxNativeVersion
    QuitSuccess
  else:
    helpMessage()

proc buildCommand(target: string = OS, release: bool = false, opt: string = "size",
                  no_x86_64: bool = false, no_x86: bool = false, no_armeabi_v7a: bool = false,
                  no_arm64_v8a: bool = false, no_gradle: bool = false, no_build_assets: bool = false,
                  chrome: bool = true, yandex: bool = false, edge: bool = false,
                  app: string = "gui"): int =
  buildCommandAux(
    target, release, opt, no_x86_64, no_x86, no_armeabi_v7a, no_arm64_v8a,
    no_gradle, no_build_assets, chrome, yandex, edge, app
  )

proc initCommand(name: string, kind: string = "SPA"): int =
  initCommandAux(name, kind)



when isMainModule:
  dispatchMultiGen(
    [initCommand, cmdName = "init"],
    [buildCommand, cmdName = "build"],
    [
      mainCommand,
      short = {"version": 'v'}
    ]
  )
  
  var pars = commandLineParams()
  let
    subcmd =
      if pars.len > 0 and not pars[0].startsWith("-"):
        pars[0]
      else:
        ""
  case subcmd
  of "init":
    quit(dispatchinit(cmdline = pars[1..^1]))
  of "build":
    quit(dispatchbuild(cmdline = pars[1..^1]))
  of "help":
    let
      subcmdHelp =
        if pars.len > 1 and not pars[1].startsWith("-"):
          pars[1]
        else:
          ""
    case subcmdHelp:
    of "":
      quit(helpMessage())
    of "init":
      styledEcho fgBlue, "HappyX Native", fgMagenta, " init ", fgWhite, " command creates app project."
      styledEcho "\nUsage:"
      styledEcho fgMagenta, "  hpx-native init\n"
      styledEcho "Arguments:"
      styledEcho fgBlue, align("name", 4), fgWhite, " - project name."
    of "build":
      styledEcho fgBlue, "HappyX Native", fgMagenta, " build ", fgWhite, " command builds app."
      styledEcho "\nUsage:"
      styledEcho fgMagenta, "  hpx-native build\n"
      styledEcho "Optional arguments:"
      styledEcho fgBlue, align("target", 14), fgWhite, " - build target. By default target is your OS."
      styledEcho align("", 14), "   Possible targets:"
      styledEcho align("", 14), "   - windows (win);"
      styledEcho align("", 14), "   - linux (unix);"
      styledEcho align("", 14), "   - macosx (mac, macos);"
      styledEcho align("", 14), "   - android."
      styledEcho fgBlue, align("no-x86_64", 14), fgWhite, " - disable building for x86_64 arch (android only)"
      styledEcho fgBlue, align("no-x86", 14), fgWhite, " - disable building for x86 arch (android only)"
      styledEcho fgBlue, align("no-armeabi-v7a", 14), fgWhite, " - disable building for armeabi-v7a arch (android only)"
      styledEcho fgBlue, align("no-arm64-v8a", 14), fgWhite, " - disable building for arm64-v8a arch (android only)"
      styledEcho fgBlue, align("release", 14), fgWhite, " - enable release build"
      styledEcho fgBlue, align("opt", 14), fgWhite, " - Nim compilation option"
      styledEcho fgBlue, align("", 14), fgWhite, "   Possible values:"
      styledEcho fgBlue, align("", 14), fgWhite, "   - size (optimize build size);"
      styledEcho fgBlue, align("", 14), fgWhite, "   - speed (optimize app speed);"
      styledEcho fgBlue, align("", 14), fgWhite, "   - none (no optimizations, by default)."
    else:
      styledEcho fgRed, "Unknown subcommand: ", fgWhite, subcmdHelp
    quit(QuitSuccess)
  of "":
    quit(dispatchmainCommand(cmdline = pars[0..^1]))
  else:
    styledEcho fgRed, styleBright, "Unknown subcommand: ", fgWhite, subcmd
    styledEcho fgYellow, "Use ", fgMagenta, "hpx_native help ", fgYellow, "to get all commands"
    quit(QuitFailure)
