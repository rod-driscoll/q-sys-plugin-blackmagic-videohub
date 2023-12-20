# q-sys-plugin-blackmagic-videohub

Q-SYS plugin for BlackMagic VideoHub

Language: Lua\
Platform: Q-Sys

Source code location: <https://github.com/rod-driscoll/q-sys-plugin-blackmagic-videohub>

![Matrix switcher tab](https://github.com/rod-driscoll/q-sys-plugin-blackmagic-videohub/blob/main/content/images/ui-tab-matrix-switcher.png)

## Deploying code

Copy the *.qplug file into "%USERPROFILE%\Documents\QSC\Q-Sys Designer\Plugins" then drag the plugin into a design.

## Developing code

Instructions and resources for Q-Sys plugin development is available at:

* <https://q-syshelp.qsc.com/DeveloperHelp/>
* <https://github.com/q-sys-community/q-sys-plugin-guide/tree/master>

Do not edit the *.qplug file directly, this is created using the compiler.
"plugin.lua" contains the main code.

### Development and testing

The files in "./DEV/" are for dev only and may not be the most current code, they were created from the main *.qplug file following these instructions for run-time debugging:\
[Debugging Run-time Code](https://q-syshelp.qsc.com/DeveloperHelp/#Getting_Started/Building_a_Plugin.htm?TocPath=Getting%2520Started%257C_____3)

## Features

### Features tested and functional

* Video switching
* Output locks - note output locks can't override locks set to 'L'
  
### Features not tested

* Serial control

## Dependencies

Uses the module "Helpers" which is located in /DEV/Helpers.
To install module dependencies copy the whole directory into "%USERPROFILE%\Documents\QSC\Q-Sys Designer\Modules" and then in Designer go to Tools > Designer Resources, and Install the module.

## Contributors

Author: Rod Driscoll <rod@theavitgroup.com.au>
