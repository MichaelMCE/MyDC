'
' see MyDCProxyUI.x for an updated version of this file but without the proxy components
'	add path to dll to the 'pluginlist' file to autostart 
'
'
'
'
'
'	use "MyDCProxyUI.x" instead!
'
PROGRAM	"MyDCUI"
VERSION	"0.31"
MAKEFILE "xdll.xxx"
'CONSOLE

	IMPORT "kernel32"
	IMPORT "shell32"
	IMPORT "msvcrt"
	IMPORT "user32"
	IMPORT "gdi32"
	IMPORT "comctl32"
'	IMPORT "xio"

	IMPORT "MyDC.dec"
	IMPORT "dcutils"

$$PluginTitle = "MyDC GUI 0.31"

$$Tab1				= 120
$$ListView1			= 121
$$Splitter1			= 122
$$PopUp_Exit		= 134
$$PopUp_1			= 135
'$$WindowStatus		= 135

$$EDITBOX_RETURN	= 401
$$EDITBOX_TAB		= 402


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
$$WM_MsgWin						= 1036
$$WM_MsgCmd						= 1037

$$SR_USER		= 0
$$SR_FILENAME	= 1
$$SR_SIZE		= 2
$$SR_SLOTS		= 3
$$SR_FILEPATH	= 4
$$SR_HUB		= 5

$$Filter_URL			= 1
$$Filter_NAME			= 2
$$Filter_DC				= 3

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
	STRING * 64 .title
	STRING * 32 .user
END TYPE


$$SPLITTERCLASSNAME = "splitterctrl"
' define splitter styles
$$SS_HORZ = 0
$$SS_VERT = 1

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
DECLARE FUNCTION HubProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION CmdProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION SerProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION SplitProc (hWnd, msg, wParam, lParam)
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
DECLARE FUNCTION AddClient (STRING username)
DECLARE FUNCTION AddClients (STRING ctotal)
DECLARE FUNCTION GetTabChild (htabc)
DECLARE FUNCTION SetTabChild (htabc,handle)
DECLARE FUNCTION AddEditTabChild (hparent,STRING title,IDC)
DECLARE FUNCTION AddSplitTabChild (hparent,STRING title,IDC)
DECLARE FUNCTION SetTabTitle (tabc,STRING title)
DECLARE FUNCTION AddListViewTabChild (hparent,STRING title,IDC)
DECLARE FUNCTION SearchResult (STRING result)
DECLARE FUNCTION RemoveClients ()
DECLARE FUNCTION RemoveClient (STRING user)
DECLARE FUNCTION InsertListViewItem (hwndCtl,pos, STRING item)
DECLARE FUNCTION SetListViewSubItem (hwndCtl, iColumn, STRING text, item)

DECLARE FUNCTION CCmdNick (nick$)
DECLARE FUNCTION CCmdConnect (STRING address,port)
DECLARE FUNCTION CCmdReconnect ()
DECLARE FUNCTION CCmdDisconnect ()
DECLARE FUNCTION CCmdMsg (STRING to, STRING from, STRING text)

DECLARE FUNCTION InitNewCmd (hwndCtl,lpcmd)

DECLARE FUNCTION HubChat (STRING user,STRING text)
DECLARE FUNCTION PMChat (STRING user,STRING text)

DECLARE FUNCTION CPrint (EditControl,STRING text)				' print text to an edit control
DECLARE FUNCTION urlCatch (STRING url)							' record and log url
DECLARE FUNCTION urlOpen (STRING url)							' open url in new browser
DECLARE FUNCTION LaunchBrowser (STRING url)						' launch url
DECLARE FUNCTION urlList (starturl)								' relist url's
DECLARE FUNCTION filterFind (STRING str,STRING text,offset)		' search string for text beginning at offset
DECLARE FUNCTION filterMessage (message$,text$,action)

DECLARE FUNCTION UpdateListBox (hctrl)
DECLARE FUNCTION ShowUserDetails (STRING user,edit)

DECLARE FUNCTION CreateMsgWindow (lpuser)
DECLARE FUNCTION CreateMsgWindowA (STRING user)
DECLARE FUNCTION MsgProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION MsgCmdSubProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION MsgEditSubProc (hWnd, msg, wParam, lParam)
DECLARE FUNCTION RegisterMsgClass ()

DECLARE FUNCTION ProcessClientText (addrtext)
DECLARE FUNCTION ClientQuit (STRING user)
DECLARE FUNCTION ClientJoin (STRING user)

DECLARE FUNCTION MPrint (m,STRING text)
DECLARE FUNCTION SleepMsg (time)
DECLARE FUNCTION SendMsg (STRING msg)
DECLARE FUNCTION STRING GetHubNick ()
DECLARE FUNCTION STRING GetNick ()
DECLARE FUNCTION STRING DisplayNick (STRING nick)
DECLARE FUNCTION ProcessClientCommand (cmd$,msg$)
DECLARE FUNCTION FileSearch (STRING who, STRING result)
DECLARE FUNCTION getLastSlash(str$, stop)
DECLARE FUNCTION DecomposePathname (pathname$, @path$, @parent$, @filename$, @file$, @extent$)

DECLARE FUNCTION MAKELONG (lo, hi)
DECLARE FUNCTION HIWORD (x)
DECLARE FUNCTION LOWORD (x)

DECLARE FUNCTION GetConSocket ()
DECLARE FUNCTION DispatchDCTMsg (token, STRING msg1, STRING msg2)

'FUNCTION DllMain (a,reason,c)
FUNCTION DllEntry ()


	RETURN 0
END FUNCTION

FUNCTION DllExit ()
	' this function will be called when exiting plugin and must exist even if a cleanup is not required
	CleanUp()
END FUNCTION

FUNCTION DllStartup (TDCPlugin dcp)
	SHARED FUNCADDR DDCTM (XLONG,STRING,STRING)
	STATIC ENTERONCE
	SHARED ShowJQ
	SHARED MsgScroll
	SHARED TIMESTAMP
	SHARED SHOWSEARCH
	SHARED TMsgWin MsgWin[]
	SHARED MWTotal
	SHARED STRING Nick,Server


	IF ENTERONCE THEN
		RETURN $$FALSE
	ELSE
		ENTERONCE = 1
	END IF
	
	DIM MsgWin[0]
	MWTotal = 0
	
	TIMESTAMP	= $$FALSE
	SHOWSEARCH	= $$FALSE
	DEBUG		= $$FALSE
	ShowJQ		= $$TRUE
	MsgScroll	= $$TRUE

	#WindowCreated = $$FALSE
	#hThread = _beginthreadex (NULL, 0, &InitGUI(), 0, 0, &tid)
	
	DO
		Sleep (10)
	LOOP WHILE (#WindowCreated = $$FALSE)
	
'	dcp.hWinMain = #winMain
	dcp.pDllExit = &DllExit()
	dcp.pDllFunc = &DllProc()
	dcp.lpPluginTitle = &$$PluginTitle

	Server = CSTRING$(dcp.lpserver)
	Port = dcp.port
	Nick = CSTRING$(dcp.lpnick)	
	DDCTM = dcp.lpDDCTM

	RETURN $$TRUE
END FUNCTION

FUNCTION DispatchDCTMsg (token, STRING msg1, STRING msg2)
	SHARED FUNCADDR DDCTM (XLONG,STRING,STRING)

	RETURN @DDCTM (token,@msg1,@msg2)
END FUNCTION

FUNCTION DllProc (token, STRING msg1, STRING msg2)
	STATIC STRING text
	SHARED socket
	SHARED STRING Nick,Server
	SHARED Port
	SHARED STRING HubShare
	SHARED STRING HubName
	SHARED STRING TotalHubUsers
	SHARED DEBUG


	IFT DEBUG CPrint ($$Debug,STRING$(token)+" "+msg1+" : "+msg2)
	
	SELECT CASE token
		CASE $$MDCT_InitiatingConn	:
			CPrint ($$Hub,"\r\n* connecting to "+TRIM$(msg2))
			RETURN $$MDCTH_HandledCont

		'CASE $$MDCT_InitiatingDisconn	:
		'	CPrint ($$Hub,"* disconnecting "+TRIM$(msg1))
		'	RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_Disconnected
			CPrint ($$Hub,"\r\n\* "+GetTime()+": disconnected "+TRIM$(msg1))
			socket = 0
			HubShare = ""
			HubName = ""
			TotalHubUsers = ""
			RemoveClients ()
			RETURN $$MDCTH_HandledCont
					
		CASE $$DCT_Search			:
			FileSearch (msg1,msg2)
			RETURN $$MDCTH_HandledCont
			
		CASE $$DCT_SR				:
			SearchResult (msg1)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_ClientConnected	:
			Nick = GetTokenEx (@msg2,':',0)
			Server = GetTokenEx (@msg2,':',0)
			Port = XLONG(GetTokenEx (@msg2,':',0))
			socket = XLONG(msg1)
			CPrint ($$Hub,"* connected to "+Server+" on port "+STRING$(Port)+"\r\n\r\n")
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_PubCmdMsg		:
			CPrint ($$Hub,DisplayNick(msg1)+" "+msg2)
			RETURN $$MDCTH_HandledCont
					
		CASE $$MDCT_PrvTxtMsg		:
			CPrint (XLONG(msg1),@msg2)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_PubTxtMsg		:
			CPrint ($$Hub,DisplayNick(msg1)+" "+msg2)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_PMTxtMsg		:	' pm from another user sent via hub
			CCmdMsg (GetNick(),msg1,msg2)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_SendPMsg		:	' pm to a user sent from this client
			CCmdMsg (msg1,GetNick(),msg2)
			RETURN $$MDCTH_UnhandledCont
			
		CASE $$MDCT_NickList		:
			AddClients (@msg1)
			IFZ msg2 THEN msg2 = "0"
			TotalHubUsers = msg2
			UpdateTitle ()
			RETURN $$MDCTH_HandledCont
		
		CASE $$MDCT_ClientJoin		:
			AddClient (msg1)
			ClientJoin (msg1)
			RETURN $$MDCTH_HandledCont

		CASE $$DCT_Quit				:
			RemoveClient (msg1)
			ClientQuit (msg1)
			UpdateTitle ()
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_NickListTotal	:
			IF msg1 THEN TotalHubUsers = msg1
			UpdateTitle ()
			RETURN $$MDCTH_HandledCont
	
		CASE $$MDCT_HubShareTotal	:
			IF msg1 THEN HubShare = msg1
			IFZ msg2 THEN msg2 = "0"
			TotalHubUsers = msg2
			UpdateTitle ()

		CASE $$MDCT_HubUsers		:
			IFZ msg1 THEN msg1 = "0"
			TotalHubUsers = msg1
			'UpdateTitle()
			RETURN RETURN $$MDCTH_HandledCont
			
		CASE $$DCT_HubName			:
			IF msg1 THEN
				HubName = msg1
				UpdateTitle ()
				RETURN $$MDCTH_HandledCont
			ELSE
				RETURN $$MDCTH_UnhandledCont
			END IF
		 
		CASE $$MDCT_MyShareSize		:
			CPrint ($$Hub,"* share set to "+TRIM$(msg1))
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_ClientOpJoin	:
			CPrint ($$Hub,"* Operators are: "+TRIM$(msg1))
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_IntNickList		:
			AddClient (msg1)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_UnknownCmd		:
			CPrint ($$Hub,"* unknown command: "+msg1+" "+msg2)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_PluginLoaded	:
			'CPrint ($$Hub,"* Plugin loaded: "+msg1)
			CPrint ($$Hub,"* Plugin #"+GetTokenEx(@msg2,':',0)+":"+msg1)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_PluginUnloaded	:
			CPrint ($$Hub,"* Plugin unloaded: "+msg1)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_Error			:
			CPrint ($$Hub,"* "+msg1+" "+msg2)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_Plugin			:
			'CPrint ($$Hub,"* Plugin #"+GetTokenEx(@msg2,':',0)+" loaded: "+msg2)
			CPrint ($$Hub,"* Plugin loaded: #"+GetTokenEx(@msg2,':',0)+":"+msg2)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_Debug
			CPrint ($$Debug,"::::--"+msg1+"-- --"+msg2+"--")
			RETURN $$MDCTH_HandledCont
	END SELECT

	RETURN $$MDCTH_UnhandledCont
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
		CASE "getuserlist"	:DispatchDCTMsg ($$MDCT_GetIntNickList,"","")
'		CASE "load"			:LoadPlugin (msg$)
		CASE "ul"			:'#hThread =_beginthreadex (NULL, 0, &UnLoadPlugin(), XLONG(TRIM$(msg$)), 0, &tid2)
'							 UnLoadPlugin (XLONG(TRIM$(msg$)))
							 DispatchDCTMsg ($$MDCT_Unload,TRIM$(msg$),"")
'		CASE "pluginlist"	:ListPlugins ()
		CASE "showsearch"	:IFT SHOWSEARCH THEN
							 	SHOWSEARCH = $$FALSE
							 	CPrint ($$Hub,"* filesearch off")
							 ELSE
								SHOWSEARCH = $$TRUE
								CPrint ($$Hub,"* filesearch on")
							 END IF
		CASE "info"			:ShowUserDetails (TRIM$(GetTokenEx(msg$,32,0)),$$Hub)
		CASE "share"		:FShared = "97198295245"
							 'CPrint ($$Hub,"* share set to "+FShared)
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
		CASE "refresh"		:CPrint ($$Hub,"* refreshing user list")
							 RemoveClients ()
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
							 GetToken (@msg$,@ip$,32)
							 GetToken (TRIM$(msg$),@port$,32)
							 CCmdConnect (ip$,XLONG(port$))
		CASE "reconnect"	:CCmdReconnect ()
		CASE "disconnect"	:CCmdDisconnect ()
		CASE "msg","pm"		:to$ = GetTokenEx (@msg$,32,0)
							 DispatchDCTMsg ($$MDCT_SendPMsg,@to$,@msg$)
							 'CCmdMsg (to$,msg$)
		CASE "max"			:CCmdConnect ("80.60.63.79", 411)
		CASE "maxspeed"		:CCmdConnect ("Maximumspeed3.no-ip.org", 411)
		CASE "mul"			:CCmdConnect ("mulciber.dnsalias.com", 6666)
		CASE "local"		:CCmdConnect ("localhost", 4111)
		CASE ELSE			:RETURN $$FALSE
	END SELECT
	
	RETURN $$TRUE
END FUNCTION

FUNCTION GetConSocket ()
	SHARED socket
	
	RETURN socket
END FUNCTION

FUNCTION SendMsg (STRING text)

	text = TRIM$(text)+"|"
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

FUNCTION STRING DisplayNick (STRING nick)

	RETURN "("+nick+")"
END FUNCTION

FUNCTION Splitter ()

	WNDCLASS wc
	STATIC init
	SHARED hInst

' do this once
	IF init THEN RETURN
	init = $$TRUE

' get Instance handle
	hInst = GetModuleHandleA (0)

' fill in WNDCLASS struct
	wc.style           = $$CS_GLOBALCLASS | $$CS_HREDRAW | $$CS_VREDRAW | $$CS_PARENTDC
	wc.lpfnWndProc     = &SplitterProc()										' splitter control callback function
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 4																	' space for a pointer to a SPLITTERDATA struct
	wc.hInstance       = hInst
	wc.hIcon           = 0
	wc.hCursor         = 0
	wc.hbrBackground   = $$COLOR_BTNFACE + 1
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &$$SPLITTERCLASSNAME

' register window class
	RETURN RegisterClassA (&wc)

END FUNCTION
'
'
' #############################
' #####  SplitterProc ()  #####
' #############################
'
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
			style        	= $$SS_LEFT | $$SS_NOTIFY | $$WS_CHILD | $$WS_VISIBLE
			w 				= cs.cx
			IF w < splitterSize THEN w = splitterSize
			x 				= w/2 - splitterSize/2
			h 				= cs.cy

			hStatic = CreateWindowExA (0, &"static", &text$, style, x, 0, splitterSize, h, hWnd, idCount, hInst, 0)
			INC idCount

' assign static control callbacks StaticProc ()
			#old_proc = SetWindowLongA (hStatic, $$GWL_WNDPROC, &StaticProc())

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
			IF style = $$SS_HORZ THEN
				width = MAX(minSize, width)
			ELSE
				height = MAX(minSize, height)
			END IF

			GOSUB CalcSizes										' compute the sizes of all the panels
			IF style = $$SS_HORZ THEN					' resize windows
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

		CASE $$WM_CTLCOLOREDIT  ,$$WM_CTLCOLORSTATIC,$$WM_CTLCOLORLISTBOX
			RETURN SetColor (RGB(100, 100, 100), RGB(212, 208, 200), wParam, lParam)
			
		CASE $$WM_SET_SPLITTER_PANEL_HWND:
' client calls SendMessageA() just after the control is created
' to set the two side panel window handles
' store this data in object area
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+4) 	= wParam									' hWnd1
			XLONGAT(pData+8) 	= lParam									' hWnd2
			GOSUB Resize																' resize all panels
			RETURN 0

		CASE $$WM_SET_SPLITTER_MIN_PANEL_SIZE:
' client calls SendMessageA() just after the control is created
' to set the border width for the splitter control
' store data in object area
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+12) = wParam									' wnd1 min size
			XLONGAT(pData+16) = lParam									' wnd2 min size
			GOSUB Resize																' resize all panels
			RETURN 0

		CASE $$WM_SET_SPLITTER_SIZE:
' client calls SendMessageA() just after the control is created
' to set the splitter size
			pData = GetWindowLongA (hWnd, $$GWL_USERDATA)
			XLONGAT(pData+24) = lParam									' splitter size
			GOSUB Resize																' resize all panels
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
			IF style = $$SS_HORZ THEN
				x = (rect.right - rect.left)/2 - splitterSize/2
				MoveWindow (hStatic, x, 0, splitterSize, rect.bottom-rect.top, 0)
			ELSE
				y = (rect.bottom - rect.top)/2 - splitterSize/2
				MoveWindow (hStatic, 0, y, rect.right-rect.left, splitterSize,  0)
			END IF

			GOSUB Resize																' resize all panels
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
			IF style = $$SS_HORZ THEN
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

			IF style = $$SS_HORZ THEN
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

	IF style = $$SS_HORZ THEN
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

			style = spdata.style						' get horz or vert splitter style
			IF style = $$SS_HORZ THEN
				SetCursor (hCursorH)					' set cursor
			ELSE
				SetCursor (hCursorV)
			END IF

			SetCapture (hWnd)								' capture the mouse to static control

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
			style = spdata.style

			IF style = $$SS_HORZ THEN
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

				IF style = $$SS_HORZ THEN
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

RETURN CallWindowProcA (#old_proc, hWnd, msg, wParam, lParam)

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
			RETURN u
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
	LaunchBrowser (url$)
	
	RETURN $$TRUE

END FUNCTION

FUNCTION LaunchBrowser (url$)		' function taken from 'launchbrowser' by D.S.
	STATIC defBrowserExe$
	
	
	IFZ defBrowserExe$ THEN										' first, create a known, temporary HTML file
		defBrowserExe$ = NULL$ (256)							' create default browser path string
		file$ = "temphtm.htm"									' temp html file
		s$ = "<HTML> <\HTML>"									' html string

		of = OPEN (file$, $$RW)									' open temp html file
		WRITE [of], s$											' write string to file
		CLOSE (of)												' close file

		ret = FindExecutableA (&file$, NULL, &defBrowserExe$)	' find executable
		defBrowserExe$ = CSIZE$ (defBrowserExe$)
		DeleteFileA (&file$)									' delete temp file
		
		IF (ret <= 32) || (defBrowserExe$ = "") THEN
			CPrint ($$Hub,"* no browser")
			RETURN $$FALSE
		END IF
	END IF

	ret = ShellExecuteA (NULL, &"open", &defBrowserExe$, &url$, NULL, $$SW_SHOWNORMAL)
	IF url$ THEN
		IF ret <= 32 THEN
			CPrint ($$Hub,"* no nourlpage")
			RETURN $$FALSE
		END IF
	END IF
	
	RETURN $$TRUE
	
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
				CASE $$Filter_URL	:url$ = trim (GetTokenEx (message$,32,start-1),0)
								 	insert$ = " " + STRING$(urlCatch (url$)) +": "
								 	textInsert (insert$,@message$,start-1)
								 	start = start + LEN(insert$)
								 
				CASE $$Filter_NAME	:name$ = trim (GetTokenEx (message$,32,start+1),0)
								 	textRemove (@message$,2 + (LEN(name$)),start-1)
								' 	IF name$ THEN textInsert (FindUser(name$),@message$,start-1)

				CASE $$Filter_DC	:value = XLONG(trim (GetTokenEx (message$,32,start+1),0))
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

FUNCTION ClearEditText (edit)
	SHARED STRING textAll1,textAll2,textAll3
	SHARED STRING textAll4,textAll5,textAll6
	STRING text
	

	SELECT CASE edit
		CASE $$Hub			:textAll1 = ""
							 hedit = #hub
		CASE $$Debug		:textAll2 = ""
							 hedit = #debug
		CASE $$Search		:textAll3 = ""
							 hedit = #search
		CASE $$SResults		:textAll4 = ""
							 hedit = #SResultList
		CASE $$URLCatch		:textAll5 = ""
							 hedit = #urlcatch
		CASE $$BotMsg		:textAll6 = ""
							 hedit = #botmessage
		CASE ELSE			:RETURN $$FALSE
	END SELECT

	text = ""
	SendMessageA (hedit, $$WM_SETTEXT, 0, &text)

	RETURN $$TRUE
END FUNCTION

FUNCTION SetEditText (edit, STRING text)
	SHARED STRING textAll1,textAll2,textAll3
	SHARED STRING textAll4,textAll5,textAll6
	STATIC SCROLLINFO sinfo
	SHARED MsgScroll


	IFZ text THEN RETURN $$FALSE
	
	SELECT CASE edit
		CASE $$Hub			:textAll1 = textAll1 + text
							 text = textAll1
							 hedit = #hub
							 IFF MsgScroll THEN RETURN $$FALSE
		CASE $$Debug		:textAll2 = textAll2 + text
							 text = textAll2
							 hedit = #debug
							 IFF MsgScroll THEN RETURN $$FALSE
		CASE $$Search		:textAll3 = textAll3 + text
							 text = textAll3
							 hedit = #search
							 IFF MsgScroll THEN RETURN $$FALSE
		CASE $$SResults		:textAll4 = textAll4 + text
							 text = textAll4
							 hedit = #SResultList
							 IFF MsgScroll THEN RETURN $$FALSE
		CASE $$URLCatch		:textAll5 = textAll5 + text
							 text = textAll5
							 hedit = #urlcatch
							 IFF MsgScroll THEN RETURN $$FALSE
		CASE $$BotMsg		:textAll6 = textAll6 + text
							 text = textAll6
							 hedit = #botmessage
							 IFF MsgScroll THEN RETURN $$FALSE
		CASE ELSE			:RETURN $$FALSE
	END SELECT

	SendMessageA (hedit, $$WM_SETTEXT, 0, &text)
	RETURN $$TRUE
END FUNCTION

FUNCTION SetListViewSubItem (hwndCtl, iColumn, STRING text, item)
	LV_ITEM lvi

	
	IFZ text THEN RETURN -1
	lvi.mask 		= $$LVIF_TEXT
	lvi.iItem 		= item
	lvi.pszText 	= &text
	lvi.cchTextMax 	= LEN(text)
	lvi.iSubItem 	= iColumn
	
	RETURN SendMessageA (hwndCtl, $$LVM_SETITEM , 0, &lvi)
		
END FUNCTION

FUNCTION InsertListViewItem (hwndCtl,pos, STRING item)
	LV_ITEM lvi


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
	LV_COLUMN lvcol

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

	
	IF SHUTONCE THEN RETURN $$FALSE
		
	IF #hPopMenu THEN DestroyMenu (#hPopMenu): #hPopMenu = 0
	IF #hTabFont THEN DeleteObject (#hTabFont) : #hTabFont = 0
	IF #hHubFont THEN DeleteObject (#hHubFont): #hHubFont = 0
	IF #hCListFont THEN DeleteObject (#hCListFont): #hCListFont = 0

	IF DCClassName THEN UnregisterClassA(&DCClassName, hInst): DCClassName = ""
	IF MsgClassName THEN UnregisterClassA(&MsgClassName, hInst): MsgClassName = ""

	IF #MSGThread THEN CloseHandle (#MSGThread): #MSGThread = 0
	IF #hThread THEN CloseHandle (#hThread): #hThread = 0
	
	IF #winMain THEN
		DeleteTrayIcon (#winMain)
		DestroyWindow (#winMain)
		#winMain = 0
	END IF
	
END FUNCTION

FUNCTION RegisterWinClass (className$, titleBar$)

	SHARED hInst
	WNDCLASS wc

	wc.style           = $$CS_HREDRAW OR $$CS_VREDRAW OR $$CS_OWNDC
	wc.lpfnWndProc     = &WndProc()
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 0
	wc.hInstance       = hInst
	wc.hIcon           = LoadIconA (hInst, &"scrabble")
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = GetStockObject ($$LTGRAY_BRUSH)
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &className$

	RETURN RegisterClassA (&wc)

END FUNCTION

FUNCTION CreateWindows ()
	SHARED STRING DCClassName

	
	#WindowCreated = $$FALSE
	DCClassName  = "DCCLIENT"+STRING$(GetTickCount())
	titleBar$  	= "MyDC"
	style 		= $$WS_OVERLAPPEDWINDOW
	w 			= 700
	h 			= 360
	#winMain = NewWindow (DCClassName, titleBar$, style, x, y, w, h, 0)

	#CmdLine = NewChild ("edit","", $$ES_MULTILINE | $$ES_AUTOHSCROLL, 1, h-45, 550, 18, #winMain, $$CmdLine, $$WS_EX_STATICEDGE)
	#SearchLine = NewChild ("edit","", $$ES_MULTILINE | $$ES_AUTOHSCROLL, 1, h-45, 550, 18, #winMain, $$SearchLine, $$WS_EX_STATICEDGE)
	#hTabCtl = NewChild ($$WC_TABCONTROL, "", $$WS_CLIPSIBLINGS | $$TCS_EX_FLATSEPARATORS | $$WS_VISIBLE | $$WS_TABSTOP | $$WS_CHILD, 1, 1, w, h-40, #winMain, $$Tab1, $$WS_EX_STATICEDGE)  '  | $$TCS_BUTTONS |  $$TCS_FLATBUTTONS | $$TCS_FOCUSONBUTTONDOWN

	#hSplitter1 = AddSplitTabChild (#hTabCtl,"Hub",$$Splitter1)
	#hub = NewChild ("edit", "", $$ES_MULTILINE | $$ES_READONLY | $$WS_VSCROLL | $$ES_LEFT , 1, 20, 300, 300, #hSplitter1, $$Hub, $$WS_EX_STATICEDGE)

	exStyle = $$WS_EX_ACCEPTFILES | $$WS_EX_TRANSPARENT | $$WS_EX_STATICEDGE | $$WS_EX_CONTEXTHELP
	#CListBox = NewChild ("listbox", "", $$LBS_HASSTRINGS | $$LBS_STANDARD & ~$$LBS_SORT & ~$$LBS_DISABLENOSCROLL  , 0, 0, rc_right, rc_bottom, #hSplitter1, $$ListView1,exStyle)' $$WS_EX_CLIENTEDGE)
	
	SendMessageA (#hSplitter1, $$WM_SET_SPLITTER_PANEL_HWND, #hub, #CListBox)
	SendMessageA (#hSplitter1, $$WM_SET_SPLITTER_POSITION, w-100, 0)
	SendMessageA (#hSplitter1, $$WM_SET_SPLITTER_MIN_PANEL_SIZE, 0, 0)

	#debug = AddEditTabChild (#hTabCtl,"Debug",$$Debug)	
	#search = AddEditTabChild (#hTabCtl,"Search",$$Search)
	#SResultList = AddListViewTabChild (#hTabCtl,"Search Results",$$SResults)
	#urlcatch = AddEditTabChild (#hTabCtl,"URL's",$$URLCatch)
	#botmessage = AddEditTabChild (#hTabCtl,"Bot's",$$BotMsg)
	
	#hTabFont = NewFont ("MS Sans Serif", 10, $$FW_NORMAL, $$FALSE, $$FALSE)
	SetNewFont (#hTabCtl, #hTabFont)
	#hHubFont = NewFont ("MS Sans Serif", 10, $$FW_BOLD, $$FALSE, $$FALSE)
	SetNewFont (#hub, #hHubFont)
	#hCListFont = NewFont ("MS Sans Serif", 10, $$FW_BOLD, $$FALSE, $$FALSE)
	SetNewFont (#CListBox, #hCListFont)


	ret = AddListViewColumn (#SResultList, 0,120, "User")
	ret = AddListViewColumn (#SResultList, 1,350, "File Name")
	ret = AddListViewColumn (#SResultList, 2, 90, "Size")
	ret = AddListViewColumn (#SResultList, 3, 40, "Slots")
	ret = AddListViewColumn (#SResultList, 4,550, "Path")
	ret = AddListViewColumn (#SResultList, 5,120, "Hub")

	'SendMessageA (#SResultList, $$LVM_SETTEXTBKCOLOR, 0, RGB(212, 208, 200))
	'SendMessageA (#SResultList, $$LVM_SETTEXTCOLOR, 0, RGB(100, 100, 100))	

	exStyle = SendMessageA (#SResultList, $$LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
	exStyle = exStyle | $$LVS_EX_FULLROWSELECT | $$LVS_EX_TRACKSELECT | $$LVS_EX_INFOTIP | $$LVS_EX_LABELTIP | $$LVS_EX_HEADERDRAGDROP
	SendMessageA (#SResultList, $$LVM_SETEXTENDEDLISTVIEWSTYLE, 0, exStyle)

	SetWindowPos (#winMain, 0, 100, 250, 0, 0, $$SWP_NOSIZE OR $$SWP_NOZORDER)
	SetTaskbarIcon (#winMain, "scrabble", "")
	
	ShowWindow (#SearchLine , $$SW_HIDE)
	SendMessageA (#hTabCtl, $$TCM_SETCURFOCUS, 5, 0)
	SendMessageA (#hTabCtl, $$TCM_SETCURFOCUS, 4, 0)
	SendMessageA (#hTabCtl, $$TCM_SETCURFOCUS, 3, 0)
	SendMessageA (#hTabCtl, $$TCM_SETCURFOCUS, 2, 0)
	SendMessageA (#hTabCtl, $$TCM_SETCURFOCUS, 1, 0)
	SendMessageA (#hTabCtl, $$TCM_SETCURFOCUS, 0, 0)

	#hPopMenu = CreatePopupMenu ()
'	AppendMenuA (#hPopMenu, $$MF_STRING, $$WindowStatus, &"Minimize")
	AppendMenuA (#hPopMenu, $$MF_SEPARATOR, 0, 0)
	AppendMenuA (#hPopMenu, $$MF_STRING, $$PopUp_Exit, &"&Exit")


	'#hEPopMenu = CreatePopupMenu ()
	'AppendMenuA (#hEPopMenu, $$MF_STRING   , $$PopUp_1,    &"&test")
	'AppendMenuA (#hEPopMenu, $$MF_SEPARATOR, 0, 0)
	'AppendMenuA (#hEPopMenu, $$MF_STRING   , $$PopUp_Exit, &"&Exit")

	ShowWindow (#winMain, $$SW_SHOWNORMAL)
	UpdateWindow (#winMain)
	#WindowCreated = $$TRUE
	
	RETURN $$TRUE	
END FUNCTION

FUNCTION CreateMsgWindow (lpuser)
	SHARED MsgUserFlag,MsgWinI
	SHARED STRING MsgUser
	USER32_MSG msg
	STRING user

	
	IFZ CSTRING$(lpuser) THEN RETURN -1
	IF (WaitForSingleObject (#hSemCrtMsgWnd,3000) == $$WAIT_TIMEOUT) THEN
		RETURN -1
	END IF

	MsgUser = CSTRING$(lpuser)
	MsgWinI = -1
	MsgUserFlag = $$TRUE
	
	DO
'		IF PeekMessageA (&msg,0, 0, 0, 0) THEN
'			GetMessageA (&msg, 0, 0, 0)
'			TranslateMessage (&msg)
'			DispatchMessageA (&msg)
'		END IF
		Sleep (3)
		'SleepMsg (1)
	LOOP WHILE (MsgWinI == -1)

	ReleaseSemaphore (#hSemCrtMsgWnd,1,NULL)
	
	RETURN MsgWinI
END FUNCTION

FUNCTION RegisterMsgClass ()
	SHARED STRING MsgClassName
	SHARED hInst
	WNDCLASS wc


	MsgClassName = "DCMSG"
	
	wc.style           = $$CS_HREDRAW OR $$CS_VREDRAW OR $$CS_OWNDC
	wc.lpfnWndProc     = &MsgProc()
	wc.cbClsExtra      = 0
	wc.cbWndExtra      = 0
	wc.hInstance       = hInst
	wc.hIcon           = LoadIconA (hInst, &"scrabble")
	wc.hCursor         = LoadCursorA (0, $$IDC_ARROW)
	wc.hbrBackground   = GetStockObject ($$LTGRAY_BRUSH)
	wc.lpszMenuName    = 0
	wc.lpszClassName   = &MsgClassName
	RETURN RegisterClassA (&wc)
	
END FUNCTION

FUNCTION CreateMsgWindowA (STRING user)
	SHARED STRING MsgClassName
	SHARED hInst
	SHARED TMsgWin MsgWin[]
	SHARED MWTotal
	STRING title
	CRITICAL_SECTION cs


	IFZ MsgClassName THEN RegisterMsgClass ()
	
	title = TRIM$(GetTokenEx(user,32,0))
	IFZ title THEN
		LeaveCriticalSection (&cs)
		DeleteCriticalSection (&cs)
		RETURN -1
	END IF

	found = $$FALSE
	FOR m = 0 TO MWTotal
		IFZ MsgWin[m].hwin THEN
			found = $$TRUE
			EXIT FOR
		END IF
	NEXT m

	InitializeCriticalSection (&cs)
	EnterCriticalSection (&cs)
	
	IFF found THEN
		REDIM MsgWin[MWTotal+10]
		MWTotal = MWTotal+10
	END IF

	LeaveCriticalSection (&cs)
	DeleteCriticalSection (&cs)
	
	w = 500: h = 300
			
	MsgWin[m].title = "___MyDC: "+GetNick()+" -> "+title
	MsgWin[m].user = title
	MsgWin[m].hwin = CreateWindowExA (exStyle, &MsgClassName, &MsgWin[m].title, $$WS_OVERLAPPEDWINDOW, x, y, w, h, 0, 0, hInst, 0)
	MsgWin[m].hedit = NewChild ("edit","", $$ES_MULTILINE | $$ES_READONLY | $$WS_VSCROLL | $$ES_LEFT , 0, 0, w, h-20, MsgWin[m].hwin, $$WM_MsgWin, $$WS_EX_STATICEDGE)
	MsgWin[m].hcmd = NewChild ("edit","", $$ES_MULTILINE | $$ES_AUTOHSCROLL, 0, h-20, w, 18, MsgWin[m].hwin, $$WM_MsgCmd, $$WS_EX_STATICEDGE)
	MsgWin[m].hcmdsubproc = SetWindowLongA(MsgWin[m].hcmd , $$GWL_WNDPROC, &MsgCmdSubProc())
	MsgWin[m].heditsubproc = SetWindowLongA(MsgWin[m].hedit , $$GWL_WNDPROC, &MsgEditSubProc())
		
	SetWindowPos (MsgWin[m].hwin, 0, 100, 250, 0, 0, $$SWP_NOSIZE OR $$SWP_NOZORDER)
	ShowWindow (MsgWin[m].hwin, $$SW_SHOWNORMAL)
	UpdateWindow (MsgWin[m].hwin)
	
	RETURN m
END FUNCTION

FUNCTION MsgEditSubProc (hWnd, msg, wParam, lParam)
	SHARED TMsgWin MsgWin[]
	SHARED MWTotal
	

	SELECT CASE msg
	
		CASE  $$WM_MBUTTONDOWN :	' set focus to cmd control when middle button is pressed
			FOR m = 0 TO MWTotal
				IF (MsgWin[m].hedit == hWnd) THEN
					SetFocus (MsgWin[m].hcmd)
					RETURN 0
				END IF
			NEXT m
			
	END SELECT

	FOR m = 0 TO MWTotal
		IF (MsgWin[m].hedit == hWnd) THEN
			RETURN CallWindowProcA (MsgWin[m].heditsubproc, hWnd, msg, wParam, lParam)
		END IF
	NEXT m
	
	RETURN 0

END FUNCTION

FUNCTION MsgCmdSubProc (hWnd, msg, wParam, lParam)
	SHARED TMsgWin MsgWin[]
	SHARED MWTotal
	

	SELECT CASE msg
		CASE $$WM_KEYDOWN :
			virtKey = wParam
			SELECT CASE virtKey
				CASE $$VK_RETURN 		:
					id = GetWindowLongA (hWnd, $$GWL_ID)
					wParam = ($$EDITBOX_RETURN << 16) OR id
					SendMessageA (GetParent(hWnd), $$WM_COMMAND, wParam, hWnd)	' send WM_COMMAND message to main window callback function
					RETURN 0
			END SELECT

	END SELECT
	
	FOR m = 0 TO MWTotal
		IF (MsgWin[m].hcmd == hWnd) THEN
			RETURN CallWindowProcA (MsgWin[m].hcmdsubproc, hWnd, msg, wParam, lParam)
		END IF
	NEXT m
	
	RETURN 0

END FUNCTION

FUNCTION MsgProc (hWnd, msg, wParam, lParam)
	PAINTSTRUCT ps
	TRECT rect
	STATIC lastcmd$
	SHARED TMsgWin MsgWin[]
	SHARED MWTotal
	STATIC cmd$
	

	SELECT CASE msg

		CASE $$WM_DESTROY, $$WM_CLOSE :
			FOR m = 0 TO MWTotal
				IF MsgWin[m].hwin == hWnd THEN
					MPrint (m,"$|"+STRING$(m)+"|$")		' signal deletion
					MsgWin[m].title = ""
					MsgWin[m].user = ""
					MsgWin[m].hwin = 0
					MsgWin[m].hedit = 0
					MsgWin[m].hcmd = 0
					MsgWin[m].hcmdsubproc = 0
					MsgWin[m].heditsubproc = 0
				END IF
			NEXT m
		
		CASE $$WM_COMMAND :
			id         = LOWORD (wParam)
			notifyCode = HIWORD (wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode

				CASE $$EDITBOX_RETURN	:
					cmd$ = NULL$(4096)										
					SendMessageA (hwndCtl, $$WM_GETTEXT, 4096, &cmd$)
					cmd$ = CSIZE$(cmd$)
					
	'				SELECT CASE id 
	'					CASE $$CmdLine			:
							IF cmd$=="/" THEN
								SendMessageA (hwndCtl, $$WM_SETTEXT, 0, &lastcmd$)
								RETURN 0
							END IF

							FOR m = 0 TO MWTotal
								IF (hWnd == MsgWin[m].hwin) THEN
									DispatchDCTMsg ($$MDCT_SendPMsg,MsgWin[m].user,cmd$)
									'CCmdMsg (MsgWin[m].user,cmd$)
									lastcmd$ = cmd$
									cmd$ = ""
									SendMessageA (hwndCtl, $$WM_SETTEXT, 0, &cmd$)		' clear new text
									RETURN 0
								END IF
							NEXT m
							
							RETURN 0
	'				END SELECT

			END SELECT

		CASE $$WM_CTLCOLOREDIT,$$WM_CTLCOLORSTATIC :
			RETURN SetColor (RGB(100, 100, 100), RGB(212, 208, 200), wParam, lParam)
			
		CASE $$WM_PAINT:
			hdc = BeginPaint (hWnd, &ps)
			EndPaint (hWnd, &ps)
			RETURN 0

		CASE $$WM_SIZE :
			fSizeType = wParam
			width = LOWORD(lParam)
			height = HIWORD(lParam)

			FOR m = 0 TO MWTotal
				IF (MsgWin[m].hwin == hWnd) THEN
					SetWindowPos (MsgWin[m].hedit,0, 0, 0, width,height-18, 0)
					SetWindowPos (MsgWin[m].hcmd,0, 0, height-18, width,18, 0)
					RETURN 0
				END IF
			NEXT m

			
			'SELECT CASE fSizeType
			'	CASE $$SIZE_MINIMIZED :
			'		ShowWindow (hWnd, $$SW_HIDE)
			'	CASE $$SIZE_RESTORED, $$SIZE_MAXIMIZED  :
			'		GetClientRect (hWnd, &rc)
			'		MoveWindow (#winMain, 0, 0, rc.right, rc.bottom, $$TRUE)
			'END SELECT
			
			RETURN

	END SELECT

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)
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
	SHARED UpdateTitleRequest
	USER32_MSG msg
	STATIC t0
	SHARED STRING MsgUser
	SHARED MsgUserFlag,MsgWinI


	MsgUserFlag = $$FALSE

	DO															' the message loop
		IF PeekMessageA (&msg,0 , 0, 0, 0) THEN
			SELECT CASE GetMessageA (&msg, 0, 0, 0)
				CASE 0		:'DispatchDCTMsg ($$MDCT_RequestShutDown,"","")
							 RETURN msg.wParam					' WM_QUIT message
				CASE -1		:'DispatchDCTMsg ($$MDCT_RequestShutDown,"","")
							 RETURN $$TRUE						' error
				CASE ELSE	:TranslateMessage (&msg)			' translate virtual-key messages into character messages
  							 DispatchMessageA (&msg)			' send message to window callback function WndProc()
			END SELECT
		ELSE
			Sleep (4)
			
			IFT MsgUserFlag THEN
				MsgUserFlag = $$FALSE
				MsgWinI = CreateMsgWindowA (MsgUser)
			END IF
			
			'IF (GetTickCount()-t0 > 100) THEN
			'
			'	IFT UpdateTitleRequest THEN
			'		UpdateTitle ()
			'		EXIT IF 2
			'	END IF
			'	
			'	t0 = GetTickCount()
			'END IF		

		END IF
	LOOP

END FUNCTION

FUNCTION CreateCallbacks ()

'	assign a new callback function to be used by child edit controls
	#hub_proc = SetWindowLongA(#hub, $$GWL_WNDPROC, &HubProc())
	#cmd_proc = SetWindowLongA(#CmdLine, $$GWL_WNDPROC, &CmdProc())
	#ser_proc = SetWindowLongA(#SearchLine, $$GWL_WNDPROC, &SerProc())
	
'	#split_proc = SetWindowLongA(#hSplitter1, $$GWL_WNDPROC, &SplitProc())

END FUNCTION

FUNCTION SplitProc (hWnd, msg, wParam, lParam)

END FUNCTION

FUNCTION HubProc (hWnd, msg, wParam, lParam)
	'POINTAPI pt


	SELECT CASE msg
		CASE  $$WM_MBUTTONDOWN :	' set focus to cmd control when middle button is pressed
			SetFocus (#CmdLine)
			RETURN 0
			
		'CASE $$WM_RBUTTONDOWN   :
			'x = LOWORD(lParam)
			'y = HIWORD(lParam)
			'fKeys = wParam
			'pt.x = x
			'pt.y = y
			'ClientToScreen (hWnd, &pt)		' convert from clint coordinates to screen coordinates
   			'TrackPopupMenuEx (#hEPopMenu, $$TPM_LEFTALIGN | $$TPM_LEFTBUTTON | $$TPM_RIGHTBUTTON, pt.x, pt.y, hWnd, 0)
			'RETURN
						
		'CASE $$WM_MOUSEMOVE :
			'fSizeType = wParam
			'x = LOWORD(lParam)
			'y = HIWORD(lParam)

			'SetWindowPos (#hub,0, x, 300-y, 300,300,0)
			
	END SELECT

	RETURN CallWindowProcA (#hub_proc, hWnd, msg, wParam, lParam)
END FUNCTION

FUNCTION CmdProc (hWnd, msg, wParam, lParam)


	SELECT CASE msg

		CASE $$WM_KEYDOWN :			' WM_KEYDOWN returns virtKey constants
			virtKey = wParam
			
			SELECT CASE virtKey
				CASE $$VK_RETURN 		:
					id = GetWindowLongA (hWnd, $$GWL_ID)
					wParam = ($$EDITBOX_RETURN << 16) OR id
					SendMessageA (GetParent(hWnd), $$WM_COMMAND, wParam, hWnd)	' send WM_COMMAND message to main window callback function
					RETURN 0
					
				CASE $$VK_TAB
					id = GetWindowLongA (hWnd, $$GWL_ID)
					wParam = ($$EDITBOX_TAB << 16) OR id
					SendMessageA (GetParent(hWnd), $$WM_COMMAND, wParam, hWnd)	' send WM_COMMAND message to main window callback function
					RETURN 0
			END SELECT
		
'		CASE $$WM_CHAR :				' WM_CHAR can capture keyboard characters
'			charCode = wParam
'			PRINT "WM_CHAR message: ASCII charCode="; charCode, "CHAR="; CHR$(charCode)	' validate text entry by character
'			RETURN 0
	END SELECT
	
	RETURN CallWindowProcA (#cmd_proc, hWnd, msg, wParam, lParam)

END FUNCTION

FUNCTION SerProc (hWnd, msg, wParam, lParam)
	POINTAPI pt
	

	SELECT CASE msg
		
		CASE $$WM_KEYDOWN :			' WM_KEYDOWN returns virtKey constants
			virtKey = wParam
			IF virtKey == $$VK_RETURN THEN
				id = GetWindowLongA (hWnd, $$GWL_ID)
				wParam = ($$EDITBOX_RETURN << 16) OR id
				SendMessageA (GetParent(hWnd), $$WM_COMMAND, wParam, hWnd)	' send WM_COMMAND message to main window callback function
				RETURN 0
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
	TabChildCon[upper] = NewChild ($$WC_LISTVIEW, "", $$LVS_REPORT, 0, 0, 0, 0, hparent, IDC, exStyle)

	RETURN TabChildCon[upper]
	
END FUNCTION

FUNCTION SetTabTitle (tabc,STRING title)
	TC_ITEM tci


	IFZ title THEN RETURN $$FALSE
	
	tci.mask 		= $$TCIF_TEXT
	tci.pszText 	= &title
	tci.cchTextMax 	= LEN(title)
	SendMessageA (#hTabCtl, $$TCM_SETITEM, tabc, &tci)
	
	RETURN $$TRUE
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
	TabChildCon[upper] = NewChild ("edit", "", $$ES_MULTILINE  | $$ES_READONLY | $$WS_VSCROLL | $$ES_LEFT, 1, 20, 300, 300, hparent, IDC, $$WS_EX_STATICEDGE | style)

	RETURN TabChildCon[upper]
END FUNCTION

FUNCTION WndProc (hWnd, msg, wParam, lParam)
	SHARED STRING LastSelNick
	SHARED TabChildCon[]
	STATIC STRING tmp
	STATIC cmd$
	STATIC SHUTONCE
	TRECT rc
	POINTAPI pt
	STATIC t0


	SELECT CASE msg
		CASE $$WM_NOTIFY			:
			GetNotifyMsg (lParam, @hwndFrom, @idFrom, @code)
			idCtrl = idFrom
			SELECT CASE idCtrl
		
				CASE $$Tab1 :
					SELECT CASE code
						CASE $$TCN_SELCHANGE :
							iTab = SendMessageA (hwndFrom, $$TCM_GETCURSEL, 0, 0)
							
							FOR t = 0 TO UBOUND(TabChildCon[])	' hide deslected tabs
								IF (t != iTab) THEN ShowWindow (GetTabChild(t), $$SW_HIDE)
							NEXT t
							
							IF ((iTab == 2) OR (iTab == 3)) THEN
								ShowWindow (#CmdLine, $$SW_HIDE)
								ShowWindow (#SearchLine, $$SW_SHOWNORMAL)
							ELSE
								ShowWindow (#SearchLine, $$SW_HIDE)
								ShowWindow (#CmdLine, $$SW_SHOWNORMAL)
							END IF
						
							ShowWindow (GetTabChild(iTab), $$SW_SHOWNORMAL)	'show selected tab
							RETURN 0
					END SELECT
			END SELECT

		CASE $$WM_CREATE 		:
		CASE $$WM_DESTROY		:IFZ SHUTONCE THEN
									SHUTONCE = 1
									DispatchDCTMsg ($$MDCT_RequestShutDown,"","")
									'CleanUp()
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
					SetForegroundWindow (hWnd)
			END SELECT
			RETURN
	
		CASE $$WM_COMMAND :
			id         = LOWORD (wParam)
			notifyCode = HIWORD (wParam)
			hwndCtl    = lParam

			SELECT CASE notifyCode
				CASE 0: 
					SELECT CASE id
						CASE $$PopUp_Exit 		: ' DestroyWindow (hWnd)
					END SELECT

				CASE $$EDITBOX_RETURN	:
					cmd$ = NULL$(4096)										
					SendMessageA (hwndCtl, $$WM_GETTEXT, 4096, &cmd$)
					cmd$ = CSIZE$(cmd$)
					
					SELECT CASE id 
						CASE $$CmdLine			:InitNewCmd (hwndCtl,&cmd$)
					 							 RETURN 0
						CASE $$SearchLine		:text$ = "/search "+cmd$
													PRINT text$
												 InitNewCmd (hwndCtl,&text$)
												 RETURN 0
					END SELECT

			END SELECT

		CASE $$WM_CTLCOLOREDIT,$$WM_CTLCOLORSTATIC
			RETURN SetColor (RGB(100, 100, 100), RGB(212, 208, 200), wParam, lParam)

		CASE $$WM_SIZE :
			fSizeType = wParam
			width = LOWORD(lParam)
			height = HIWORD(lParam)

			SetWindowPos (#hTabCtl,0, 0, 0, width,height-20, 0)
			SetWindowPos (#CmdLine,0, 0, height-20, width, 20,0)
			SetWindowPos (#SearchLine,0, 0, height-20, width, 20,0)

			FOR w = 0 TO UBOUND(TabChildCon[])
				SetWindowPos (GetTabChild(w),0, 0, 26, width-2,height-47, 0)
			NEXT w
			
			SendMessageA (#hSplitter1, $$WM_SET_SPLITTER_POSITION, width-120, 0)

			SELECT CASE fSizeType
				CASE $$SIZE_MINIMIZED :
					ShowWindow (hWnd, $$SW_HIDE)
			'	CASE $$SIZE_RESTORED, $$SIZE_MAXIMIZED  :
			'		GetClientRect (hWnd, &rc)
			'		MoveWindow (#winMain, 0, 0, rc.right, rc.bottom, $$TRUE)
			END SELECT
			
			RETURN 0
	END SELECT

	RETURN DefWindowProcA (hWnd, msg, wParam, lParam)

END FUNCTION

FUNCTION InitNewCmd (hwndCtl,lpcmd)
	STATIC STRING msg,cmd
	STATIC lastcmd$


	msg = CSTRING$(lpcmd)
	IFZ msg THEN
		RETURN $$FALSE
	ELSE
		IF (msg == "/") THEN
			SendMessageA (hwndCtl, $$WM_SETTEXT, 0, &lastcmd$)
			RETURN $$FALSE
		END IF
	END IF

	SELECT CASE LCASE$(GetTokenEx (TRIM$(msg),32,0))
		CASE "/pm","/msg"				:#MSGThread = _beginthreadex (NULL, 0, &ProcessClientText(), &msg, 0, &tid2)
										 Sleep (2)
		'CASE "/unload"					:#MSGThread = _beginthreadex (NULL, 0, &ProcessClientText(), &msg, 0, &tid2)
		'CASE "/ul"						:#MSGThread = _beginthreadex (NULL, 0, &ProcessClientText(), &msg, 0, &tid2)
		CASE ELSE						:ProcessClientText (&msg)
	END SELECT

	lastcmd$ = msg
	text$ = ""
	SendMessageA (hwndCtl, $$WM_SETTEXT, 0, &text$)		' clear new text

	RETURN $$TRUE
END FUNCTION

FUNCTION CenterWindow (hWnd)
	TRECT wRect


	GetWindowRect (hWnd, &wRect)
	x = (GetSystemMetrics ($$SM_CXSCREEN) - (wRect.right - wRect.left))/2
	y = (GetSystemMetrics ($$SM_CYSCREEN) - (wRect.bottom - wRect.top))/2
	SetWindowPos (hWnd, 0, x, y, 0, 0, $$SWP_NOSIZE OR $$SWP_NOZORDER)

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


	hInst = GetModuleHandleA (0)		' get current instance handle
	IFZ hInst THEN QUIT(0)

	'IFZ #hSemWndProc THEN #hSemWndProc = CreateSemaphoreA (NULL,1,1,NULL)
	IFZ #hSemCrtMsgWnd THEN #hSemCrtMsgWnd = CreateSemaphoreA (NULL,1,1,NULL)

	'IFZ #hSemMDCTb THEN #hSemMDCTb = CreateSemaphoreA (NULL,1,1,NULL)
	InitCommonControls()
	Splitter ()								' initiate splitter control

END FUNCTION

FUNCTION InitGUI ()
	STATIC	entry
'
	IF entry THEN RETURN					' enter once
	entry =  $$TRUE							' enter occured

	InitGui ()								' initialize program and libraries
	CreateWindows ()						' create main windows and other child controls
	CreateCallbacks ()						' if necessary, assign callback functions to child controls
	MessageLoop ()							' the message loop
	CleanUp ()								' unregister all window classes
	
END FUNCTION

FUNCTION CPrint (ECtrl,STRING text)
	SHARED MsgScroll


	IFZ text THEN RETURN $$FALSE
	trim (@text,'|')
	
	SELECT CASE ECtrl	
		CASE $$Hub			:hedit = #hub
		CASE $$Debug		:hedit = #debug
		CASE $$Search		:hedit = #search
		CASE $$SResults		:hedit = #SResultList
		CASE $$URLCatch		:hedit = #urlcatch
		CASE $$BotMsg		:hedit = #botmessage
		CASE ELSE			:RETURN $$FALSE
	END SELECT

	filterMessage (@text,"&#",$$Filter_DC)' filter dc++ unicode text
	SetEditText (ECtrl, trim (text,0)+"\r\n")
	
	IFT MsgScroll THEN
		tline = SendMessageA (hedit, $$EM_GETLINECOUNT, 0,0 )
		SendMessageA (hedit, $$EM_LINESCROLL, 0,tline )
		RETURN $$TRUE
	ELSE
 		RETURN $$FALSE
	END IF
	
END FUNCTION

FUNCTION HubChat (STRING user,STRING text)
	SHARED TIMESTAMP
	STATIC STRING name,msg


	filterMessage (@text,"http://",$$Filter_URL)
	filterMessage (@text,"www.",$$Filter_URL)
	filterMessage (@text,"ftp://",$$Filter_URL)
	filterMessage (@text,"ftp.",$$Filter_URL)

	name = replace (replace(user,'<','('),'>',')')
	IF (TRIM$(text){0} == '!') THEN
		IFT TIMESTAMP THEN
			CPrint ($$Hub,"["+GetTime()+"]"+name+" "+text)
		ELSE
			CPrint ($$Hub,name+" "+text)
		END IF
		name = trim(trim(name,'('),')')
		DispatchDCTMsg ($$MDCT_PubCmdMsg,@name,@text)
	ELSE
		IFF DispatchDCTMsg ($$MDCT_PubTxtMsg,@name,@text) THEN
			IFT TIMESTAMP THEN
				CPrint ($$Hub,"["+GetTime()+"]"+name+" "+text)
			ELSE
				CPrint ($$Hub,name+" "+text)
			END IF
		END IF
	END IF
	
	RETURN $$TRUE
END FUNCTION

FUNCTION PMChat (STRING user,STRING text)
	SHARED TIMESTAMP
	SHARED TMsgWin MsgWin[]
	SHARED MWTotal
	STATIC STRING name,msg
	

	filterMessage (@text,"http://",$$Filter_URL)
	filterMessage (@text,"www.",$$Filter_URL)
	filterMessage (@text,"ftp://",$$Filter_URL)
	filterMessage (@text,"ftp.",$$Filter_URL)

	user = TRIM$(replace (replace(user,'<','('),'>',')'))
	'who$ = FindUser(trim (trim (user,'('),')'))
	who$ = trim (trim (user,'('),')')
	
	IFZ who$ THEN		' client is not in list so msg must be from hub bot
		IFT TIMESTAMP THEN
			CPrint ($$BotMsg,"["+GetTime()+"]"+user+" "+text)
		ELSE
			CPrint ($$BotMsg,user+" "+text)
		END IF
		RETURN $$TRUE
	END IF

	found = $$FALSE
	FOR m = 0 TO MWTotal
		IF (who$ == MsgWin[m].user) THEN
			found = $$TRUE
			EXIT FOR
		END IF
	NEXT m

	IFF found THEN
		m = CreateMsgWindow (&who$)
		IF (m == -1) THEN
			CPrint ($$Hub,"* unable to create message window")
			RETURN $$FALSE
		END IF
	END IF
	
	IFT TIMESTAMP THEN
		MPrint (m,"["+GetTime()+"]"+user+" "+text)
	ELSE
		MPrint (m,user+" "+text)
	END IF
	
	IF LEFT$(TRIM$(text),1) == "!" THEN
		name = trim(trim(user,'('),')')
		DispatchDCTMsg ($$MDCT_PMCmdMsg,@name,@text)
	END IF
	RETURN $$TRUE
END FUNCTION

FUNCTION UpdateListBox (hwndCtl)
	STRING name,text
	CRITICAL_SECTION cs
	

	InitializeCriticalSection (&cs)
	EnterCriticalSection (&cs)
	
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
	
	LeaveCriticalSection (&cs)
	DeleteCriticalSection (&cs)
	
	RETURN $$TRUE
END FUNCTION


FUNCTION RemoveClients ()
	SHARED STRING TotalHubUsers 

	'FOR i = 0 TO SendMessageA (#CListBox, $$LB_GETCOUNT, 0, 0)
	'	SendMessageA (#CListBox, $$LB_DELETESTRING, i, 0)
	'NEXT i
	
	SendMessageA (#CListBox, $$LB_RESETCONTENT,0 ,0)
	TotalHubUsers = ""
	UpdateTitle ()	
	
	RETURN $$TRUE
END FUNCTION

FUNCTION RemoveClient (STRING user)
	
	user = TRIM$(user)
	i = SendMessageA (#CListBox, $$LB_FINDSTRING,-1 ,&user)
	IF (i >= 0) THEN SendMessageA (#CListBox, $$LB_DELETESTRING,i ,0)
	UpdateTitle ()

	RETURN $$TRUE
END FUNCTION

FUNCTION ClientQuit (STRING user)
	SHARED ShowJQ


	user = TRIM$(user)
	IFZ user THEN RETURN $$FALSE	
	IFT ShowJQ THEN CPrint ($$Hub,"Quit: "+user)

	RETURN $$TRUE
END FUNCTION

FUNCTION UpdateTitle ()
	SHARED UpdateTitleRequest
	SHARED STRING HubName
	SHARED STRING HubShare
	SHARED STRING TotalHubUsers


'	IF !(GetTickCount()-t0 > 1000) THEN
'		UpdateTitleRequest = $$TRUE
'		RETURN $$FALSE
'	ELSE
'		UpdateTitleRequest = $$FALSE
'	END IF
	
	IF GetConSocket() THEN
		title$ = "MyDC - "+HubName+" - "+TotalHubUsers+" users - " +HubShare+" TB"
	ELSE
		title$ = "MyDC"
	END IF
		
	SetWindowTextA (#winMain,&title$)
	t0 = GetTickCount()
	
	RETURN $$TRUE
END FUNCTION

FUNCTION FileSearch (STRING who, STRING msg)
	SHARED TIMESTAMP
	SHARED SHOWSEARCH
	STRING flag
	

	IFF SHOWSEARCH THEN RETURN $$FALSE

	GetToken (@msg,flag,'?')
	GetToken (@msg,flag,'?')
	GetToken (@msg,flag,'?')
	GetToken (@msg,flag,'?')
	GetToken (@msg,@file$,0)
	file$ = replace (file$,'$',' ')

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
	
	GetToken (@result,@user$,' ')
	GetToken (@result,@filepath$,5)
	GetToken (@result,@size$,' ' )
	GetToken (@result,@slots$,5)
	GetToken (@result,@hub$,0)
	
	DecomposePathname (filepath$, @path$, @parent$, @filename$, @file$, @extent$)
	size = SINGLE (size$) / 1024 / 1024

	IF size THEN
		size$ = STRING$(size)+" MB"
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
		InsertListViewItem (#SResultList,last,user$)

		'SetListViewSubItem (#SResultList, $$SR_USER , text, last)
		SetListViewSubItem (#SResultList, $$SR_FILENAME, filename$, last)
		SetListViewSubItem (#SResultList, $$SR_SIZE, size$ , last)
		SetListViewSubItem (#SResultList, $$SR_SLOTS, slots$, last)
		SetListViewSubItem (#SResultList, $$SR_FILEPATH, filepath$, last)
		SetListViewSubItem (#SResultList, $$SR_SLOTS, slots$, last)
		SetListViewSubItem (#SResultList, $$SR_HUB, hub$, last)
	
	RETURN $$TRUE
END FUNCTION

FUNCTION CCmdMsg (to$,STRING from, msg$)
	SHARED TMsgWin MsgWin[]
	SHARED MWTotal
	SHARED TIMESTAMP
	STRING who
	

	to$ = TRIM$(to$)
	msg$ = TRIM$(msg$)
	IFZ to$ THEN RETURN $$FALSE
	IFZ msg$ THEN RETURN $$FALSE
	
	IFZ GetConSocket() THEN
		RemoveClients ()
		CPrint ($$Hub,"* no connection")
		RETURN $$FALSE
	END IF
	
	IF (to$ == GetNick()) THEN
		to$ = from
		who = from
	ELSE
		who = GetNick()
	END IF
	
	found = $$FALSE
	FOR m = 0 TO MWTotal
		IF (LCASE$(to$) == LCASE$(MsgWin[m].user)) THEN
			found = $$TRUE
			EXIT FOR
		END IF
	NEXT m
		
	IFF found THEN
		m = CreateMsgWindow (&to$)
		IF (m == -1) THEN
			CPrint ($$Hub,"* unable to create message window")
			RETURN $$FALSE
		END IF
	END IF
		
	IFT TIMESTAMP THEN
		MPrint (m,"["+GetTime()+"]"+DisplayNick(who)+" "+msg$)
	ELSE
		MPrint (m,DisplayNick(who)+" "+msg$)
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION AddClient (STRING name)

	name = TRIM$(name)
	IF name THEN
		i = SendMessageA (#CListBox, $$LB_FINDSTRING,-1 ,&name)
		IF (i == $$LB_ERR) THEN 
			SendMessageA (#CListBox, $$LB_ADDSTRING, 0, &name)
		END IF
	END IF
	
	UpdateTitle ()
	RETURN $$TRUE
END FUNCTION

FUNCTION AddClients (STRING ctotal)
	STRING name

	DO
		name = TRIM$(GetTokenEx (@ctotal,5,0))
		IF name THEN
			i = SendMessageA (#CListBox, $$LB_FINDSTRING,-1 ,&name)
			IF (i == $$LB_ERR) THEN 
				SendMessageA (#CListBox, $$LB_ADDSTRING, 0, &name)
			END IF
		END IF
	LOOP WHILE ctotal
	
	RETURN $$TRUE
END FUNCTION

FUNCTION MPrint (m,STRING text)
	SHARED TMsgWin MsgWin[]
	SHARED MWTotal
	STATIC STRING text[]
	STATIC once
	
	
	IFZ once THEN
		once = 1
		DIM text[10]
	END IF

	IFZ text THEN RETURN $$FALSE
	IF m > UBOUND(text[]) THEN
		REDIM text[m+5]
	END IF

	IF (text == "$|"+STRING$(m)+"|$") THEN	' == delete window
		text[m] = ""
		RETURN $$TRUE
	END IF
	
	text[m] = text[m] + text + "\r\n"
	SendMessageA (MsgWin[m].hedit, $$WM_SETTEXT, 0, &text[m])
	tline = SendMessageA (MsgWin[m].hedit, $$EM_GETLINECOUNT, 0,0 )
	SendMessageA (MsgWin[m].hedit, $$EM_LINESCROLL, 0,tline )

	RETURN $$TRUE
END FUNCTION

FUNCTION CCmdNick (STRING nick)
	SHARED STRING Nick
	

	IF Socket THEN
		CPrint ($$Hub,"* cannot modify username while connected")
		RETURN $$FALSE
	END IF
	
	nick = TRIM$(trim(trim(nick,0),32))
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
  			Sleep (2)
  		END IF

  	LOOP WHILE ((GetTickCount()-t0) < time)
  	
END FUNCTION

FUNCTION ShowUserDetails (STRING user,edit)
	STRING ui
	

	user = TRIM$(user)
'	IFF IsUserConnected(user) THEN
'		CPrint (edit,"* user '"+user+"' not found")
'		RETURN $$FALSE
'	END IF

'	ui = CSTRING$(GetUserInfoAll (CSTRING$(&user)))
	IF ui THEN
		CPrint (edit,"* "+GetTokenEx(@ui,'$',0)+": share: "+GetTokenEx(@ui,'$',0)+" GB  comment: "+GetTokenEx(@ui,'$',0)+"  speed: "+GetTokenEx(@ui,'$',0)+"  email: "+GetTokenEx(@ui,'$',0))
		RETURN $$TRUE
	ELSE
		RETURN $$FALSE
	END IF

END FUNCTION

FUNCTION ClientJoin (STRING user)
	SHARED ShowJQ

	IFT ShowJQ THEN CPrint ($$Hub,"Join: "+user)
END FUNCTION

FUNCTION ProcessClientText (addrtext)
	STATIC cmd$,msg$


	IFZ addrtext THEN RETURN $$FALSE
	str$ = TRIM$(trim(CSTRING$(addrtext),'|'))
	IFZ	str$ THEN RETURN $$FALSE

	IF str${0} == '/' THEN
		str${0} = 0
		msg$ = LTRIM$(str$)
		GetToken (@msg$,@cmd$,32)
	'	filterMessage (@msg$,"\\\\",$$Filter_NAME)
		
		IFF ProcessClientCommand (cmd$,msg$) THEN
			DispatchDCTMsg ($$MDCT_ClientCmdMsg,cmd$,msg$)
		END IF
	ELSE
		IFZ GetConSocket() THEN
			RemoveClients ()
			CPrint ($$Hub,"* no connection")
			RETURN $$FALSE
		END IF
		
	'	filterMessage (@str$,"\\\\",$$Filter_NAME)
		DispatchDCTMsg ($$MDCT_SendPubTxt,str$,"")

	END IF

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

END PROGRAM
