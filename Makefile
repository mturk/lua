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

!IF !DEFINED(SRCDIR) || "$(SRCDIR)" == ""
SRCDIR = .
!ENDIF

CFLAGS = $(CFLAGS) -I$(SRCDIR)\src
CFLAGS = $(CFLAGS) -DNDEBUG -DWIN32 -D_WIN32_WINNT=$(WINVER) -DWINVER=$(WINVER)
CFLAGS = $(CFLAGS) -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE $(EXTRA_CFLAGS)
LFLAGS = /nologo /INCREMENTAL:NO /OPT:REF /SUBSYSTEM:CONSOLE /MACHINE:$(BUILD_CPU) $(EXTRA_LFLAGS)

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

WORKDIR = $(BUILD_CPU)$(TARGET)
LIBLUA  = $(WORKDIR)\$(LDNAME).$(TARGET)
LLUA    = $(WORKDIR)\$(LDNAME).lib
LUAI    = $(WORKDIR)\lua.exe
LUAC    = $(WORKDIR)\luac.exe

CLOPTS = /c /nologo $(CRT_CFLAGS) -W3 -O2 -Ob2
RFLAGS = /l 0x409 /n /i $(SRCDIR)\src /d NDEBUG /d WIN32 /d WINNT /d WINVER=$(WINVER)
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
	$(CC) $(CLOPTS) $(CFLAGS) -Fo$(WORKDIR)\ $<


$(LIBLUA) : $(WORKDIR) $(LLUAOBJS)
!IF "$(TARGET)" == "dll"
	$(RC) $(RFLAGS) /d BIN_NAME="$(LDNAME).dll" /d APP_NAME="Lua Library" /fo $(WORKDIR)\$(LDNAME).res $(SRCDIR)\lua.rc
	$(LN) $(LDFLAGS) $(LLUAOBJS) $(WORKDIR)\$(LDNAME).res $(LDLIBS) /out:$(LIBLUA)
!ELSE
	$(AR) $(ARFLAGS) $(LLUAOBJS) /out:$(LIBLUA)
!ENDIF

$(LUAI) : $(LIBLUA) $(LUAIOBJS)
	$(RC) $(RFLAGS) /d BIN_NAME="lua.exe" /d APP_NAME="Lua Interpreter" /d APP_FILE /d ICO_FILE /fo $(WORKDIR)\lua.res $(SRCDIR)\lua.rc
	$(LN) $(LFLAGS) $(LUAIOBJS) $(WORKDIR)\lua.res $(LLUA) $(LDLIBS) /out:$(LUAI)

!IF "$(TARGET)" == "lib"
$(LUAC) : $(LIBLUA) $(LUACOBJS)
	$(RC) $(RFLAGS) /d BIN_NAME="luac.exe" /d APP_NAME="Lua Compiler" /d APP_FILE /d ICO_FILE /fo $(WORKDIR)\luac.res $(SRCDIR)\lua.rc
	$(LN) $(LFLAGS) $(LUACOBJS) $(WORKDIR)\lua.res $(LLUA) $(LDLIBS) /out:$(LUAC)
!ELSE
$(LUAC) :

!ENDIF

clean:
	@-rd /S /Q $(WORKDIR) 2>NUL