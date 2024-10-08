# MIT License
#
# Copyright (C) 1964-2024 Mladen Turk
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

CC = cl.exe
LN = link.exe
AR = lib.exe
RC = rc.exe
MT = mt.exe
SRCDIR = .

_CPU = x64
_LIB = lib

!IF !DEFINED(WINVER) || "$(WINVER)" == ""
WINVER = 0x0A00
!ENDIF

CFLAGS = -DNDEBUG
LFLAGS = /nologo /OPT:REF /INCREMENTAL:NO
RFLAGS = /nologo /d NDEBUG
BLDVER = -rel-
LFLAGS = $(LFLAGS) /NODEFAULTLIB:libucrt.lib /DEFAULTLIB:ucrt.lib

CFLAGS = -I$(SRCDIR)\src $(CFLAGS)
CFLAGS = $(CFLAGS) -DWIN32 -D_WIN32_WINNT=$(WINVER) -DWINVER=$(WINVER)
CFLAGS = $(CFLAGS) -D_CRT_SECURE_NO_WARNINGS
CFLAGS = $(CFLAGS) -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE $(EXTRA_CFLAGS)
LFLAGS = $(LFLAGS) /MACHINE:$(_CPU) $(EXTRA_LFLAGS)

!IF DEFINED(_STATIC)
TARGET  = lib
LDNAME  = lua54
ARFLAGS = /nologo /MACHINE:$(_CPU) $(EXTRA_ARFLAGS)
!ELSE
TARGET  = dll
CFLAGS  = $(CFLAGS) -DLUA_BUILD_AS_DLL
LDNAME  = liblua54
!ENDIF

WORKDIR = $(_CPU)$(BLDVER)$(TARGET)
LIBLUA  = $(WORKDIR)\$(LDNAME).$(TARGET)
LLUA    = $(WORKDIR)\$(LDNAME).lib
LUAI    = $(WORKDIR)\lua.exe
LUAC    = $(WORKDIR)\luac.exe

CLOPTS  = /c /nologo -MT -W3 -O2 -Ob2
RFLAGS  = $(RFLAGS) /l 0x409 /n /i $(SRCDIR)\src /d WIN32 /d WINNT /d WINVER=$(WINVER)
RFLAGS  = $(RFLAGS) /d _WIN32_WINNT=$(WINVER) $(EXTRA_RFLAGS)
LDLIBS  = kernel32.lib

!IF DEFINED(_VENDOR_SFX)
RFLAGS  = $(RFLAGS) /d _VENDOR_SFX=$(_VENDOR_SFX)
!ENDIF
!IF DEFINED(_VENDOR_NUM)
RFLAGS  = $(RFLAGS) /d _VENDOR_NUM=$(_VENDOR_NUM)
!ENDIF

!IF DEFINED(_PDB)
LLUAPDB = /pdb:$(WORKDIR)\$(LDNAME).pdb
LUAIPDB = /pdb:$(WORKDIR)\lua.pdb
LUACPDB = /pdb:$(WORKDIR)\luac.pdb
LLUAPFD = -Fd$(WORKDIR)\$(LDNAME)
LUAIPFD = -Fd$(WORKDIR)\lua
LUACPFD = -Fd$(WORKDIR)\luac
CLOPTS  = $(CLOPTS) -Zi
LDFLAGS = $(LDFLAGS) /DEBUG
!ENDIF


LLUAOBJS = \
	$(WORKDIR)\lapi.obj \
	$(WORKDIR)\lauxlib.obj \
	$(WORKDIR)\lbaselib.obj \
	$(WORKDIR)\lcode.obj \
	$(WORKDIR)\lcorolib.obj \
	$(WORKDIR)\lctype.obj \
	$(WORKDIR)\ldblib.obj \
	$(WORKDIR)\ldebug.obj \
	$(WORKDIR)\ldo.obj \
	$(WORKDIR)\ldump.obj \
	$(WORKDIR)\lfunc.obj \
	$(WORKDIR)\lgc.obj \
	$(WORKDIR)\linit.obj \
	$(WORKDIR)\liolib.obj \
	$(WORKDIR)\llex.obj \
	$(WORKDIR)\lmathlib.obj \
	$(WORKDIR)\lmem.obj \
	$(WORKDIR)\loadlib.obj \
	$(WORKDIR)\lobject.obj \
	$(WORKDIR)\lopcodes.obj \
	$(WORKDIR)\loslib.obj \
	$(WORKDIR)\lparser.obj \
	$(WORKDIR)\lstate.obj \
	$(WORKDIR)\lstring.obj \
	$(WORKDIR)\lstrlib.obj \
	$(WORKDIR)\ltable.obj \
	$(WORKDIR)\ltablib.obj \
	$(WORKDIR)\ltm.obj \
	$(WORKDIR)\lundump.obj \
	$(WORKDIR)\lutf8lib.obj \
	$(WORKDIR)\lvm.obj \
	$(WORKDIR)\lzio.obj

LUACOBJS = \
	$(WORKDIR)\luac.obj

LUAIOBJS = \
	$(WORKDIR)\lua.obj

all : $(WORKDIR) $(LIBLUA) $(LUAI) $(LUAC)

$(WORKDIR):
	@-md $(WORKDIR)

{$(SRCDIR)\src}.c{$(WORKDIR)}.obj:
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ $(LLUAPFD) $<

$(LUAIOBJS):
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ $(LUAIPFD) $(SRCDIR)\src\lua.c

$(LUACOBJS):
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ $(LUACPFD) $(SRCDIR)\src\luac.c

$(LIBLUA): $(LLUAOBJS)
!IF "$(TARGET)" == "dll"
	$(RC) $(RFLAGS) /d BIN_NAME="$(LDNAME).dll" /d APP_NAME="Lua Library" /fo $(WORKDIR)\$(LDNAME).res $(SRCDIR)\lua.rc
	$(LN) $(LFLAGS) /DLL /SUBSYSTEM:WINDOWS $(LLUAOBJS) $(WORKDIR)\$(LDNAME).res $(LDLIBS) $(LLUAPDB) /out:$(LIBLUA)
	$(MT) -manifest standard.manifest -outputresource:$(LIBLUA);2
!ELSE
	$(AR) $(ARFLAGS) $(LLUAOBJS) /out:$(LIBLUA)
!ENDIF

$(LUAI): $(LIBLUA) $(LUAIOBJS)
	$(RC) $(RFLAGS) /d BIN_NAME="lua.exe" /d APP_NAME="Lua Command Line Interpreter" /d APP_FILE /d ICO_FILE /fo $(WORKDIR)\lua.res $(SRCDIR)\lua.rc
	$(LN) $(LFLAGS) /SUBSYSTEM:CONSOLE $(LUAIOBJS) $(WORKDIR)\lua.res $(LLUA) $(LDLIBS) $(LUAIPDB) /out:$(LUAI)
	$(MT) -manifest standard.manifest -outputresource:$(LUAI);1

$(LUAC): $(LIBLUA) $(LUACOBJS)
	$(RC) $(RFLAGS) /d BIN_NAME="luac.exe" /d APP_NAME="Lua Compiler" /d APP_FILE /d ICO_FILE /fo $(WORKDIR)\luac.res $(SRCDIR)\lua.rc
	$(LN) $(LFLAGS) /SUBSYSTEM:CONSOLE $(LUACOBJS) $(WORKDIR)\luac.res $(LLUA) $(LDLIBS) $(LUACPDB) /out:$(LUAC)
	$(MT) -manifest standard.manifest -outputresource:$(LUAC);1

!IF !DEFINED(PREFIX) || "$(PREFIX)" == ""
install:
	@echo PREFIX is not defined
	@echo Use `nmake install PREFIX=directory`
	@echo.
	@exit /B 1
!ELSE
install: all
!IF "$(TARGET)" == "dll"
	@xcopy /I /Y /Q "$(WORKDIR)\*.dll" "$(PREFIX)\bin"
!ENDIF
	@xcopy /I /Y /Q "$(WORKDIR)\*.exe" "$(PREFIX)\bin"
	@xcopy /I /Y /Q "$(WORKDIR)\*.lib" "$(PREFIX)\$(_LIB)"
	@xcopy /I /Y /Q "$(SRCDIR)\src\lua.h*" "$(PREFIX)\include"
	@xcopy /Y /Q "$(SRCDIR)\src\luaconf.h" "$(PREFIX)\include"
	@xcopy /Y /Q "$(SRCDIR)\src\lualib.h"  "$(PREFIX)\include"
	@xcopy /Y /Q "$(SRCDIR)\src\lauxlib.h" "$(PREFIX)\include"
!IF DEFINED(_PDB)
	@xcopy /I /Y /Q "$(WORKDIR)\*.pdb" "$(PREFIX)\bin"
!ENDIF
!ENDIF

clean:
	@-rd /S /Q $(WORKDIR) 2>NUL
