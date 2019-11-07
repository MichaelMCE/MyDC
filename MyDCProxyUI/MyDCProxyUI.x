'
'
'	a GUI for the MyDC Proxy.
'
'	first connect to the MyDC proxy (default port is 401):
'	"/proxy address port"
'	from here select a nickname then connect to a hub.
'	"/nick mynickname"
'	"/connect address port"
'	see below for other commands (there are quite a few)
'
'
PROGRAM	"MyDCUI"
VERSION	"0.50"
'MAKEFILE "xdll.xxx"
' CONSOLE

	'IMPORT "xio"
	IMPORT "kernel32"
	IMPORT "msvcrt"
	IMPORT "gdi32"
	IMPORT "user32"
	IMPORT "shell32"
	IMPORT "comctl32"
	IMPORT "comdlg32"
	IMPORT "wsock32"
	IMPORT "advapi32"
'	IMPORT "zlib"

	IMPORT "MyDC.dec"
	IMPORT "dcutils"
	'IMPORT "xsx"


$$PluginTitle = "MyDC Proxy GUI 0.50"

$$ZSocketBuffer		= 132000

$$Tab1				= 120
$$ListView1			= 121
$$Splitter1			= 122
$$PopUp_Exit		= 134
$$PopUp_1			= 135
'$$WindowStatus		= 135


$$EDITBOX_RETURN	= 401
$$EDITBOX_TAB		= 402


$$HubTitle			= 2000

$$LBUFFER_MAX = 132000		' listening buffer size.
							' size of buffer really depends on data expected from host.
							' eg, IRC protocol states buffersize of 512 bytes

$$SOCK_TCP = $$SOCK_STREAM
$$SOCK_UDP = $$SOCK_DGRAM

$$INTERNET_FLAG_RELOAD = 0x80000000
$$INTERNET_OPEN_TYPE_PRECONFIG = 0
$$INTERNET_FLAG_EXISTING_CONNECT = 0x20000000

$$Listen_Port = 22

' define custom window messages
$$WM_SET_SPLITTER_PANEL_HWND    = 1025		' this msg MUST be called, wParam = left/top panel hWnd, lParam = right/bottom panel hWnd
$$WM_SET_SPLITTER_MIN_PANEL_SIZE= 1026		' wParam = left/top panel minimum size, lParam = right/bottom panel minimum size
$$WM_SET_SPLITTER_SIZE          = 1027		' size of splitter panel, wParam = 0, lParam = width/height of splitter panel in pixels
$$WM_SET_SPLITTER_STYLE         = 1028		' splitter control style, wParam = 0, lParam = style flag (default = $$SS_HORZ)
$$WM_SET_SPLITTER_POSITION      = 1029		' splitter position, wParam = x position (for $$SS_HORZ style), lParam = y position (for $$SS_VERT style), only one arg is necessary
$$WM_GET_SPLITTER_POSITION      = 1030		' return is current splitter panel position
$$WM_GET_SPLITTER_MIN_SIZE      = 1031		' return is minimum splitter control size (splitterSize + minPanel1Size + minPanel2Size)
$$WM_SPITTER_BAR_MOVED          = 1032		' this message is sent to splitter parent after splitter bar has been moved

$$WM_TRAYICON					= 1035


$$SR_USER		= 0
$$SR_FILENAME	= 1
$$SR_SIZE		= 2
$$SR_SLOTS		= 3
$$SR_FILEPATH	= 4
$$SR_HUB		= 5

$$Filter_URL	= 1
$$Filter_NAME	= 2
$$Filter_DC		= 3

$$POPURL_Open	= 180
$$POPURL_Copy	= 181
$$POPURL_Save	= 182

$$POPHUB_Copy	= 185
$$POPHUB_SelAll = 186

$$EM_SETLIMITTEXT = 197
$$LB_INITSTORAGE  = 424


$$RTFHEADER = "{\\rtf1\\ansi\\deff0{\\fonttbl{\\f0\\froman\\fprq2\\fcharset0 Comic Sans MS;}}{\\colortbl ;\\red70\\green70\\blue70;\\red10\\green30\\blue70;}\\viewkind4\\uc1\\pard\\ri24\\lang1033\\f0\\cf1\\fs20\\b0 "

'$$RTFHEADER = "{\\rtf1\\ansi\\deff0{\\fonttbl{\\f0\\froman\\fprq2\\fcharset0 Comic Sans MS;}}{\\colortbl ;\\red200\\green200\\blue200;\\red170\\green180\\blue200;}\\viewkind4\\uc1\\pard\\ri24\\lang1033\\f0\\cf1\\fs20\\b0 "
'$$RTFHEADER = "{\\rtf1\\ansi\\deff0{\\fonttbl{\\f0\\froman\\fprq2\\fcharset0 Comic Sans MS;}}{\\colortbl ;\\red90\\green90\\blue90;\\red35\\green40\\blue60;}\\viewkind4\\uc1\\pard\\ri24\\lang1033\\f0\\cf1\\fs20\\b0 "
'$$RTFHEADER = "{\\rtf1\\ansi\\deff0{\\fonttbl{\\f0\\froman\\fprq2\\fcharset0 MS Sans Serif;}}{\\colortbl ;\\red100\\green100\\blue100;\\red65\\green70\\blue80;}\\viewkind4\\uc1\\pard\\ri24\\lang1033\\f0\\cf1\\fs20\\b1 "
'$$RTFHEADER = "{\\rtf1\\ansi\\deff0{\\fonttbl{\\f0\\froman\\fprq2\\fcharset0 Comic Sans MS;}}{\\colortbl ;\\red100\\green100\\blue100;\\red65\\green70\\blue80;}\\viewkind4\\uc1\\pard\\ri24\\lang1033\\f0\\cf1\\fs20\\b1 "
$$NEWLINE = "\\par "  ' ie, \r\n


$$AW_HOR_POSITIVE = 0x00000001
$$AW_HOR_NEGATIVE = 0x00000002
$$AW_VER_POSITIVE = 0x00000004
$$AW_VER_NEGATIVE = 0x00000008
$$AW_CENTER = 0x00000010
$$AW_HIDE = 0x00010000
$$AW_ACTIVATE = 0x00020000
$$AW_SLIDE = 0x00040000
$$AW_BLEND = 0x00080000

$$MSGWINCLASSNAME = "MyDCPM"

$$WM_MSG_CREATE		= 1300
$$WM_MSG_SETCLIENTS	= 1301
$$WM_MSG_SETTEXT	= 1302
$$WM_MSG_GETTEXT	= 1303


$$MsgEdit			= 101
$$MsgCmd			= 102

$$SPLITTERCLASSNAME = "splitterctrl"
' define splitter styles
$$SS_HORZ = 0
$$SS_VERT = 1

$$CL_NAME		= 0
$$CL_SHARED		= 1
$$CL_COMMENT	= 2
$$CL_TAG		= 3
$$CL_CONNECTION	= 4
$$CL_EMAIL		= 5
$$CL_Op			= 6

TYPE LPINITCOMMONCONTROLSEX
	XLONG	.size
	XLONG	.icc
END TYPE

TYPE TRECT
  XLONG     .left
  XLONG     .top
  XLONG     .right
  XLONG     .bottom
END TYPE

TYPE SPLITTERDATA
	XLONG	.hWndParent			' handle of parent window
	XLONG	.hWnd1				' handle to contained window 1 (left or top)
	XLONG	.hWnd2				' handle to contained window 2 (right or bottom)
	XLONG	.wnd1MinSize		' window 1 minimum size allowed
	XLONG	.wnd2MinSize		' window 2 minimum size allowed
	XLONG	.style				' splitter style ($$SS_HORZ or $$SS_VERT)
	XLONG	.splitterSize		' size of the splitter bar in pixels
	XLONG	.hStatic			' handle of static control used as splitter panel
	XLONG	.id					' static control id
END TYPE

TYPE TMsgWin
	XLONG		.hwin
	XLONG		.hedit
	XLONG		.hcmd
	XLONG		.hcmdsubproc
	XLONG		.heditsubproc
	XLONG		.hIcon
	XLONG		.TChars
	STRING * 64 .title
	STRING * 32 .from
	STRING * 32 .to
END TYPE

PACKED TBUFFER
	XLONG 	.size
	UBYTE	.buffer[65530]
END TYPE

'DECLARE FUNCTION DllMain (a,b,c)
DECLARE FUNCTION DllEntry ()

EXPORT
DECLARE FUNCTION DllExit ()
DECLARE FUNCTION DllStartup (TDCPlugin dcp)
DECLARE FUNCTION DllProc (token, STRING msg1, STRING msg2)
END EXPORT

DECLARE FUNCTION Splitter ()
DECLARE FUNCTION SplitterProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION StaticProc (hWnd, msg, wParam, lParam)

DECLARE FUNCTION InitGUI ()
DECLARE FUNCTION WndProc (hwnd, msg, wParam, lParam)
DECLARE FUNCTION CenterWindow (hwnd)
DECLARE FUNCTION InitGui ()
DECLARE FUNCTION RegisterWinClass (className$, titleBar$)
DECLARE FUNCTION CreateWindows ()
DECLARE FUNCTION NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
DECLARE FUNCTION NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
DECLARE FUNCTION MessageLoop ()
DECLARE FUNCTION CreateCallbacks ()
DECLARE FUNCTION GetNotifyMsg (lParam, hwndFrom, idFrom, code)
DECLARE FUNCTION urlcatchProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION CListViewProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION HubProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION CmdProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION SerProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION SetColor (txtColor, bkColor, wParam, lParam)
DECLARE FUNCTION NewFont (fontName$, pointSize, weight, italic, underline)
DECLARE FUNCTION SetNewFont (hwndCtl, hFont)
DECLARE FUNCTION CleanUp ()
DECLARE FUNCTION SetTaskbarIcon (hWnd, iconName$, tooltip$)
DECLARE FUNCTION DeleteTrayIcon (hWnd)
DECLARE FUNCTION SetEditText (idx, STRING text)
DECLARE FUNCTION ClearEditText (edit)
DECLARE FUNCTION AddListViewColumn (hwndCtl, iCol, width, heading$)
DECLARE FUNCTION RGB (r, g, b)
DECLARE FUNCTION UpdateTitle ()
DECLARE FUNCTION UpdateTitleEx ()
DECLARE FUNCTION AddClient (STRING username, STRING info)
DECLARE FUNCTION AddClients (STRING ctotal)
DECLARE FUNCTION GetTabChild (htabc)
DECLARE FUNCTION SetTabChild (htabc,handle)
DECLARE FUNCTION AddEditTabChild (hparent,STRING title,IDC)
DECLARE FUNCTION AddSplitTabChild (hparent,STRING title,IDC)
DECLARE FUNCTION AddListViewTabChild (hparent,STRING title,IDC)
DECLARE FUNCTION SearchResult (STRING result)
DECLARE FUNCTION RemoveClients ()
DECLARE FUNCTION RemoveClient (STRING user)
DECLARE FUNCTION InsertListViewItem (hwndCtl,pos, STRING item)
DECLARE FUNCTION SetListViewSubItem (hwndCtl, iColumn, STRING text, item)
DECLARE FUNCTION FindListViewItem (hwndCtl,start,STRING item)
DECLARE FUNCTION STRING GetListViewItem (hwndCtl,i)
DECLARE FUNCTION UpdateListBox (hctrl)

DECLARE FUNCTION CCmdNick (nick$)
DECLARE FUNCTION CCmdConnect (STRING address,port)
DECLARE FUNCTION CCmdReconnect ()
DECLARE FUNCTION CCmdDisconnect ()
DECLARE FUNCTION CCmdMsg (STRING to, STRING from, STRING text)

DECLARE FUNCTION ConnectToServer (STRING address,port)			' connect to address on port, return socket success, zero if fail
DECLARE FUNCTION InitNewCmd (hwndCtl,STRING msg)
DECLARE FUNCTION HubChat (STRING text)

DECLARE FUNCTION CPrint (EditControl,STRING text)				' print text to an edit control
DECLARE FUNCTION urlCatch (STRING url)							' record and log url
DECLARE FUNCTION urlOpen (STRING url)							' open url in new browser
DECLARE FUNCTION LaunchBrowser (STRING url)						' launch url
DECLARE FUNCTION urlList (starturl)								' relist url's
DECLARE FUNCTION filterFind (STRING str,STRING text,offset)		' search string for text beginning at offset
DECLARE FUNCTION filterMessage (message$,text$,action)

DECLARE FUNCTION ProcessClientText (addrtext)
DECLARE FUNCTION ClientQuit (STRING user)
DECLARE FUNCTION ClientJoin (STRING user)

DECLARE FUNCTION SendMsgToHub (STRING msg)
DECLARE FUNCTION AddClientFull (STRING list, total)
DECLARE FUNCTION STRING GetHubNick ()
DECLARE FUNCTION STRING GetNick ()
DECLARE FUNCTION STRING DisplayNick (STRING nick)
DECLARE FUNCTION STRING GetNumIPAddr (IPName$)
DECLARE FUNCTION ProcessClientCommand (cmd$,msg$)
DECLARE FUNCTION SetHubShare (SINGLE share)
DECLARE FUNCTION SetHubName (STRING name)
DECLARE FUNCTION SetTotalUsers (XLONG total)
DECLARE FUNCTION FileSearch (STRING who, STRING result)
DECLARE FUNCTION getLastSlash(str$, stop)
DECLARE FUNCTION DecomposePathname (pathname$, @path$, @parent$, @filename$, @file$, @extent$)

DECLARE FUNCTION MAKELONG (lo, hi)
DECLARE FUNCTION HIWORD (x)
DECLARE FUNCTION LOWORD (x)

DECLARE FUNCTION SetConSocket (socket)
DECLARE FUNCTION GetConSocket ()
DECLARE FUNCTION DispatchDCTMsg (token, STRING msg1, STRING msg2)

DECLARE FUNCTION MessagePump (socket, STRING message)		' each message ends with |
DECLARE FUNCTION ProcessToken (socket, STRING message)

DECLARE FUNCTION ListenBin (socket,ANY,tbytes)
DECLARE FUNCTION ListenMsg (socket)
DECLARE FUNCTION SendBin (socket,bufferaddr,tbytes)
DECLARE FUNCTION SendMsg (socket,STRING buffer)

DECLARE FUNCTION SocketInitWinSock()
DECLARE FUNCTION SocketOpen (sockettype)
DECLARE FUNCTION SocketConnect (socket,STRING address,port)
DECLARE FUNCTION SocketRecv (socket,ANY,totalbytes)
DECLARE FUNCTION SocketSend (socket,address,totalbytes)
DECLARE FUNCTION SocketClose (socket)
DECLARE FUNCTION SocketBind (socket,STRING address,port)
DECLARE FUNCTION SocketListen (socket)
DECLARE FUNCTION SocketAccept (socket,STRING claddress,clport)
DECLARE FUNCTION MDCT_Disconnected ()

DECLARE FUNCTION TimerShare (id,count,msec,time)
DECLARE FUNCTION  CreateRichEdit (x, y, w, h, hParent, id, kbTextMax)
DECLARE FUNCTION AddRichEditTabChild (hparent,STRING title,IDC,style)
DECLARE FUNCTION  GetRegKey (key, subkey$, @retdata$)
DECLARE FUNCTION SetClipText (STRING text)

DECLARE FUNCTION URL_GetFile (URL$,TBUFFER buff[])
DECLARE FUNCTION URL_SaveFile (STRING filename,TBUFFER buff[])
DECLARE FUNCTION open_file (pfilename, flags)
DECLARE FUNCTION close_file (file)
DECLARE FUNCTION write_file (hfile,ULONG buffer,nbytes)
DECLARE FUNCTION ShowSaveFileDialog (hWndOwner, fileName$, filter$, initDir$, title$)
DECLARE FUNCTION GetURL (STRING URLBuffer)

DECLARE FUNCTION STRING RTF_Highlight (STRING text)
DECLARE FUNCTION STRING StripRTF (STRING text)
DECLARE FUNCTION STRING GetText(hWnd)
DECLARE FUNCTION SetText(hWnd,STRING text)
DECLARE FUNCTION SelectTab (iTab)

DECLARE FUNCTION MsgWindow ()
DECLARE FUNCTION MsgWindowProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION MsgWindowCmdProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION MsgWindowEditProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION SleepMsg (time)

'FUNCTION DllMain (a,reason,c)
FUNCTION DllEntry ()
	SHARED FUNCADDR DDCTM (XLONG,STRING,STRING)
	STATIC ENTERONCE
	SHARED ShowJQ
	SHARED MsgScroll
	SHARED TIMESTAMP
	SHARED SHOWSEARCH
	SHARED STRING Nick,Server
	SHARED DISCONCE


	IF ENTERONCE THEN
		RETURN $$FALSE
	ELSE
		ENTERONCE = 1
	END IF
	
	TIMESTAMP	= $$FALSE
	SHOWSEARCH	= $$FALSE
	DEBUG		= $$FALSE
	ShowJQ		= $$TRUE
	MsgScroll	= $$TRUE
	DISCONCE	= 1

	#WindowCreated = $$FALSE
	'#hThread = _beginthreadex (NULL, 0, &InitGUI(), 0, 0, &tid)
	
	SocketInitWinSock ()
	InitGUI()

	RETURN 0
END FUNCTION

FUNCTION DllExit ()
	' this function will be called when exiting plugin and must exist even if a cleanup is not required
	'CleanUp()
END FUNCTION

FUNCTION DllStartup (TDCPlugin dcp)

END FUNCTION

FUNCTION DispatchDCTMsg (token, STRING msg1, STRING msg2)
	STRING buffer
	

	IFZ msg1 THEN msg1 = " "
	IFZ msg2 THEN msg2 = " "
	buffer = CHR$($$PCCA) + STRING$(token)+ CHR$($$PCCB)+msg1+ CHR$($$PCCC)+msg2+ CHR$($$PCCD)
	SendBin (GetConSocket(),&buffer,SIZE(buffer))
	
	RETURN $$MDCTH_UnhandledCont
END FUNCTION

FUNCTION DllProc (token, STRING msg1, STRING msg2)
	STATIC STRING text
	SHARED CONNECTED
	SHARED STRING Nick,Server
	SHARED Port
	SHARED DEBUG
	SHARED DISCONCE
	

	IFT DEBUG CPrint ($$Debug,STRING$(token)+" "+msg1+" : "+msg2)
	
	SELECT CASE token
		CASE $$MDCT_InitiatingConn	:
			CPrint ($$Hub,$$NEWLINE+"* connecting to "+msg2)
			RETURN $$MDCTH_HandledCont

		CASE $$MDCT_InitiatingDisconn	:
			IFT #ConnToHub THEN
				CPrint ($$Hub,"* disconnecting from hub.. "+msg1)
			END IF
		'	SocketClose (GetConSocket())  
		'	SetConSocket (0)
		'	#ConnToHub = $$FALSE
			MDCT_Disconnected()
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_Disconnected	:
			IFT #ConnToHub THEN
				CPrint ($$Hub,$$NEWLINE+"* "+GetTime()+": disconnected from hub")
			END IF
			#ConnToHub = $$FALSE
			MDCT_Disconnected()
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_RequestShutDown	:
			SocketClose (GetConSocket())  
			SetConSocket (0)
			#ConnToHub = $$FALSE
			MDCT_Disconnected()
			CPrint ($$Hub,"* "+msg1)
			CPrint ($$Hub,$$NEWLINE+"* "+GetTime()+": disconnected from proxy")
			RETURN $$MDCTH_HandledCont
		
		CASE $$DCT_Search			:
			FileSearch (@msg1,@msg2)
			RETURN $$MDCTH_HandledCont
			
		CASE $$DCT_SR				:
			SearchResult (@msg1)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_ClientConnected	:
			DISCONCE = 0
			Nick = GetTokenEx2 (@msg2,':')
			Server = GetTokenEx2 (@msg2,':')
			Port = XLONG(GetTokenEx2 (@msg2,':'))
'			socket = XLONG(msg1)
			#ConnToHub = $$TRUE
			CPrint ($$Hub,"* connected to "+Server+" on port "+STRING$(Port)+ $$NEWLINE + $$NEWLINE)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_PubCmdMsg		:
			CPrint ($$Hub,DisplayNick(@msg1)+" "+StripRTF(msg2))
			RETURN $$MDCTH_HandledCont
					
		CASE $$MDCT_PrvTxtMsg		:
			CPrint (XLONG(msg1),@msg2)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_PubTxtMsg		:
			CPrint ($$Hub,DisplayNick(@msg1)+" "+StripRTF(msg2))
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_PMTxtMsg		:	' pm from another user sent via hub
			CCmdMsg (GetNick(),@msg1,StripRTF(msg2))
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_PMCmdMsg		:	' pm cmd from another user sent via hub
			CCmdMsg (GetNick(),@msg1,StripRTF(msg2))
			RETURN $$MDCTH_HandledCont

		CASE $$MDCT_SendPMsg		:	' pm to a user sent from this client
			CCmdMsg (@msg1,GetNick(),StripRTF(msg2))
			RETURN $$MDCTH_UnhandledCont
			
		
		CASE $$MDCT_NickList		:
			RemoveClients()
			SetTotalUsers (XLONG(msg2))
			UpdateTitle ()
			AddClients (@msg1)
			RETURN $$MDCTH_HandledCont
		
		CASE $$MDCT_ClientJoinAll		:
			IF AddClient (@msg1,@msg2) THEN ClientJoin (@msg1)
			RETURN $$MDCTH_HandledCont

		CASE $$DCT_Quit				:
			RemoveClient (msg1)
			ClientQuit (msg1)
			UpdateTitle ()
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_NickListTotal	:
			SetTotalUsers (XLONG(msg1))
			UpdateTitle ()
			RETURN $$MDCTH_HandledCont
	
		CASE $$MDCT_HubShareTotal	:
			SetHubShare(SINGLE(msg1))
			SetTotalUsers (XLONG(msg2))
			UpdateTitle ()

		CASE $$MDCT_HubUsers		:
			SetTotalUsers (XLONG(msg1))
			UpdateTitle()
			RETURN RETURN $$MDCTH_HandledCont
			
		CASE $$DCT_HubName			:
			IF msg1 THEN
				SetHubName (@msg1)
				UpdateTitle ()
				RETURN $$MDCTH_HandledCont
			ELSE
				RETURN $$MDCTH_UnhandledCont
			END IF
		 
		CASE $$MDCT_MyShareSize		:
			CPrint ($$Hub,"* share set to "+msg1)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_ClientOpJoin	:
			CPrint ($$Hub,"* Operators are:"+RTF_Highlight(msg1)) '+ $$NEWLINE)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_IntNickList		:
			RemoveClients()
			SetTotalUsers (XLONG(msg2))
			UpdateTitle ()
			AddClientFull (@msg1,XLONG(msg2))
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_UnknownCmd		:
			CPrint ($$Hub,"* unknown command: "+msg1+" "+msg2)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_PluginLoaded	:
			'CPrint ($$Hub,"* Plugin loaded: "+msg1)
			CPrint ($$Hub,"* Plugin #"+GetTokenEx2(@msg2,':')+":"+msg1)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_PluginUnloaded	:
			CPrint ($$Hub,"* Plugin unloaded: "+msg1)
			RETURN $$MDCTH_HandledCont
			
		CASE $$DCT_HubINFO			:
			CPrint ($$Hub,"* HubINFO: "+msg1)
			
		CASE $$MDCT_Error			:
			CPrint ($$Debug,"* "+msg1+" "+msg2)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_Plugin			:
			'CPrint ($$Hub,"* Plugin #"+GetTokenEx2(@msg2,':')+" loaded: "+msg2)
			CPrint ($$Hub,"* Plugin loaded: #"+GetTokenEx2(@msg2,':')+":"+msg2)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_Debug			:
			CPrint ($$Debug,"::::--"+msg1+"-- --"+msg2+"--")
			RETURN $$MDCTH_HandledCont

		CASE $$DCT_UserCommand
			CPrint ($$Hub,"User command: "+StripRTF(msg1)+" "+StripRTF(msg2))
			RETURN $$MDCTH_HandledCont

		CASE $$DCT_Unknown			:
			CPrint ($$Hub,""+StripRTF(msg1)+" "+StripRTF(msg2))
			RETURN $$MDCTH_HandledCont
	END SELECT

	RETURN $$MDCTH_UnhandledCont
END FUNCTION

FUNCTION SetTotalUsers (XLONG total)
	SHARED STRING TotalHubUsers
	
	IF total > 0 THEN
		TotalHubUsers = STRING$(total)
	ELSE
		TotalHubUsers = "0"
	END IF
	
END FUNCTION

FUNCTION SetHubName (STRING name)
	SHARED STRING HubName

	HubName = name
END FUNCTION

FUNCTION SetHubShare (SINGLE share)
	SHARED STRING HubShare

	IF share > SINGLE(0.001) THEN
		HubShare = LTRIM$(FORMAT$("####.##",share))
	ELSE
		HubShare = "0"
	END IF

END FUNCTION			

FUNCTION ProcessClientCommand (STRING cmd,msg$)
	SHARED STRING Password
	SHARED STRING FShared
	SHARED SHOWSEARCH
	SHARED MsgScroll
	SHARED TIMESTAMP
	SHARED DEBUG
	SHARED ShowJQ


	cmd = LCASE$(TRIM$(cmd))
	SELECT CASE cmd
		CASE "oplist"		:DispatchDCTMsg ($$MDCT_GetOpList,"","")
		CASE "shutdown"		:DispatchDCTMsg ($$MDCT_RequestShutDown,"","")
		CASE "proxwork"		:ConnectToServer ("192.168.1.42",401)
		CASE "proxlocal"	:ConnectToServer ("localhost",222)
		CASE "proxy"		:IFZ msg$ THEN
							 	ConnectToServer ("10.0.0.2",401)
							 ELSE
							 	ConnectToServer (GetTokenEx2(@msg$,32),XLONG(msg$))
							 END IF
		CASE "intlist"		:'RemoveClients()
							 DispatchDCTMsg ($$MDCT_GetIntNickListFull,"","")
							 
							 
		CASE "nicklist"		:'RemoveClients()
							 DispatchDCTMsg ($$MDCT_GetIntNickList,"","")
		CASE "ul"			:DispatchDCTMsg ($$MDCT_Unload,TRIM$(msg$),"")
		CASE "showsearch"	:IFT SHOWSEARCH THEN
							 	SHOWSEARCH = $$FALSE
							 	CPrint ($$Hub,"* filesearch off")
							 ELSE
								SHOWSEARCH = $$TRUE
								CPrint ($$Hub,"* filesearch on")
							 END IF
		CASE "share"		:FShared = "147198295245"
							 DispatchDCTMsg ($$MDCT_SetMyShareSize,FShared,"")
		CASE "time"			:CPrint ($$Hub,"* current time is "+GetTime())
		CASE "timestamp"	:IFT TIMESTAMP THEN
							 	TIMESTAMP = $$FALSE
							 	CPrint ($$Hub,"* timestamp off")
							 ELSE
								TIMESTAMP = $$TRUE
								CPrint ($$Hub,"* timestamp on")
							 END IF
		CASE "me"			:DispatchDCTMsg ($$MDCT_SendPubTxt,"!me "+msg$,"")
		CASE "debug"		:IFT DEBUG THEN
							 	DEBUG = $$FALSE
							 	CPrint ($$Hub,"* debug off")
							 ELSE
							 	DEBUG = $$TRUE
							 	CPrint ($$Hub,"* debug on")
							 END IF
		CASE "urllist"		:urlList (XLONG(TRIM$(msg$)))
		CASE "url"			:urlOpen (msg$)
		CASE "search"		:SendMessageA (#SResultList, $$LVM_DELETEALLITEMS,0 ,0)
							 file$ = replace(TRIM$(msg$),' ','$')
							 DispatchDCTMsg ($$MDCT_SendFileSearch,"",file$)
		CASE "scroll"		:IFT MsgScroll THEN
							 	CPrint ($$Hub,"* message scroll off")
							 	MsgScroll = $$FALSE
							 ELSE
							 	MsgScroll = $$TRUE
							 	CPrint ($$Hub,"* message scroll on")
							 END IF
		CASE "joins"		:IFT ShowJQ THEN
							 	ShowJQ = $$FALSE
							 	CPrint ($$Hub,"* display joins off")
							 ELSE
							 	ShowJQ = $$TRUE
							 	CPrint ($$Hub,"* display joins on")
							 END IF
		CASE "clear","cls"	:ClearEditText ($$Hub)
							:ClearEditText ($$Debug)
		CASE "refresh"		:CPrint ($$Hub,"* refreshing user list")
							 'RemoveClients ()
							 UpdateTitle ()
							 RETURN $$FALSE
		CASE "password"		:IF TRIM$(msg$) THEN
							 	Password = TRIM$(msg$)
							 	DispatchDCTMsg ($$MDCT_SetPassword,Password,"")
							 	CPrint ($$Hub,"* password set")
							 ELSE
							 	CPrint ($$Hub,"* password unset")
							 END IF
		CASE "nick"			:CCmdNick (TRIM$(msg$))
		CASE "connect"		:replace (@msg$,':',' ')
							 msg$ = TRIM$(msg$)
							 ip$ = GetTokenEx2 (@msg$,32)
							 port = XLONG(GetTokenEx2 (TRIM$(msg$),32))
							 CCmdConnect (ip$,port)
		CASE "reconnect"	:CCmdReconnect ()
		CASE "disconnect"	:CCmdDisconnect ()
		CASE "msg","pm"		:to$ = GetTokenEx2 (@msg$,32)
							 i = FindListViewItem (#hInfoListV,-1,@to$)
							 IF (i == -1) THEN
							 	CPrint ($$Hub,"* "+to$+" is not here")
							 ELSE
							 	to$ = GetListViewItem (#hInfoListV,i) ' names are case sensitive
							 	DispatchDCTMsg ($$MDCT_SendPMsg,@to$,@msg$)
							 END IF
		CASE "big"			:FShared = "97198295245"
							 DispatchDCTMsg ($$MDCT_SetMyShareSize,FShared,"")
							 ShowJQ = $$FALSE
							 CPrint ($$Hub,"* display joins off")
							 CCmdConnect ("maximum-big.no-ip.com", 411)
		CASE "maxspeed"		:CCmdConnect ("Maximumspeed3.no-ip.org", 411)
		CASE "rage3d"		:CCmdConnect ("rage3dhub.no-ip.org", 6666)
		CASE "db"			:CCmdConnect ("jattfx.dbhubz.com", 4111)
		CASE "pool"			:CCmdConnect ("8ball.is-a-geek.com", 27015)
		CASE "local"		:CCmdConnect ("localhost", 223)
		CASE ELSE			:RETURN $$FALSE
	END SELECT
	
	RETURN $$TRUE
END FUNCTION

FUNCTION GetConSocket ()
	SHARED socket
	
	RETURN socket
END FUNCTION

FUNCTION SendMsgToHub (STRING text)

	'text = TRIM$(text)+"|"
	text = text + "|"
	RETURN DispatchDCTMsg ($$MDCT_SendBin,text,STRING$(LEN(text)))
END FUNCTION

FUNCTION STRING GetHubNick ()
	SHARED STRING Nick

	RETURN "<"+Nick+">"
END FUNCTION


FUNCTION STRING GetNick ()
	SHARED STRING Nick

	RETURN Nick
END FUNCTION

FUNCTION ClientQuit (STRING user)
	SHARED ShowJQ

	IFZ user THEN RETURN $$FALSE
	IFT ShowJQ THEN CPrint ($$Hub,"Quit: "+RTF_Highlight(user))
END FUNCTION

FUNCTION ClientJoin (STRING user)
	SHARED ShowJQ
	
	IFZ user THEN RETURN $$FALSE
	IFT ShowJQ THEN CPrint ($$Hub,"Join: "+RTF_Highlight(user))
END FUNCTION

FUNCTION STRING RTF_Highlight (STRING text)

	RETURN "\\cf2 "+text+"\\cf1 "
END FUNCTION

FUNCTION STRING DisplayNick (STRING nick)

	RETURN "("+RTF_Highlight(@nick)+")"
END FUNCTION

FUNCTION MsgWindow ()
	STATIC WNDCLASS wc


	hInst = GetModuleHandleA (0)
	wc.style           =  $$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC
	wc.lpfnWndProc     = &MsgWindowProc()
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = SIZE(XLONG)
	wc.hInstance       = hInst
	wc.hIcon           = LoadIconA (hInst, &"msga")
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = GetStockObject ($$LTGRAY_BRUSH)
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &$$MSGWINCLASSNAME

	RETURN RegisterClassA (&wc)
END FUNCTION

FUNCTION Splitter ()
	STATIC WNDCLASS wc
	SHARED hInst


	hInst = GetModuleHandleA (0)
	
	wc.style           = $$CS_GLOBALCLASS | $$CS_HREDRAW | $$CS_VREDRAW | $$CS_PARENTDC
	wc.lpfnWndProc     = &SplitterProc()
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = SIZE(XLONG)
	wc.hInstance       = hInst
	wc.hIcon           = LoadIconA (hInst, &"Hub")
	wc.hCursor         = 0
	wc.hbrBackground   = $$COLOR_BTNFACE + 1
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &$$SPLITTERCLASSNAME

	RETURN RegisterClassA (&wc)
END FUNCTION

FUNCTION MsgWindowProc (hWnd, msg, wParam, lParam)
	CREATESTRUCT cs
	TMsgWin MsgWin
	STRING title,text,user
	STATIC STRING lastcmd,cmd
	STATIC STRING textEdit,textCmd
	SHARED hInst


	SELECT CASE msg
		CASE $$WM_COMMAND :
			id         = LOWORD (wParam)
			notifyCode = HIWORD (wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode
				CASE $$EDITBOX_RETURN	:
					pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
					RtlMoveMemory (&MsgWin, pData, SIZE(TMsgWin))

					IF (MsgWin.hcmd == hwndCtl) THEN
						textCmd = NULL$(4096)
						XLONGAT(&textCmd) = 4096
						SendMessageA (MsgWin.hwin,$$WM_MSG_GETTEXT,&textCmd,$$MsgCmd)
						textCmd = CSTRING$(&textCmd)

						IF (textCmd == "/") THEN
							SendMessageA (MsgWin.hwin,$$WM_MSG_SETTEXT,&lastcmd,$$MsgCmd)
							RETURN 0
						END IF

						IF (MsgWin.to == GetNick()) THEN ' decide who the other user is
							DispatchDCTMsg ($$MDCT_SendPMsg,MsgWin.from,textCmd)
						ELSE
							DispatchDCTMsg ($$MDCT_SendPMsg,MsgWin.to,textCmd)
						END IF

						SendMessageA (MsgWin.hwin,$$WM_MSG_SETTEXT,&"\0",$$MsgCmd)
						lastcmd = textCmd
						RETURN 0
					END IF
			END SELECT

		CASE $$WM_MSG_GETTEXT:
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&MsgWin, pData, SIZE(TMsgWin))

			SELECT CASE lParam
				CASE $$MsgEdit	:
					SendMessageA (MsgWin.hedit, $$WM_GETTEXT, XLONGAT(wParam), wParam)
					RETURN 0
				CASE $$MsgCmd	:
					SendMessageA (MsgWin.hcmd, $$WM_GETTEXT, XLONGAT(wParam), wParam)
					RETURN 0
			END SELECT
			
		CASE $$WM_MSG_SETTEXT:
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&MsgWin, pData, SIZE(TMsgWin))

			SELECT CASE lParam
				CASE $$MsgEdit	:
					text = CSTRING$(wParam)
					IFZ text THEN EXIT SELECT

					t0 = SendMessageA (MsgWin.hedit, $$EM_GETLINECOUNT, 0,0 )
					text = $$RTFHEADER +text+" "+ $$NEWLINE
					MsgWin.TChars = MsgWin.TChars + LEN(text)
					RtlMoveMemory (pData,&MsgWin, SIZE(TMsgWin))

					SendMessageA (MsgWin.hedit, $$EM_SETSEL, MsgWin.TChars, MsgWin.TChars+1)
					SendMessageA (MsgWin.hedit, $$EM_REPLACESEL, 0, &text)
					t1 = SendMessageA (MsgWin.hedit, $$EM_GETLINECOUNT, 0,0 )
					SendMessageA (MsgWin.hedit, $$EM_LINESCROLL, 0,(t1-t0))
					RETURN 0

				CASE $$MsgCmd	:
					SendMessageA (MsgWin.hcmd, $$WM_SETTEXT, 0, wParam)
					RETURN 0
			END SELECT
			
		CASE $$WM_MSG_SETCLIENTS	:
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&MsgWin, pData, SIZE(TMsgWin))
			MsgWin.from = CSTRING$(wParam)
			MsgWin.to = CSTRING$(lParam)
			MsgWin.title = "PM: "+MsgWin.from +" -> "+MsgWin.to
			IF MsgWin.hIcon THEN CloseHandle (MsgWin.hIcon)
			IF (MsgWin.from == GetNick()) THEN
				MsgWin.hIcon = LoadIconA (hInst,&"msga")
			ELSE
				MsgWin.hIcon = LoadIconA (hInst,&"msgb")
			END IF
			'SetWindowLongA (MsgWin.hwin,$$GCL_HICON,MsgWin.hIcon)
			SetClassLongA (MsgWin.hwin,$$GCL_HICON,MsgWin.hIcon)
			RtlMoveMemory (pData,&MsgWin, SIZE(TMsgWin))
			SetWindowTextA (hWnd,&MsgWin.title)
			RETURN 0

		CASE $$WM_CTLCOLOREDIT
			RETURN SetColor (RGB(100, 100, 100), RGB(212, 208, 200), wParam, lParam)

		CASE $$WM_CREATE:
			hHeap = GetProcessHeap ()
			pData = HeapAlloc (hHeap, $$HEAP_ZERO_MEMORY, SIZE(TMsgWin))
			SetWindowLongA (hWnd, $$GWL_USERDATA, pData)
			SetLastError (0)
			RtlMoveMemory (&cs, lParam, SIZE(CREATESTRUCT))

			x = cs.x: y = cs.y
			w = cs.cx: h = cs.cy
			MsgWin.title = "PM: "
			MsgWin.hwin = hWnd
			MsgWin.hIcon = LoadIconA (hInst,&"msga")
			MsgWin.hedit = CreateRichEdit (0, 0, w, h-20, MsgWin.hwin, $$MsgEdit, 2000)
			MsgWin.hcmd = NewChild ("edit","", $$ES_MULTILINE | $$ES_AUTOHSCROLL, 0, h-20, w, 18, MsgWin.hwin, $$MsgCmd, $$WS_EX_STATICEDGE)
			MsgWin.hcmdsubproc = SetWindowLongA(MsgWin.hcmd , $$GWL_WNDPROC, &MsgWindowCmdProc())
			MsgWin.heditsubproc = SetWindowLongA(MsgWin.hedit , $$GWL_WNDPROC, &MsgWindowEditProc())
			RtlMoveMemory (pData,&MsgWin, SIZE(TMsgWin))

			SetWindowTextA (hWnd,&MsgWin.title)
			SetClassLongA (MsgWin.hwin, $$GCL_HICON,MsgWin.hIcon)
			SendMessageA (MsgWin.hedit, $$EM_SETBKGNDCOLOR, 0, RGB(212, 208, 200))
			SetFocus (MsgWin.hwin)
			SetFocus (MsgWin.hedit)

			RETURN 0
			
		CASE $$WM_DESTROY:
			hHeap = GetProcessHeap ()
			IF pData THEN
				pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
				RtlMoveMemory (&MsgWin, pData, SIZE(TMsgWin))
				IF MsgWin.hIcon THEN CloseHandle (MsgWin.hIcon)
				HeapFree (hHeap, 0, pData)
			END IF
			RETURN 0

		CASE $$WM_SIZE:
			width  = LOWORD(lParam)
			height = HIWORD(lParam)

			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&MsgWin, pData, SIZE(TMsgWin))

			SetWindowPos (MsgWin.hedit,0, 0, 0, width,height-18, 0)
			SetWindowPos (MsgWin.hcmd,0, 0, height-18, width,18, 0)
			RETURN 0
	END SELECT

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)	
END FUNCTION

FUNCTION MsgWindowEditProc (hWnd, msg, wParam, lParam)
	TMsgWin MsgWin


	pData = GetWindowLongA (GetParent(hWnd), $$GWL_USERDATA)
	RtlMoveMemory (&MsgWin, pData, SIZE(TMsgWin))

	SELECT CASE msg
		CASE $$WM_MBUTTONDOWN :	' set focus to cmd control when middle button is pressed
			SetFocus (MsgWin.hcmd)
			RETURN 0
	END SELECT
	
	RETURN CallWindowProcA (MsgWin.heditsubproc, hWnd, msg, wParam, lParam)
END FUNCTION

FUNCTION MsgWindowCmdProc (hWnd, msg, wParam, lParam)
	TMsgWin MsgWin
	

	SELECT CASE msg
		CASE $$WM_KEYDOWN :
			SELECT CASE wParam
				CASE $$VK_RETURN 		:
					id = GetWindowLongA (hWnd, $$GWL_ID)
					wParam = ($$EDITBOX_RETURN << 16) | id
					SendMessageA (GetParent(hWnd), $$WM_COMMAND, wParam, hWnd)
					RETURN 0
			END SELECT
	END SELECT
	
	pData = GetWindowLongA (GetParent(hWnd), $$GWL_USERDATA)
	RtlMoveMemory (&MsgWin, pData, SIZE(TMsgWin))
	RETURN CallWindowProcA (MsgWin.hcmdsubproc, hWnd, msg, wParam, lParam)
END FUNCTION

FUNCTION SplitterProc (hWnd, msg, wParam, lParam)
	CREATESTRUCT cs
	TRECT splitterRect
	TRECT wnd1Rect
	TRECT wnd2Rect
	TRECT rect
	SPLITTERDATA spdata
	POINTAPI ptClient
	POINTAPI pt
	SHARED moveX, moveY
	STATIC idCount				' id of static control
	SHARED hInst
	SHARED hCursorH, hCursorV
	STATIC hNewBrush


	SELECT CASE msg
		CASE $$WM_CREATE:
' create the heap for this instance of the class and
' allocate heap for the SPLITTERDATA struct
			hHeap = GetProcessHeap ()
			pData = HeapAlloc (hHeap, $$HEAP_ZERO_MEMORY, SIZE(SPLITTERDATA))

' store this data pointer in class data area
			SetLastError (0)
			ret = SetWindowLongA (hWnd, $$GWL_USERDATA, pData)

' get data in createstruct from pointer lParam
			RtlMoveMemory (&cs, lParam, SIZE(CREATESTRUCT))

' create the splitter panel using a static control, set initial size and position in middle
			text$        	= ""
			splitterSize 	= 5								' default splitter panel size
			'style        	= $$SS_LEFT | $$SS_NOTIFY | $$WS_CHILD | $$WS_VISIBLE |  $$SS_ETCHEDVERT  | $$ES_SUNKEN
			style        	= $$WS_CHILD | $$WS_VISIBLE | $$ES_SUNKEN | $$ES_READONLY
			w 				= cs.cx
			IF w < splitterSize THEN w = splitterSize
			x 				= w/2 - splitterSize/2
			h 				= cs.cy

			hStatic = CreateWindowExA ( $$WS_EX_STATICEDGE, &"edit", &text$, style, x, 0, splitterSize, h, hWnd, idCount, hInst, 0)
			INC idCount

' assign static control callbacks StaticProc ()
			#old2_proc = SetWindowLongA (hStatic, $$GWL_WNDPROC, &StaticProc())

' initialize default SPLITTERDATA into data buffer
			IF pData THEN
				XLONGAT(pData)    = cs.hWndParent	' hWndParent
				XLONGAT(pData+4)  = 0				' hWnd1
				XLONGAT(pData+8)  = 0				' hWnd2
				XLONGAT(pData+12) = 20				' wnd1 min size
				XLONGAT(pData+16) = 20				' wnd2 min size
				XLONGAT(pData+20) = 0				' splitter style = default = 0 = horizontal
				XLONGAT(pData+24) = splitterSize	' splitter size
				XLONGAT(pData+28) = hStatic			' handle static control
				XLONGAT(pData+32) = idCount			' static control id
			ELSE
				RETURN 0
			END IF
			
			hCursorH = LoadCursorA (hInst, &"hsplit")
			hCursorV = LoadCursorA (hInst, &"vsplit")

			RETURN 0

		CASE $$WM_DESTROY:
			hHeap = GetProcessHeap ()
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			IF pData THEN
				HeapFree (hHeap, 0, pData)					' free the heap created in WM_CREATE
			END IF
			DeleteObject (hNewBrush)
			RETURN 0

		CASE $$WM_SIZE:
			width  = LOWORD(lParam)
			height = HIWORD(lParam)

			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)				' get splitter data
			RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))
			hWndParent 	= spdata.hWndParent
			hWnd1 		= spdata.hWnd1
			hWnd2 		= spdata.hWnd2
			minSize1 	= spdata.wnd1MinSize
			minSize2 	= spdata.wnd2MinSize
			splitterSize= spdata.splitterSize
			hStatic     = spdata.hStatic
			style       = spdata.style

' don't resize below minimum total splitter size
			minSize = splitterSize + minSize1 + minSize2
			IF style == $$SS_HORZ THEN
				width = MAX(minSize, width)
			ELSE
				height = MAX(minSize, height)
			END IF

			GOSUB CalcSizes							' compute the sizes of all the panels
			IF style == $$SS_HORZ THEN				' resize windows
				MoveWindow (hStatic, splitterRect.left, splitterRect.top, splitterSize, height, 0)
 				MoveWindow (hWnd1, wnd1Rect.left, wnd1Rect.top, wnd1Rect.right, height, 0)
 				MoveWindow (hWnd2, wnd2Rect.left, wnd2Rect.top, wnd2Rect.right - wnd2Rect.left, height, 0)
			ELSE
				MoveWindow (hStatic, 0, splitterRect.top, width, splitterSize, 0)
 				MoveWindow (hWnd1, 0, wnd1Rect.top, width, wnd1Rect.bottom, 0)
 				MoveWindow (hWnd2, 0, wnd2Rect.top, width, wnd2Rect.bottom - wnd2Rect.top, 0)
			END IF
			InvalidateRgn (hWnd, 0, 0)
			RETURN 0

		CASE $$WM_CTLCOLOREDIT  ,$$WM_CTLCOLORSTATIC,$$WM_CTLCOLORLISTBOX,$$WM_CTLCOLORDLG
			RETURN SetColor (RGB(100, 100, 100), RGB(212, 208, 200), wParam, lParam)
			
		CASE $$WM_SET_SPLITTER_PANEL_HWND:
' client calls SendMessageA() just after the control is created
' to set the two side panel window handles
' store this data in object area
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+4) 	= wParam								' hWnd1
			XLONGAT(pData+8) 	= lParam								' hWnd2
			GOSUB Resize												' resize all panels
			RETURN 0

		CASE $$WM_SET_SPLITTER_MIN_PANEL_SIZE:
' client calls SendMessageA() just after the control is created
' to set the border width for the splitter control
' store data in object area
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+12) = wParam									' wnd1 min size
			XLONGAT(pData+16) = lParam									' wnd2 min size
			GOSUB Resize												' resize all panels
			RETURN 0

		CASE $$WM_SET_SPLITTER_SIZE:
' client calls SendMessageA() just after the control is created
' to set the splitter size
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+24) = lParam									' splitter size
			GOSUB Resize												' resize all panels
			RETURN 0

		CASE $$WM_SET_SPLITTER_STYLE:
' client calls SendMessageA() just after the control is created
' to set the splitter style
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+20) = lParam									' set splitter style
			RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))
			hStatic      = spdata.hStatic
			style        = lParam
			splitterSize = spdata.splitterSize

			GetWindowRect (hWnd, &rect)
			IF style == $$SS_HORZ THEN
				x = (rect.right - rect.left)/2 - splitterSize/2
				MoveWindow (hStatic, x, 0, splitterSize, rect.bottom-rect.top, 0)
			ELSE
				y = (rect.bottom - rect.top)/2 - splitterSize/2
				MoveWindow (hStatic, 0, y, rect.right-rect.left, splitterSize,  0)
			END IF

			GOSUB Resize												' resize all panels
			RETURN 0

		CASE $$WM_SET_SPLITTER_POSITION:
' client calls SendMessageA() just after the control is created
' to set the splitter panel horizontal (x) or vertical (y) position
' wParam - x, lParam - y ... only one value is needed

			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))
			hStatic      = spdata.hStatic
			style        = spdata.style
			splitterSize = spdata.splitterSize
			hWndParent   = spdata.hWndParent

			GetWindowRect (hWndParent, &rect)
			IF style == $$SS_HORZ THEN
				MoveWindow (hStatic, wParam, 0, splitterSize, rect.bottom-rect.top, 0)
			ELSE
				MoveWindow (hStatic, 0, lParam, rect.right-rect.left, splitterSize,  0)
			END IF

			GOSUB Resize																' resize all panels
			RETURN 0

		CASE $$WM_GET_SPLITTER_POSITION:
' client calls SendMessageA() just after the control is created
' to get the splitter panel horizontal (x) or vertical (y) position
' return value is current splitter (x or y) depending on style.

			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))
			hStatic      = spdata.hStatic
			style        = spdata.style

' get bounding rectangle for splitter panel (hStatic)
			GetWindowRect (hStatic, &splitterRect)

' convert splitter panel coords to client coords
			pt.x = splitterRect.left
			pt.y = splitterRect.top
			ScreenToClient (hWnd, &pt)
			splitterRect.left = pt.x
			splitterRect.top = pt.y

			IF style == $$SS_HORZ THEN
				RETURN splitterRect.left
			ELSE
				RETURN splitterRect.top
			END IF

		CASE $$WM_GET_SPLITTER_MIN_SIZE:
' the minimum splitter size is the smallest size the control
' should be resized in width or height based on style
' minSize = splitterWidth + minSizePanel1 + minSizePanel2
' applications should call this function before resizing the control
' default minSize = 6 + 20 + 20 = 46

			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))
			RETURN spdata.splitterSize + spdata.wnd1MinSize + spdata.wnd2MinSize

		CASE $$WM_NOTIFY :
			hParent = GetParent (hWnd)
			IF hParent THEN SendMessageA (hParent, $$WM_NOTIFY, wParam, lParam)
			RETURN

		CASE $$WM_COMMAND :
			hParent = GetParent (hWnd)
			IF hParent THEN SendMessageA (hParent, $$WM_COMMAND, wParam, lParam)
			RETURN

		CASE $$WM_CONTEXTMENU :			' right button click inside window
			hParent = GetParent (hWnd)
			IF hParent THEN SendMessageA (hParent, $$WM_CONTEXTMENU, wParam, lParam)
			RETURN


	END SELECT

' The DefWindowProcA function calls the default window
' procedure to provide default processing for any window
' messages that an application does not process. This
' function ensures that every message is processed.
' DefWindowProc is called with the same parameters
' received by the window procedure.

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

' ***** Resize *****
SUB Resize
' resize all splitter panels
	GetClientRect (hWnd, &rect)
	SendMessageA (hWnd, $$WM_SIZE, 0, MAKELONG (rect.right ,rect.bottom))
END SUB


' ***** CalcSizes *****
SUB CalcSizes

' calculate the sizes for all the panels

' get bounding rectangle for splitter panel (hStatic)
	GetWindowRect (hStatic, &splitterRect)

' convert splitter panel coords to client coords
	pt.x = splitterRect.left
	pt.y = splitterRect.top
	ScreenToClient (hWnd, &pt)
	splitterRect.left = pt.x
	splitterRect.top = pt.y

	pt.x = splitterRect.right
	pt.y = splitterRect.bottom
	ScreenToClient (hWnd, &pt)
	splitterRect.right = pt.x
	splitterRect.bottom = pt.y

	IF style == $$SS_HORZ THEN
' set new splitter panel position
		splitterRect.left   = splitterRect.left + moveX
		splitterRect.right  = splitterRect.left + splitterSize
		splitterRect.top    = 0
		splitterRect.bottom = height

' resize panel 1 (left)
		wnd1Rect.left   = 0
		wnd1Rect.right  = splitterRect.left
		wnd1Rect.top    = 0
		wnd1Rect.bottom = height

' resize panel 2 (right)
		wnd2Rect.left   = splitterRect.right
		wnd2Rect.right  = width
		wnd2Rect.top    = 0
		wnd2Rect.bottom = height

' check if panel 1 (left) width is too small
		IF wnd1Rect.right < minSize1 THEN
			wnd1Rect.right     = minSize1
			splitterRect.left  = wnd1Rect.right
			splitterRect.right = wnd1Rect.right + splitterSize
			wnd2Rect.left      = splitterRect.right
		ELSE
' check if panel2 (right) width is too small
			width2 = wnd2Rect.right - wnd2Rect.left
			IF width2 < minSize2 THEN
				wnd2Rect.left      = width - minSize2
				splitterRect.right = wnd2Rect.left
				splitterRect.left  = splitterRect.right - splitterSize
				wnd1Rect.right     = splitterRect.left
			END IF
		END IF

	ELSE
' vertical splitter
' set new splitter panel position
		splitterRect.left   = 0
		splitterRect.right  = width
		splitterRect.top    = splitterRect.top + moveY
		splitterRect.bottom = splitterRect.top + splitterSize

' resize panel 1 (top)
		wnd1Rect.left   = 0
		wnd1Rect.right  = width
		wnd1Rect.top    = 0
		wnd1Rect.bottom = splitterRect.top

' resize panel 2 (bottom)
		wnd2Rect.left   = 0
		wnd2Rect.right  = width
		wnd2Rect.top    = splitterRect.bottom
		wnd2Rect.bottom = height
	END IF

' check if panel 1 (top) height is too small
		IF wnd1Rect.bottom < minSize1 THEN
			wnd1Rect.bottom     = minSize1
			splitterRect.top    = wnd1Rect.bottom
			splitterRect.bottom = wnd1Rect.bottom + splitterSize
			wnd2Rect.top        = splitterRect.bottom
		ELSE
' check if panel2 (bottom) height is too small
			height2 = wnd2Rect.bottom - wnd2Rect.top
			IF height2 < minSize2 THEN
				wnd2Rect.top        = height - minSize2
				splitterRect.bottom = wnd2Rect.top
				splitterRect.top    = splitterRect.bottom - splitterSize
				wnd1Rect.bottom     = splitterRect.top
			END IF
		END IF

END SUB

END FUNCTION
'
'
' ###########################
' #####  StaticProc ()  #####
' ###########################
'
' subclass static control callback function
' this allows mouse messages to be tracked/captured
' and for setting the splitter cursor

FUNCTION StaticProc (hWnd, msg, wParam, lParam)

	SPLITTERDATA spdata
	STATIC splitterX0, splitterY0
	SHARED hCursorH, hCursorV
	SHARED moveX, moveY
	TRECT rect
	STATIC fTrackMouse
	TRACKMOUSEEVENT tme

	SELECT CASE msg

		CASE $$WM_LBUTTONDOWN:
			hWndParent = GetParent (hWnd)
			pData = GetWindowLongA (hWndParent, $$GWL_USERDATA)	' get splitter data
			RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))	' copy data into local struct spdata

				' get horz or vert splitter style
			IF spdata.style = $$SS_HORZ THEN
				SetCursor (hCursorH)					' set cursor
			ELSE
				SetCursor (hCursorV)
			END IF

			SetCapture (hWnd)				' capture the mouse to static control

			splitterX0 = LOWORD (lParam)		' get initial x mouse position
			splitterY0 = HIWORD (lParam)

			RETURN 0

		CASE $$WM_LBUTTONUP:
			ReleaseCapture ()								' release the mouse
			hSplitter = GetParent (hWnd)
			SendMessageA (GetParent (hSplitter), $$WM_SPITTER_BAR_MOVED, 0, 0)
			RETURN 0

		CASE $$WM_MOUSELEAVE:
			fTrackMouse = 0
			SetCursor (LoadCursorA (0, $$IDC_ARROW))	' change cursor back to standard arrow
			RETURN 0

		CASE $$WM_MOUSEMOVE:
			hWndParent = GetParent (hWnd)
			pData = GetWindowLongA (hWndParent, $$GWL_USERDATA)	' get splitter data
			RtlMoveMemory (&spdata, pData, SIZE(SPLITTERDATA))

			IF spdata.style == $$SS_HORZ THEN
				last = SetCursor (hCursorH)										' change cursor
			ELSE
				last = SetCursor (hCursorV)
			END IF

			IFZ fTrackMouse THEN
				tme.cbSize = SIZE(tme)
				tme.dwFlags = $$TME_LEAVE
				tme.hwndTrack = hWnd
				ret = TrackMouseEvent (&tme)
				fTrackMouse = $$TRUE
			END IF

			IF (wParam & $$MK_LBUTTON) THEN						' left button down (drag)

				IF spdata.style = $$SS_HORZ THEN
					moveX = LOWORD (lParam) - splitterX0	' get delta x mouse position
					IFZ moveX THEN RETURN 0
				ELSE
					moveY = HIWORD (lParam) - splitterY0
					IFZ moveY THEN RETURN 0
				END IF

				GetClientRect (hWndParent, &rect)		' get parent size and send WM_SIZE message to splitter control
				SendMessageA (hWndParent, $$WM_SIZE, 0, MAKELONG (rect.right , rect.bottom))

			END IF
			RETURN 0

	END SELECT

	RETURN CallWindowProcA (#old2_proc, hWnd, msg, wParam, lParam)

END FUNCTION

FUNCTION urlCatch (url$)
	SHARED urllog$[]
	STATIC count


	IFZ url$ THEN RETURN -1
	IFZ count THEN
		DIM urllog$[10]
	ELSE
		IF count >= UBOUND(urllog$[]) THEN
			REDIM urllog$[count+10]
		END IF
	END IF
	
	IF LEFT$(url$,4) = "www." THEN url$ = "http://" + url$
	IF LEFT$(url$,4) = "ftp." THEN url$ = "ftp://" + url$

	FOR u = 0 TO count
		IF url$ == urllog$[u] THEN
			' do not log
			'PRINT "type '/url ";u;"' to open ";url$
			RETURN -1
		END IF
	NEXT u
	
	urllog$[count] = url$
	CPrint ($$URLCatch,STRING$(count)+": "+url$)
	
	INC count
	RETURN count-1
	
END FUNCTION

FUNCTION urlOpen (url$)
	SHARED urllog$[]

	
	url$ = TRIM$(trim(url$,32))
	
	IF LEN (url$) < 6 THEN
		url = XLONG(url$)
		IF url > UBOUND (urllog$[]) THEN RETURN $$FALSE
		IFZ urllog$[url] THEN RETURN $$FALSE
		
		url$ = urllog$[url]
		text$ = "* opening url "+STRING$(url) ' +" - "+url$
	ELSE
		text$ = "* opening url "+url$
	END IF
	
	CPrint ($$Hub,text$)
	RETURN LaunchBrowser (url$)
END FUNCTION

FUNCTION LaunchBrowser (url$)		' function taken from 'launchbrowser' by D.S.
	IFZ url$ THEN RETURN

	key$ = NULL$ (512)

' First try ShellExecute()
	result = ShellExecuteA (NULL, &"open", &url$, NULL, NULL, showcmd)

' If it failed, get the .htm regkey and lookup the program
	IF (result <= $$HINSTANCE_ERROR) THEN
		IF (GetRegKey ($$HKEY_CLASSES_ROOT, ".htm", @key$) == $$ERROR_SUCCESS) THEN
			key$ = key$ + "\\shell\\open\\command"
			IF (GetRegKey ($$HKEY_CLASSES_ROOT, key$, @path$) == $$ERROR_SUCCESS) THEN
				pos = INSTR (path$, "\"%1\"")						' Look for "%1"
				IFZ pos THEN 										' No quotes found
					pos = INSTR (path$, "%1") 						' Check for %1, without quotes
				END IF
				IF pos THEN path$ = TRIM$ (LEFT$ (path$, pos-1))
				path$ = path$ + " " + url$
				result = WinExec (&path$, showcmd)
			END IF
		END IF
	END IF
	RETURN result

END FUNCTION

FUNCTION  GetRegKey (key, subkey$, @retdata$)

	retval = RegOpenKeyExA (key, &subkey$, 0, $$KEY_QUERY_VALUE, &hkey)

	IF (retval == $$ERROR_SUCCESS) THEN
		datasize = $$MAX_PATH
		retdata$ = NULL$ ($$MAX_PATH)
		RegQueryValueA (hkey, NULL, &retdata$, &datasize)
		retdata$ = TRIM$ (retdata$)
		RegCloseKey (hkey)
	END IF

	RETURN retval
END FUNCTION

FUNCTION urlList (starturl)
	SHARED urllog$[]

	
	IF url > UBOUND (urllog$[]) THEN RETURN $$FALSE
	
	ClearEditText ($$URLCatch)
	
	FOR u = url TO UBOUND (urllog$[])
		IF urllog$[u] THEN
			text$ = STRING$(u)+": "+urllog$[u]
			CPrint ($$URLCatch,text$)
			'Log (text$,#clog$)
		END IF
	NEXT u
	
	RETURN $$TRUE
		
END FUNCTION


FUNCTION filterMessage (message$,text$,action)
	SLONG value
	

	start = 1
	found = $$FALSE
	
	DO 
		IFT filterFind (message$,text$,@start) THEN
			' text found
			
			found = $$TRUE
			SELECT CASE action
				CASE $$Filter_URL	:url$ = GetTokenEx (message$,32,start-1)
									i = urlCatch (url$)
								 	IF i != -1 THEN
								 		insert$ = " " + STRING$(i) +": "
								 		textInsert (insert$,@message$,start-1)
								 		start = start + LEN(insert$)
								 	END IF

				CASE $$Filter_NAME	:name$ = GetTokenEx (message$,32,start+1)
								 	textRemove (@message$,2 + (LEN(name$)),start-1)
								' 	IF name$ THEN textInsert (FindUser(name$),@message$,start-1)

				CASE $$Filter_DC	:value = XLONG(GetTokenEx (message$,32,start+1))
									 IF value < 0 THEN EXIT SELECT
									 
									 size = 0
									 SELECT CASE ALL TRUE
									 	CASE (value > 9999)		:size = 8: EXIT SELECT
									 	CASE (value > 999)		:size = 7: EXIT SELECT
									 	CASE (value > 99)		:size = 6: EXIT SELECT
									 	CASE (value > 9)		:size = 5: EXIT SELECT
									 	CASE (value < 10)		:size = 4: EXIT SELECT
									 	CASE (value < 0)		:EXIT SELECT
									 END SELECT
									 
									 IF size THEN
								 	 	textRemove (@message$,size,start-1)
								 	 	IF value THEN textInsert (CHR$(value),@message$,start-1)
								 	 	DEC start
								 	 END IF
			'	CASE 4			:
			'	CASE 5			:
				CASE ELSE		:
			END SELECT
			
			start = start + LEN(text$)
		ELSE
			' text no longer found
			start = -1
		END IF
	LOOP WHILE (start != -1)
	
	RETURN found
END FUNCTION

FUNCTION RGB (r, g, b)

	IF r > 255 THEN r = 255
	IF g > 255 THEN g = 255
	IF b > 255 THEN b = 255

	RETURN r | (g << 8) | (b << 16)

END FUNCTION

FUNCTION filterFind (message$,text$,start)


	IFZ text$ THEN RETURN $$FALSE
	IFZ message$ THEN RETURN $$FALSE
	
	sizet = LEN(text$)
	sizem = LEN(message$)
	IF (start+size) > sizem THEN RETURN $$FALSE
	IF sizet > sizem THEN RETURN $$FALSE
	
	FOR p = start TO sizem-sizet
		msg$ = MID$(message$,p,sizet)
		IF msg$ = text$ THEN
			start = p
			RETURN $$TRUE
		END IF
	NEXT p

	start = -1
	RETURN $$FALSE

END FUNCTION

FUNCTION HIWORD (x)

	RETURN x{{16,16}}
END FUNCTION

FUNCTION SetTaskbarIcon (hWnd, iconName$, tooltip$)
	SHARED hInst
	NOTIFYICONDATA nid


	IFZ hWnd THEN RETURN
	IFZ iconName$ THEN RETURN

	nid.cbSize = SIZE(nid)
	nid.hWnd   = hWnd
	nid.uID    = hInst
	IF tooltip$ THEN
		nid.uFlags = $$NIF_ICON | $$NIF_MESSAGE | $$NIF_TIP
		nid.szTip  = tooltip$
	ELSE
		nid.uFlags = $$NIF_ICON | $$NIF_MESSAGE
	END IF
	
	nid.uCallbackMessage = $$WM_TRAYICON
	nid.hIcon  = LoadIconA(hInst, &iconName$)
	ret = Shell_NotifyIconA ($$NIM_ADD, &nid)
	IF nid.hIcon THEN DestroyIcon (nid.hIcon)
	
	RETURN ret
END FUNCTION

FUNCTION DeleteTrayIcon (hWnd)
	SHARED hInst
	NOTIFYICONDATA nid


	nid.cbSize = SIZE(nid)
	nid.hWnd   = hWnd
	nid.uID    = hInst
	RETURN Shell_NotifyIconA ($$NIM_DELETE, &nid)

END FUNCTION

FUNCTION SetListViewSubItem (hwndCtl, iColumn, STRING text, item)
	STATIC LV_ITEM lvi

	
	IFZ text THEN RETURN -1
	lvi.mask 		= $$LVIF_TEXT
	lvi.iItem 		= item
	lvi.pszText 	= &text
	lvi.cchTextMax 	= LEN(text)
	lvi.iSubItem 	= iColumn
	
	RETURN SendMessageA (hwndCtl, $$LVM_SETITEM , 0, &lvi)
END FUNCTION

FUNCTION InsertListViewItem (hwndCtl,pos, STRING item)
	STATIC LV_ITEM lvi


	lvi.mask 		= $$LVIF_TEXT ' | $$LVIF_IMAGE | $$LVIF_PARAM | $$LVIF_STATE
	lvi.state		= 0
	lvi.stateMask 	= 0
	lvi.iItem 		= pos
	lvi.pszText 	= &item
	lvi.cchTextMax	= LEN(item)
	lvi.iImage 		= 0 ' iImage[i]
	lvi.iSubItem 	= 0
	lvi.lParam 		= 0 ' data[i]
	
	RETURN SendMessageA (hwndCtl, $$LVM_INSERTITEM, 0, &lvi)
END FUNCTION

FUNCTION AddListViewColumn (hwndCtl, iCol, width, heading$)
	STATIC LV_COLUMN lvcol

	lvcol.mask 			= $$LVCF_FMT | $$LVCF_WIDTH | $$LVCF_TEXT | $$LVCF_SUBITEM
	lvcol.fmt 			= $$LVCFMT_LEFT
	lvcol.cx 			= width
	lvcol.pszText 		= &heading$
	lvcol.cchTextMax 	= LEN(heading$)
	lvcol.iSubItem		= iCol
	RETURN SendMessageA (hwndCtl, $$LVM_INSERTCOLUMN, iCol, &lvcol)

END FUNCTION

FUNCTION CleanUp ()
	SHARED STRING DCClassName
	SHARED STRING MsgClassName
	SHARED hInst
	SHARED SHUTONCE
	SHARED SHUTDOWN
	SHARED titleTimer

	
	IF SHUTONCE THEN RETURN $$FALSE
	
	IF titleTimer THEN
		KillTimer (#winMain,$$HubTitle)
		titleTimer = 0
	END IF
		
	IF #hPopMenu THEN DestroyMenu (#hPopMenu): #hPopMenu = 0
	IF #hTabFont THEN DeleteObject (#hTabFont) : #hTabFont = 0
	IF #hHubFont THEN DeleteObject (#hHubFont): #hHubFont = 0
	IF #hCListFont THEN DeleteObject (#hCListFont): #hCListFont = 0
	IF #hMenuURL THEN DeleteObject (#hMenuURL): #hMenuURL = 0
	IF #hMenuHub THEN DeleteObject (#hMenuHub): #hMenuHub = 0
	IF ##hMenuClInfo THEN DeleteObject (#hMenuClInfo): #hMenuClInfo = 0
	IF ##hClientListFontB THEN DeleteObject (#hClientListFontB): #hClientListFontB = 0
	

'	IF DCClassName THEN UnregisterClassA(&DCClassName, hInst): DCClassName = ""
'	IF MsgClassName THEN UnregisterClassA(&MsgClassName, hInst): MsgClassName = ""

	IF #MSGThread THEN CloseHandle (#MSGThread): #MSGThread = 0
	IF #hThread THEN CloseHandle (#hThread): #hThread = 0
	
	IF #winMain THEN
		DeleteTrayIcon (#winMain)
		DestroyWindow (#winMain)
		#winMain = 0
		SHUTDOWN = $$TRUE
	END IF
	
END FUNCTION

FUNCTION RegisterWinClass (className$, titleBar$)
	SHARED hInst
	WNDCLASS wc

	wc.style           = $$CS_HREDRAW | $$CS_VREDRAW | $$CS_OWNDC
	wc.lpfnWndProc     = &WndProc()
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 0
	wc.hInstance       = hInst
	wc.hIcon           = LoadIconA (hInst, &"Hub")
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = GetStockObject ($$LTGRAY_BRUSH)
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &className$

	RETURN RegisterClassA (&wc)
END FUNCTION

FUNCTION CreateWindows ()
	SHARED STRING DCClassName
	SHARED FUNCADDR AW (XLONG,XLONG,XLONG)
	
	#WindowCreated = $$FALSE

	#winMain = NewWindow ("MyDcPxyGUI"+STRING$(GetTickCount()), "MyDC", $$WS_OVERLAPPEDWINDOW, 0, 0, 700, 360, 0)
	SetWindowPos (#winMain, 0, 100, 250, 0, 0, $$SWP_NOSIZE | $$SWP_NOZORDER)
	#WM_TaskbarRestart = RegisterWindowMessageA(&"TaskbarCreated") ' listen for explorer restart messages
	SetTaskbarIcon (#winMain, "Hub", "")

'	InitializeFlatSB (#winMain)
	#CmdLine = NewChild ("edit","", $$ES_MULTILINE | $$WS_VSCROLL | $$ES_AUTOHSCROLL, 1, h-45, 550, 18, #winMain, $$CmdLine, $$WS_EX_STATICEDGE)
	#SearchLine = NewChild ("edit","", $$ES_MULTILINE | $$ES_AUTOHSCROLL, 1, h-45, 550, 18, #winMain, $$SearchLine, $$WS_EX_STATICEDGE)
	#hTabCtl = NewChild ($$WC_TABCONTROL, "", $$WS_CLIPSIBLINGS | $$TCS_HOTTRACK | $$TCS_BUTTONS | $$TCS_FLATBUTTONS , 1, 1, w, h-40, #winMain, $$Tab1, $$WS_EX_STATICEDGE ) 
	'exStyle = SendMessageA (#hTabCtl, $$TCM_GETEXTENDEDSTYLE, 0, 0)
	'exStyle = exStyle | $$TCS_EX_FLATSEPARATORS '|  $$TCS_FLATBUTTONS
	'SendMessageA (#hTabCtl, $$TCM_SETEXTENDEDSTYLE, 0, exStyle)
	'SendMessageA (#hTabCtl, $$TCM_SETMINTABWIDTH, 50, 50)
	

	#hSplitter1 = AddSplitTabChild (#hTabCtl,"Hub",$$Splitter1)
	
	#hub = CreateRichEdit (1, 20, 300, 300, #hSplitter1, $$Hub, 2035)
	exStyle = $$WS_EX_TRANSPARENT | $$WS_EX_STATICEDGE | $$WS_EX_CONTEXTHELP ' | $$LVS_EX_GRIDLINES

	#hInfoListV = NewChild ($$WC_LISTVIEW, "", $$LVS_REPORT | $$LVS_NOSORTHEADER , 0, 0, rc_right, rc_bottom, #hSplitter1, 2034, exStyle)
	exStyle = SendMessageA (#hInfoListV, $$LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
	exStyle = exStyle | $$LVS_EX_FULLROWSELECT | $$LVS_EX_TRACKSELECT | $$LVS_EX_INFOTIP | $$LVS_EX_LABELTIP | $$LVS_EX_HEADERDRAGDROP
	SendMessageA (#hInfoListV, $$LVM_SETEXTENDEDLISTVIEWSTYLE, 0, exStyle)
	AddListViewColumn (#hInfoListV, $$CL_NAME, 100, "Name")
	AddListViewColumn (#hInfoListV, $$CL_SHARED, 80, "Shared")
	AddListViewColumn (#hInfoListV, $$CL_COMMENT, 90, "Comment")
	AddListViewColumn (#hInfoListV, $$CL_TAG, 90, "Tag")
	AddListViewColumn (#hInfoListV, $$CL_CONNECTION, 90, "Connection")
	AddListViewColumn (#hInfoListV, $$CL_EMAIL, 90, "Email")
	'AddListViewColumn (#hInfoListV, $$CL_Op, 40, "Op")

	#debug = AddRichEditTabChild (#hTabCtl,"Debug",$$Debug,0)
	#search = AddEditTabChild (#hTabCtl,"Search",$$Search)

	#SResultList = AddListViewTabChild (#hTabCtl,"Search Results",$$SResults)
	exStyle = SendMessageA (#SResultList, $$LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
	exStyle = exStyle | $$LVS_EX_FULLROWSELECT  | $$LVS_EX_TRACKSELECT | $$LVS_EX_INFOTIP | $$LVS_EX_LABELTIP | $$LVS_EX_HEADERDRAGDROP
	SendMessageA (#SResultList, $$LVM_SETEXTENDEDLISTVIEWSTYLE, 0, exStyle)
	AddListViewColumn (#SResultList, 0,120, "User")
	AddListViewColumn (#SResultList, 1,350, "File Name")
	AddListViewColumn (#SResultList, 2, 90, "Size")
	AddListViewColumn (#SResultList, 3, 40, "Slots")
	AddListViewColumn (#SResultList, 4,550, "Path")
	AddListViewColumn (#SResultList, 5,120, "Hub")

	#urlcatch = AddRichEditTabChild (#hTabCtl,"URLs",$$URLCatch,0)

	#hTabFont = NewFont ("Comic Sans MS", 9, $$FW_NORMAL, $$FALSE, $$FALSE)
	SetNewFont (#hTabCtl, #hTabFont)
	#hClientListFontB = NewFont ("Comic Sans MS", 9, $$FW_NORMAL, $$FALSE, $$FALSE)
	SetNewFont (#hInfoListV, #hClientListFontB)
	SetNewFont (#CmdLine, #hClientListFontB)


'	hWnd = #hub ' hInfoListV
'	InitializeFlatSB (hWnd)
'	FlatSB_EnableScrollBar (hWnd,$$SB_BOTH,$$ESB_ENABLE_BOTH)
''	FlatSB_SetScrollProp(hWnd, $$WSB_PROP_CXVSCROLL, GetSystemMetrics($$SM_CXVSCROLL), 0)
''	FlatSB_SetScrollProp(hWnd, $$WSB_PROP_CYVSCROLL, GetSystemMetrics($$SM_CYVSCROLL), 0)
''	FlatSB_SetScrollProp(hWnd, $$WSB_PROP_CXHSCROLL, GetSystemMetrics($$SM_CXHSCROLL), 0)
''	FlatSB_SetScrollProp(hWnd, $$WSB_PROP_CYHSCROLL, GetSystemMetrics($$SM_CYHSCROLL), 0)
''	FlatSB_SetScrollProp(hWnd, $$WSB_PROP_CXHTHUMB, GetSystemMetrics($$SM_CXHTHUMB), 0)
	'FlatSB_SetScrollProp(hWnd, $$WSB_PROP_HSTYLE, $$FSB_FLAT_MODE, 0)
	'FlatSB_SetScrollProp(hWnd, $$WSB_PROP_VSTYLE, $$FSB_FLAT_MODE, 0)
'	FlatSB_SetScrollProp(hWnd, $$WSB_PROP_CYVTHUMB, GetSystemMetrics($$SM_CYVTHUMB), 0)


	SendMessageA (#hInfoListV, $$LVM_SETBKCOLOR, 0, RGB(212, 208, 200))
	SendMessageA (#hInfoListV, $$LVM_SETTEXTBKCOLOR, 0, RGB(212, 208, 200))
	SendMessageA (#hInfoListV, $$LVM_SETTEXTCOLOR, 0, RGB(90, 90, 90))

	SendMessageA (#SResultList, $$LVM_SETBKCOLOR, 0, RGB(212, 208, 200))
	SendMessageA (#SResultList, $$LVM_SETTEXTBKCOLOR, 0, RGB(212, 208, 200))
	SendMessageA (#SResultList, $$LVM_SETTEXTCOLOR, 0, RGB(90, 90, 90))

	SendMessageA (#hSplitter1, $$WM_SET_SPLITTER_PANEL_HWND, #hub,#hInfoListV)
	SendMessageA (#hSplitter1, $$WM_SET_SPLITTER_POSITION, 600, 0)
	SendMessageA (#hSplitter1, $$WM_SET_SPLITTER_MIN_PANEL_SIZE, 0, 0)	

	ShowWindow (#SearchLine , $$SW_HIDE)
	ShowWindow (#winMain, $$SW_SHOWNORMAL)
	UpdateWindow (#winMain)
	
	' $$AW_BLEND ' $$AW_SLIDE ' $$AW_HOR_NEGATIVE

'	IF @AW(#winMain,1300,$$AW_BLEND | $$AW_ACTIVATE) THEN
'		Beep (800,90)
'	END IF
'	SetWindowPos(#winMain,0,-1,-1,-1,-1,$$SWP_NOSIZE)
'	UpdateWindow (#winMain)

	SelectTab (0)
	#WindowCreated = $$TRUE

	'EnableScrollBar (#hub,$$SB_VERT,$$ESB_DISABLE_BOTH)
	
	RETURN $$TRUE	
END FUNCTION

FUNCTION SelectTab (iTab)
	SHARED TabChildCon[]


	FOR t = 0 TO UBOUND(TabChildCon[])	' hide deslected tabs
		IF (t != iTab) THEN ShowWindow (GetTabChild(t), $$SW_HIDE)
	NEXT t
							
	IF ((iTab == 2) || (iTab == 3)) THEN
		ShowWindow (#CmdLine, $$SW_HIDE)
		ShowWindow (#SearchLine, $$SW_SHOWNORMAL)
	ELSE
		ShowWindow (#SearchLine, $$SW_HIDE)
		ShowWindow (#CmdLine, $$SW_SHOWNORMAL)
	END IF

	ShowWindow (GetTabChild(iTab), $$SW_SHOWNORMAL)
	SendMessageA (#hTabCtl, $$TCM_SETCURFOCUS, 0, iTab)
	SendMessageA (#hTabCtl, $$TCM_SETCURSEL, iTab,0)

END FUNCTION 

FUNCTION NewWindow (className$, titleBar$, style, x, y, w, h, exStyle)
	SHARED hInst


	RegisterWinClass (className$, titleBar$)
	RETURN CreateWindowExA (exStyle, &className$, &titleBar$, style, x, y, w, h, 0, 0, hInst, 0)

END FUNCTION

FUNCTION NewChild (className$, text$, style, x, y, w, h, parent, id, exStyle)
	SHARED hInst

' create child control
	style = style | $$WS_CHILD | $$WS_VISIBLE
	RETURN CreateWindowExA (exStyle, &className$, &text$, style, x, y, w, h, parent, id, hInst, 0)

END FUNCTION

FUNCTION MessageLoop ()
	USER32_MSG msg
	STATIC t0
	SHARED SHUTDOWN


	SHUTDOWN = $$FALSE
	DO
		'IF PeekMessageA (&msg,0 , 0, 0, 0) THEN
			SELECT CASE GetMessageA (&msg, 0, 0, 0)
				CASE 0		:RETURN msg.wParam
				CASE -1		:RETURN $$TRUE
				CASE ELSE	:TranslateMessage (&msg)
  							 DispatchMessageA (&msg)
			END SELECT
		'ELSE
			'Sleep (1)
		'END IF
	LOOP WHILE (SHUTDOWN == $$FALSE)

END FUNCTION

FUNCTION CreateCallbacks ()

'	assign a new callback function to be used by child edit controls
	#hub_proc = SetWindowLongA(#hub, $$GWL_WNDPROC, &HubProc())
	#cmd_proc = SetWindowLongA(#CmdLine, $$GWL_WNDPROC, &CmdProc())
	#ser_proc = SetWindowLongA(#SearchLine, $$GWL_WNDPROC, &SerProc())
	#urlcatch_proc = SetWindowLongA(#urlcatch, $$GWL_WNDPROC, &urlcatchProc())
	#CListView_proc = SetWindowLongA(#hInfoListV, $$GWL_WNDPROC, &CListViewProc())

END FUNCTION

FUNCTION CListViewProc (hWnd, msg, wParam, lParam)
	STRING text,cmd
	POINTAPI pt

	SELECT CASE msg	
		CASE $$WM_RBUTTONDOWN	:
		'	x = LOWORD(lParam)
		'	y = HIWORD(lParam)
		'	pt.x = x
		'	pt.y = y
		'	ClientToScreen (hWnd, &pt)
   		'	TrackPopupMenuEx (#hMenuClInfo, $$TPM_LEFTALIGN | $$TPM_LEFTBUTTON | $$TPM_RIGHTBUTTON, pt.x, pt.y, hWnd, 0)

		CASE $$WM_LBUTTONDBLCLK		:
			i = SendMessageA (hWnd, $$LVM_GETSELECTIONMARK , 0, 0)
			text = GetListViewItem (hWnd,i)
			IF text THEN SetText(#CmdLine,GetText(#CmdLine)+text)
			SetFocus (#CmdLine)
			RETURN 0
	END SELECT
	
	RETURN CallWindowProcA (#CListView_proc, hWnd, msg, wParam, lParam)
END FUNCTION

FUNCTION urlcatchProc (hWnd, msg, wParam, lParam)
	SHARED STRING URLBuffer


	SELECT CASE msg
		CASE $$WM_COMMAND :
			id = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl = lParam

			SELECT CASE id
				CASE $$POPURL_Open	:IF URLBuffer THEN LaunchBrowser (URLBuffer)
				CASE $$POPURL_Copy	:IF URLBuffer THEN SetClipText (URLBuffer)
				CASE $$POPURL_Save	:IF URLBuffer THEN GetURL (URLBuffer): URLBuffer = ""
			END SELECT

			RETURN 0
	END SELECT
	
	RETURN CallWindowProcA (#urlcatch_proc, hWnd, msg, wParam, lParam)
END FUNCTION

FUNCTION GetURL (STRING URLBuffer)
	STRING filename,filter,ext,file
	TBUFFER buff[]
	

	IFZ URLBuffer THEN RETURN 0
	DecomposePathname (URLBuffer, path$, parent$, @filename, @file, @ext)
	IFZ filename THEN RETURN 0

	filter = "*"+ext+" \0*"+ext+"\0All Files (*.*)\0*.*\0\0"
	ShowSaveFileDialog (hWnd, @filename,filter , initDir$, "Save As")

	IF filename THEN
		IF URL_GetFile (URLBuffer,@buff[]) THEN
			IF URL_SaveFile (filename,@buff[]) THEN
				CPrint ($$Hub,"* URL downloaded to: "+filename)
				RETURN 1
			ELSE
				CPrint ($$Hub,"* Unable to save file: "+filename)
			END IF
		ELSE
			CPrint ($$Hub,"* Unable to retrieve URL: "+URLBuffer + $$NEWLINE)
		END IF
	END IF

	RETURN 0
END FUNCTION

FUNCTION HubProc (hWnd, msg, wParam, lParam)
	SHARED STRING URLBuffer
	STATIC STRING buffer,CopyBuffer
	POINTAPI pt
	STATIC CHARRANGE cr
	STATIC TEXTRANGE txtr
	STATIC LPSCROLLINFO lpsi
	

	SELECT CASE msg

	'	CASE $$WM_SIZE      :
	'		FlatSB_ShowScrollBar (#hub,$$SB_VERT,0)
	'		FlatSB_ShowScrollBar (#hub,$$SB_VERT,1)

	'	CASE $$WM_VSCROLL 	:
	'		lpsi.cbSize = SIZE(lpsi)
	'		lpsi.fMask = $$SIF_PAGE | $$SIF_POS | $$SIF_RANGE | $$SIF_TRACKPOS
	'		GetScrollInfo (#hub,$$SB_VERT,&lpsi)
	'		lpsi.fMask = $$SIF_PAGE | $$SIF_POS | $$SIF_RANGE | $$SIF_TRACKPOS
	'		FlatSB_SetScrollInfo (#hub,$$SB_VERT,&lpsi,1)
	'		FlatSB_SetScrollProp(#hub, $$WSB_PROP_CYVTHUMB, GetSystemMetrics($$SM_CYVTHUMB), 1)
	'		FlatSB_ShowScrollBar (#hub,$$SB_VERT,0)
	'		FlatSB_ShowScrollBar (#hub,$$SB_VERT,1)
		CASE $$WM_COMMAND :
			id = LOWORD(wParam)
			notifyCode = HIWORD(wParam)
			hwndCtl = lParam

			SELECT CASE id
				CASE $$POPURL_Open		:IF URLBuffer THEN LaunchBrowser (URLBuffer): URLBuffer = ""
				CASE $$POPURL_Copy		:IF URLBuffer THEN SetClipText (URLBuffer): URLBuffer = ""
				CASE $$POPURL_Save		:IF URLBuffer THEN GetURL (URLBuffer): URLBuffer = ""
				
				CASE $$POPHUB_Copy		:SetClipText (CopyBuffer): CopyBuffer = ""
				CASE $$POPHUB_SelAll	:cr.cpMin = 0: cr.cpMax = -1
										SetFocus (hWnd)
										SendMessageA (hWnd, $$EM_EXSETSEL,0,&cr)
			END SELECT
			'RETURN 0

		CASE $$WM_MBUTTONDOWN :	' set focus to cmd control when middle button is pressed
			SetFocus (#CmdLine)
			RETURN 0
			
		CASE $$WM_RBUTTONDOWN   :
			SendMessageA (hWnd, $$EM_EXGETSEL,0,&cr)
			tchar = (cr.cpMax - cr.cpMin)

			IF tchar THEN
				buffer = NULL$(tchar)
				txtr.chrg = cr
				txtr.lpstrText = &buffer
				ret = SendMessageA (hWnd, $$EM_GETTEXTRANGE  ,0, &txtr)
			END IF

			IFZ ret THEN
				ModifyMenuA (#hMenuHub,$$POPHUB_Copy,$$MF_BYCOMMAND | $$MF_GRAYED,$$POPHUB_Copy, &"Copy              Ctrl+C")
			ELSE
				ModifyMenuA (#hMenuHub,$$POPHUB_Copy,$$MF_BYCOMMAND | $$MF_ENABLED,$$POPHUB_Copy, &"Copy              Ctrl+C")
			END IF

			x = LOWORD(lParam)
			y = HIWORD(lParam)
			pt.x = x
			pt.y = y
			ClientToScreen (hWnd, &pt)
			CopyBuffer = buffer
   			TrackPopupMenuEx (#hMenuHub, $$TPM_LEFTALIGN | $$TPM_LEFTBUTTON | $$TPM_RIGHTBUTTON, pt.x, pt.y, hWnd, 0)
		'	RETURN
	END SELECT

	RETURN CallWindowProcA (#hub_proc, hWnd, msg, wParam, lParam)
END FUNCTION

FUNCTION CmdProc (hWnd, msg, wParam, lParam)
	STATIC STRING cmd


	SELECT CASE msg
		CASE $$WM_KEYDOWN :
			IF (wParam == $$VK_RETURN) THEN
				IF (GetWindowLongA (hWnd, $$GWL_ID) == $$CmdLine) THEN
					InitNewCmd (hWnd,GetText(hWnd))
					RETURN 0
				END IF
			END IF

		CASE $$WM_KEYUP :
			IF (wParam == $$VK_RETURN) THEN
				IF (GetWindowLongA (hWnd, $$GWL_ID) == $$CmdLine) THEN
					SetText(hWnd,GetText(hWnd)) 
					RETURN 0
				END IF
			END IF

	'	CASE $$WM_KEYDOWN :
	'		SELECT CASE wParam
	'			CASE $$VK_TAB
	'				id = GetWindowLongA (hWnd, $$GWL_ID)
	'				wParam = ($$EDITBOX_TAB << 16) | id
	'				SendMessageA (GetParent(hWnd), $$WM_COMMAND, wParam, hWnd)	' send WM_COMMAND message to main window callback function
	'				RETURN 0
	'		END SELECT
		
	'	CASE $$WM_CHAR :				' WM_CHAR can capture keyboard characters
	'		charCode = wParam
	'		PRINT "WM_CHAR message: ASCII charCode="; charCode, "CHAR="; CHR$(charCode)	' validate text entry by character
	'		RETURN 0
	END SELECT
	
	RETURN CallWindowProcA (#cmd_proc, hWnd, msg, wParam, lParam)
END FUNCTION

FUNCTION SerProc (hWnd, msg, wParam, lParam)
	POINTAPI pt
	STRING cmd
	

	SELECT CASE msg
		CASE $$WM_KEYDOWN :
			IF (wParam == $$VK_RETURN) THEN
				IF (GetWindowLongA (hWnd, $$GWL_ID) == $$SearchLine) THEN
					InitNewCmd (hWnd,"/search "+GetText(hWnd))
					RETURN 0
				END IF
			END IF
	END SELECT
	
	RETURN CallWindowProcA (#ser_proc, hWnd, msg, wParam, lParam)
END FUNCTION

FUNCTION SetColor (txtColor, bkColor, wParam, lParam)
	SHARED hNewBrush
	
	
	DeleteObject (hNewBrush)
	hNewBrush = CreateSolidBrush(bkColor)
	SetTextColor (wParam, txtColor)
	SetBkColor (wParam, bkColor)
	
	RETURN hNewBrush
END FUNCTION

FUNCTION NewFont (fontName$, pointSize, weight, italic, underline)
	LOGFONT lf
	
	
	hDC 			= GetDC ($$HWND_DESKTOP)
	hFont 			= GetStockObject ($$DEFAULT_GUI_FONT)	' get a font handle
	bytes 			= GetObjectA (hFont, SIZE(lf), &lf)		' fill LOGFONT struct lf
	lf.faceName 	= fontName$														' set font name
	lf.italic 		= italic															' set italic
	lf.weight 		= weight															' set weight
	lf.underline 	= underline														' set underlined
	lf.height 		= -1 * pointSize * GetDeviceCaps(hDC, $$LOGPIXELSY) / 72.0
	ReleaseDC ($$HWND_DESKTOP, hDC)
	RETURN CreateFontIndirectA (&lf)										' create a new font and get handle

END FUNCTION

FUNCTION SetNewFont (hwndCtl, hFont)

	RETURN SendMessageA (hwndCtl, $$WM_SETFONT, hFont, $$TRUE)
END FUNCTION

FUNCTION GetTabChild (htabc)
	SHARED TabChildCon[]
	

	RETURN TabChildCon[htabc]
END FUNCTION

FUNCTION SetTabChild (htabc,handle)
	SHARED TabChildCon[]

	
	TabChildCon[htabc] = handle

	RETURN $$TRUE
END FUNCTION

FUNCTION AddSplitTabChild (hparent,STRING title,IDC)
	SHARED TabChildCon[]
	TC_ITEM tci
	
	
	found = $$FALSE
	FOR h = 0 TO UBOUND(TabChildCon[]) 
		IF TabChildCon[h] == 0 THEN
			upper = h
			found = $$TRUE
			EXIT FOR
		END IF
	NEXT h
	
	IFF found THEN
		upper = UBOUND(TabChildCon[])
		INC upper
		REDIM TabChildCon[upper]
	END IF

	tci.mask 		= $$TCIF_TEXT
	tci.pszText 	= &title
	tci.cchTextMax 	= LEN(title)
	SendMessageA (#hTabCtl, $$TCM_INSERTITEM, upper, &tci)	
	
	TabChildCon[upper] = NewChild ($$SPLITTERCLASSNAME, "", 0, 1, 40, w-130, h-46, hparent, IDC, $$WS_EX_TRANSPARENT)
	RETURN TabChildCon[upper]
END FUNCTION

FUNCTION AddListViewTabChild (hparent,STRING title,IDC)
	SHARED TabChildCon[]
	TC_ITEM tci
	
	
	found = $$FALSE
	FOR h = 0 TO UBOUND(TabChildCon[]) 
		IF TabChildCon[h] == 0 THEN
			upper = h
			found = $$TRUE
			EXIT FOR
		END IF
	NEXT h
	
	IFF found THEN
		upper = UBOUND(TabChildCon[])
		INC upper
		REDIM TabChildCon[upper]
	END IF

	tci.mask 		= $$TCIF_TEXT
	tci.pszText 	= &title
	tci.cchTextMax 	= LEN(title)
	SendMessageA (#hTabCtl, $$TCM_INSERTITEM, upper, &tci)	
	
	exStyle = $$WS_EX_TRANSPARENT | $$WS_EX_STATICEDGE | $$WS_EX_CONTEXTHELP
	TabChildCon[upper] = NewChild ($$WC_LISTVIEW, "", $$LVS_REPORT | $$LVS_NOSORTHEADER, 0, 0, 0, 0, hparent, IDC, exStyle)

	RETURN TabChildCon[upper]
END FUNCTION

FUNCTION AddEditTabChild (hparent,STRING title,IDC)
	SHARED TabChildCon[]
	TC_ITEM tci
	
	
	found = $$FALSE
	FOR h = 0 TO UBOUND(TabChildCon[]) 
		IFZ TabChildCon[h] THEN
			upper = h
			found = $$TRUE
			EXIT FOR
		END IF
	NEXT h
	
	IFF found THEN
		upper = UBOUND(TabChildCon[])
		INC upper
		REDIM TabChildCon[upper]
	END IF

	tci.mask 		= $$TCIF_TEXT
	tci.pszText 	= &title
	tci.cchTextMax 	= LEN(title)
	SendMessageA (#hTabCtl, $$TCM_INSERTITEM, upper, &tci)
	
	style = $$WS_EX_TRANSPARENT | $$WS_EX_ACCEPTFILES
	TabChildCon[upper] = NewChild ("edit", "", $$ES_MULTILINE  | $$ES_READONLY  | $$ES_LEFT , 1, 20, 300, 300, hparent, IDC, $$WS_EX_STATICEDGE | style)

	RETURN TabChildCon[upper]
END FUNCTION


FUNCTION AddRichEditTabChild (hparent,STRING title,IDC,style)
	SHARED TabChildCon[]
	TC_ITEM tci
	
	
	found = $$FALSE
	FOR h = 0 TO UBOUND(TabChildCon[]) 
		IFZ TabChildCon[h] THEN
			upper = h
			found = $$TRUE
			EXIT FOR
		END IF
	NEXT h
	
	IFF found THEN
		upper = UBOUND(TabChildCon[])
		INC upper
		REDIM TabChildCon[upper]
	END IF

	tci.mask 		= $$TCIF_TEXT
	tci.pszText 	= &title
	tci.cchTextMax 	= LEN(title)
	SendMessageA (hparent, $$TCM_INSERTITEM, upper, &tci)

	TabChildCon[upper] = CreateRichEdit (1, 20, 300, 300, hparent, IDC, 30000)
	RETURN TabChildCon[upper]
END FUNCTION

FUNCTION STRING GetText(hWnd)
	STATIC STRING text
	

	IFZ hWnd THEN RETURN ""
	text = NULL$(4096)
	t = SendMessageA (hWnd, $$WM_GETTEXT, 4096, &text)
	IF t THEN
		RETURN LTRIM$(LEFT$(text,t))
	ELSE
		RETURN ""
	END IF

END FUNCTION

FUNCTION SetText(hWnd,STRING text)

	IF (hWnd > 0) THEN
		RETURN SendMessageA (hWnd, $$WM_SETTEXT, 0, &text)
	ELSE
		RETURN 0
	END IF
END FUNCTION

FUNCTION WndProc (hWnd, msg, wParam, lParam)
	SHARED STRING LastSelNick
	SHARED TabChildCon[]
	SHARED FUNCADDR AW (XLONG,XLONG,XLONG)
	STATIC STRING tmp,buffer
	STATIC cmd$
	STATIC SHUTONCE
	TRECT rc
	POINTAPI pt
	PAINTSTRUCT ps
	STATIC t0
	STATIC text$
	SHARED STRING URLBuffer
	STATIC ENLINK en
	'STATIC GETTEXTEX getex
	STATIC TEXTRANGE txtr
	STATIC LPSCROLLINFO lpsi



	SELECT CASE msg
		CASE $$WM_MSG_CREATE :
			hWin = NewWindow ($$MSGWINCLASSNAME, "PM:", $$WS_OVERLAPPEDWINDOW, 100, 100, 550, 270, 0)	
			SendMessageA (hWin, $$WM_MSG_SETCLIENTS,wParam,lParam)
			ShowWindow (hWin, $$SW_SHOWNORMAL)
			RETURN hWin
		
		CASE $$WM_CREATE :
			#hMenuURL = CreatePopupMenu ()
			AppendMenuA (#hMenuURL, $$MF_STRING, $$POPURL_Open, &"Open URL")
			AppendMenuA (#hMenuURL, $$MF_STRING, $$POPURL_Save, &"Download")
			AppendMenuA (#hMenuURL, $$MF_SEPARATOR, 0, 0)
			AppendMenuA (#hMenuURL, $$MF_STRING, $$POPURL_Copy, &"Copy")

			#hMenuHub = CreatePopupMenu ()
			AppendMenuA (#hMenuHub, $$MF_STRING, $$POPHUB_Copy,   &"Copy              Ctrl+C")
			AppendMenuA (#hMenuHub, $$MF_STRING, $$POPHUB_SelAll, &"Select All        Ctrl+A")
	
			'ShowWindow (hWnd, $$SW_SHOWNORMAL)
			'@AW(hWnd,300,$$AW_HIDE)
			'@AW(hWnd,300,$$AW_BLEND)
			'ShowWindow (hWnd, $$SW_SHOWNORMAL)
			
'			SetWindowPos (#winMain,0,-1,-1,-1,-1,0)

		CASE $$WM_NOTIFY :
			GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
			idCtrl = idFrom

			SELECT CASE idCtrl
				CASE $$URLCatch,$$Hub
					SELECT CASE code
						CASE $$EN_LINK	:
							RtlMoveMemory (&en, lParam, SIZE(en))
							buffer = NULL$((en.chrg.cpMax - en.chrg.cpMin)+1)
							txtr.chrg = en.chrg
							txtr.lpstrText = &buffer
							ret = SendMessageA (en.hdr.hwndFrom, $$EM_GETTEXTRANGE  ,0, &txtr)
						
							SELECT CASE en.msg
								CASE $$WM_RBUTTONDBLCLK		:
								CASE $$WM_LBUTTONDOWN		:
									IF buffer != "" THEN
										pt.x = LOWORD(en.lParam): pt.y = HIWORD(en.lParam)
										ClientToScreen (en.hdr.hwndFrom, &pt)
										URLBuffer = buffer
										TrackPopupMenuEx (#hMenuURL, $$TPM_LEFTALIGN | $$TPM_LEFTBUTTON | $$TPM_RIGHTBUTTON, pt.x, pt.y, en.hdr.hwndFrom, 0)
									END IF
							END SELECT
					END SELECT		
				CASE $$Tab1 :
					SELECT CASE code
						CASE $$TCN_SELCHANGE :
							SelectTab (SendMessageA (hwndFrom, $$TCM_GETCURSEL, 0, 0))
							RETURN 0
					END SELECT
			END SELECT

	'	CASE $$WM_CREATE 		:
		CASE $$WM_DESTROY		:IFZ SHUTONCE THEN
									SHUTONCE = 1
									'DispatchDCTMsg ($$MDCT_RequestShutDown,"","")
									CleanUp()
'									SHUTONCE = 1
								 END IF
								RETURN 0
		CASE $$WM_TRAYICON 		:			' taskbar mouse event message
			idIcon = wParam
			mouseMsg = lParam
			SELECT CASE mouseMsg
			'	CASE $$WM_RBUTTONDOWN   :
			'		GetCursorPos (&pt)
    		'		SetForegroundWindow (hWnd)
    		'		TrackPopupMenuEx (#hPopMenu, $$TPM_LEFTALIGN | $$TPM_LEFTBUTTON | $$TPM_RIGHTBUTTON, pt.x, pt.y, hWnd, 0)

				CASE $$WM_LBUTTONDOWN   : 
					ShowWindow (#winMain, $$SW_SHOWNORMAL)
					'@AW(#winMain,300,$$AW_SLIDE | $$AW_HOR_POSITIVE)
				'	UpdateWindow (#winMain)
				'	IF @AW(#winMain,500,$$AW_SLIDE | $$AW_HOR_POSITIVE) THEN
				'		Beep (800,90)
				'	END IF
					SetForegroundWindow (hWnd)
			END SELECT
			RETURN 0

		CASE #WM_TaskbarRestart	: SetTaskbarIcon (hWnd, "Hub", "")

		CASE $$WM_CTLCOLOREDIT  ,$$WM_CTLCOLORSTATIC,$$WM_CTLCOLORBTN,$$WM_CTLCOLORDLG
			RETURN SetColor (RGB(100, 100, 100), RGB(212, 208, 200), wParam, lParam)

		CASE $$WM_SIZE :
			fSizeType = wParam
			width = LOWORD(lParam)
			height = HIWORD(lParam)

			clheight = 20
			SetWindowPos (#hTabCtl,0, 0, 0, width,height-clheight , 0)
			SetWindowPos (#CmdLine,0, 0, height-clheight , width, clheight ,0)
			SetWindowPos (#SearchLine,0, 0, height-clheight , width, clheight ,0)
			
			FOR w = 0 TO UBOUND(TabChildCon[])
				SetWindowPos (TabChildCon[w],0, 0, 26, width-2,height-47, 0)
			NEXT w
			
			SendMessageA (#hSplitter1, $$WM_SET_SPLITTER_POSITION, width-130, 0)
			
			'FlatSB_ShowScrollBar (#hub,$$SB_VERT,0)
			'FlatSB_ShowScrollBar (#hub,$$SB_VERT,1)
			'FlatSB_SetScrollProp(#hub, $$WSB_PROP_CYVTHUMB, GetSystemMetrics($$SM_CYVTHUMB), 1)
			 

		'	lpsi.cbSize = SIZE(lpsi)
		'	lpsi.fMask = $$SIF_PAGE | $$SIF_POS | $$SIF_RANGE | $$SIF_TRACKPOS
		'	GetScrollInfo (#hub,$$SB_VERT,&lpsi)
		'	FlatSB_SetScrollInfo (#hub,$$SB_VERT,&lpsi,1)

			SELECT CASE fSizeType
				CASE $$SIZE_MINIMIZED :
					ShowWindow (hWnd, $$SW_HIDE)
					
					'@AW(hWnd,300,$$AW_SLIDE | $$AW_VER_POSITIVE | $$AW_HOR_NEGATIVE | $$AW_HIDE)
				
					RETURN 0
			END SELECT
			
			RETURN 0
	END SELECT

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)
END FUNCTION

FUNCTION InitNewCmd (hwndCtl,STRING msg)
	STATIC STRING lastcmd


	IFZ msg THEN
		RETURN 0
	ELSE
		IF (msg == "/") THEN
			SetText (hwndCtl,lastcmd)
			RETURN 1
		END IF
	END IF

	SELECT CASE GetTokenEx2(msg,32)
		CASE "/pm","/msg"				:#MSGThread = _beginthreadex (0, 0, &ProcessClientText(), &msg, 0, &tid)
										 Sleep (2)
		CASE ELSE						:ProcessClientText (&msg)
	END SELECT

	lastcmd = msg
	SetText (hwndCtl,"\0")
	RETURN 0
END FUNCTION

FUNCTION CenterWindow (hWnd)
	TRECT wRect


	GetWindowRect (hWnd, &wRect)
	x = (GetSystemMetrics ($$SM_CXSCREEN) - (wRect.right - wRect.left))/2
	y = (GetSystemMetrics ($$SM_CYSCREEN) - (wRect.bottom - wRect.top))/2
	SetWindowPos (hWnd, 0, x, y, 0, 0, $$SWP_NOSIZE | $$SWP_NOZORDER)

END FUNCTION

FUNCTION GetNotifyMsg (lParam, hwndFrom, idFrom, code)
	NMHDR nmhdr


	nmhdrAddr = lParam
	RtlMoveMemory (&nmhdr, nmhdrAddr, SIZE(nmhdr))
	hwndFrom = nmhdr.hwndFrom
	idFrom   = nmhdr.idFrom
	code     = nmhdr.code

END FUNCTION

FUNCTION InitGui ()
	SHARED hInst
	STATIC LPINITCOMMONCONTROLSEX icc

	hInst = GetModuleHandleA (0)		' get current instance handle
	IFZ hInst THEN QUIT(0)
	IFZ #hSemCrtMsgWnd THEN #hSemCrtMsgWnd = CreateSemaphoreA (NULL,1,1,NULL)
	
	icc.size = SIZE (icc)
	icc.icc = ICC_TAB_CLASSES
	InitCommonControlsEx (&icc)
	'InitCommonControls()

	Splitter ()								' initiate splitter control
	MsgWindow ()
END FUNCTION

FUNCTION InitGUI ()
	STATIC	entry
'	SHARED FUNCADDR AW (XLONG,XLONG,XLONG)


	IF entry THEN RETURN					' enter once
	entry =  $$TRUE							' enter occured

	'AW = GetProcAddress (LoadLibraryA (&"user32.dll"),&"AnimateWindow")
	
	InitGui ()								' initialize program and libraries
	CreateWindows ()						' create main windows and other child controls
	CreateCallbacks ()						' if necessary, assign callback functions to child controls
	SetTimer (#winMain, $$HubTitle, 1000, &TimerShare())
	MessageLoop ()							' the message loop
	CleanUp ()								' unregister all window classes
END FUNCTION

FUNCTION CPrint (ECtrl,STRING text)
	SHARED MsgScroll


	IFZ text THEN RETURN $$FALSE
	trim (@text,'|')
	
	SELECT CASE ECtrl	
		CASE $$Hub			:hedit = #hub: HubChat (@text)
		CASE $$Debug		:hedit = #debug
		CASE $$Search		:hedit = #search
		CASE $$SResults		:hedit = #SResultList
		CASE $$URLCatch		:hedit = #urlcatch
		'CASE $$BotMsg		:hedit = #botmessage
		CASE ELSE			:RETURN $$FALSE
	END SELECT

	filterMessage (@text,"&#",$$Filter_DC)	' filter dc++ unicode text
	
	t0 = SendMessageA (hedit, $$EM_GETLINECOUNT, 0,0 )
	text = $$RTFHEADER + text + " " + $$NEWLINE
	SetEditText (ECtrl,@text)

	IFT MsgScroll THEN
		t1 = SendMessageA (hedit, $$EM_GETLINECOUNT, 0,0 )
		SendMessageA (hedit, $$EM_LINESCROLL, 0,(t1-t0))
	'	FlatSB_ShowScrollBar (#hub,$$SB_VERT,0)
		'FlatSB_ShowScrollBar (#hub,$$SB_VERT,1)
		RETURN $$TRUE
	ELSE
 		RETURN $$FALSE
	END IF

END FUNCTION

FUNCTION SetEditText (edit, STRING text)
	STATIC total[]


	IFZ text THEN RETURN $$FALSE
	IFZ total[] THEN
		DIM total[5]
		SendMessageA (#hub, $$EM_SETLIMITTEXT,-1, 0)
		SendMessageA (#debug, $$EM_SETLIMITTEXT,-1, 0)
		SendMessageA (#search, $$EM_SETLIMITTEXT,-1, 0)
		SendMessageA (#SResultList, $$EM_SETLIMITTEXT,-1, 0)
		SendMessageA (#urlcatch, $$EM_SETLIMITTEXT,-1, 0)
		'SendMessageA (#botmessage, $$EM_SETLIMITTEXT,-1, 0)
		ClearEditText ($$Hub)
	END IF
	
	SELECT CASE edit
		CASE $$Hub			:hedit = #hub: e = 0
		CASE $$Debug		:hedit = #debug: e = 1
		CASE $$Search		:hedit = #search: e = 2
		CASE $$SResults		:hedit = #SResultList: e = 3
		CASE $$URLCatch		:hedit = #urlcatch: e = 4
		'CASE $$BotMsg		:hedit = #botmessage: e = 5
		CASE ELSE			:RETURN $$FALSE
	END SELECT

	total[e] = total[e] + LEN(text)
	SendMessageA (hedit, $$EM_SETSEL, total[e], total[e]+1)
	SendMessageA (hedit, $$EM_REPLACESEL, 0, &text)
	RETURN $$TRUE
END FUNCTION

FUNCTION ClearEditText (edit)
	STATIC STRING text
	
	
	text = ""
	SELECT CASE edit
		CASE $$Hub			:hedit = #hub
							 text = $$RTFHEADER
		CASE $$Debug		:hedit = #debug
		CASE $$Search		:hedit = #search
		CASE $$SResults		:hedit = #SResultList
		CASE $$URLCatch		:hedit = #urlcatch
		'CASE $$BotMsg		:hedit = #botmessage
		CASE ELSE			:RETURN $$FALSE
	END SELECT

	SetText (hedit,@text)
	RETURN $$TRUE
END FUNCTION

FUNCTION HubChat (STRING text)
	SHARED TIMESTAMP


	filterMessage (@text,"http://",$$Filter_URL)
	filterMessage (@text,"www.",$$Filter_URL)
	filterMessage (@text,"ftp://",$$Filter_URL)
	filterMessage (@text,"ftp.",$$Filter_URL)

	IFT TIMESTAMP THEN text = ""+GetTime()+"; "+text
	
	RETURN $$TRUE
END FUNCTION

FUNCTION UpdateListBox (hwndCtl)
	STRING name,text
	'CRITICAL_SECTION cs
	

'	InitializeCriticalSection (&cs)
'	EnterCriticalSection (&cs)
	
'	total = UBOUND(CLtmp[])
'	FOR i = 0 TO SendMessageA (hwndCtl, $$LB_GETCOUNT, 0, 0)
'		IF i > SendMessageA (hwndCtl, $$LB_GETCOUNT, 0, 0) THEN EXIT FOR
'
'		name = NULL$(64)
'		SendMessageA (hwndCtl, $$LB_GETTEXT, i, &name)
'		name = CSIZE$(name)
'
'		NAMEFOUND = $$FALSE
'		FOR u = 0 TO total
'			IF CLtmp[u].name == name THEN
'				NAMEFOUND = $$TRUE
'				EXIT FOR
'			END IF
'		NEXT u
'		
'		IFF NAMEFOUND THEN SendMessageA (hwndCtl, $$LB_DELETESTRING, i, 0)
'	NEXT i

'	SendMessageA (hwndCtl, $$LB_RESETCONTENT,0 ,0)
	
'	FOR i = 0 TO total
'		SendMessageA (hwndCtl, $$LB_ADDSTRING, 0, &CLtmp[i].name)
'	NEXT i
	
'	LeaveCriticalSection (&cs)
'	DeleteCriticalSection (&cs)
	
	RETURN $$TRUE
END FUNCTION

FUNCTION UpdateTitle ()
	SHARED titleTimer
	SHARED LastTitleUp


	IF ((GetTickCount()-LastTitleUp) < 1100) THEN
		IFZ titleTimer THEN
			SetTimer (#winMain, $$HubTitle, 1000, &TimerShare())
			titleTimer = 1
		END IF
		RETURN $$FALSE
	ELSE
		IF titleTimer THEN
			KillTimer (#winMain,$$HubTitle)
			titleTimer = 0
		END IF
		UpdateTitleEx()
	END IF

END FUNCTION

FUNCTION UpdateTitleEx ()
	SHARED STRING HubName
	SHARED STRING HubShare
	SHARED STRING TotalHubUsers
	SHARED CONNECTED
	SHARED LastTitleUp


	LastTitleUp = GetTickCount()
	IF GetConSocket() && (CONNECTED == $$TRUE) && (#ConnToHub == $$TRUE)THEN
		title$ = "MyDC - "+HubName+" - "+TotalHubUsers+" users - " +HubShare+" TB"
	ELSE
		title$ = "MyDC"
	END IF
		
	SetWindowTextA (#winMain,&title$)
	RETURN $$TRUE
END FUNCTION

FUNCTION TimerShare (hwnd,umsg,id,time)
	SHARED titleTimer


	SELECT CASE umsg
		CASE $$WM_TIMER  :
			SELECT CASE id
				CASE $$HubTitle	:
					'hubtitle = 1
					KillTimer (#winMain,$$HubTitle)
					titleTimer = 0
					UpdateTitleEx ()
				'	DispatchDCTMsg ($$MDCT_GetHubShareTotal,"","")
				'	MessageBoxA (0,&"updated", &"title updated", $$MB_OK)
					RETURN -1
			END SELECT
	END SELECT
	
END FUNCTION

FUNCTION FileSearch (STRING who, STRING msg)
	SHARED TIMESTAMP
	SHARED SHOWSEARCH
	STRING flag
	

	IFF SHOWSEARCH THEN RETURN $$FALSE

	GetTokenEx2 (@msg,'?')	' flag
	GetTokenEx2 (@msg,'?')	' flag
	GetTokenEx2 (@msg,'?')	' flag
	GetTokenEx2 (@msg,'?')	' flag
	file$ = GetTokenEx2 (@msg,0)
	file$ = replace(file$,'$',' ')

	IFT TIMESTAMP THEN
		CPrint ($$Search,"["+GetTime()+"]("+who+") "+file$)
	ELSE
		CPrint ($$Search,"("+who+") "+file$)
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION SearchResult (STRING result)
	SINGLE size
	STRING text
	

	IFZ result THEN RETURN $$FALSE
	
	user$ = GetTokenEx2 (@result,' ')
	filepath$ = GetTokenEx2 (@result,5)
	size$ = GetTokenEx2 (@result,' ' )
	slots$ = GetTokenEx2 (@result,5)
	hub$ = GetTokenEx2 (@result,0)
	
	DecomposePathname (filepath$, @path$, parent$, @filename$, file$, extent$)
	size = SINGLE (size$) / 1024 / 1024

	IF size THEN
		size$ = FORMAT$("####.##",size)+" MB"
	ELSE
		hub$ = slots$
		slots$ = RIGHT$(filepath$,3)
		size$ = ""
		filename$ = ""
		len = LEN(filepath$)
		filepath${len} = 0
		filepath${len-1} = 0
		filepath${len-2} = 0
		filepath${len-3} = 0
		filepath$ = TRIM$(filepath$)
	END IF
	
	last = SendMessageA (#SResultList, $$LVM_GETITEMCOUNT, 0, 0)
	InsertListViewItem (#SResultList,last,@user$)

	'SetListViewSubItem (#SResultList, $$SR_USER , text, last)
	SetListViewSubItem (#SResultList, $$SR_FILENAME,@filename$, last)
	SetListViewSubItem (#SResultList, $$SR_SIZE, @size$ , last)
	SetListViewSubItem (#SResultList, $$SR_SLOTS, @slots$, last)
	SetListViewSubItem (#SResultList, $$SR_FILEPATH, @filepath$, last)
	SetListViewSubItem (#SResultList, $$SR_SLOTS, @slots$, last)
	SetListViewSubItem (#SResultList, $$SR_HUB, @hub$, last)
	
	RETURN $$TRUE
END FUNCTION

FUNCTION CCmdMsg (STRING to, STRING from, STRING text)
	SHARED TIMESTAMP
	STATIC hMsgWin[]
	STATIC once
	TMsgWin MsgWin
	

	IFZ to THEN RETURN $$FALSE
	IFZ from THEN RETURN $$FALSE
	IFZ text THEN RETURN $$FALSE
	
	IFZ GetConSocket() THEN
		RemoveClients ()
		CPrint ($$Hub,"* no connection")
		RETURN $$FALSE
	END IF
	
	IFZ once THEN
		once = 1 
		DIM hMsgWin[0]
	END IF

	found = $$FALSE
	FOR w = 0 TO UBOUND(hMsgWin[])
		IF hMsgWin[w] THEN
			pData = GetWindowLongA (hMsgWin[w], $$GWL_USERDATA)
			IF pData THEN
				RtlMoveMemory (&MsgWin, pData, SIZE(TMsgWin))
				IF ((MsgWin.from == from) && (MsgWin.to == to)) || ((MsgWin.from == to) && (MsgWin.to == from)) THEN
					found = $$TRUE
					hWin = MsgWin.hwin
					EXIT FOR
				END IF
			END IF
		END IF
	NEXT w
		
	IFF found THEN
		hWin = SendMessageA (#winMain,$$WM_MSG_CREATE,&from,&to)
		IF hWin THEN
			w = UBOUND(hMsgWin[])+1
			REDIM hMsgWin[w]
			hMsgWin[w] = hWin
		ELSE
			CPrint ($$Hub,":: unable to create MsgWindow: from="+from+" to="+to)
			RETURN $$FALSE
		END IF
	END IF

	IFT TIMESTAMP THEN
		text = "["+GetTime()+"]"+DisplayNick(from)+" "+text
		SendMessageA (hWin,$$WM_MSG_SETTEXT,&text,$$MsgEdit)
	ELSE
		text = DisplayNick(from)+" "+text
		SendMessageA (hWin,$$WM_MSG_SETTEXT,&text,$$MsgEdit)
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION AddClientFull (STRING list, total)
	STRING share,comment,tag,name,info
	SINGLE sshare


	UpdateTitle ()
	i = SendMessageA (#hInfoListV,$$LVM_GETITEMCOUNT, 0, 0)
	
'	XstLog ("list:  "+list,0,"t:\\clist.log")
	'XstLog ("total: "+STRING$(total)+" size: "+STRING$(SIZE(list)),0,"t:\\clist.log")
	
	FOR c = 1 TO total
		name = GetTokenEx2 (@list,5)
		IF name THEN
			info = GetTokenEx2 (@list,5)
		
			'i = FindListViewItem (#hInfoListV,-1,@name)
			'IF (i == -1) THEN
				'i = SendMessageA (#hInfoListV,$$LVM_GETITEMCOUNT, 0, 0)
				InsertListViewItem (#hInfoListV,i,@name)
			'END IF

			comment = GetTokenEx2 (@info,'$')
			x = INSTR (comment,"<++ V")
			IFZ x THEN x = INSTR (comment,"<oDC V")
			IF x THEN
				tag = RIGHT$ (comment,LEN(comment)-x+1)
				comment = LEFT$(comment,x-1)
			ELSE
				tag = ""
			END IF
		
			SetListViewSubItem (#hInfoListV, $$CL_COMMENT,@comment, i)
			SetListViewSubItem (#hInfoListV, $$CL_TAG,@tag, i)
			SetListViewSubItem (#hInfoListV, $$CL_CONNECTION,GetTokenEx2(@info,'$'), i)
			SetListViewSubItem (#hInfoListV, $$CL_EMAIL,GetTokenEx2(@info,'$'), i)
			sshare = SINGLE (GetTokenEx2(@info,'$')) / 1024 / 1024 / 1024
		
			IF sshare THEN
				share = LTRIM$(FORMAT$("####.##",sshare))+ " GB"
			ELSE
				share = "0 GB"
			END IF
			SetListViewSubItem (#hInfoListV, $$CL_SHARED ,@share, i)

			'SetListViewSubItem (#hInfoListV, $$CL_Op, GetTokenEx (@info,'$',0), i)
			INC i
		ELSE
			EXIT FOR
		END IF
	NEXT c

	UpdateTitle ()
	RETURN 1
END FUNCTION

FUNCTION AddClient (STRING name, STRING info)
	STRING share,comment,tag
	SINGLE sshare
	

	ret = 0
	IF name THEN
		i = FindListViewItem (#hInfoListV,-1,@name)
		IF (i == -1) THEN
			' not in list so add
			i = SendMessageA (#hInfoListV,$$LVM_GETITEMCOUNT, 0, 0)
			InsertListViewItem (#hInfoListV,i,@name)
			ret = 1
		END IF

		comment = GetTokenEx2 (@info,'$')
		x = INSTR (comment,"<++ V")
		IFZ x THEN x = INSTR (comment,"<oDC V")
		IF x THEN
			tag = RIGHT$ (comment,LEN(comment)-x+1)
			comment = LEFT$(comment,x-1)
		ELSE
			tag = ""
		END IF
		
		SetListViewSubItem (#hInfoListV, $$CL_COMMENT,@comment, i)
		SetListViewSubItem (#hInfoListV, $$CL_TAG,@tag, i)
		SetListViewSubItem (#hInfoListV, $$CL_CONNECTION,GetTokenEx2 (@info,'$'), i)
		SetListViewSubItem (#hInfoListV, $$CL_EMAIL,GetTokenEx2 (@info,'$'), i)
		sshare = SINGLE (GetTokenEx (@info,'$',0)) / 1024 / 1024 / 1024
		
		IF sshare THEN
			share = LTRIM$(FORMAT$("####.##",sshare))+ " GB"
		ELSE
			share = "0 GB"
		END IF
		SetListViewSubItem (#hInfoListV, $$CL_SHARED ,@share, i)
		'SetListViewSubItem (#hInfoListV, $$CL_Op, GetTokenEx2 (@info,'$'), i)
	
		UpdateTitle ()
	END IF
	
	RETURN ret
END FUNCTION

FUNCTION RemoveClient (STRING user)
	
	'user = TRIM$(user)
	i = FindListViewItem (#hInfoListV,-1,@user)
	IF (i != -1) THEN
		SendMessageA (#hInfoListV,$$LVM_DELETEITEM, i, 0)
	END IF
	
	UpdateTitle ()

	RETURN $$TRUE
END FUNCTION

FUNCTION RemoveClients ()

	SendMessageA (#hInfoListV, $$LVM_DELETEALLITEMS,0 ,0)
	SetTotalUsers (0)
	UpdateTitle ()	
	
	RETURN $$TRUE
END FUNCTION

FUNCTION FindListViewItem (hwndCtl,start,STRING item)
	STATIC LV_FINDINFO lvf
	
	
	IFZ item THEN RETURN -1
	lvf.flags = $$LVFI_STRING
	lvf.psz = &item
	
	RETURN SendMessageA (hwndCtl, $$LVM_FINDITEM, start, &lvf)
END FUNCTION

FUNCTION STRING GetListViewItem (hwndCtl,i)
	STATIC LV_ITEM lvi
	STATIC STRING item

	item = NULL$(65)
	lvi.mask 		= $$LVIF_TEXT
	lvi.state		= 0
	lvi.stateMask 	= 0
	lvi.iItem 		= i
	lvi.pszText 	= &item
	lvi.cchTextMax	= 64

	IF SendMessageA (hwndCtl, $$LVM_GETITEM, 0, &lvi) THEN
		RETURN CSTRING$(&item)
	ELSE
		RETURN ""
	END IF
END FUNCTION

FUNCTION AddClients (STRING nicklist)
	STRING name


	first = 1
	nicklen = 1
	last = SendMessageA (#hInfoListV,$$LVM_GETITEMCOUNT, 0, 0)

	FOR n = 1 TO SIZE(nicklist)
		IF (nicklist{n} == 5) THEN
			name = MID$(nicklist,first,nicklen)
			first = n+2
			IF name THEN
				'last = SendMessageA (#hInfoListV, $$LVM_GETITEMCOUNT, 0, 0)
				InsertListViewItem (#hInfoListV,last,@name)
				INC last
			END IF
			nicklen = 0
		ELSE
			INC nicklen
		END IF
	NEXT n
	
	Sleep (50)
	UpdateTitle ()
	
	RETURN $$TRUE
END FUNCTION

FUNCTION CCmdNick (STRING nick)
	SHARED STRING Nick
	

	IF Socket THEN
		CPrint ($$Hub,"* cannot modify username while connected")
		RETURN $$FALSE
	END IF
	
	nick = trim(trim(trim(trim(nick,0),32),13),10)
	IF nick THEN
		Nick = nick
		DispatchDCTMsg ($$MDCT_SetNick,Nick,Nick+"-")
		CPrint ($$Hub,"* username set to "+Nick)
	END IF
	
	RETURN $$TRUE
END FUNCTION

FUNCTION CCmdDisconnect ()

'	DisconnectFromServer (GetConSocket())
	DispatchDCTMsg ($$MDCT_Disconnect,"","")
	RETURN $$TRUE
END FUNCTION

FUNCTION CCmdConnect (STRING address,port)
	SHARED STRING Server
	SHARED Port


	IFZ address THEN CPrint ($$Hub,"* invalid address")
	IFZ port THEN port = $$Default_Port
	
	Server = address
	Port = port
	DispatchDCTMsg ($$MDCT_ConnectToAddress,Server,STRING$(Port))
	
	RETURN $$TRUE
END FUNCTION

FUNCTION CCmdReconnect ()
	SHARED STRING Server
	SHARED Port


	IF GetConSocket() THEN
		CCmdDisconnect ()
		SleepMsg (1000)
	END IF
	CCmdConnect (Server,Port)

	RETURN $$TRUE
END FUNCTION

FUNCTION SleepMsg (time)
	USER32_MSG msg
	
	
	' QueryPerformanceCounter(lppc)
	t0 = GetTickCount()
	DO
		IF PeekMessageA (&msg,0 , 0, 0, 0) THEN
			GetMessageA (&msg, 0, 0, 0)
			TranslateMessage (&msg)
  			DispatchMessageA (&msg)
  		ELSE
  			Sleep (1)
  		END IF

  	LOOP WHILE ((GetTickCount()-t0) < time)
  	
END FUNCTION

FUNCTION ProcessClientText (addrtext)
	STATIC cmd$,msg$


	IFZ addrtext THEN RETURN $$FALSE
	str$ = trim(CSTRING$(addrtext),'|')
	IFZ	str$ THEN RETURN $$FALSE

	IF str${0} == '/' THEN
		str${0} = 0
		msg$ = LTRIM$(str$)
		GetToken (@msg$,@cmd$,32)
	'	filterMessage (@msg$,"\\\\",$$Filter_NAME)
		
		IFF ProcessClientCommand (cmd$,msg$) THEN
			DispatchDCTMsg ($$MDCT_ClientCmdMsg,@cmd$,@msg$)
		END IF
	ELSE
		IFZ GetConSocket() THEN
			RemoveClients ()
			CPrint ($$Hub,"* no connection")
			RETURN $$FALSE
		END IF
		
	'	filterMessage (@str$,"\\\\",$$Filter_NAME)
		DispatchDCTMsg ($$MDCT_SendPubTxt,@str$,"")

	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION SetConSocket(sock)
	SHARED socket
	
	socket = sock
	RETURN $$TRUE
END FUNCTION

FUNCTION MAKELONG (lo, hi)

	RETURN lo | (hi << 16)
END FUNCTION

FUNCTION LOWORD (x)

	RETURN x{{16,0}}
END FUNCTION


FUNCTION DecomposePathname (pathname$, @path$, @parent$, @filename$, @file$, @extent$)
'
	path$ = ""
	file$ = ""
	extent$ = ""
	parent$ = ""
	filename$ = ""
	name$ = TRIM$ (pathname$)
	dot = RINSTR (name$, ".")
	slash = getLastSlash(name$, -1)
	
	IF slash THEN preslash = getLastSlash(name$, slash-1)
	IF (dot < slash) THEN dot = 0
'
	filename$ = MID$ (name$, slash+1)							' filename = "name.ext"
	IFZ dot THEN
		file$ = filename$										' file = filename (filename has no extent)
	ELSE
		file$ = MID$ (name$, slash+1, dot-slash-1)	' file = "name" (without extent)
		extent$ = MID$ (name$, dot)					' extent = ".ext"
	END IF
'
	IF slash THEN
		path$ = LEFT$ (name$, slash-1)							' path = full pathname to left of "/file.ext"
		IF preslash THEN
			parent$ = MID$ (name$, preslash+1, slash-preslash-1)
		ELSE
			parent$ = LEFT$ (name$, slash-1)
		END IF
	END IF
	
END FUNCTION

FUNCTION getLastSlash(str$, stop)
	$PathSlash$   = "\\" 

	IF stop < 0 THEN
		slash1 = RINSTR(str$, "/")
		slash2 = RINSTR(str$, $PathSlash$)
	ELSE
		slash1 = RINSTR(str$, "/", stop)
		slash2 = RINSTR(str$, $PathSlash$, stop)
	END IF
	IFZ slash1 THEN
		RETURN slash2
	ELSE
		RETURN MAX(slash1, slash2)
	END IF
	
END FUNCTION


FUNCTION SocketListen (socket)

	IF (listen (socket, 1) == $$SOCKET_ERROR) THEN
		CPrint ($$Hub,"* SocketListen: "+GetLastErrorStr())
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF
		
END FUNCTION

FUNCTION SocketBind (socket,STRING address,port)
	SOCKADDR_IN udtSocket


	numIPAddr$ = GetNumIPAddr (address)
	address$$ = inet_addr (&numIPAddr$)
	IF (address$$ <= 0) THEN address$$ = $$INADDR_ANY
	IF (port <= 0) THEN port = 0
	
	udtSocket.sin_family = $$AF_INET
	udtSocket.sin_port = htons (port)
	udtSocket.sin_addr = address$$
	length = LEN (udtSocket)
	
	IF bind (socket, &udtSocket, length) == $$SOCKET_ERROR THEN
		CPrint ($$Hub,"* SocketBind: "+GetLastErrorStr())
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF
	
END FUNCTION

FUNCTION SocketAccept (socket,STRING claddress,clport) ' returns client socket along with client address and port
	SOCKADDR_IN  sockaddrin
	
	
	size = SIZE(sockaddrin)
	clientsocket = accept (socket, &sockaddrin, &size)
	claddress = CSTRING$(inet_ntoa (sockaddrin.sin_addr))
	clport = htons(sockaddrin.sin_port)

	RETURN clientsocket
END FUNCTION

FUNCTION SocketSend (socket,pbuffer,tbytes)
	SHARED CONNECTED
	

	bytessent = 0

	DO WHILE (CONNECTED == $$TRUE)
		tbytes = tbytes - bytessent
		bytessent = send (socket,pbuffer + bytessent,tbytes,0)
		
		IF (bytessent == $$SOCKET_ERROR) THEN
			CPrint ($$Hub,"* SendBin: "+GetLastErrorStr())
			RETURN $$FALSE
		END IF
	LOOP WHILE (bytessent < tbytes)
	
	RETURN $$TRUE
END FUNCTION

FUNCTION SocketRecv (socket,STRING buffer,bufferlen)
	TZPASS zpass
	STRING dbuffer,oldbuffer

	
'	XstLog ("in",1,"c:\\z.log")
	
	zpass.uncompsize = 0
	zpass.compsize = 0

	tdata = 0
	oldbuffer = ""
	
	DO
		dbuffer = NULL$(SIZE(zpass))
		a = recv (socket, &dbuffer, SIZE(zpass), 0)
		IF (a == $$SOCKET_ERROR) THEN RETURN $$SOCKET_ERROR
		IF (a == 0) THEN RETURN 0
		
		IF a < SIZE(zpass) THEN
			tdata = tdata + a
			dbuffer = oldbuffer + dbuffer
			oldbuffer = dbuffer
		ELSE
			EXIT DO
		END IF
	LOOP WHILE (tdata < SIZE(zpass))
	memcpy (&zpass,&dbuffer,SIZE(zpass))
	
	'XstLog (STRING$(a)+":"+STRING$(b)+":"+STRING$(zpass.compsize)+":"+STRING$(zpass.uncompsize),1,"c:\\z.log")

	oldbuffer = ""
	tdata = 0
	
	DO
		dbuffer = NULL$(zpass.compsize)
		b = recv (socket, &dbuffer, zpass.compsize, 0)
		IF (b == $$SOCKET_ERROR) THEN RETURN $$SOCKET_ERROR
		IF (b == 0) THEN RETURN 0

		IF b < zpass.compsize THEN
			tdata = tdata + b
			dbuffer = oldbuffer + dbuffer
			oldbuffer = dbuffer
		ELSE
			EXIT DO
		END IF
	LOOP WHILE (tdata < zpass.compsize)

	
	buffer = NULL$(zpass.uncompsize)
	bufferlen = zpass.uncompsize
'	uncompress (&buffer,&bufferlen,&dbuffer,zpass.compsize)

	'XstLog (STRING$(bufferlen),1,"c:\\z.log")

	RETURN bufferlen
END FUNCTION

FUNCTION SocketClose (socket)
	
	RETURN closesocket (socket)
END FUNCTION

FUNCTION SocketOpen (sockettype)


	IFZ sockettype THEN RETURN 0
	
	socket = socket ($$AF_INET, sockettype, 0)
	IFZ socket THEN
		CPrint ($$Hub,"* SocketOpen: "+GetLastErrorStr())
		RETURN 0
	END IF
	
	RETURN socket
	
END FUNCTION

FUNCTION SocketConnect (socket,STRING address,port)
	SOCKADDR_IN udtSocket

	
	udtSocket.sin_family = $$AF_INET
	udtSocket.sin_port = htons (port)
	udtSocket.sin_addr = inet_addr (&ipaddress$)

	IF udtSocket.sin_addr = $$INADDR_NONE THEN
		NumIPAddr$ = GetNumIPAddr (address)
		udtSocket.sin_addr = inet_addr (&NumIPAddr$)
	END IF
	
	IF (connect (socket, &udtSocket, SIZE(udtSocket)) == $$SOCKET_ERROR) THEN
		CPrint ($$Hub,"* SocketConnect: "+GetLastErrorStr())
		RETURN $$FALSE
	ELSE
		'setsockopt(socket,$$SOL_SOCKET,$$SO_LINGER,0,0)
		'setsockopt(socket,$$SOL_SOCKET,$$SO_REUSEADDR,0,0)
		setsockopt(socket,$$SOL_SOCKET,$$SO_KEEPALIVE,0,0)
		
		RETURN $$TRUE
	END IF

END FUNCTION

FUNCTION SocketInitWinSock()
	WSADATA wsadata
	

	version = 2 OR (2 << 8)								' version winsock v2.2 (MAKEWORD (2,2))
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll
	IF ret THEN
		CPrint ($$Hub,"* SocketInitWinSock:wsa: "+GetLastErrorStr())
		WSACleanup ()
		RETURN $$FALSE
	END IF

	IF wsadata.wVersion != version THEN
		CPrint ($$Hub,"* SocketInitWinSock:wsa: "+GetLastErrorStr())
		WSACleanup ()
		RETURN $$FALSE
	END IF
	
	RETURN $$TRUE
	
END FUNCTION

FUNCTION SendMsg (socket,STRING buffer)
	SHARED CONNECTED
	
	
	IFT CONNECTED THEN
		'buffer = buffer + "\r\n"		' depending on what the host expected to receive terminating
		buffer = buffer + "|"
		RETURN SendBin (socket, &buffer, SIZE(buffer))
	ELSE
		RETURN $$FALSE
	END IF

END FUNCTION

FUNCTION SendBin (socket,pbuffer,tbytes)

	RETURN SocketSend (socket, pbuffer, tbytes)
END FUNCTION

FUNCTION ListenBin (socket,UBYTE buffer[],tbytes)
	SHARED CONNECTED

	
	IFZ tbytes THEN RETURN $$FALSE

	DIM buffer[tbytes-1]
	rover = &buffer[]
	read = 0
		
	DO WHILE (read < tbytes)
		thisRead = SocketRecv (socket,rover, tbytes-read)
	
		IF (thisRead == $$SOCKET_ERROR || thisRead == 0) THEN
			IF (thisRead == $$SOCKET_ERROR) THEN
				CPrint ($$Hub,"* ListenBin: "+GetLastErrorStr())
				EXIT DO
			ELSE
				EXIT DO
			END IF
		ELSE		
			read = read + thisRead
			rover = rover + thisRead
		END IF
	LOOP WHILE (CONNECTED == $$TRUE)
	
	tbytes = read
	RETURN $$TRUE

END FUNCTION

FUNCTION MDCT_Disconnected ()
	SHARED socket
	SHARED DISCONCE
	

'	IF DISCONCE THEN
'		RETURN
'	ELSE
'		DISCONCE = 1
'	END IF

'	IF socket THEN SocketClose (socket)
'	socket = 0

	SetHubShare (0)
	SetHubName ("")
	SetTotalUsers (0)
	Sleep (100)
	RemoveClients ()
'	SetConSocket (0)
'	CPrint ($$Hub,"\r\n\* "+GetTime()+": disconnected from server")
				
END FUNCTION

FUNCTION ListenMsg (socket)
	SHARED CONNECTED
	STRING buffer
	
	
	buffer = NULL$ ($$ZSocketBuffer)
	DO WHILE socket
		'buffer = NULL$ ($$ZSocketBuffer)
		'bytesRead = SocketRecv (socket,@buffer, $$ZSocketBuffer)
		bytesRead = recv (socket, &buffer, $$ZSocketBuffer, 0)
		IF (bytesRead == $$SOCKET_ERROR) THEN
			IFT GetConSocket() THEN CPrint ($$Hub,$$NEWLINE+"* ListenMsg: "+GetLastErrorStr())
			EXIT DO
		ELSE
			IFZ bytesRead THEN
				CPrint ($$Hub,$$NEWLINE+"* Disconnected from proxy")
				EXIT DO
			END IF
		END IF

		MessagePump (socket,LEFT$(buffer,bytesRead))				' send message to queue
	LOOP WHILE (CONNECTED == $$TRUE) && (#SHUTDOWN == $$FALSE)

	CONNECTED = $$FALSE
	SetConSocket (0)
	MDCT_Disconnected ()
	RETURN $$FALSE
END FUNCTION

FUNCTION MessagePump (socket,msg$)
	SHARED CONNECTED
	STATIC cmd$
	STATIC STRING msg1,msg2
	STATIC token
	STATIC tstart,tend
	STATIC m1start,m1end
	STATIC m2start,m2end
	STATIC flag


	msg$ = cmd$ + msg$
	msglen = LEN(msg$)
	p = LEN (cmd$)
	start = 1
	
	DO
		SELECT CASE msg${p}
			CASE $$PCCA		:IF (flag == 0x00) THEN
								flag = $$PCCB
								token = 0
								msg1 = "": msg2 = ""
								m1start = 0: m1end = 0
								m2start = 0: m2end = 0
								tstart = p+2
							END IF
			CASE $$PCCB		:IF (flag == $$PCCB) THEN
								flag = $$PCCC
								tend = p-tstart+1
								token = XLONG(TRIM$(MID$(msg$,tstart,tend)))
								m1start = p+2
						'	ELSE
						'		flag = 0x00
							END IF
			CASE $$PCCC		:IF (flag == $$PCCC) THEN
								flag = $$PCCD
								m1end = p-m1start+1
								msg1 = MID$(msg$,m1start,m1end)
								m2start = p+2
						'	ELSE
						'		flag = 0x00
							END IF
			CASE $$PCCD		:IF (flag == $$PCCD) THEN
							 	m2end = p-m2start+1
								msg2 = MID$(msg$,m2start,m2end)
							 	IF token THEN DllProc (token, @msg1,@msg2)
							 	msg1 = ""
							 	msg2 = ""
							 	flag = 0x00
							 	start = p+2
							 END IF
		END SELECT

		INC p	
	LOOP WHILE ((p < msglen) && (CONNECTED == $$TRUE))
	
	cmd$ = MID$(msg$,start,p-start+1)
	msg$ = ""

	RETURN 0
END FUNCTION

FUNCTION ProcessToken (socket,STRING message) 	' process each token (command) from host
	STRING msg1,msg2


	GetTokenEx (@message,$$PCCA,0)
	token = XLONG(TRIM$(GetTokenEx (@message,$$PCCB,0)))
	IFZ token THEN RETURN $$FALSE
	
	msg1 = TRIM$(GetTokenEx (@message,$$PCCC,0))
	msg2 = TRIM$(message) ' ,$$PCCD)
	DllProc (token, @msg1,@msg2)
END FUNCTION

FUNCTION ConnectToServer (STRING server,port)
	SHARED LastSockSendT
	SHARED CONNECTED
	SHARED STRING Nick,Server
	SHARED Port
	SHARED DISCONCE 
	

	IFT CONNECTED THEN
		CPrint ($$Hub,":: already connected to "+Server+":"+STRING$(Port))
		RETURN 0
	END IF

	IFZ port THEN port = $$Default_Port
'	info$ = server+":"+STRING$(port)
'	DispatchDCTMessage ($$MDCT_InitiatingConn,Nick,info$)

	socket = SocketOpen ($$SOCK_TCP)		' create TCP socket
	IFZ socket THEN	RETURN 0

	'IFF SocketBind (socket, "",$$LOCALPORT) THEN

	IFT SocketConnect (socket,server,port) THEN
		RemoveClients ()
		LastSockSendT = GetTickCount()
		Server = server
		Port = port
		SetConSocket(socket)
	'	CPrint ($$Hub,"connected")
		CONNECTED = $$TRUE
		DISCONCE = 0
		#hThread = _beginthreadex (NULL, 0, &ListenMsg(), socket, 0, &tid)
		'#hThread = CreateThread (NULL, 0, &ListenMsg(), socket, 0, &tid)
		
		Sleep(1) ' give time for ListenMsg() to startup
		'info$ = Nick+":"+Server+":"+STRING$(Port)+":"
		'DispatchDCTMessage ($$MDCT_ClientConnected,STRING$(socket),info$)
	'	SendConnStatus ()
		RETURN socket
	ELSE
		CONNECTED = $$FALSE
		SocketClose (socket)
		SetConSocket(0)
'		DispatchDCTMessage ($$MDCT_Error,$$MDCE_ConnectFailed,info$)
		RETURN 0
	END IF
END FUNCTION

FUNCTION STRING GetNumIPAddr (IPName$)
	WSADATA wsadata
	HOSTENT	host


	host = gethostbyname (&IPName$)

	IF host.h_addr_list <> 0 THEN
		addr = 0
		RtlMoveMemory (&addr, host.h_addr_list, 4)
		RtlMoveMemory (&addr, addr, 4)

		addr2 = inet_ntoa (addr)

'		length = strlen (addr2)
		numIPAddr$ = NULL$ (512)
		RtlMoveMemory (&numIPAddr$, addr2, LEN(numIPAddr$))

		RETURN CSIZE$ (numIPAddr$)
	ELSE
		RETURN ""
	END IF
	
END FUNCTION

FUNCTION  CreateRichEdit (x, y, w, h, hParent, id, kbTextMax)
	SHARED hInst

' load riched20.dll or riched32.dll if available

	class$ = "richedit20A"
	hRichEditDll = LoadLibraryA (&"riched20.dll")
	IFZ hRichEditDll THEN
		class$ = "richedit"
		hRichEditDll = LoadLibraryA (&"riched32.dll")
	END IF
	IFZ hRichEditDll THEN RETURN 0

' create rich edit child window
	style = $$WS_VISIBLE | $$WS_CHILD
	style = style | $$ES_MULTILINE  | $$ES_READONLY  '  | $$ES_SUNKEN
	style = style   | $$WS_VSCROLL ' | $$WS_HSCROLL
	style = style | $$ES_AUTOVSCROLL '  | $$ES_AUTOHSCROLL 
	'style = style | $$ES_NOHIDESEL 
	style = style | $$ES_SAVESEL  ' | $$ES_WANTRETURN' | $$WS_OVERLAPPED
	 
	
	exstyle =  $$WS_EX_STATICEDGE 
	'style = style | $$ES_MULTILINE | $$ES_READONLY | $$ES_LEFT 
	hRichEd =  CreateWindowExA (exstyle, &class$, 0, style, x, y, w, h, hParent, id, hInst, 0)

' set upper limit to amount of text in rich edit control
' default upper limit is 32k, max upper is 2GB
	SendMessageA (hRichEd, $$EM_EXLIMITTEXT, 0, 1024 * kbTextMax)
	SendMessageA (hRichEd, $$EM_SETBKGNDCOLOR, 0, RGB(212, 208, 200))
	SendMessageA (hRichEd, $$EM_AUTOURLDETECT, 1, 0)
	SendMessageA (hRichEd, $$EM_SETEVENTMASK , 0 , $$ENM_LINK )
	SetText (hRichEd, $$RTFHEADER)

	RETURN hRichEd
END FUNCTION

FUNCTION SetClipText (STRING text)
	$Text = 1

	length = LEN(text) << 1 + 1
	handle = GlobalAlloc (0x2002, length)
	addr = GlobalLock (handle)
	j = 0
	'preByte = 0

	IFZ text THEN
		UBYTEAT (addr) = 0				' if text$ is an empty string
	ELSE
		FOR i = 0 TO LEN(text)
			byte = text{i}
			UBYTEAT (addr,j) = byte
			
			IF (byte == 0x0D) THEN
				IF text{i+1} != 0x0A THEN
			'	IF (preByte != 0x0A) THEN
			'		UBYTEAT (addr,j) = 0x0D
					INC j
					UBYTEAT (addr,j) = 0x0A
				END IF
			END IF

			'preByte = byte
			INC j
		NEXT i
	END IF

	OpenClipboard (0)
	EmptyClipboard ()
	GlobalUnlock (handle)
	SetClipboardData ($Text, handle)
	CloseClipboard ()

END FUNCTION

FUNCTION URL_SaveFile (STRING filename,TBUFFER buff[])


	hfile = open_file (&filename, &"wb")
	IFZ hfile THEN RETURN 0
	
	FOR i = 0 TO UBOUND(buff[])
		IF buff[i].size THEN
			write_file (hfile,&buff[i].buffer[0],buff[i].size)
		ELSE
			EXIT FOR
		END IF
	NEXT i

	close_file (hfile)
	RETURN 1
END FUNCTION

FUNCTION URL_GetFile (STRING URL,TBUFFER buff[])
	FUNCADDR Open (XLONG, XLONG, XLONG, XLONG, XLONG)
	FUNCADDR OpenUrl (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
	FUNCADDR ReadFile (XLONG, XLONG, XLONG, XLONG)
	FUNCADDR CloseHandle (XLONG)
	STRING null,agent


	IFZ URL THEN RETURN 0

	hWininetDll = LoadLibraryA (&"wininet.dll")
	IFZ hWininetDll THEN RETURN 0

	Open = GetProcAddress (hWininetDll, &"InternetOpenA")
	OpenUrl = GetProcAddress (hWininetDll, &"InternetOpenUrlA")
	ReadFile = GetProcAddress (hWininetDll, &"InternetReadFile")
	CloseHandle = GetProcAddress (hWininetDll, &"InternetCloseHandle")

	IFZ Open THEN
		FreeLibrary (hWininetDll)
		RETURN 0
	ELSE
		IFZ OpenUrl THEN
			FreeLibrary (hWininetDll)
			RETURN 0
		ELSE
			IFZ ReadFile THEN
				FreeLibrary (hWininetDll)
				RETURN 0
			ELSE
				IFZ CloseHandle THEN
					FreeLibrary (hWininetDll)
					RETURN 0
				END IF
			END IF
		END IF
	END IF

	null = ""
	agent = "httpGetFile"
	hSession = @Open (&agent, $$INTERNET_OPEN_TYPE_PRECONFIG, &null, &null, 0)
	IFZ hSession THEN RETURN 0

	hOpenUrl = @OpenUrl (hSession, &URL, &null, 0, $$INTERNET_FLAG_RELOAD | $$INTERNET_FLAG_EXISTING_CONNECT, 0)
	IFZ hOpenUrl THEN
		IF (hSession != 0) THEN @CloseHandle (hSession)
		RETURN 0
	END IF
	
	DIM buff[15]
	tbytes = 0
	i = 0

	DO
		IFZ @ReadFile (hOpenUrl,&buff[i].buffer[0],65530,&buff[i].size) THEN EXIT DO
		IFZ buff[i].size THEN EXIT DO
		tbytes = tbytes + buff[i].size

		INC i
		IF (i >= UBOUND(buff[])) THEN REDIM buff[i+15]
	LOOP

	' Use InternetGetLastResponseInfo () to retrieve error info

	IF (hOpenUrl != 0) THEN @CloseHandle (hOpenUrl): hOpenUrl = 0
	IF (hSession != 0) THEN @CloseHandle (hSession): hSession = 0

	RETURN tbytes
END FUNCTION

FUNCTION open_file (lpfilename, flags)


	IFZ lpfilename THEN RETURN 0
	IFZ flags THEN
		type = &"rb"
	ELSE
		type = flags
	END IF
	
	hfile = fopen (lpfilename, type)
	IFZ hfile THEN
		RETURN 0
	ELSE
		RETURN hfile
	END IF
END FUNCTION

FUNCTION close_file (file)

	IF file THEN
		fclose (file)
		RETURN 1
	ELSE
		RETURN 0
	END IF
END FUNCTION

FUNCTION write_file (hfile,ULONG buffer,nbytes)

	'_write (hfile, buffer, nbytes)
	foffset = 0
	fgetpos (hfile,&foffset)
	
	IF (fwrite (buffer, 1, nbytes, hfile) < nbytes) THEN
		RETURN -1
	ELSE
		RETURN foffset
	END IF
END FUNCTION

FUNCTION ShowSaveFileDialog (hWndOwner, fileName$, filter$, initDir$, title$)
	OPENFILENAME ofn
	SHARED hInst

	ofn.lStructSize = SIZE(ofn)
	ofn.hwndOwner 	= hWndOwner
	ofn.hInstance 	= hInst
	ofn.lpstrFilter = &filter$

'create a buffer for the returned file
	IF fileName$ = "" THEN
		fileName$ = SPACE$(254)
	ELSE
		fileName$ = fileName$ + SPACE$(254 - LEN(fileName$))
	END IF
	ofn.lpstrFile 			= &fileName$

	ofn.nMaxFile = 255
	buffer2$ = SPACE$(254)
	ofn.lpstrFileTitle = &buffer2$
	ofn.nMaxFileTitle = 255
	ofn.lpstrInitialDir = &initDir$
	ofn.lpstrTitle = &title$
	ofn.flags = $$OFN_PATHMUSTEXIST | $$OFN_EXPLORER

'call dialog
	IFZ GetSaveFileNameA (&ofn) THEN
		fileName$ = ""
		RETURN 0
	ELSE
		fileName$ = CSTRING$(ofn.lpstrFile)
		RETURN 1
	END IF
END FUNCTION

FUNCTION STRING StripRTF (STRING text)

	Replace(@text,"\\","\\\\")
	Replace(@text,"{","\\{")
	Replace(@text,"}","\\}")
	Replace(@text,"\r\n"," "+ $$NEWLINE)
	Replace(@text,"\r"," "+ $$NEWLINE)
	Replace(@text,"\n"," "+ $$NEWLINE)
	
	RETURN text
END FUNCTION

END PROGRAM
