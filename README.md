# Lua : Overview

Lua is a powerful, light-weight programming language designed for extending
applications. Lua is also frequently used as a general-purpose, stand-alone
language. Lua is free software.

For complete information, visit Lua's web site at http://www.lua.org/ .
For an executive summary, see http://www.lua.org/about.html .

This is Lua 5.4.4, released on 2022-01-26.

## Building Lua

The build process supports only command line tools.

Lua release comes with the **lua.exe** **luac.exe** and **liblua54.dll**
binaries, libraries and header files.
In case you wish to create your own binary build,
download or clone Lua sources and follow a
few standard rules.

### Prerequisites

To compile Lua from source code you will need either
Microsoft C/C++ Compiler from Microsoft Visual Studio 2010
or any later version.

The official distributions are build using
[Custom Microsoft Compiler Toolkit](https://github.com/mturk/cmsc)
compiler bundle.


### Build using CMSC

Presuming that you have downloaded and unzipped
[CMSC release](https://github.com/mturk/cmsc/releases)
in the root of C drive.

Open command prompt in the directory where you have
downloaded or cloned Lua and do the following

```cmd
> C:\cmsc-15.0_39\setenv.bat
Using default architecture: x64
Setting build environment for win-x64/0x0601

> nmake

Microsoft (R) Program Maintenance Utility Version 9.00.30729.207
...
```

In case there are no compile errors, binaries are located
inside **x64-rel-dll** subdirectory.

### Build using Visual Studio

To build the Lua using an already installed Visual Studio,
you will need to open the Visual Studio native x64 command
line tool. The rest is almost the same as with CMSC toolkit.

Here is the example for Visual Studio 2012

Inside the Start menu select Microsoft Visual Studio 2012 then
click on Visual Studio Tools and click on
Open `VC2012 x64 Native Tools Command Prompt`.

If using Visual Studio 2017 or later, open command prompt
and call `vcvars64.bat` from Visual Studio install location
eg, `C:\Program Files\Visual Studio 2017\VC\Auxiliary\Build`


After setting the compiler, use the following

```cmd
> cd C:\Some\Location\lua
> nmake

```

The binary should be inside **x64-rel-dll** subdirectory.

Using Visual Studio, Lua can be built
as statically linked to the MSVCRT library.

Add `_STATIC_MSVCRT=1` as nmake parameter:
```cmd
> nmake _STATIC_MSVCRT=1

```

### Static library builds

By default Makefile builds Lua Library as dll. To build
static version of the library add `_STATIC=1` as nmake parameter

```cmd
> nmake _STATIC=1

```

This will build **lua54.lib**, **lua.exe** and **luac.exe**.
The binary should be inside **x64-rel-lib** subdirectory.


### Makefile targets

Makefile has two additional targets which can be useful
for Lua development and maintenance

```cmd
> nmake clean
```

This will remove all produced binaries and object files
by deleting **x64** subdirectory.

```cmd
> nmake PREFIX=C:\some\directory install
```

Standard makefile install target that will
copy the executables, libraries and include files to the PREFIX location.

This can be useful if you are building Lua with
some Continuous build application that needs produced
binaries at a specific location for later use.


## Create Release

To create a release use the provided **mkrelease.bat** script

```cmd
> mkrelease.bat 5.4.3_1 x64 "_VENDOR_SFX=_1"
```

Inside **dist** directory you can find .zip and .txt files
containing build artifacts and release metadata

# License

The code in this repository is licensed under the [MIT License](LICENSE.txt)
according to the upstream project.
