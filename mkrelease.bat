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
rem Release helper script
rem
rem Usage: mkrelease.bat version architecture
rem    eg: mkrelease 5.4.6_1 x64 "_VENDOR_SFX=_1"
rem
setlocal
if "x%~1" == "x" goto Einval
if "x%~2" == "x" goto Einval
rem
set "ProjectName=lua"
set "ReleaseVersion=%~1"
set "ReleaseArch=%~2"
rem
set "ReleaseName=%ProjectName%-%ReleaseVersion%-win-%ReleaseArch%"
set "ReleaseLog=%ReleaseName%.txt
pushd %~dp0
set "BuildDir=%cd%"
popd
nmake /nologo clean
nmake /nologo clean _STATIC=1
if not %ERRORLEVEL% == 0 goto Failed
rem
rem Create builds
nmake "PREFIX=%BuildDir%\dist\%ReleaseName%" %~3 %~4 install
nmake "PREFIX=%BuildDir%\dist\%ReleaseName%" %~3 %~4 _STATIC=1 install
rem
pushd "%BuildDir%\dist"
rem
rem Get nmake and cl versions
rem
echo _MSC_FULL_VER > %ProjectName%.i
nmake /? 2>%ProjectName%.p 1>NUL
cl.exe /EP %ProjectName%.i >>%ProjectName%.p 2>&1
rem
echo ## Binary release v%ReleaseVersion% > %ReleaseLog%
echo. >> %ReleaseLog%
echo ```no-highlight >> %ReleaseLog%
echo. >> %ReleaseLog%
echo Compiled using: >> %ReleaseLog%
echo nmake %~3 %~4 >> %ReleaseLog%
findstr /B /C:"Microsoft (R) " %ProjectName%.p >> %ReleaseLog%
echo. >> %ReleaseLog%
rem
del /F /Q %ProjectName%.i 2>NUL
del /F /Q %ProjectName%.p 2>NUL
echo. >> %ReleaseLog%
echo. >> %ReleaseLog%
7za.exe a -bd %ReleaseName%.zip .\%ReleaseName%\*
certutil -hashfile %ReleaseName%.zip SHA256 | findstr /v "CertUtil" >> %ReleaseLog%
echo. >> %ReleaseLog%
echo ``` >> %ReleaseLog%
rem
popd
goto End
rem
:Einval
echo Error: Invalid parameter
echo Usage: %~nx0 version target
exit /b 1
rem
:Failed
echo.
echo Error: Cannot build %ProjectName%.exe
exit /b 1
rem
:End
exit /b 0
