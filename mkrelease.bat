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
rem Usage: mkrelease.bat [version]
rem
setlocal
if not "x%~1" == "x" goto haveVersion
rem
echo Error: Missing release version
echo Usage: %~nx0 [version]
exit /b 1

:haveVersion
set "LuaVersion=%~1"
rem
rem Set path for ClamAV and 7za
rem
set "PATH=C:\Tools\clamav;C:\Utils;%PATH%"
rem
freshclam.exe --quiet
echo ## Binary release v%LuaVersion% > lua-%LuaVersion%.txt
echo. >> lua-%LuaVersion%.txt
echo. >> lua-%LuaVersion%.txt
echo ```no-highlight >> lua-%LuaVersion%.txt
clamscan.exe --version >> lua-%LuaVersion%.txt
clamscan.exe --bytecode=no -r lua-%LuaVersion%-win-x64 >> lua-%LuaVersion%.txt
echo ``` >> lua-%LuaVersion%.txt
7za.exe a -bd lua-%LuaVersion%-win-x64.zip lua-%LuaVersion%-win-x64
sigtool.exe --sha256 lua-%LuaVersion%-win-x64.zip >> lua-%LuaVersion%-sha256.txt
rem
