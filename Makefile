# MIT License
#
# Copyright (C) 1964-2021 Mladen Turk
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

!IF !DEFINED(BUILD_CPU) || "$(BUILD_CPU)" == ""
!IF DEFINED(VSCMD_ARG_TGT_ARCH)
BUILD_CPU = $(VSCMD_ARG_TGT_ARCH)
!ELSE
!ERROR Must specify BUILD_CPU matching compiler x86 or x64
!ENDIF
!ENDIF

!IF !DEFINED(WINVER) || "$(WINVER)" == ""
WINVER = 0x0601
!ENDIF

!IF DEFINED(_STATIC_MSVCRT)
CRT_CFLAGS = -MT
!ELSE
CRT_CFLAGS = -MD
!ENDIF

!IF DEFINED(_DEBUG)
CRT_CFLAGS = $(CRT_CFLAGS)d
CFLAGS = -DDEBUG -D_DEBUG
RFLAGS = /d DEBUG /d _DEBUG
BLDVER = -dbg-
!ELSE
CFLAGS = -DNDEBUG
LFLAGS = /OPT:REF
RFLAGS = /d NDEBUG
BLDVER = -rel-
!ENDIF

!IF !DEFINED(SRCDIR) || "$(SRCDIR)" == ""
SRCDIR = .
!ENDIF

!IF !DEFINED(TARGET_LIB) || "$(TARGET_LIB)" == ""
TARGET_LIB = lib
!ENDIF

CFLAGS = -I$(SRCDIR)\src $(CFLAGS)
CFLAGS = $(CFLAGS) -DWIN32 -D_WIN32_WINNT=$(WINVER) -DWINVER=$(WINVER)
CFLAGS = $(CFLAGS) -DLUA_COMPAT_5_3 -D_CRT_SECURE_NO_WARNINGS
CFLAGS = $(CFLAGS) -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE $(EXTRA_CFLAGS)
LFLAGS = /nologo /INCREMENTAL:NO /DEBUG $(LFLAGS) /SUBSYSTEM:CONSOLE /MACHINE:$(BUILD_CPU) $(EXTRA_LFLAGS)

!IF DEFINED(_STATIC)
TARGET  = lib
LDNAME  = lua54
ARFLAGS = /nologo /SUBSYSTEM:CONSOLE /MACHINE:$(BUILD_CPU) $(EXTRA_LFLAGS)
!ELSE
TARGET  = dll
CFLAGS  = $(CFLAGS) -DLUA_BUILD_AS_DLL
LDNAME  = liblua54
LDFLAGS = $(LFLAGS) /DLL
!ENDIF

WORKDIR = $(BUILD_CPU)$(BLDVER)$(TARGET)
LIBLUA  = $(WORKDIR)\$(LDNAME).$(TARGET)
LLUA    = $(WORKDIR)\$(LDNAME).lib
LUAI    = $(WORKDIR)\lua.exe
LUAC    = $(WORKDIR)\luac.exe
LLUAPDB = /pdb:$(WORKDIR)\$(LDNAME).pdb
LUAIPDB = /pdb:$(WORKDIR)\lua.pdb
LUACPDB = /pdb:$(WORKDIR)\luac.pdb

CLOPTS = /c /nologo $(CRT_CFLAGS) -W3 -O2 -Ob2 -Zi
RFLAGS = /l 0x409 /n /i $(SRCDIR)\src $(RFLAGS) /d WIN32 /d WINNT /d WINVER=$(WINVER)
RFLAGS = $(RFLAGS) /d _WIN32_WINNT=$(WINVER) $(EXTRA_RFLAGS)
LDLIBS = kernel32.lib $(EXTRA_LIBS)

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

$(WORKDIR) :
	@-md $(WORKDIR)

{$(SRCDIR)\src}.c{$(WORKDIR)}.obj:
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ -Fd$(WORKDIR)\$(LDNAME) $<

$(LUAIOBJS) :
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ -Fd$(WORKDIR)\lua  $(SRCDIR)\src\lua.c

$(LUACOBJS) :
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ -Fd$(WORKDIR)\luac $(SRCDIR)\src\luac.c

$(LIBLUA) : $(WORKDIR) $(LLUAOBJS)
!IF "$(TARGET)" == "dll"
	$(RC) $(RFLAGS) /d BIN_NAME="$(LDNAME).dll" /d APP_NAME="Lua Library" /fo $(WORKDIR)\$(LDNAME).res $(SRCDIR)\lua.rc
	$(LN) $(LDFLAGS) $(LLUAOBJS) $(WORKDIR)\$(LDNAME).res $(LDLIBS) $(LLUAPDB) /out:$(LIBLUA)
!ELSE
	$(AR) $(ARFLAGS) $(LLUAOBJS) /out:$(LIBLUA)
!ENDIF

$(LUAI) : $(LIBLUA) $(LUAIOBJS)
	$(RC) $(RFLAGS) /d BIN_NAME="lua.exe" /d APP_NAME="Lua Command Line Interpreter" /d APP_FILE /d ICO_FILE /fo $(WORKDIR)\lua.res $(SRCDIR)\lua.rc
	$(LN) $(LFLAGS) $(LUAIOBJS) $(WORKDIR)\lua.res $(LLUA) $(LDLIBS) $(LUAIPDB) /out:$(LUAI)

!IF "$(TARGET)" == "lib"
$(LUAC) : $(LIBLUA) $(LUACOBJS)
	$(RC) $(RFLAGS) /d BIN_NAME="luac.exe" /d APP_NAME="Lua Compiler" /d APP_FILE /d ICO_FILE /fo $(WORKDIR)\luac.res $(SRCDIR)\lua.rc
	$(LN) $(LFLAGS) $(LUACOBJS) $(WORKDIR)\luac.res $(LLUA) $(LDLIBS) $(LUACPDB) /out:$(LUAC)
!ELSE
$(LUAC) :

!ENDIF

!IF !DEFINED(PREFIX) || "$(PREFIX)" == ""
install :
	@echo PREFIX is not defined
	@echo Use `nmake install PREFIX=directory`
	@echo.
	@exit /B 1
!ELSE
install : all
!IF "$(TARGET)" == "dll"
	@xcopy /I /Y /Q "$(WORKDIR)\*.dll" "$(PREFIX)\bin"
!ENDIF
	@xcopy /I /Y /Q "$(WORKDIR)\*.exe" "$(PREFIX)\bin"
	@xcopy /I /Y /Q "$(WORKDIR)\*.lib" "$(PREFIX)\$(TARGET_LIB)"
	@xcopy /I /Y /Q "$(SRCDIR)\src\lua.h*" "$(PREFIX)\include"
	@xcopy /Y /Q "$(SRCDIR)\src\luaconf.h" "$(PREFIX)\include"
	@xcopy /Y /Q "$(SRCDIR)\src\lualib.h"  "$(PREFIX)\include"
	@xcopy /Y /Q "$(SRCDIR)\src\lauxlib.h" "$(PREFIX)\include"
!ENDIF

clean :
	@-rd /S /Q $(WORKDIR) 2>NUL
