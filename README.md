# q-sys-plugin-blackmagic-videohub

Q-SYS plugin for BlackMagic VideoHub

Language: Lua\
Platform: Q-Sys

Source code location: <https://github.com/rod-driscoll/q-sys-plugin-blackmagic-videohub>

![Matrix switcher tab](https://github.com/rod-driscoll/q-sys-plugin-blackmagic-videohub/blob/main/content/images/ui-tab-matrix-switcher.png)

## Demo project

A working demo Q-Sys Designer project is located at [//demo/BlackMagic VideoHub - Demo.qsys](https://github.com/rod-driscoll/q-sys-blackmagic-videohub/blob/main/demo/BlackMagic%20VideoHub%20-%20DEV.qsys)\

The demo project has all dependencies pre-loaded so it ready to load to use.

## Deploying code

### Dependencies

Install dependencies before installing the plugin.\
Dependencies (modules) are stored in the [//dependencies](https://github.com/rod-driscoll/q-sys-blackmagic-videohub/blob/main/dependencies/) folder

Copy any/all module folders in the dependencies directly to the Q-Sys modules folder on your PC ("**%USERPROFILE%\Documents\QSC\Q-Sys Designer\Modules**") and then in Designer go to Tools > Designer Resources, and Install the module(s).\

For more detailed instructions on installing dependencies follow the instructions in the README located in the dependencies folder.

### The compiled plugin

The compiled plugin file is located in this repo at [//demo/q-sys-blackmagic-videohub.qplug](https://github.com/rod-driscoll/q-sys-blackmagic-videohub/blob/main/demo/q-sys-blackmagic-videohub.qplug)\
Copy the *.qplug file into "**%USERPROFILE%\Documents\QSC\Q-Sys Designer\Plugins**" then drag the plugin into a design.

## Developing code

Instructions and resources for Q-Sys plugin development is available at:

* <https://q-syshelp.qsc.com/DeveloperHelp/>
* <https://github.com/q-sys-community/q-sys-plugin-guide/tree/master>

Do not edit the *.qplug file directly, this is created using the compiler.
"plugin.lua" contains the main code.

### Development and testing

The files in "//testing/" are for dev only and may not be the most current code, they were created from the main *.qplug file following these instructions for run-time debugging:\
[Debugging Run-time Code](https://q-syshelp.qsc.com/DeveloperHelp/#Getting_Started/Building_a_Plugin.htm?TocPath=Getting%2520Started%257C_____3)

## Features

### Features tested and functional

* Video switching
* Output locks - note output locks can't override locks set to 'L'
  
### Features not tested

* Serial control

## Contributors

Author: Rod Driscoll <rod@theavitgroup.com.au>
