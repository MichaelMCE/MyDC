

' displays system stats
' type /load moodll.dll to load
' /stat to display stats to self
' see ProcessClientCmd() for other commands

PROGRAM	"moodll"
VERSION	"0.20"
'MAKEFILE "moodll.mak"
MAKEFILE "xdll.xxx"


	IMPORT "gdi32"
	IMPORT "user32"
	IMPORT "moo"
	IMPORT "dcutils"
	IMPORT "MyDC.dec"
	IMPORT "advapi32"
	IMPORT "kernel32"
'	IMPORT "shell32"
'	IMPORT "msvcrt"
	
$$PluginTitle = "Moo System Stats"
$$ATIDRIVER = "SOFTWARE\\ATI Technologies\\CDS\\0000\\0\\Driver"
$$ATIBIOS = "SOFTWARE\\ATI Technologies\\CDS\\0000\\0\\BIOS"
$$ATIMEMORY = "SOFTWARE\\ATI Technologies\\CDS\\0000\\0\\Memory"
$$ATIASIC = "SOFTWARE\\ATI Technologies\\CDS\\0000\\0\\ASIC"
$$ATIPCI = "SOFTWARE\\ATI Technologies\\CDS\\0000\\0\\PCI Config"

'DECLARE FUNCTION DllMain (a,b,c)
DECLARE FUNCTION DllEntry ()

EXPORT
DECLARE FUNCTION DllExit ()
DECLARE FUNCTION DllStartup (TDCPlugin dcp)
DECLARE FUNCTION DllProc (token, STRING msg1, STRING msg2)
END EXPORT


DECLARE FUNCTION SendMsg (STRING msg)
DECLARE FUNCTION ProcessClientCmd (STRING cmd,STRING msg)
DECLARE FUNCTION DispatchDCTMsg (token, STRING msg1, STRING msg2)
DECLARE FUNCTION CPrint (edit,STRING msg)
DECLARE FUNCTION STRING GetHubNick ()
DECLARE FUNCTION STRING GetNick ()

DECLARE FUNCTION STRING _screeninfo ()
DECLARE FUNCTION STRING _connection ()
DECLARE FUNCTION STRING _diskcapacity ()
DECLARE FUNCTION STRING _interfaceinfo ()
DECLARE FUNCTION STRING _netcapacity()
DECLARE FUNCTION STRING _osinfo()
DECLARE FUNCTION STRING _cpuinfo()
DECLARE FUNCTION STRING _rambar()
DECLARE FUNCTION STRING _membar()
DECLARE FUNCTION STRING _uptime()
DECLARE FUNCTION STRING _version ()
DECLARE FUNCTION STRING _gfxinfo ()
DECLARE FUNCTION STRING _testing ()

DECLARE FUNCTION ReadReg (root,ktype,STRING subkey, STRING key, STRING value)
DECLARE FUNCTION WriteReg (root,ktype, STRING subkey, STRING key, STRING value)


DECLARE FUNCTION STRING _ATI_Driver(STRING value)
DECLARE FUNCTION STRING _ATI_BIOS(STRING value)
DECLARE FUNCTION STRING _ATI_PCI(STRING value)
DECLARE FUNCTION STRING _ATI_ASIC(STRING value)
DECLARE FUNCTION STRING _ATI_Memory(STRING value)

'FUNCTION DllMain (a,reason,c)
FUNCTION DllEntry ()


	RETURN 1	
END FUNCTION

FUNCTION DllExit ()

	' do nothing as no clean up is required for this plugin
	DispatchDCTMsg ($$MDCT_PrvTxtMsg,STRING$($$Hub),":: "+$$PluginTitle+": shutting down")
	
END FUNCTION

FUNCTION DllStartup (TDCPlugin dcp)
	SHARED FUNCADDR DDCTM (XLONG,STRING,STRING)
	

'	#winMain = dcp.hWinMain
'	Server$ = CSTRING$(dcp.lpserver)
'	Nick$ = CSTRING$(dcp.lpnick)
'	Port = dcp.port
	
	dcp.pDllExit = &DllExit()
	dcp.pDllFunc = &DllProc()
	dcp.lpPluginTitle = &$$PluginTitle
	DDCTM = dcp.lpDDCTM

END FUNCTION

FUNCTION DllProc (token, STRING msg1, STRING msg2)
	SHARED STRING Nick


	SELECT CASE token
		CASE $$MDCT_ClientConnected	:
			Nick = GetTokenEx (@msg2,':',0)
			socket = XLONG(msg1)
			RETURN $$MDCTH_HandledCont
	
		CASE $$MDCT_Nick			:
			Nick = msg1
			RETURN $$MDCTH_HandledCont

		CASE $$MDCT_ClientCmdMsg	:
			IFT ProcessClientCmd (@msg1,@msg2) THEN
				RETURN $$MDCTH_HandledStop
			ELSE
				RETURN $$MDCTH_UnhandledCont
			END IF
			
	END SELECT

	RETURN $$MDCTH_UnhandledCont
END FUNCTION
 
FUNCTION ProcessClientCmd (STRING cmd,STRING msg)
	SHARED BOTS
	SHARED InsultAll
	STATIC STRING text
	SHARED STRING Nick
	
'	/load C:\code\MyDC\MyDCMoodll\moodll.dll
	cmd = LCASE$(TRIM$(cmd))
	SELECT CASE cmd
		CASE "gfx"			:SendMsg ("Gfx: "+_gfxinfo())
							 SendMsg ("Driver build: "+_ATI_Driver("Version")+", OpenGL: "+_ATI_Driver("OGL Driver Version")+", D3D: "+_ATI_Driver("D3D Driver Version")+", 2D: "+_ATI_Driver("2D Driver Version"))
							 SendMsg ("BIOS: "+_ATI_BIOS("Version")+", Filename: "+_ATI_BIOS("File Name")+", Serial: "+_ATI_BIOS("Part Number")+", Date: "+_ATI_BIOS("Date"))
		CASE "disk"			:SendMsg (" Disk info: "+_diskcapacity())
		CASE "net"			:SendMsg (" Network info: "+_interfaceinfo())
		CASE "scr"			:SendMsg (" Screen info: "+_screeninfo())
		CASE "os"			:SendMsg (" OS info: "+_osinfo())
	'	CASE "gfx"			:SendMsg (" GFX: "+_gfxinfo())
		CASE "cpu"			:SendMsg (" CPU: "+_cpuinfo())
		'CASE "rambar"		:SendMsg (" Rambar: "+_rambar())
		CASE "mem"			:SendMsg (" Mem "+_membar())
		CASE "uptime"		:SendMsg (" Uptime: "+_uptime())
		CASE "stat"			:
			CPrint ($$Hub,"- "+_screeninfo())
			'CPrint ($$Hub,"- "+_connection())
			CPrint ($$Hub,"- "+_diskcapacity())
			CPrint ($$Hub,"- "+_interfaceinfo())
			CPrint ($$Hub,"- "+_netcapacity())
			CPrint ($$Hub,"- "+_osinfo())
			CPrint ($$Hub,"- CPU: "+_cpuinfo())
			'CPrint ($$Hub,"- "+_rambar())
			CPrint ($$Hub,"- Mem "+_membar())
			CPrint ($$Hub,"- Uptime: "+_uptime())
			'CPrint ($$Hub,"- "+_version())
			CPrint ($$Hub,"- "+_gfxinfo())
			CPrint ($$Hub,"- AGP transfers supported: "+_ATI_ASIC("AGP Transfer Supported"))
			CPrint ($$Hub,"- Device ID: "+_ATI_PCI("Device ID")+", Fast Write: "+_ATI_PCI("Fast Write"))
			'CPrint ($$Hub,"- "+_testing())
			
			CPrint ($$Hub,"ATI Driver: Build:\t"+_ATI_Driver("Version"))
			CPrint ($$Hub,"- OpenGL Driver:\t"+_ATI_Driver("OGL Driver Version"))
			CPrint ($$Hub,"- D3D Driver:\t"+_ATI_Driver("D3D Driver Version"))
			CPrint ($$Hub,"- 2D Driver:\t"+_ATI_Driver("2D Driver Version"))

			CPrint ($$Hub,"ATI BIOS:\t\t"+_ATI_BIOS("Version"))
			CPrint ($$Hub,"- Filename:\t"+_ATI_BIOS("File Name"))
			CPrint ($$Hub,"- Serial Number:\t"+_ATI_BIOS("Part Number"))
			CPrint ($$Hub,"- Date:\t\t"+_ATI_BIOS("Date"))

		CASE ELSE			:RETURN $$FALSE
	END SELECT

	RETURN $$TRUE
	
END FUNCTION

FUNCTION STRING _screeninfo ()
	STATIC STRING text,parm


	parm = NULL$(900)
	text = NULL$(900)
	screeninfo(#winMain,#winMain,&text,&parm,1,0)
	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION STRING _connection ()
	STATIC STRING text,parm


	parm = NULL$(900)
	text = NULL$(900)
	connection(#winMain,#winMain,&text,&parm,1,0)
	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION STRING _diskcapacity ()
	STATIC STRING text,parm


	parm = NULL$(900)
	text = NULL$(900)
	diskcapacity (#winMain,#winMain,&text,&parm,1,0)
	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION STRING _interfaceinfo ()
	STATIC STRING text,parm


	parm = NULL$(900)
	text = NULL$(900)
	interfaceinfo(#winMain,#winMain,&text,&parm,1,0)
	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION STRING _netcapacity()
	STATIC STRING text,parm


	parm = NULL$(900)
	text = NULL$(900)
	netcapacity(#winMain,#winMain,&text,&parm,1,0)
	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION STRING _cpuinfo()
	STATIC STRING text,parm


	parm = NULL$(900)
	text = NULL$(900)
	cpuinfo(#winMain,#winMain,&text,&parm,1,0)
	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION STRING _osinfo()
	STATIC STRING text,parm


	parm = NULL$(900)
	text = NULL$(900)
	osinfo(#winMain,#winMain,&text,&parm,1,0)
	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION STRING _membar()
	STATIC STRING text,parm


	parm = NULL$(900)
	text = NULL$(900)
	meminfo(#winMain,#winMain,&text,&parm,1,0)
	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION STRING _rambar()
	STATIC STRING text,parm


	parm = NULL$(900)
	text = NULL$(900)
	rambar(#winMain,#winMain,&text,&parm,1,0)
	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION STRING _uptime()
	STATIC STRING text,parm


	parm = NULL$(900)
	text = NULL$(900)
	uptime(#winMain,#winMain,&text,&parm,1,0)
	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION STRING _version ()
	STATIC STRING text,parm


	parm = NULL$(900)
	text = NULL$(900)
	version(#winMain,#winMain,&text,&parm,1,0)
	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION STRING _gfxinfo ()
	STATIC STRING text,parm


	RETURN _ATI_ASIC("Chip ID")+", "+_ATI_Memory("Size")+" "+_ATI_Memory("Type")+", "+_ATI_PCI("AGP Transfer Rate")+", "+_ATI_ASIC("Aperture Config")+" Aperture"

'	parm = NULL$(900)
'	text = NULL$(900)
'	gfxinfo(#winMain,#winMain,&text,&parm,1,0)
'	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION STRING _testing ()
	STATIC STRING text,parm


	parm = NULL$(900)
	text = NULL$(900)
	testing (#winMain,#winMain,&text,&parm,1,0)
	RETURN CSTRING$(&text)
END FUNCTION

FUNCTION CPrint (edit,STRING msg)
	
	msg = TRIM$(msg)
	IFZ msg THEN RETURN $$FALSE
	DispatchDCTMsg ($$MDCT_PrvTxtMsg,STRING$(edit),@msg) 
END FUNCTION

FUNCTION SendMsg (STRING msg)

	msg = TRIM$(msg)
	DispatchDCTMsg ($$MDCT_SendPubTxt,@msg,"")
END FUNCTION

FUNCTION STRING GetHubNick ()
	SHARED STRING Nick

	RETURN "<"+Nick+">"
END FUNCTION


FUNCTION STRING GetNick ()
	SHARED STRING Nick

	RETURN Nick
END FUNCTION

FUNCTION DispatchDCTMsg (token, STRING msg1, STRING msg2)
	SHARED FUNCADDR DDCTM (XLONG,STRING,STRING)

	RETURN @DDCTM (token,@msg1,@msg2)
END FUNCTION

FUNCTION STRING _ATI_PCI (STRING Ver)
	STRING value
	
	ReadReg ($$HKEY_LOCAL_MACHINE,$$REG_SZ, $$ATIPCI,Ver,@value)
	RETURN TRIM$(GetTokenExB (@value,'(',0))
END FUNCTION

FUNCTION STRING _ATI_ASIC (STRING Ver)
	STRING value
	
	ReadReg ($$HKEY_LOCAL_MACHINE,$$REG_SZ, $$ATIASIC,Ver,@value)
	RETURN TRIM$(GetTokenExB (@value,'(',0))
END FUNCTION

FUNCTION STRING _ATI_Memory (STRING Ver)
	STRING value
	
	ReadReg ($$HKEY_LOCAL_MACHINE,$$REG_SZ, $$ATIMEMORY,Ver,@value)
	RETURN TRIM$(GetTokenExB (@value,'(',0))
END FUNCTION

FUNCTION STRING _ATI_BIOS (STRING Ver)
	STRING value
	
	ReadReg ($$HKEY_LOCAL_MACHINE,$$REG_SZ, $$ATIBIOS,Ver,@value)
	RETURN TRIM$(GetTokenExB (@value,'(',0))
END FUNCTION

FUNCTION STRING _ATI_Driver(STRING Ver)
	STRING value
	
	ReadReg ($$HKEY_LOCAL_MACHINE,$$REG_SZ, $$ATIDRIVER,Ver,@value)
	RETURN GetTokenExB (@value,32,0)
END FUNCTION

FUNCTION ReadReg (root,ktype,STRING subkey, STRING key, STRING value)


	hKey = $$APINULL
	IF RegOpenKeyExA (root, &subkey, 0, $$KEY_QUERY_VALUE, &hKey) == $$ERROR_SUCCESS THEN
		vsize = 64
		value = SPACE$(vsize)
		RegQueryValueExA(hKey, &key, 0, 0,&value, &vsize)
		value = LEFT$(value,vsize)
		RegCloseKey(hKey)
		RETURN $$TRUE
	ELSE
		RETURN $$FALSE
	END IF
	
END FUNCTION

FUNCTION WriteReg (root,ktype, STRING subkey, STRING key, STRING value)


	hKey = $$APINULL
	class$ = ""
	IFZ RegCreateKeyExA (root, &subkey, 0, &class$, 0, $$KEY_WRITE, NULL, &hKey, &neworused) THEN
		ret = RegSetValueExA (hKey, &key, 0, ktype, &value, SIZE(value))
		RegCloseKey (hKey)
		RETURN $$TRUE
	ELSE
		RETURN $$FALSE
	END IF
	
END FUNCTION

END PROGRAM

