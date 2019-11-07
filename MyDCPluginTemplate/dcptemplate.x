

PROGRAM	"dcptemplate"
VERSION	"0.20"
MAKEFILE "xdll.xxx"

	IMPORT "gdi32"
	IMPORT "user32"
	IMPORT "MyDC.dec"
'	IMPORT "dcutils"

'	IMPORT "kernel32"
'	IMPORT "shell32"
'	IMPORT "msvcrt"
	

$$PluginTitle = "MyDC Plugin Template"

'DECLARE FUNCTION DllMain (a,b,c)
DECLARE FUNCTION DllEntry ()

EXPORT
DECLARE FUNCTION DllExit ()
DECLARE FUNCTION DllStartup (TDCPlugin dcp)
DECLARE FUNCTION DllProc (token, STRING msg1, STRING msg2)
END EXPORT

DECLARE FUNCTION SendMsg (STRING msg)
DECLARE FUNCTION DispatchDCTMsg (token, STRING msg1, STRING msg2)
DECLARE FUNCTION CPrint (edit,STRING msg)
DECLARE FUNCTION STRING GetHubNick ()
DECLARE FUNCTION STRING GetNick ()



'FUNCTION DllMain (a,reason,c)
FUNCTION DllEntry ()


	RETURN 1	
END FUNCTION

FUNCTION DllExit ()
	' this function will be called when exiting plugin and must exist even if a cleanup is not required

END FUNCTION

FUNCTION DllStartup (TDCPlugin dcp)
	SHARED FUNCADDR DDCTM (XLONG,STRING,STRING)
	

	Server$ = CSTRING$(dcp.lpserver)
	Port = dcp.port
	Nick$ = CSTRING$(dcp.lpnick)
	
	dcp.pDllExit = &DllExit()
	dcp.pDllFunc = &DllProc()
	dcp.lpPluginTitle = &$$PluginTitle
	DDCTM = dcp.lpDDCTM

END FUNCTION

FUNCTION DllProc (token, STRING msg1, STRING msg2)
	STATIC STRING text


	SELECT CASE token
		CASE $$MDCT_ClientJoin		:
			text = "* "+msg1+ " has joined in on the fun"
			CPrint ($$Hub,@text)
			RETURN $$MDCTH_HandledCont

		CASE $$DCT_Quit				:
			text = "* "+msg1+ " has left us"
			CPrint ($$Hub,@text)
			RETURN $$MDCTH_HandledCont
	END SELECT

	RETURN $$MDCTH_UnhandledCont
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

FUNCTION DispatchDCTMsg (token, STRING msg1, STRING msg2)
	SHARED FUNCADDR DDCTM (XLONG,STRING,STRING)

	RETURN @DDCTM (token,@msg1,@msg2)
END FUNCTION

FUNCTION STRING GetHubNick ()
	SHARED STRING Nick

	RETURN "<"+Nick+">"
END FUNCTION


FUNCTION STRING GetNick ()
	SHARED STRING Nick

	RETURN Nick
END FUNCTION

END PROGRAM

