import
  os,
  osproc,
  terminal,
  strformat,
  strutils,
  ./utils,
  ../core/constants


proc helpMessage*(): int =
  let
    subcommands = [
      "build", "init", "help"
    ]
    delimeter = ansiForegroundColorCode(fgWhite) & "|" & ansiForegroundColorCode(fgBlue)
  styledEcho fgGreen, styleBright, r"""    __                                
   / /_  ____ _____  ____  __  ___  __
  / __ \/ __ `/ __ \/ __ \/ / / / |/_/
 / / / / /_/ / /_/ / /_/ / /_/ />  <  
/_/ /_/\__,_/ .___/ .___/\__, /_/|_|  
           /_/   /_/_  _/____/        """
  styledEcho fgGreen, """      ____  ____ _/ /_(_)   _____     
     / __ \/ __ `/ __/ / | / / _ \    
    / / / / /_/ / /_/ /| |/ /  __/    
   /_/ /_/\__,_/\__/_/ |___/\___/     
                                      """
  styledEcho fgYellow, fmt"v{HpxNativeVersion}".align(36)
  styledEcho(
    "\nCLI for ", fgGreen, "creating", fgWhite, " and ", fgGreen, "building",
    fgWhite, " HappyX native applications\n"
  )
  styledEcho "Usage:"
  styledEcho fgMagenta, " hpx-native ", fgYellow, "help", fgBlue, " subcommand"
  styledEcho fgMagenta, " hpx-native ", fgBlue, subcommands.join(delimeter), fgYellow, " [subcommand-args]"
  QuitSuccess
