@echo off
rem Licensed to the Apache Software Foundation (ASF) under one or more
rem contributor license agreements.  See the NOTICE file distributed with
rem this work for additional information regarding copyright ownership.
rem The ASF licenses this file to You under the Apache License, Version 2.0
rem (the "License"); you may not use this file except in compliance with
rem the License.  You may obtain a copy of the License at
rem
rem     http://www.apache.org/licenses/LICENSE-2.0
rem
rem Unless required by applicable law or agreed to in writing, software
rem distributed under the License is distributed on an "AS IS" BASIS,
rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
rem See the License for the specific language governing permissions and
rem limitations under the License.
rem
rem --------------------------------------------------
rem Lua release helper script
rem
rem Usage: mkrelease.bat version target
rem    eg: mkrelease 5.4.23 x64
rem
setlocal
if "x%~1" == "x" goto Einval
if "x%~2" == "x" goto Einval
rem
set "LuaVersion=%~1"
set "LuaTarget=%~2"
rem
set "LuaDistro=%LuaVersion%-win-%LuaTarget%"
pushd %~dp0
set "BuildDir=%cd%"
popd
rem
rem Create builds
nmake "INSTALLDIR=%BuildDir%\dist\lua-%LuaDistro%" _STATIC=1 install
nmake "INSTALLDIR=%BuildDir%\dist\lua-%LuaDistro%" install
rem
rem Set path for ClamAV and 7za
rem
set "PATH=C:\Tools\clamav;C:\Utils;%PATH%"
pushd "%BuildDir%\dist"
rem
freshclam.exe --quiet
echo ## Binary release v%LuaVersion% > lua-%LuaDistro%.txt
echo. >> lua-%LuaDistro%.txt
echo. >> lua-%LuaDistro%.txt
echo ```no-highlight >> lua-%LuaDistro%.txt
clamscan.exe --version >> lua-%LuaDistro%.txt
clamscan.exe --bytecode=no -r lua-%LuaDistro% >> lua-%LuaDistro%.txt
echo ``` >> lua-%LuaDistro%.txt
7za.exe a -bd lua-%LuaDistro%.zip lua-%LuaDistro%
sigtool.exe --sha256 lua-%LuaDistro%.zip >> lua-%LuaDistro%-sha256.txt
rem
popd
goto End
:Einval
echo Error: Invalid parameter
echo Usage: %~nx0 version target
exit /b 1

:End
