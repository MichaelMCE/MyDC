# Note: the next six lines are modified by the makefile-generator in xcowlite.x.
APP       = MyDCUI
LIBS      = xbl.lib kernel32.lib shell32.lib msvcrt.lib user32.lib gdi32.lib comctl32.lib dcutils.lib
OBJS      = $(APP).o
START     = START /W
XBLITE    = xblite -lib
SUBSYSTEM = WINDOWS,4.0

# The linker
LD          = link

# Flags for the linker
#LDFLAGS     = /NODEFAULTLIB /SUBSYSTEM:$(SUBSYSTEM) /INCREMENTAL:NO /RELEASE /NOLOGO /OPT:REF

# Flags for the linker when building .dll-files
LDFLAGS_DLL = -dll -subsystem:$(SUBSYSTEM) -entry:DllMain

# Needed resources 
RESOURCES   = $(APP).rbj

# The assembler
AS          = spasm

# All needed standard libraries.
STDLIBS     = kernel32.lib advapi32.lib user32.lib gdi32.lib \
              comdlg32.lib winspool.lib

# The main directory for \xblite 
DIR         = $(XBLDIR)

all: $(APP).dll

$(APP).dll: $(APP).o $(APP).def $(APP).rbj
	$(LD) $(LDFLAGS_DLL) -out:$(APP).dll -def:$(APP).def $(OBJS) $(RESOURCES) $(LIBS) $(STDLIBS)

$(APP).rbj: $(APP).res
	cvtres -i386 -NOLOGO $(APP).res -o $(APP).rbj

$(APP).res: $(APP).rc
	rc -i$(DIR)\images -r -fo $(APP).res $(APP).rc

$(APP).o: $(APP).s
	$(AS) $(APP).s

$(APP).s: $(APP).x
	$(START) $(XBLITE) $(APP).x -lib

clean:
	IF EXIST $(APP).def DEL $(APP).def
	IF EXIST $(APP).o DEL $(APP).o
	IF EXIST $(APP).s DEL $(APP).s
	IF EXIST $(APP).exp DEL $(APP).exp
	IF EXIST $(APP).res DEL $(APP).res
	IF EXIST $(APP).rbj DEL $(APP).rbj
	COPY /B $(APP).lib /B $(DIR)\lib\$(APP).lib /Y
	COPY /A $(APP).dec /A $(DIR)\include\$(APP).dec /Y
	COPY /B $(APP).dll /B $(DIR)\programs\$(APP).dll /Y



