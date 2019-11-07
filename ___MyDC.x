'
'	My Direct Connect
'	A Direct Connect expandable client & daemon
'	do not run this file without first adding the proxy or gui plugin to the autostart file (pluginlist).
'	i recommend using the proxy, connect to the proxy (via the gui) then connect to dc hub
'
'
'	Michael McElligott
'	Sixth of April 2004
'
'	this client has used with much success on 10000+ client hubs without fault for weeks on end.
'
PROGRAM	"MyDC"
VERSION	"0.50"
 'CONSOLE
' MAKEFILE "xexe.xxx"


	IMPORT "kernel32"
	IMPORT "wsock32"
	IMPORT "gdi32"
	IMPORT "user32"	'  MessageBoxA()
	IMPORT "msvcrt"	'  _beginthreadex ()
	IMPORT "winmm"	'  timer functions
	IMPORT "dcutils"
	IMPORT "MyDC.dec"
	
	'IMPORT "xio"	'  console printing
'	IMPORT "xsx"	'  XstLog()
	IMPORT "xst"	'  exception functions


$$FN_PluginList	= "pluginlist"

$$LBUFFER_MAX		= 131000		' socket recv buffer size
$$LOCALPORT			= 9991			' unused
$$SHUTDOWN			= 1

$$SOCK_TCP = $$SOCK_STREAM
$$SOCK_UDP = $$SOCK_DGRAM

$$DONT_RESOLVE_DLL_REFERENCES     = 0x00000001
$$LOAD_LIBRARY_AS_DATAFILE        = 0x00000002
$$LOAD_WITH_ALTERED_SEARCH_PATH   = 0x00000008

'$$UpperSlotID		= 

DECLARE FUNCTION Entry ()
DECLARE FUNCTION Shutdown ()

EXPORT
DECLARE FUNCTION DispatchDCTMessage (token, STRING msg1, STRING msg2)
DECLARE FUNCTION DispatchDCTMessageEx (token, STRING msg1, STRING msg2)
DECLARE FUNCTION ProcessPluginMessage (token, STRING msg1, STRING msg2)
END EXPORT

DECLARE FUNCTION PeekQueueMsg ()
DECLARE FUNCTION ReadQueueMsg (index,mode,token,STRING msg1,STRING msg2)
DECLARE FUNCTION VOID WriteQueueMsg (mode,token,STRING msg1,STRING msg2)
DECLARE FUNCTION DeleteQueueMsg (index)
DECLARE FUNCTION GetNextQueueMsg (mode,token,STRING msg1,STRING msg2)
DECLARE FUNCTION DeleteTypeQueueMsgs (mode,token)

DECLARE FUNCTION TDCPlugin InitPlugin (STRING dcpname, handle, XLONG udata1, XLONG udata2)
DECLARE FUNCTION StartupPlugins ()
DECLARE FUNCTION ShutdownPlugins ()

DECLARE FUNCTION ClientCommandLine (STRING text)
DECLARE FUNCTION ProcessClientCommand (STRING cmd ,STRING msg)

DECLARE FUNCTION ConnectToServer (STRING address,port)			' connect to address on port, return socket success, zero if fail
DECLARE FUNCTION DisconnectFromServer (socket)					' initiate server disconnect
DECLARE FUNCTION MessagePump (socket,STRING messages)			' extract commands from received messages
DECLARE FUNCTION ProcessServerToken (socket,STRING DCMSG,STRING message)		' process commands
DECLARE FUNCTION QueueToken (null)
DECLARE FUNCTION ListenBin (socket,ANY,tbytes)					' listen on socket and return after tbytes have been received with data contained within ANY type
DECLARE FUNCTION ListenMsg (socket)								' listen on socket for messages then send to messagepump
DECLARE FUNCTION SendBin (socket,bufferaddr,tbytes)				' send data to socket
DECLARE FUNCTION SendMsg (socket,STRING buffer)					' send string to socket
DECLARE FUNCTION SendMsgB (socket,STRING buffer)

DECLARE FUNCTION SocketInitWinSock()							' initiate winsocks32
DECLARE FUNCTION SocketOpen (sockettype)						' open a TCP or UDP socket, return socket handle if succede or zero otherwise
DECLARE FUNCTION SocketConnect (socket,STRING address,port)		' connect socket to address on port
DECLARE FUNCTION SocketRecv (socket,address,totalbytes)			' receive totalbytes to address from socket
DECLARE FUNCTION SocketSend (socket,address,totalbytes)			' send ttoalbytes at address to socket
DECLARE FUNCTION SocketClose (socket)							' close socket
DECLARE FUNCTION SocketBind (socket,STRING address,port)		' bind socket to address:port
DECLARE FUNCTION SocketListen (socket)							' set socket to listening state
DECLARE FUNCTION SocketAccept (socket,STRING claddress,clport)	' set socket to accept sate. returns clientsocket when conenction has been established

DECLARE FUNCTION WaitForConnect (socket)
DECLARE FUNCTION GetConSocket ()
DECLARE FUNCTION SetConSocket (socket)

DECLARE FUNCTION _socket (af, s_type, protocol)
DECLARE FUNCTION _EnumNetworkEvents (socket, hWsaEvent, lpNetworkEvents)
DECLARE FUNCTION _WaitForMultipleEvents (cEvents, lphEvents, fWaitAll, dwTimeout, fAlertable)
DECLARE FUNCTION _EventSelect (socket, hWsaEvent, lNetworkEvents)
DECLARE FUNCTION _CloseEvent (hWsaEvent)
DECLARE FUNCTION _CreateEvent ()
DECLARE FUNCTION _WSAConnect (s, sname, namelen, lpCallerData, lpCalleeData, lpSQOS, lpGQOS)

DECLARE FUNCTION STRING FindUser (STRING nick)					' search client list for partial nick
DECLARE FUNCTION STRING LockToKey (STRING lock)					' return key from lock 
DECLARE FUNCTION STRING GetNick ()
DECLARE FUNCTION STRING GetAltNick ()
DECLARE FUNCTION STRING GetHubNick ()
DECLARE FUNCTION STRING GetUser (user)							' get username from list
DECLARE FUNCTION STRING GetNumIPAddr (STRING IPName)			' convert dns name to ip dot format (name lookup)

DECLARE FUNCTION IsUserConnected (STRING user)					' check if user is connected
DECLARE FUNCTION SetNick (STRING nick, STRING altnick)
DECLARE FUNCTION FileSearch (msg$)
DECLARE FUNCTION RemoveClient (STRING user)

DECLARE FUNCTION SetHubOperators (STRING text)
DECLARE FUNCTION IsUserAnOp	(STRING user)

DECLARE FUNCTION AddClients (socket,STRING users)
DECLARE FUNCTION AddClient (msg$)
DECLARE FUNCTION RemoveClients ()

DECLARE FUNCTION STRING GetHubShare ()
DECLARE FUNCTION GetUserInfoAll (STRING user)
DECLARE FUNCTION STRING CalcHubShare ()
DECLARE FUNCTION GetTotalHubUsers ()

DECLARE FUNCTION LoadPlugin (STRING filename, XLONG udata1, XLONG udata2)
DECLARE FUNCTION UnLoadPlugin (index)
DECLARE FUNCTION ListPlugins (dest)

DECLARE FUNCTION HubChat (socket,STRING user,STRING text)
DECLARE FUNCTION PMChat (socket,STRING user,STRING text)
DECLARE FUNCTION SendPMTxt (STRING text, STRING to)

DECLARE FUNCTION STRING GetHubName ()
DECLARE FUNCTION SetHubName (STRING name)

DECLARE FUNCTION SendConnStatus()
DECLARE FUNCTION CleanUp ()
DECLARE FUNCTION SetMyShare (STRING share)
DECLARE FUNCTION STRING GetMyShare ()
DECLARE FUNCTION SendSearchQuery (STRING flags, STRING file)
DECLARE FUNCTION SendIntClientList ()
DECLARE FUNCTION SetPassword (STRING password)
DECLARE FUNCTION STRING GetPassword ()

DECLARE FUNCTION InitConsoleTimer ()
DECLARE FUNCTION TimerCallback (wtimerid, msg, dwUser, dw1, dw2) 
DECLARE FUNCTION SetTimerCallback (npSeq, msInterval)
DECLARE FUNCTION SetTimerCallbackSingle (npSeq, msInterval)
DECLARE FUNCTION DestroyTimer (wTimerID) 

DECLARE FUNCTION SendOpList (plugin)
DECLARE FUNCTION SendHubShare ()
DECLARE FUNCTION UpdateNewPlugin (TPlugin)
DECLARE FUNCTION MsgPlugin (hdcp, token, STRING msg1, STRING msg2)
DECLARE FUNCTION GetPluginCount ()
DECLARE FUNCTION STRING GetFormatedClientList (char)
DECLARE FUNCTION SendFormatedClientListAll ()

'DECLARE FUNCTION OffLoadMsgForDispatch (mode, lpFunadr, token, STRING msg1, STRING msg2)
DECLARE FUNCTION OffLoadMsgForDispatch (token, STRING msg1, STRING msg2)

DECLARE FUNCTION TimerShare (id,count,msec,time)

DECLARE FUNCTION VOID except ()		' basic exception handling
DECLARE FUNCTION VOID error()
DECLARE FUNCTION VOID retry()


FUNCTION VOID Entry ()
	SHARED STRING Connection
	SHARED STRING TSlots
	SHARED CONNECTED
	SHARED DEBUG
	SHARED MSGREADY 
	SHARED EXCEPTION_DATA exception
	
	
	XstSetExceptionFunction (&error())
	XstTry (SUBADDRESS(try),SUBADDRESS(except),@exception)
	RETURN


SUB try
	DEBUG		= $$FALSE
	MSGREADY	= $$TRUE
	CONNECTED	= $$FALSE

	SetNick ("Okio","Okio-")
	SetPassword ("password")
	SetMyShare ("0")				' share size in bytes
	Connection = "Cable\1"
	TSlots = "3"					' total file slots


	IFF SocketInitWinSock() THEN RETURN $$FALSE

	#hSemCList = CreateSemaphoreA (NULL,1,1,NULL)
	#hSemConnect = CreateSemaphoreA (NULL,0,1,NULL)
	
	id$ = "MDCTBlk"+STRING$(GetTickCount()) 'create a unique id
	#hMuteMDCT = CreateMutexA (0,0,&id$)
	id$ = "TBlk"+STRING$(GetTickCount())
	#hMuteTimerB = CreateMutexA (0,0,&id$)
	id$ = "TDvar"+STRING$(GetTickCount())
	#QDVar = CreateMutexA (0,0,&id$)
	
	#hSemQueueBlkC = CreateSemaphoreA (NULL,0,1,NULL)
	#hQDispatchTh = _beginthreadex (NULL, 0, &QueueToken(), #hSemQueueBlkC, 0, &tid)

	StartupPlugins ()
	InitConsoleTimer ()

	DO
		ret = WaitForSingleObject (#hSemConnect,$$INFINITE)
		SELECT CASE CONNECTED
			CASE $$SHUTDOWN		:EXIT DO
			CASE $$TRUE			:IF (ret == $$WAIT_OBJECT_0) THEN ListenMsg(GetConSocket())
			CASE $$FALSE		:
		END SELECT
	LOOP WHILE (CONNECTED != $$SHUTDOWN)

	Shutdown ()
	RETURN
END SUB

SUB retry
	retry()
END SUB
SUB except
	except()
END SUB
END FUNCTION


FUNCTION VOID except ()
	SHARED EXCEPTION_DATA exception
	
	XstExceptionNumberToName (exception.code, @name$)
	'PRINT "except():",exception.code,name$

	IFZ name$ THEN name$ = "unhandled exception" 
	MessageBoxA (0,&name$, &"Exception Error", $$MB_OK | $$MB_ICONSTOP)

	Shutdown ()
	exception.response = $$ExceptionTerminate ' $$ExceptionRetry
	'exception.address = SUBADDR(retry)
END FUNCTION

FUNCTION VOID retry()
	SHARED EXCEPTION_DATA exception
	
	'PRINT "retry()"
END FUNCTION

FUNCTION VOID error()
	SHARED EXCEPTION_DATA exception

	XstExceptionNumberToName (exception.code, @name$)
	'PRINT "error(): fatal exception",exception.code,name$
	
	IFZ name$ THEN name$ = "unhandled exception" 
	MessageBoxA (0,&name$$, &"Fatal Program Error", $$MB_OK | $$MB_ICONSTOP)
	Shutdown ()
END FUNCTION

FUNCTION ClientCommandLine (STRING text)
	STATIC cmd$,msg$


	IFZ text THEN RETURN $$FALSE
	str$ = trim(text,'|')
	IFZ	str$ THEN RETURN $$FALSE

	IF str${0} == '/' THEN
		str${0} = 0
		msg$ = LTRIM$(str$)
		cmd$ = GetTokenEx2 (@msg$,32)
		
		IFF DispatchDCTMessage ($$MDCT_ClientCmdMsg,@cmd$,@msg$) THEN
			ProcessClientCommand (cmd$,@msg$)
		END IF
	ELSE
		IFZ GetConSocket() THEN
			DispatchDCTMessage ($$MDCT_Error,$$MDCE_NotConnected,"")
			RETURN $$FALSE
		END IF
		
		IFF DispatchDCTMessage ($$MDCT_ClientTxtMsg,@str$,"") THEN
			msg$ = GetHubNick()+" "+str$
			SendMsg (GetConSocket(),@msg$)
		END IF
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION ProcessClientCommand (cmd$,msg$)
	SHARED SHOWSEARCH
	SHARED MsgScroll
	SHARED TIMESTAMP
	SHARED DEBUG
	SHARED tplugin

	cmd$ = LCASE$(TRIM$(cmd$))
	SELECT CASE cmd$
		CASE "load"			:file$ = GetTokenEx2 (@msg$,',')
							 udata1 = XLONG(GetTokenEx2 (@msg$,','))
							 udata2 = XLONG(GetTokenEx2 (@msg$,','))
							 LoadPlugin (file$,udata1,udata2)
		CASE "unload"		:#hplunThrd =_beginthreadex (NULL, 0, &UnLoadPlugin(), XLONG(TRIM$(msg$)), 0, &tid2)
							 'Sleep (100)
							 'UnLoadPlugin (XLONG(TRIM$(msg$)))
							 'tplugin = XLONG(TRIM$(msg$))
							 '#timerplugin = SetTimerCallback ($$TimerUnload,100)
							 
		CASE "pluginlist"	:ListPlugins (-1)
		CASE "debugall"		:IFT DEBUG THEN
							 	DEBUG = $$FALSE
							 ELSE
							 	DEBUG = $$TRUE
							 END IF
		CASE "refresh"		:RemoveClients ()
							 SendMsg (GetConSocket(),"$GetNickList")
		CASE ELSE			:DispatchDCTMessage ($$MDCT_UnknownCmd,@cmd$,@msg$)
							 RETURN $$FALSE
	END SELECT
	
	RETURN $$TRUE
END FUNCTION

FUNCTION STRING GetPassword ()
	SHARED STRING Password

	RETURN Password
END FUNCTION

FUNCTION SetPassword (STRING password)
	SHARED STRING Password


	password = TRIM$(password)
	IF password THEN
		Password = password
		DispatchDCTMessage ($$MDCT_Password,Password,"")
		RETURN $$TRUE
	ELSE
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_BadPassword,@password)
		RETURN $$FALSE
	END IF
	
END FUNCTION

FUNCTION GetUserInfoAll (STRING user)
	SHARED TCLIENTS ClientList[]
	STATIC STRING info	
	STRING share


	user = LCASE$(TRIM$(user))
	IFF IsUserConnected(@user) THEN RETURN 0
	
	IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN RETURN $$FALSE
	FOR i = 0 TO UBOUND(ClientList[])
		IF user == LCASE$(ClientList[i].name) THEN
			info = ClientList[i].name+"$"+ClientList[i].share+"$"+ClientList[i].comment+"$"+ClientList[i].speed+"$"+ClientList[i].email+"$"
			ReleaseSemaphore (#hSemCList,1,0)
			RETURN &info
		END IF
	NEXT i
	ReleaseSemaphore (#hSemCList,1,0)
	RETURN 0
END FUNCTION

FUNCTION HubChat (socket,STRING user, STRING text)
	STATIC STRING name,cmd

	name = trim(trim(trim(trim(user,'('),')'),'<'),'>')
	IFZ name THEN RETURN $$FALSE
	IFZ text THEN RETURN $$FALSE
	
	SELECT CASE text{0}
		CASE '!','+','?','~'	:DispatchDCTMessage ($$MDCT_PubCmdMsg,@name,@text)
		CASE ELSE				:DispatchDCTMessage ($$MDCT_PubTxtMsg,@name,@text)
	END SELECT
	
	RETURN $$TRUE
END FUNCTION

FUNCTION PMChat (socket,STRING name,STRING text)


	name = trim(trim(trim(trim(name,'('),')'),'<'),'>')
'	text = TRIM$(text)
	IFZ name THEN RETURN $$FALSE
	IFZ text THEN RETURN $$FALSE

	IF text{0} == '!' THEN
		DispatchDCTMessage ($$MDCT_PMCmdMsg,name,text)
	ELSE
		DispatchDCTMessage ($$MDCT_PMTxtMsg,name,text)
	END IF
	
	RETURN $$TRUE
END FUNCTION

FUNCTION QueueToken (hSemQueueBlkC)
	SHARED EXCEPTION_DATA exception
	SHARED CONNECTED
	STRING msg1,msg2

	
	XstTry (SUBADDRESS(try),SUBADDRESS(except),@exception)
	RETURN
	
SUB try
	DO
		DO
			i = PeekQueueMsg()
			IF (i == -1) THEN
				Sleep (3)
			ELSE
				EXIT DO
			END IF
		LOOP 'WHILE (i == -1)

		mode = 0
		ReadQueueMsg (i,@mode,@token,@msg1,@msg2)
		IF mode THEN		' if mode == 0 then message was deleted
			DeleteQueueMsg (i)
			SELECT CASE mode
				CASE 1		:DispatchDCTMessage (token,@msg1,@msg2)
				CASE 2		:ProcessServerToken (token,@msg1,@msg2)
						 	 ReleaseSemaphore (hSemQueueBlkC,1,0)
			END SELECT
		END IF
	LOOP WHILE (CONNECTED != $$SHUTDOWN)
	RETURN 
END SUB

SUB retry
	retry()
END SUB
SUB except
	except()
END SUB
END FUNCTION

FUNCTION GetNextQueueMsg (mode,token,STRING msg1,STRING msg2)
	SHARED STRING QDmsg1[],QDmsg2[]
	SHARED QDtoken[],QDMode[],QDid[]
	SHARED id


	IF WaitForSingleObject (#QDVar,$$INFINITE) != $$WAIT_OBJECT_0 THEN RETURN -1
	
	slotid = 999999
	FOR s = 0 TO UBOUND(QDtoken[])
		IF QDtoken[s] THEN
			IF (QDid[s] < slotid) THEN
				slotid = QDid[s]
				slot = s
			END IF
		END IF
	NEXT s

	IF (slotid != 999999) THEN
		mode = QDMode[slot]
		token = QDtoken[slot]
		SWAP QDmsg1[slot], msg1
		SWAP QDmsg2[slot], msg2
		'msg1 = QDmsg1[slot]
		'msg2 = QDmsg2[slot]
		ReleaseMutex (#QDVar)
		RETURN slot
	ELSE
		ReleaseMutex (#QDVar)
		RETURN -1
	END IF

END FUNCTION

FUNCTION PeekQueueMsg ()
	SHARED QDtoken[],QDid[]


	IF WaitForSingleObject (#QDVar,$$INFINITE) != $$WAIT_OBJECT_0 THEN RETURN -1
	
	slotid = 999999
	FOR s = 0 TO UBOUND(QDtoken[])
		IF QDtoken[s] THEN
			IF (QDid[s] < slotid) THEN
				slotid = QDid[s]
				slot = s
			END IF
		END IF
	NEXT s

	IF (slotid != 999999) THEN
		ReleaseMutex (#QDVar)
		RETURN slot
	ELSE
		ReleaseMutex (#QDVar)
		RETURN -1
	END IF

END FUNCTION

FUNCTION ReadQueueMsg (index,mode,token,STRING msg1,STRING msg2)
	SHARED STRING QDmsg1[],QDmsg2[]
	SHARED QDtoken[],QDMode[],QDid[]


	IF WaitForSingleObject (#QDVar,$$INFINITE) != $$WAIT_OBJECT_0 THEN RETURN 0
	
	IF (index >=0) && (index <= UBOUND(QDtoken[]))
		IF QDMode[index] THEN
			mode = QDMode[index]
			token = QDtoken[index]
			SWAP QDmsg1[index], msg1
			SWAP QDmsg2[index], msg2
			'msg1 = QDmsg1[index]
			'msg2 = QDmsg2[index]
		ELSE
			mode = 0
			token = 0
			msg1 = ""
			msg2 = ""
		END IF
	END IF
	
	ReleaseMutex (#QDVar)
	RETURN token
END FUNCTION

FUNCTION OffLoadMsgForDispatch (token, STRING msg1, STRING msg2)

	WriteQueueMsg (2,token,msg1,msg2)
	WaitForSingleObject (#hSemQueueBlkC,$$INFINITE)
	RETURN $$TRUE
END FUNCTION

FUNCTION DispatchDCTMessageEx (token, STRING msg1, STRING msg2)

	WriteQueueMsg (1,token,msg1,msg2)
	RETURN $$FALSE
END FUNCTION

FUNCTION VOID WriteQueueMsg (mode,token,STRING msg1,STRING msg2)
	SHARED STRING QDmsg1[],QDmsg2[]
	SHARED QDtoken[],QDMode[],QDid[]
	SHARED id


	IF WaitForSingleObject (#QDVar,$$INFINITE) != $$WAIT_OBJECT_0 THEN RETURN 0

	found = $$FALSE
	slot = 0
	upper = UBOUND(QDtoken[])

	FOR s = 0 TO upper		' find a free slot
		IFZ QDtoken[s] THEN
			slot = s
			found = $$TRUE
			EXIT FOR
		END IF
	NEXT s
	
	IFF found THEN
		newupper = upper + 50
		REDIM QDtoken[newupper]
		REDIM QDMode[newupper]
		REDIM QDmsg1[newupper]
		REDIM QDmsg2[newupper]
		REDIM QDid[newupper]
		slot = upper+1
		found = $$TRUE
	END IF
	
	IFT found THEN
		QDMode[slot] = mode
		QDtoken[slot] = token
		SWAP QDmsg1[slot], msg1
		SWAP QDmsg2[slot], msg2
		'QDmsg1[slot] = msg1
		'QDmsg2[slot] = msg2
		QDid[slot] = id
		INC id
		ReleaseMutex (#QDVar)
		RETURN ' slot
	ELSE
		ReleaseMutex (#QDVar)
		RETURN  ' 0
	END IF
	
END FUNCTION

FUNCTION DeleteTypeQueueMsgs (mode,token)
	SHARED STRING QDmsg1[],QDmsg2[]
	SHARED QDtoken[],QDMode[]
	SHARED QDid[]


	IF WaitForSingleObject (#QDVar,$$INFINITE) != $$WAIT_OBJECT_0 THEN RETURN $$FALSE
	
	IFZ (mode && token) THEN
		'RETURN $$FALSE
		Beep (400,400)
	END IF

	found = $$FALSE
	FOR s = 0 TO UBOUND(QDtoken[])
		IF (QDtoken[s] == token) THEN
			IF (QDMode[s] == mode) THEN
				QDMode[s] = 0
				QDtoken[s] = 0
				QDmsg1[s] = ""
				QDmsg2[s] = ""
				QDid[s] = 999999
				found = $$TRUE
			END IF
		END IF
	NEXT s

	ReleaseMutex (#QDVar)
	RETURN found

END FUNCTION

FUNCTION DeleteQueueMsg (index)
	SHARED STRING QDmsg1[],QDmsg2[]
	SHARED QDtoken[],QDMode[]
	SHARED QDid[]
	
	
	IF WaitForSingleObject (#QDVar,$$INFINITE) != $$WAIT_OBJECT_0 THEN RETURN $$FALSE
	
	IF (index >=0) AND (index <= UBOUND(QDtoken[]))
		QDMode[index] = 0
		QDtoken[index] = 0
		QDmsg1[index] = ""
		QDmsg2[index] = ""
		QDid[index] = 999999
		ReleaseMutex (#QDVar)
		RETURN $$TRUE
	ELSE
		ReleaseMutex (#QDVar)
		RETURN $$FALSE
	END IF	

END FUNCTION

FUNCTION ProcessServerToken (socket,cmd$,msg$)
	SHARED STRING Connection
	SHARED STRING TSlots
	SHARED CONNECTED
	SHARED DEBUG


	'XstLog (cmd$+" "+msg$,0,"n:\\dc.log")

	IF CONNECTED != $$TRUE THEN RETURN $$FALSE
	IFZ cmd$ THEN RETURN $$FALSE
	IFT DEBUG THEN DispatchDCTMessage ($$MDCT_Debug,@cmd$,@msg$)


	SELECT CASE cmd$
		CASE "$Search"			:'FileSearch (@msg$)
		'CASE "$MyInfo"			:AddClient (@msg$)
		CASE "$MyINFO"			:AddClient (@msg$)
		CASE "$Quit"			:who$ = GetTokenEx2 (@msg$,32)
								 ret = RemoveClient(who$)
								 IF ret THEN
									DispatchDCTMessage ($$MDCT_ClientQuit,who$,"")
									IF (ret == 2) THEN SendOpList(-1)
									SendHubShare ()
								 END IF
		CASE "$SR"				:DispatchDCTMessage($$DCT_SR,@msg$,"")
		CASE "$UserCommand"		:DispatchDCTMessage($$DCT_UserCommand,msg$,"")
		CASE "$HubName"			:SetHubName (@msg$)
		CASE "$OpList"			:DispatchDCTMessage($$DCT_OpList,msg$,"")
								 SetHubOperators (@msg$)
								 SendOpList (-1)
		CASE "$NickList"		:AddClients (GetConSocket(),msg$)
		CASE "$MyNick"			:DispatchDCTMessage($$DCT_MyNick,msg$,"")
		CASE "$Direction"		:DispatchDCTMessage($$DCT_Direction,msg$,"")
		CASE "$Error"			:DispatchDCTMessage($$DCT_Error,msg$,"")
		CASE "$Get"				:DispatchDCTMessage($$DCT_Get,msg$,"")
		CASE "$Send"			:DispatchDCTMessage($$DCT_Send,msg$,"")
		CASE "$HubIsFull"		:DispatchDCTMessage($$DCT_HubIsFull,msg$,"")
		CASE "$BadPass"			:DispatchDCTMessage($$DCT_BadPass,msg$,"")
		CASE "$Cancel"			:DispatchDCTMessage($$DCT_Cancel,msg$,"")
		CASE "$Canceled"		:DispatchDCTMessage($$DCT_Canceled,msg$,"")
		CASE "$GetNetInfo"		:IFF DispatchDCTMessage($$DCT_GetNetInfo,msg$,"") THEN
									'SendMsg (socket,"$NetInfo "+TSlots+"$1$P")	' only NMDC clients reply to $GetNetInfo messages
								 END IF
		CASE "$Key"				:DispatchDCTMessage($$DCT_Key,msg$,"")
		CASE "$ValidateNick"	:DispatchDCTMessage($$DCT_ValidateNick,msg$,"")
		CASE "$ValidateDenide"	:DispatchDCTMessage($$DCT_ValidateDenide,msg$,"")
								 DisconnectFromServer (GetConSocket())
		CASE "$MyPass"			:DispatchDCTMessage($$DCT_MyPass,msg$,"")
		CASE "$Supports"		:DispatchDCTMessage($$DCT_Supports,msg$,"")
		CASE "$GetNickList"		:DispatchDCTMessage($$DCT_GetNickList,msg$,"")
		CASE "$GetINFO"			:IFF DispatchDCTMessage ($$DCT_GetINFO,msg$,"") THEN
									' SendMsg (socket,"$MyINFO $ALL "+GetNick()+" <++ V:0.264,M:P,H:0,S:"+TSlots+">$ $"+Connection+"$$"+GetMyShare ()+"$")
								 END IF
		CASE "$MultiSearch"		:DispatchDCTMessage($$DCT_MultiSearch,msg$,"")
		CASE "$To:"				:GetTokenEx2 (@msg$,32) ' to$
								 GetTokenEx2 (@msg$,32)	' junk
								 GetTokenEx2 (@msg$,'$')	' from
								 to$ = GetTokenEx2 (@msg$,32)	' to
							 	 PMChat (GetConSocket(),to$,msg$)
		CASE "$ConnectToMe"		:DispatchDCTMessage($$DCT_ConnectToMe,msg$,"")
		CASE "$RevConnectToMe"	:DispatchDCTMessage($$DCT_RevConnectToMe,msg$,"")
		CASE "$MultiConnectToMe":DispatchDCTMessage($$DCT_MultiConnectToMe,msg$,"")
		CASE "$Kick"			:DispatchDCTMessage($$DCT_Kick,msg$,"")
		CASE "$HubINFO"			:DispatchDCTMessage($$DCT_HubINFO,msg$,"")
		CASE "$OpForceMove"		:DispatchDCTMessage($$DCT_OpForceMove,msg$,"")
		CASE "$ForceMove"		:DisconnectFromServer (GetConSocket())
								 DispatchDCTMessage($$DCT_ForceMove,msg$,"")
		CASE "$GetPass"			:IFF DispatchDCTMessage($$DCT_GetPass,msg$,"") THEN
									IFZ GetPassword() THEN
										DispatchDCTMessage ($$MDCT_Error,$$MDCE_NoPassSet,"")
								 	ELSE
									 	SendMsg (socket,"$MyPass "+GetPassword())
									 END IF
								 END IF
		CASE "$LogedIn"			:DispatchDCTMessage($$DCT_LogedIn,msg$,"")
		CASE "$UserIP"			:DispatchDCTMessage($$DCT_UserIP,msg$,"")
		CASE "$HubTopic"		:DispatchDCTMessage($$DCT_HubTopic,msg$,"")
		CASE "$Lock"			:lock$ = GetTokenEx2 (@msg$,32)
								 DispatchDCTMessage($$DCT_Lock,lock$,msg$)
								 IF INSTR(lock$,"EXTENDEDPROTOCOL") THEN
								 	EXTPROT = $$TRUE
								 	'SendMsg (socket,"$Supports NoHello Ping")
								 	SendMsg (socket,"$Supports Ping")
								 ELSE
								 	EXTPROT = $$FALSE
								 END IF
							 	 SendMsg (socket,"$Key "+LockToKey(@lock$))
							 	 SendMsg (socket,"$ValidateNick "+GetNick())
								 #NickList = $$FALSE
		CASE "$Hello"			:DispatchDCTMessage($$DCT_Hello,"","")
								 IFF #NickList THEN
								 	SendMsg (socket,"$Version 1,0091")
								 	SendMsg (socket,"$MyINFO $ALL "+GetNick()+" "+"I Rok<++ V:0.401,M:P,H:1/0/0,S:"+TSlots+">$ $"+Connection+"$$"+GetMyShare()+"$")
								 	SendMsg (socket,"$GetNickList")
								 	IFT EXTPROT THEN SendMsg (socket,"$BotINFO pinger")
								 END IF
								 #NickList = $$TRUE
		CASE ELSE				:
			IF (cmd${0} == '<') OR (cmd${0} == '*') THEN		' process chat messages
				'IFZ TRIM$(msg$) THEN msg$ = "<no text>"
				HubChat (GetConSocket(),@cmd$,@msg$)
				RETURN $$TRUE
			END IF
	
			IFT IsUserConnected (@cmd$) THEN
				'IFZ TRIM$(msg$) THEN msg$ = "<no text>"
				msg$ = cmd$+" "+msg$
				HubChat (GetConSocket(),"*",@msg$)
				RETURN $$TRUE
			END IF

			DispatchDCTMessage($$DCT_Unknown,@cmd$,@msg$)
			RETURN $$FALSE
	END SELECT
	
	RETURN $$TRUE
END FUNCTION

FUNCTION DispatchDCTMessage (token, STRING msg1, STRING msg2) ' recursive function


	'XstLog (STRING$(token)+" "+msg1+" : "+msg2,0,"r:\\ddctm.log")

	SELECT CASE WaitForSingleObject (#hMuteMDCT,4000)
		CASE $$WAIT_OBJECT_0	:
			FOR t = 0 TO GetPluginCount ()
				SELECT CASE MsgPlugin (t,token,msg1,msg2)
					'CASE $$MDCTH_Error			:#hplunThrd =_beginthreadex (NULL, 0, &UnLoadPlugin(), t, 0, &tid2)
					'							 ret = $$FALSE
					CASE $$MDCTH_HandledStop	:ret = $$TRUE: EXIT FOR
					CASE $$MDCTH_HandledCont	:ret = $$TRUE
					CASE $$MDCTH_UnhandledStop	:ret = $$FALSE: EXIT FOR
					CASE $$MDCTH_UnhandledCont	:ret = $$FALSE
					CASE ELSE					:#hplunThrd =_beginthreadex (NULL, 0, &UnLoadPlugin(),t, 0, &tid2)
												ret = $$FALSE
				END SELECT
			NEXT t
			
			IFF ret THEN
				IFF ProcessPluginMessage (token,msg1,msg2) THEN ret = $$FALSE
			END IF
			
			ReleaseMutex (#hMuteMDCT)
			RETURN ret
			
		CASE $$WAIT_TIMEOUT		:
			'XstLog (STRING$(token)+" "+msg1+" "+msg2,0,"c:\\ddctmtimeout.log")
			Beep(400,100):RETURN $$FALSE
		CASE $$WAIT_ABANDONED	:RETURN $$FALSE
		CASE ELSE				:RETURN $$FALSE
	END SELECT
	
END FUNCTION

FUNCTION ProcessPluginMessage (token, STRING msg1, STRING msg2)


	handled = $$TRUE
	SELECT CASE token
		CASE $$MDCT_SendBin				:SendBin (GetConSocket(),&msg1,XLONG(msg2))
		CASE $$MDCT_ConnectToAddress	:ConnectToServer (@msg1,XLONG(msg2))
		CASE $$MDCT_Disconnect			:DisconnectFromServer ($$NULL)
		CASE $$MDCT_GetConSocket		:DispatchDCTMessage ($$MDCT_ConSocket,STRING$(GetConSocket()),"")
		CASE $$MDCT_GetConnStatus		:SendConnStatus ()
		CASE $$MDCT_SendPubTxt			:ClientCommandLine (@msg1)
		CASE $$MDCT_SendPMsg			:SendPMTxt (msg1,msg2)
		CASE $$MDCT_SetMyShareSize		:SetMyShare (msg1)
		CASE $$MDCT_GetMyShareSize		:DispatchDCTMessage ($$MDCT_MyShareSize,GetMyShare(),"")
		CASE $$MDCT_SetNick				:SetNick (@msg1,@msg2)
		CASE $$MDCT_GetNick				:DispatchDCTMessage ($$MDCT_Nick,GetNick(),GetAltNick())
		CASE $$MDCT_GetHubShareTotal	:SendHubShare () 'DispatchDCTMessage ($$MDCT_HubShareTotal,GetHubShare(),STRING$(GetTotalHubUsers()))
		CASE $$MDCT_RequestShutDown		:Shutdown()
		CASE $$MDCT_SendFileSearch		:SendSearchQuery (@msg1,@msg2)
		CASE $$MDCT_ClientCmdMsg		:ProcessClientCommand (@msg1,@msg2)
		CASE $$MDCT_GetIntNickList		:SendIntClientList ()
		CASE $$MDCT_GetIntNickListFull	:SendFormatedClientListAll ()
		CASE $$MDCT_SetPassword			:SetPassword (msg1)
		CASE $$MDCT_GetPassword			:DispatchDCTMessage ($$MDCT_Password,GetPassword(),"")
		CASE $$MDCT_Unload				:UnLoadPlugin (XLONG(TRIM$(msg1)))
		CASE $$MDCT_IsUserConnected		:RETURN IsUserConnected (@msg1)
		CASE $$MDCT_IsUserAnOp			:RETURN IsUserAnOp (@msg1)
		CASE $$MDCT_GetOpList			:SendOpList(-1)
		CASE $$MDCT_UpdateNewPlugin		:UpdateNewPlugin (XLONG(msg1))
		CASE ELSE						:handled = $$FALSE
	END SELECT
	
	RETURN handled
END FUNCTION

FUNCTION MsgPlugin (hdcp, token, STRING msg1, STRING msg2)
	SHARED TDCPlugin dcp[]

	
	IF (hdcp < 0) OR (hdcp > GetPluginCount()) THEN RETURN $$MDCTH_UnhandledCont
	IFZ dcp[hdcp].hLibPlugin THEN RETURN $$MDCTH_UnhandledCont
	
	RETURN @dcp[hdcp].pDllFunc (token,@msg1,@msg2)
END FUNCTION

FUNCTION UpdateNewPlugin (TPlugin)
	SHARED STRING Server
	SHARED CONNECTED
	SHARED Port


	IF (CONNECTED == $$TRUE) && GetConSocket() THEN
	'	DispatchDCTMessage ($$MDCT_ConStatus,"Connected","")
		ListPlugins (TPlugin)
		MsgPlugin (TPlugin,$$MDCT_ClientConnected,STRING$(GetConSocket()),GetNick()+":"+Server+":"+STRING$(Port)+":")
		MsgPlugin (TPlugin,$$MDCT_Nick,GetNick(),GetAltNick())
		MsgPlugin (TPlugin,$$DCT_HubName,GetHubName(),"")
		MsgPlugin (TPlugin,$$MDCT_HubShareTotal,GetHubShare(),STRING$(GetTotalHubUsers()))
		'MsgPlugin (TPlugin,$$MDCT_ClientOpJoin,OpList,STRING$(OpTotal))
		'SendOpList(TPlugin)
		MsgPlugin (TPlugin,$$MDCT_NickList,GetFormatedClientList(5),STRING$(GetTotalHubUsers()))
		SendOpList(TPlugin)
	ELSE
		ListPlugins (TPlugin)
		MsgPlugin (TPlugin,$$MDCT_Nick,GetNick(),GetAltNick())
	'	MsgPlugin (TPlugin,$$MDCT_Disconnected,"","")
	'	MsgPlugin (TPlugin,$$MDCT_ConStatus,"Disconnected","")
	END IF

END FUNCTION

FUNCTION STRING GetHubName ()
	SHARED STRING HubName
	
	RETURN HubName
END FUNCTION

FUNCTION GetPluginCount ()
	SHARED TDCPlugin dcp[]
	
	RETURN UBOUND(dcp[])
END FUNCTION

FUNCTION SetHubName (STRING name)
	SHARED STRING HubName
	
	'name = TRIM$(name)
	IF name THEN
		HubName = name
		DispatchDCTMessage($$DCT_HubName,name,"")
		RETURN $$TRUE
	ELSE
		HubName = ""
		DispatchDCTMessage($$DCT_HubName,"","")
		RETURN $$FALSE
	END IF

END FUNCTION

FUNCTION SendConnStatus()
	SHARED CONNECTED
	SHARED STRING Nick,Server
	SHARED socket
	SHARED Port
	STRING info


	IF (CONNECTED == $$TRUE) && GetConSocket() THEN
	'	DispatchDCTMessage ($$MDCT_ConStatus,"Connected","")
	
		info = Nick+":"+Server+":"+STRING$(Port)+":"
		DispatchDCTMessage ($$MDCT_ClientConnected,STRING$(socket),@info)
	ELSE
		DispatchDCTMessage ($$MDCT_Disconnected,"","")
	'	DispatchDCTMessage ($$MDCT_ConStatus,"Disconnected","")
	END IF
	
END FUNCTION

FUNCTION SendPMTxt (STRING to, STRING text)
	

	to = TRIM$(to)
'	text = TRIM$(text)
	IFZ to THEN RETURN $$FALSE
	IFZ text THEN RETURN $$FALSE
	
	IFZ GetConSocket() THEN
		RemoveClients ()
		RETURN $$FALSE
	END IF

	IFT IsUserConnected (@to) THEN
		SendMsg (GetConSocket(),"$To: "+to+" From: "+GetNick()+" $"+GetHubNick()+" "+text)
		RETURN $$TRUE
	ELSE
		RETURN $$FALSE
	END IF

END FUNCTION

FUNCTION SetHubOperators (STRING text)
	SHARED TCLIENTS ClientList[]
	STRING OpList
	STRING op
	
	
	'OpList = replace (text,'$',32)
'	PRINT "-";text;"-"
	
	DO
		op = GetTokenEx2 (@text,'$')
	'	PRINT "-";op;"-"
		IF op THEN
			IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN EXIT IF 2
			FOR i = 0 TO UBOUND (ClientList[])
				IF (op == ClientList[i].name) THEN
					ClientList[i].op = 1
					EXIT FOR
				END IF
			NEXT i
			ReleaseSemaphore (#hSemCList,1,0)
		END IF
		GetTokenEx2 (@text,'$') ' remove extra $
	LOOP WHILE text

	RETURN $$TRUE
END FUNCTION

FUNCTION SendOpList (Plugin)
	SHARED TCLIENTS ClientList[]
	STRING OpList,op
	

	IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN RETURN 0

	OpList = ""
	OpTotal = 0
	
	FOR i = 0 TO UBOUND (ClientList[])
		IF ClientList[i].op THEN
			OpList = OpList +"  "+ ClientList[i].name
			INC OpTotal
		END IF
	NEXT i

	ReleaseSemaphore (#hSemCList,1,0)

	IF (Plugin == -1) THEN
		'DispatchDCTMessage ($$MDCT_ClientOpTotal,STRING$(OpTotal),"")
		DispatchDCTMessage ($$MDCT_ClientOpJoin,@OpList,STRING$(OpTotal))
	ELSE
		MsgPlugin (Plugin,$$MDCT_ClientOpJoin,@OpList,STRING$(OpTotal))
	END IF
	
	RETURN $$TRUE
END FUNCTION

FUNCTION IsUserAnOp	(STRING user)
	SHARED TCLIENTS ClientList[]
	
	
	IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN RETURN 0
	'user = TRIM$(user)
	FOR i = 0 TO UBOUND(ClientList[])
		IF (user == ClientList[i].name) THEN
			IF ClientList[i].op THEN
				ReleaseSemaphore (#hSemCList,1,0)
				RETURN $$TRUE
			ELSE
				EXIT FOR
			END IF
		END IF
	NEXT i
	
	ReleaseSemaphore (#hSemCList,1,0)
	RETURN $$FALSE
END FUNCTION

FUNCTION FileSearch (msg$)	' a client is searching for a file
	STRING flag

	who$ = GetTokenEx2 (@msg$,' ')
'	GetToken (@msg$,flag,'?')
'	GetToken (@msg$,flag,'?')
'	GetToken (@msg$,flag,'?')
'	GetToken (@msg$,flag,'?')
'	GetToken (@msg$,@file$,0)
'	file$ = replace (file$,'$',' ')

	DispatchDCTMessage ($$DCT_Search,@who$,@msg$)
	RETURN $$TRUE
END FUNCTION

FUNCTION SendSearchQuery (STRING flags, STRING file)

	IFZ TRIM$(flags) THEN flags = "F?F?0?1?"
	RETURN SendMsg (GetConSocket(),"$Search Hub:"+GetNick()+" "+flags+file)
END FUNCTION

FUNCTION STRING GetHubShare()

	RETURN CalcHubShare()
END FUNCTION

FUNCTION SendHubShare ()
	STATIC t0


'	IF (GetTickCount()-t0) > 10 THEN
'		t0 = GetTickCount()

		'DeleteTypeQueueMsgs (1,$$MDCT_HubShareTotal) ' enable this on busy hubs
		DispatchDCTMessage ($$MDCT_HubShareTotal,CalcHubShare(),STRING$(GetTotalHubUsers()))
		
		
	'	SetTimerCallbackSingle ($$SendHubShare,250)
		'hubShare = 0
		'XstStartTimer (@hubShare, 1, 250, &TimerShare())
		
		RETURN $$TRUE
'	ELSE
'		RETURN $$FALSE
'	END IF

END FUNCTION

FUNCTION TimerShare (id,count,msec,time)
	SHARED hubShare


'	SELECT CASE id
'		CASE hubShare		:
	'		WriteQueueMsg (1,$$MDCT_HubShareTotal,CalcHubShare(),STRING$(GetTotalHubUsers()))
	'		RETURN -1
'	END SELECT
	
	'ReleaseMutex (#hMuteTimerB)
END FUNCTION

FUNCTION SetMyShare (STRING share)
	SHARED STRING FShared

	share = TRIM$(share)
	IF share THEN
		FShared = share
		DispatchDCTMessage ($$MDCT_MyShareSize,FShared,"")
	END IF
	RETURN $$TRUE
END FUNCTION

FUNCTION STRING GetMyShare ()
	SHARED STRING FShared
	
	RETURN FShared
END FUNCTION

FUNCTION SetNick (STRING nick, STRING altnick)
	SHARED STRING Nick
	SHARED STRING AltNick
	

	nick = TRIM$(nick)
	altnick = TRIM$(altnick)
	IFZ nick THEN RETURN $$FALSE
	Nick = nick
	IFZ altnick THEN altnick = Nick+"-"
	AltNick = altnick
	
	DispatchDCTMessage ($$MDCT_Nick,Nick,AltNick)
	RETURN $$TRUE
END FUNCTION 

FUNCTION STRING GetHubNick ()

	RETURN "<"+GetNick()+">"
END FUNCTION 

FUNCTION STRING GetNick ()
	SHARED STRING Nick

	RETURN Nick
END FUNCTION

FUNCTION STRING GetAltNick ()
	SHARED STRING AltNick

	RETURN AltNick
END FUNCTION 

FUNCTION RemoveClient (STRING user)
	SHARED TCLIENTS ClientList[]
'	CRITICAL_SECTION cs


	IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN RETURN $$FALSE

	'user = TRIM$(user)
	FOR i = 0 TO UBOUND (ClientList[])
		IF (ClientList[i].name == user) THEN
			ClientList[i].name = ""
			ClientList[i].comment = ""
			ClientList[i].speed = ""
			ClientList[i].email = ""
			ClientList[i].share = "0"
			op = ClientList[i].op + 1
			ClientList[i].op = 0
			ReleaseSemaphore (#hSemCList,1,0)
			RETURN op
		END IF
	NEXT i
	
	ReleaseSemaphore (#hSemCList,1,0)
	RETURN 0
END FUNCTION

FUNCTION AddClient (msg$)
	SHARED TCLIENTS ClientList[]
'	CRITICAL_SECTION cs
	SHARED CONNECTED
	

	IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN RETURN $$FALSE

	GetTokenEx2 (@msg$,32)	' all 
	user$ = GetTokenEx2 (@msg$,32)
	comment$ = GetTokenEx2 (@msg$,'$')
	GetTokenEx (@msg$,'$',0)	' space
	speed$  = RTRIM$(GetTokenEx2 (@msg$,'$'))
	email$ = GetTokenEx2 (@msg$,'$')
	share$ = GetTokenEx2 (msg$,'$')

	userfound = $$FALSE
	'user$ = TRIM$(user$)
	freeslot = 0

	FOR i = 0 TO UBOUND(ClientList[])
		IF (ClientList[i].name == user$) THEN
			userfound = $$TRUE
			u = i
			EXIT FOR
		ELSE
			IFZ freeslot THEN
				IF (ClientList[i].name == "") THEN freeslot = i
			END IF
		END IF
	NEXT i
'	ReleaseSemaphore (#hSemCList,1,0)

	IFF userfound THEN
'		IF (WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0) THEN RETURN  $$FALSE
		IFZ freeslot THEN
			u = UBOUND(ClientList[])+1
			REDIM ClientList[u+250]
		ELSE
			u = freeslot
		END IF

		ClientList[u].name = user$
'		ReleaseSemaphore (#hSemCList,1,0)
		
		'info$ = comment$+"$"+speed$+"$"+email$+"$"+share$+"$"
		'DispatchDCTMessage ($$MDCT_ClientJoinAll,user$,@info$)
		'DispatchDCTMessage ($$MDCT_ClientJoin,user$,@info$)
	END IF
	
'	IF (WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0) THEN RETURN  $$FALSE
	ClientList[u].comment = comment$
	ClientList[u].speed = speed$
	ClientList[u].email = email$
	ClientList[u].share = share$
	ReleaseSemaphore (#hSemCList,1,0)

	info$ = comment$+"$"+speed$+"$"+email$+"$"+share$+"$"
	DispatchDCTMessage ($$MDCT_ClientJoinAll,@user$,@info$)

	'IFT userfound THEN
	'	info$ = comment$+"$"+speed$+"$"+email$+"$"+share$+"$"
	'	DispatchDCTMessage ($$MDCT_ClientJoinAll,user$,@info$)
	'END IF

	SendHubShare()
	RETURN $$TRUE
END FUNCTION

FUNCTION SendFormatedClientListAll ()
	SHARED TCLIENTS ClientList[]
	STRING cltotal
	
	
	IF WaitForSingleObject (#hSemCList,60000) == $$WAIT_TIMEOUT THEN RETURN 0
	
	cltotal = ""
	count = 0
	FOR c = 0 TO UBOUND (ClientList[])
		IF ClientList[c].name THEN
			cltotal = cltotal + ClientList[c].name + CHR$(5) + ClientList[c].comment+"$"+ClientList[c].speed+"$"+ClientList[c].email+"$"+ClientList[c].share+"$"+ CHR$(5)
			INC count
		END IF
	NEXT c
	ReleaseSemaphore (#hSemCList,1,0)
		
	'XstLog ("list:  "+cltotal,0,"t:\\sendlistall.log")
	'XstLog ("total: "+STRING$(count)+" size: "+STRING$(SIZE(cltotal)),0,"t:\\sendlistall.log")

	DispatchDCTMessage ($$MDCT_IntNickList,@cltotal,STRING$(count))
	'PRINT "send formatted clist()",count
	RETURN 1
END FUNCTION

FUNCTION STRING GetFormatedClientList (char)
	SHARED TCLIENTS ClientList[]
	STRING cltotal
	
	
	cltotal = ""
	IF WaitForSingleObject (#hSemCList,60000) == $$WAIT_TIMEOUT THEN RETURN ""
	FOR c = 0 TO UBOUND (ClientList[])
		IF ClientList[c].name THEN
			cltotal = cltotal+ClientList[c].name+CHR$(char)
		END IF
	NEXT c
	ReleaseSemaphore (#hSemCList,1,0)
	RETURN cltotal
END FUNCTION

FUNCTION GetTotalHubUsers ()
	SHARED TCLIENTS ClientList[]
	
	IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN RETURN 0
	FOR c = 0 TO UBOUND(ClientList[])
		IF ClientList[c].name THEN INC total
	NEXT c
	ReleaseSemaphore (#hSemCList,1,0)
	RETURN total
END FUNCTION

FUNCTION STRING CalcHubShare ()
	SHARED TCLIENTS ClientList[]
	DOUBLE fltshare
	STRING share,sb


	IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN RETURN "0"
	
	fltshare = 0.0	
	FOR s = 0 TO UBOUND(ClientList[])
		IF ClientList[s].name THEN
			sb = ClientList[s].share
			IF sb THEN fltshare = fltshare + DOUBLE(sb)
		END IF
	NEXT s

	IF fltshare THEN
		share = STRING$(fltshare / 1024.0 / 1024.0 / 1024.0 / 1024.0)
		IF share{0} = '.' THEN share = "0"+share
	ELSE
		share = "0"
	END IF
	ReleaseSemaphore (#hSemCList,1,0)
	RETURN share
END FUNCTION

FUNCTION SendIntClientList ()
	SHARED TCLIENTS ClientList[]
	STRING list

	
	DispatchDCTMessage ($$MDCT_NickList,GetFormatedClientList(5),STRING$(GetTotalHubUsers()))
	RETURN $$TRUE
	
'	FOR c = 0 TO UBOUND (ClientList[])
'		IF ClientList[c].name THEN
'			DispatchDCTMessage ($$MDCT_IntNickList,ClientList[c].name,STRING$(c))
'		END IF
'	NEXT c
'	
'	RETURN $$TRUE
END FUNCTION

FUNCTION AddClients (socket,STRING users)
	SHARED TCLIENTS ClientList[]
	STRING name,tmp
	STRING clients
'	CRITICAL_SECTION cs
	STRING ctotal,mynick
	SHARED CONNECTED
	STRING GETINFO1,GETINFO2

	
	GETINFO1 = "|$GetINFO "
	GETINFO2 = "$GetINFO "


'	IFZ TRIM$(users) THEN RETURN $$FALSE

	'RemoveClients (0)
	total = 0
	IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN RETURN $$FALSE
	DIM ClientList[500]

' /connect ms8.maximumspeed.org:411
'	users = TRIM$(users)
	mynick = GetNick()

	DO 
		name = GetTokenEx2 (@users,'$'): GetTokenEx (@users,'$',0)
		'name = TRIM$(name)

		IF name THEN
			IF total THEN
				clients = clients + GETINFO1 +name+" "+mynick
				'clients = clients + "|$GetInfo "+name+" "+mynick
			ELSE
				clients = clients + GETINFO2 +name+" "+mynick
				'clients = clients + "$GetInfo "+name+" "+mynick
			END IF
			
			ClientList[total].name = name
			ctotal = ctotal + name +"\5"
			INC total
			
			IF (total+1) > UBOUND(ClientList[]) THEN
				REDIM ClientList[total + 250]
			END IF
		END IF
	LOOP WHILE (LEN(users)>1) && (CONNECTED == $$TRUE)
	
	ReleaseSemaphore (#hSemCList,1,0)

	DispatchDCTMessage ($$MDCT_NickList,@ctotal,STRING$(total))
	SendMsg (socket,@clients)

	'ctotal = ""
	'clients = ""
	
	RETURN $$TRUE
END FUNCTION

FUNCTION RemoveClients ()
	SHARED TCLIENTS ClientList[]
'	CRITICAL_SECTION cs

	
	DispatchDCTMessage ($$MDCT_RemoveClients,"","")
	
	IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN RETURN $$FALSE
	DIM ClientList[0]
	ReleaseSemaphore (#hSemCList,1,0)
	
	RETURN $$TRUE
END FUNCTION


FUNCTION IsUserConnected (STRING nick)		' or isNickRegistered/InList()
	SHARED TCLIENTS ClientList[]


	IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN RETURN $$FALSE
	FOR i = 0 TO UBOUND (ClientList[])
		IF ClientList[i].name == nick THEN
			ReleaseSemaphore (#hSemCList,1,0)
			RETURN $$TRUE
		END IF
	NEXT i
	ReleaseSemaphore (#hSemCList,1,0)
	RETURN $$FALSE
END FUNCTION

FUNCTION STRING FindUser (STRING user)
	SHARED TCLIENTS ClientList[]

	
	len = LEN(user)
	user = LCASE$(user)
	
	IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN RETURN ""
	FOR i = 0 TO UBOUND (ClientList[])
		IF user == LEFT$(LCASE$(ClientList[i].name),len) THEN
			user = ClientList[i].name
			ReleaseSemaphore (#hSemCList,1,0)
			RETURN user
		END IF
	NEXT i
	ReleaseSemaphore (#hSemCList,1,0)
	
	RETURN ""
END FUNCTION

FUNCTION STRING GetUser (user)
	SHARED TCLIENTS ClientList[]
	
	
	IF WaitForSingleObject (#hSemCList,60000) != $$WAIT_OBJECT_0 THEN RETURN ""
	IF user > UBOUND (ClientList[]) THEN
		ReleaseSemaphore (#hSemCList,1,0)
		RETURN ""
	END IF
	user$ = ClientList[user].name
	ReleaseSemaphore (#hSemCList,1,0)
	RETURN user$
END FUNCTION

FUNCTION MessagePump (socket, STRING msg)		' each message terminates with ASCI |
	SHARED CONNECTED
	SHARED MPBRESET		'message pump buffer reset
	STATIC cmd$
	STATIC STRING message
	STRING token


	IFT MPBRESET THEN
		cmd$ = ""
		MPBRESET = $$FALSE
	END IF
	
	message = cmd$ + msg
	msglen = LEN(message)
	p = SIZE(cmd$)
	start = 1


'	DO
'		p = INCHR(message,"|",start)
'		IF p THEN
'			len = p-start
'			IF len > 0 THEN
'				cmd$ = MID$(message,start,len)
'				IF cmd$ THEN
'					token = GetTokenEx2(@cmd$,32)
'					OffLoadMsgForDispatch (socket,@token,@cmd$)
'				END IF
'			END IF
'
'			cmd$ = ""
'			start = p+1
'		ELSE
'			p = msglen
'			EXIT DO
'		END IF
'	LOOP WHILE ((p > 0) && (CONNECTED == $$TRUE))

	DO
		IF message{p} == '|' THEN
			len = p-start+1
			IF len > 0 THEN
				cmd$ = MID$(message,start,len)
				IF cmd$ THEN
					'token$ = TRIM$(GetTokenEx (@cmd$,32,0))
					token$ = GetTokenEx (@cmd$,32,0)
					IF token$ THEN
						OffLoadMsgForDispatch (socket,@token$,@cmd$)
					END IF
				END IF
			END IF

			cmd$ = ""
			start = p+2
		END IF
		
		INC p
	LOOP WHILE ((p < msglen) AND (CONNECTED == $$TRUE))
	
	cmd$ = MID$(message,start,p-start+1)
	message = ""
	RETURN 0
END FUNCTION

FUNCTION Shutdown ()
	SHARED wTimerRes
	SHARED CONNECTED
	STATIC once

	IF once THEN
		Sleep (15000)
		RETURN
	ELSE
		once = 1
	END IF
	
	timeEndPeriod(wTimerRes)
	DisconnectFromServer (GetConSocket())
	CleanUp ()
	CONNECTED = $$SHUTDOWN
	ReleaseSemaphore (#hSemConnect,1,0)
	QUIT (0)

END FUNCTION

FUNCTION DisconnectFromServer (null)
	SHARED hWsaEvent
	SHARED CONNECTED
	
	
	IF #tka THEN
		DestroyTimer (#tka)
		#tka = 0
	END IF
	
	DispatchDCTMessage ($$MDCT_InitiatingDisconn,"","")
	Sleep (50)
	CONNECTED = $$FALSE	
	SocketClose(GetConSocket()): SetConSocket(0)
'	RemoveClients ()

	IF hWsaEvent THEN
		_CloseEvent (hWsaEvent)
		hWsaEvent = 0
	END IF
		
	DispatchDCTMessage ($$MDCT_Disconnected,"","")
	
	RETURN $$TRUE
END FUNCTION

FUNCTION GetConSocket()
	SHARED socket

	RETURN socket
END FUNCTION

FUNCTION SetConSocket(sock)
	SHARED socket
	
	socket = sock
	RETURN $$TRUE
END FUNCTION

FUNCTION ConnectToServer (STRING server,port)
	SHARED LastSockSendT
	SHARED CONNECTED
	SHARED STRING Nick,Server
	SHARED Port
	SHARED MPBRESET


	IFT CONNECTED THEN
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_Connected,"")
		RETURN 0
	END IF

	IFZ port THEN port = $$Default_Port
	info$ = server+":"+STRING$(port)
	DispatchDCTMessage ($$MDCT_InitiatingConn,Nick,@info$)

	socket = SocketOpen ($$SOCK_TCP)		' create TCP socket
	IFZ socket THEN	RETURN 0

	'IFF SocketBind (socket, "",$$LOCALPORT) THEN

	IFT SocketConnect (socket,server,port) THEN
		RemoveClients ()
		LastSockSendT = GetTickCount()
		Server = server
		Port = port
		SetConSocket(socket)
		MPBRESET = $$TRUE
		CONNECTED = $$TRUE
		ReleaseSemaphore (#hSemConnect,1,0)
		SendConnStatus ()
		
		IFZ #tka THEN #tka = SetTimerCallback ($$TimerKeepAlive, $$KeepAliveTime)
					
		RETURN socket
	ELSE
		CONNECTED = $$FALSE
		SocketClose (socket)
		SetConSocket(0)
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_ConnectFailed,@info$)
		RETURN 0
	END IF
	
END FUNCTION

FUNCTION SocketListen (socket)

	IF listen(socket, 1) == $$SOCKET_ERROR THEN
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketListen,GetLastErrorStr())
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
	
	IF bind(socket, &udtSocket, length) == $$SOCKET_ERROR THEN
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketBind,GetLastErrorStr())
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF
	
END FUNCTION

FUNCTION SocketAccept (socket,STRING claddress,clport) ' returns client socket along with client address and port
	SOCKADDR_IN  sockaddrin
	
	
	size = SIZE(sockaddrin)
	clientsocket = accept (socket, &sockaddrin, &size)
	IF clientsocket == $$SOCKET_ERROR THEN
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketAccept,GetLastErrorStr())
		RETURN 0
	END IF
	claddress = CSTRING$(inet_ntoa (sockaddrin.sin_addr))
	clport = sockaddrin.sin_port

	RETURN clientsocket
END FUNCTION

FUNCTION SocketSend (socket,address,size)
	SHARED LastSockSendT,CONNECTED
	

	IF WaitForSingleObject (#hSemSnd,60000) != $$WAIT_OBJECT_0 THEN RETURN $$FALSE

	sent = 0
	LastSockSendT = GetTickCount()

	DO
		size = size - sent
		sent = send (socket, address+sent, size, 0)
		IF (sent == $$SOCKET_ERROR) THEN
		'	DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketSend,WSAErrorToName(WSAGetLastError()))
			ReleaseSemaphore (#hSemSnd,1,0)
			RETURN $$FALSE
		END IF
	LOOP WHILE (sent < size) AND (CONNECTED == $$TRUE)
	
	ReleaseSemaphore (#hSemSnd,1,0)
	RETURN $$TRUE
END FUNCTION

FUNCTION SocketRecv (socket,address,totalBytes)
	SHARED LastSockSendT
	

	IF WaitForSingleObject (#hSemRcvSnd,60000) != $$WAIT_OBJECT_0 THEN RETURN $$FALSE
	
	ret = recv (socket, address, totalBytes, 0)
	IF (ret == $$SOCKET_ERROR) THEN
		'DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketRecv,WSAErrorToName(WSAGetLastError()))
		ret = 0
	ELSE
		LastSockSendT = GetTickCount()	
	END IF

	ReleaseSemaphore (#hSemRcvSnd,1,0)
	RETURN ret
END FUNCTION

FUNCTION SocketClose (socket)
	
	IF closesocket (socket) == $$SOCKET_ERROR THEN
	'	DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketClose,WSAErrorToName(WSAGetLastError()))
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF
	
END FUNCTION

FUNCTION SocketOpen (sockettype)
	SHARED SockRcvBuffSize
	SHARED hWsaEvent

	
	IFZ sockettype THEN RETURN 0

	socket = _socket ($$AF_INET, sockettype, $$IPPROTO_TCP)
	IFZ socket THEN
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketOpen,GetLastErrorStr())
		RETURN 0
	END IF
	
	a = 0
	ret = ioctlsocket(socket, $$FIONBIO, &a)
	IF (ret == $$SOCKET_ERROR) THEN
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketOpen,GetLastErrorStr())
		RETURN 0
	END IF
	
'	optlen = 4
'	optval = $$LBUFFER_MAX
'	ret = setsockopt (socket, $$SOL_SOCKET, $$SO_RCVBUF, &optval, &optlen)
'	IF (ret == $$SOCKET_ERROR) THEN
'		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketOpen,WSAErrorToName(WSAGetLastError()))
'		RETURN 0
'	END IF

'	optlen = 4
'	optval = $$LBUFFER_MAX
'	ret = setsockopt (socket, $$SOL_SOCKET, $$SO_SNDBUF, &optval, &optlen)
'	IF (ret == $$SOCKET_ERROR) THEN
'		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketOpen,WSAErrorToName(WSAGetLastError()))
'		RETURN 0
'	END IF

'	optlen = 4
	SockRcvBuffSize = $$LBUFFER_MAX
'	ret = getsockopt (socket, $$SOL_SOCKET, $$SO_RCVBUF, &SockRcvBuffSize, &optlen)
'	IF (ret == $$SOCKET_ERROR) THEN
'		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketOpen,WSAErrorToName(WSAGetLastError()))
'		RETURN 0
'	END IF
	
	IF hWsaEvent THEN _CloseEvent (hWsaEvent)
	hWsaEvent = _CreateEvent ()
	IFZ hWsaEvent THEN
		closesocket (socket)
		RETURN 0
	END IF

'	IFF _EventSelect (socket, hWsaEvent, $$FD_CONNECT | $$FD_WRITE | $$FD_READ | $$FD_CLOSE) THEN
'		closesocket (socket)
'		_CloseEvent (hWsaEvent)
'		RETURN 0
'	END IF
	
	RETURN socket
END FUNCTION

FUNCTION _EventSelect (socket, hWsaEvent, lNetworkEvents)
	SHARED FUNCADDR EventSelect (XLONG, XLONG, XLONG)

	IF (@EventSelect (socket, hWsaEvent, lNetworkEvents) == $$SOCKET_ERROR) THEN
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SEventSelect,GetLastErrorStr())
		RETURN $$FALSE
	ELSE
		RETURN $$TRUE
	END IF

END FUNCTION

FUNCTION _CreateEvent ()
	SHARED FUNCADDR CreateEvent ()
	
	hWsaEvent = @CreateEvent ()
	IF (hWsaEvent == $$WSA_INVALID_EVENT) THEN
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SEventCreate,GetLastErrorStr())
		RETURN 0
	ELSE
		RETURN hWsaEvent
	END IF

END FUNCTION

FUNCTION _CloseEvent (hWsaEvent)
	SHARED FUNCADDR CloseEvent (XLONG)
	
	RETURN @CloseEvent (hWsaEvent)
END FUNCTION

FUNCTION _socket (af, s_type, protocol)
	SHARED FUNCADDR wsasocket (XLONG,XLONG,XLONG)
	
	RETURN @wsasocket (af, s_type, protocol)
END FUNCTION

FUNCTION _WSAConnect (s, sname, namelen, lpCallerData, lpCalleeData, lpSQOS, lpGQOS)
	SHARED FUNCADDR WSAConnect (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
	
	RETURN @WSAConnect (s, sname, namelen, lpCallerData, lpCalleeData, lpSQOS, lpGQOS)
END FUNCTION

FUNCTION _EnumNetworkEvents (socket, hWsaEvent, lpNetworkEvents)
	SHARED FUNCADDR EnumNetworkEvents (XLONG, XLONG, XLONG)

	IF (@EnumNetworkEvents (socket, hWsaEvent, lpNetworkEvents) == $$SOCKET_ERROR) THEN
		ret = WSAGetLastError()
		IF (ret != $$WSAENOTSOCK) THEN
			DispatchDCTMessage ($$MDCT_Error,$$MDCE_SEventEnumNetwork,GetLastErrorStr())
		END IF
		RETURN $$FALSE
	END IF
	
	RETURN $$TRUE
END FUNCTION

FUNCTION _WaitForMultipleEvents (cEvents, lphEvents, fWaitAll, dwTimeout, fAlertable)
	SHARED FUNCADDR WaitForMultipleEvents (XLONG, XLONG, XLONG, XLONG, XLONG)
	
	ret = @WaitForMultipleEvents (cEvents, lphEvents, fWaitAll, dwTimeout, fAlertable)
	IF (ret == $$WSA_WAIT_TIMEOUT) THEN
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SEventWaitForMul,GetLastErrorStr())
		RETURN $$FALSE
	END IF
	
	RETURN $$TRUE
END FUNCTION

FUNCTION SocketConnect (socket,STRING address,port)
	SOCKADDR_IN udtSocket

	
	udtSocket.sin_family = $$AF_INET
	udtSocket.sin_port = htons (port)
	udtSocket.sin_addr = inet_addr (&address)

	IF udtSocket.sin_addr = $$INADDR_NONE THEN
		NumIPAddr$ = GetNumIPAddr (address)
		udtSocket.sin_addr = inet_addr (&NumIPAddr$)
	END IF
	
	ret = connect (socket, &udtSocket, SIZE(udtSocket))
	'ret = _WSAConnect (socket, &udtSocket, SIZE(udtSocket), lpCallerData, lpCalleeData, lpSQOS, lpGQOS)
	'IF (ret == $$SOCKET_ERROR) THEN
	'	ret = WSAGetLastError ()
	'	IF (ret == $$WSAEWOULDBLOCK) THEN
	'		PRINT "block"
	'		EXIT IF 2
	'	END IF
	'	DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketConnect,WSAErrorToName(ret))
	'	RETURN $$FALSE
	'END IF
	
	setsockopt(socket,$$SOL_SOCKET,$$SO_KEEPALIVE,0,0)
	
	IFF WaitForConnect(socket) THEN RETURN $$FALSE
	
	'setsockopt(socket,$$SOL_SOCKET,$$SO_LINGER,0,0)
	'setsockopt(socket,$$SOL_SOCKET,$$SO_REUSEADDR,0,0)
	setsockopt(socket,$$SOL_SOCKET,$$SO_KEEPALIVE,0,0)
	
	RETURN $$TRUE

END FUNCTION

FUNCTION WaitForConnect (socket)
	STATIC WSANETWORKEVENTS events
	SHARED CONNECTED
	SHARED hWsaEvent


	timeout = 5000
	#FD_WRITE = $$FALSE
	#FD_CONNECT = $$FALSE
	
	_EventSelect (socket, hWsaEvent, $$FD_CONNECT | $$FD_WRITE | $$FD_CLOSE)
	t0 = GetTickCount ()
	DO
		IFF _WaitForMultipleEvents (1, &hWsaEvent, 0, timeout, 0) THEN RETURN $$FALSE
		IFF _EnumNetworkEvents (socket, hWsaEvent, &events) THEN RETURN $$FALSE

		SELECT CASE ALL TRUE
			CASE (events.lNetworkEvents & $$FD_CLOSE)	:CONNECTED = $$FALSE
														 #FD_CONNECT = $$FALSE
														 #FD_WRITE = $$FALSE
			CASE (events.lNetworkEvents & $$FD_WRITE)	:#FD_WRITE = $$TRUE
			CASE (events.lNetworkEvents & $$FD_CONNECT)	:#FD_CONNECT = $$TRUE
														 IFF #FD_WRITE THEN RETURN $$FALSE ELSE RETURN $$TRUE
		END SELECT
		Sleep (2)
	LOOP WHILE (#FD_CONNECT == $$FALSE) AND ((GetTickCount()-t0) < 5000)
	
	RETURN $$FALSE
END FUNCTION

FUNCTION STRING GetNumIPAddr (IPName$)
	WSADATA wsadata
	HOSTENT	host


	host = gethostbyname (&IPName$)

	IF host.h_addr_list <> 0 THEN
		addr = 0
		RtlMoveMemory (&addr, host.h_addr_list, 4)
		RtlMoveMemory (&addr, addr, 4)
		'addr2 = inet_ntoa (addr)
		RETURN CSTRING$ (inet_ntoa (addr))
	ELSE
		RETURN ""
	END IF
	
END FUNCTION

FUNCTION SocketInitWinSock()
	SHARED FUNCADDR CloseEvent (XLONG)
	SHARED FUNCADDR EnumNetworkEvents (XLONG, XLONG, XLONG)
	SHARED FUNCADDR WaitForMultipleEvents (XLONG, XLONG, XLONG, XLONG, XLONG)
	SHARED FUNCADDR WSAConnect (XLONG, XLONG, XLONG, XLONG, XLONG, XLONG, XLONG)
	SHARED FUNCADDR EventSelect (XLONG, XLONG, XLONG)
	SHARED FUNCADDR CreateEvent ()
	SHARED FUNCADDR wsasocket (XLONG,XLONG,XLONG)
	SHARED hWS2Lib
	WSADATA wsadata


	version = 2 OR (2 << 8)								' version winsock v2.2 (MAKEWORD (2,2))
	ret = WSAStartup (version, &wsadata)				' initialize winsock.dll
	IF ret THEN
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketInitWinSock,GetLastErrorStr())
		WSACleanup ()
		RETURN $$FALSE
	END IF

	IF wsadata.wVersion != version THEN
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketInitWinSock,GetLastErrorStr())
		WSACleanup ()
		RETURN $$FALSE
	END IF

	hWS2Lib = LoadLibraryA (&"ws2_32.dll")
	IFZ hWS2Lib THEN
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketInitWinSock,"LoadLibraryA() ws2_32.dll failed")
		RETURN $$FALSE
	END IF

	CloseEvent = GetProcAddress (hWS2Lib, &"WSACloseEvent")
	IFZ CloseEvent THEN RETURN $$FALSE

	EnumNetworkEvents = GetProcAddress (hWS2Lib, &"WSAEnumNetworkEvents")
	IFZ EnumNetworkEvents THEN RETURN $$FALSE

	WaitForMultipleEvents = GetProcAddress (hWS2Lib, &"WSAWaitForMultipleEvents")
	IFZ WaitForMultipleEvents THEN RETURN $$FALSE

	EventSelect = GetProcAddress (hWS2Lib, &"WSAEventSelect")
	IFZ EventSelect THEN RETURN $$FALSE

	WSAConnect = GetProcAddress (hWS2Lib, &"WSAConnect")
	IFZ WSAConnect THEN RETURN $$FALSE

	CreateEvent = GetProcAddress (hWS2Lib, &"WSACreateEvent")
	IFZ CreateEvent THEN RETURN $$FALSE

	wsasocket = GetProcAddress (hWS2Lib, &"socket")
	IFZ wsasocket THEN RETURN $$FALSE	
		
	IFZ #hSemRcvSnd THEN #hSemRcvSnd = CreateSemaphoreA (NULL,1,1,NULL) '&"hSemRcvSnd")
	IFZ #hSemSnd THEN #hSemSnd = CreateSemaphoreA (NULL,1,1,NULL) ' &"hSemSnd")
	
	RETURN $$TRUE
END FUNCTION

FUNCTION SendMsg (socket,STRING buffer)

	
	IFZ buffer THEN RETURN $$FALSE
	buffer = buffer + "|"
	'XstLog (buffer,0,"x:\\SendMsg.log")
	SendBin (GetConSocket(),&buffer,SIZE(buffer))
	RETURN $$TRUE
END FUNCTION

FUNCTION SendMsgB (socket,STRING buffer)
	STATIC STRING buffer2
	SHARED CONNECTED


	IFZ buffer THEN RETURN $$FALSE
	IFT CONNECTED THEN
		buffer2 = buffer + "|"
		RETURN SendBin (socket, &buffer2, SIZE(buffer2))
	ELSE
		RETURN $$FALSE
	END IF
	
END FUNCTION

FUNCTION SendBin (socket, pbuffer, tbytes)

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
				DispatchDCTMessage ($$MDCT_Error,$$MDCE_SocketListenBin,GetLastErrorStr())
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

FUNCTION ListenMsg (socket)
	STATIC WSANETWORKEVENTS events
	SHARED SockRcvBuffSize
	SHARED CONNECTED
	SHARED hWsaEvent
	SLONG  bytesrecv
	STRING buffer


	timeout = 1000 * 60 * 60 * 5
	
	IFF _EventSelect (socket, hWsaEvent, $$FD_READ | $$FD_CLOSE) THEN
		SocketClose (socket)
		_CloseEvent (hWsaEvent)
		RETURN $$FALSE
	END IF
	

	buffer = NULL$(SockRcvBuffSize)
	DO
		IFF _WaitForMultipleEvents (1, &hWsaEvent, 0, timeout, 0) THEN EXIT DO
		IFF _EnumNetworkEvents (socket, hWsaEvent, &events) THEN EXIT DO

		SELECT CASE ALL TRUE
			CASE (events.lNetworkEvents & $$FD_CLOSE)	:CONNECTED = $$FALSE
														 EXIT DO
			CASE (events.lNetworkEvents & $$FD_READ)	:
					bytesrecv = SocketRecv (socket, &buffer, SockRcvBuffSize)
					IF (bytesrecv == $$SOCKET_ERROR) THEN
						DispatchDCTMessageEx ($$MDCT_Error,$$MDCE_SocketListenMsg,GetLastErrorStr())
						EXIT SELECT
					ELSE
						IFZ bytesrecv THEN
							DispatchDCTMessageEx ($$MDCT_Disconnected,"","")
							EXIT SELECT
						END IF
					END IF
					 
					IF !((bytesrecv < 1) || (bytesrecv > SockRcvBuffSize)) THEN
					
						'XstLog ("in: "+LEFT$(buffer,bytesrecv),0,"r:\\msgpump.log")
						MessagePump (socket,LEFT$(buffer,bytesrecv))
					END IF
		END SELECT
	LOOP WHILE (CONNECTED == $$TRUE)

	IF GetConSocket () THEN DisconnectFromServer (GetConSocket ())
	CONNECTED = $$FALSE
	
	RETURN $$TRUE
END FUNCTION

FUNCTION STRING LockToKey (STRING lock)		' hub supplies a 'lock' string, reply with a decoded 'key'
	STRING key
	STRING out

	
	len = LEN(lock)
	key = NULL$(len)

	FOR i = 1 TO len-1
		key{i} = lock{i} XOR lock{i-1}
	NEXT i
	
	key{0} = lock{0} XOR lock{len-1} XOR lock{len-2} XOR 5

	FOR i = 0 TO len-1
		key{i} = ((key{i} << 4) & 240) | ((key{i} >> 4) & 15)
		SELECT CASE key{i}
			CASE 0		:out = out + "/%DCN000%/"
			CASE 5		:out = out + "/%DCN005%/"
			CASE 36		:out = out + "/%DCN036%/"
			CASE 96		:out = out + "/%DCN096%/"
			CASE 124	:out = out + "/%DCN124%/"
			CASE 126	:out = out + "/%DCN126%/"
			CASE ELSE	:out = out + CHR$(key{i})
		END SELECT
	NEXT i

	RETURN out
END FUNCTION

FUNCTION ShutdownPlugins ()
	SHARED TDCPlugin dcp[]

	
	FOR p = GetPluginCount() TO 0 STEP -1		' shutdown plug-ins in reverse order
		IF dcp[p].hLibPlugin THEN
			@dcp[p].pDllExit()
			Sleep (100)
			FreeLibrary (dcp[p].hLibPlugin)
			dcp[p].hLibPlugin = 0
		END IF
	NEXT p
	
	RETURN $$TRUE
END FUNCTION

FUNCTION StartupPlugins ()
	STRING pluginlist[]
	STRING text


	TPlugin = LoadUnixFile ($$FN_PluginList,@pluginlist[])
	IF (TPlugin == $$LUF_ERROR) THEN RETURN $$FALSE

	DIM dcp[TPlugin]
	
	FOR p = 0 TO TPlugin
		LoadPlugin (trim(pluginlist[p],0x0D),0,0)
	NEXT p
	
	RETURN $$TRUE
END FUNCTION

FUNCTION LoadPlugin (STRING filename, XLONG udata1, XLONG udata2)
	SHARED TDCPlugin dcp[]
	
	
	filename = TRIM$(filename)
	IFZ filename THEN RETURN $$FALSE
	
	TPlugin = GetPluginCount()
	INC TPlugin
	REDIM dcp[TPlugin]
	
	dcp[TPlugin] = InitPlugin (filename,TPlugin,udata1,udata2)
	IF dcp[TPlugin].lpPluginTitle THEN
		DispatchDCTMessage ($$MDCT_PluginLoaded,CSTRING$(dcp[TPlugin].lpPluginTitle),STRING$(TPlugin)+":"+filename)
		UpdateNewPlugin (TPlugin)
		RETURN $$TRUE
	ELSE
		IF dcp[TPlugin].hLibPlugin THEN
			FreeLibrary (dcp[TPlugin].hLibPlugin)
		END IF
		
		DEC TPlugin
		REDIM dcp[TPlugin]
		DispatchDCTMessage ($$MDCT_Error,$$MDCE_PluginLoadFailed,@filename)
		RETURN $$FALSE
	END IF

END FUNCTION

FUNCTION ListPlugins (dest)
	SHARED TDCPlugin dcp[]


	ptotal = GetPluginCount()
	FOR p = 0 TO ptotal
		IF dcp[p].lpPluginTitle THEN
			IF (dest == -1) THEN 
				DispatchDCTMessage ($$MDCT_Plugin,STRING$(ptotal),STRING$(p)+":"+CSTRING$(dcp[p].lpPluginTitle))
			ELSE
				MsgPlugin (dest,$$MDCT_Plugin,STRING$(ptotal),STRING$(p)+":"+CSTRING$(dcp[p].lpPluginTitle))
			END IF
		END IF
	NEXT p
	
END  FUNCTION 

FUNCTION UnLoadPlugin (index)	' a plugin should not shut itself down
	SHARED TDCPlugin dcp[]

'	Sleep (3000)

	IF (index <= UBOUND (dcp[])) && (index >= 0) THEN
		IF dcp[index].hLibPlugin THEN
			pltitle$ = CSTRING$(dcp[index].lpPluginTitle)
			hlibp = dcp[index].hLibPlugin
			
			dcp[index].hLibPlugin = 0
			dcp[index].lpPluginTitle = 0
			@dcp[index].pDllExit()

'			IF hlibp THEN FreeLibrary (hlibp)
			DispatchDCTMessage ($$MDCT_PluginUnloaded,@pltitle$,STRING$(index))
			FreeLibraryAndExitThread (hlibp,1)
			'ExitThread (1)

		END IF
	END IF
	
	#hplunThrd = 0
END FUNCTION

FUNCTION TDCPlugin InitPlugin (STRING dcpname, XLONG TPlugin, XLONG udata1, XLONG udata2)
	FUNCADDR DllStartup (TDCPlugin)
	SHARED STRING Server
	SHARED STRING Nick
	TDCPlugin dcp
	SHARED Port


	hPlugin = LoadLibraryA (&dcpname)
	'tmp$ = NULL$(0)
	'hPlugin = LoadLibraryExA (&dcpname,&tmp$,$$DONT_RESOLVE_DLL_REFERENCES)
	IF hPlugin THEN
		DisableThreadLibraryCalls (hPlugin)
		DllStartup = GetProcAddress (hPlugin, &"DllStartup")
		IF DllStartup THEN
		
			dcp.hLibPlugin = hPlugin
			dcp.hInst = TPlugin
			
			dcp.udata1 = udata1
			dcp.udata2 = udata2

			dcp.lpnick = &Nick
			dcp.lpserver = &Server
			dcp.port = Port
			
			' to allow other plug-ins to receive other plug-in messages use this callback function
			dcp.lpDDCTM = &DispatchDCTMessageEx()
			
			' to prevent other plug-ins from receiving other plug-in messages (including own) use this callback
			'dcp.lpDDCTM = &ProcessPluginMessage()
			
			@DllStartup (@dcp)
			
			IF (dcp.pDllExit) THEN 
				IF (dcp.pDllFunc) THEN RETURN dcp
			END IF
		END IF
	END IF
	
	IF hPlugin THEN FreeLibrary (hPlugin)
	RETURN 0
END FUNCTION
 
FUNCTION CleanUp ()
	SHARED hWS2Lib
	SHARED hWsaEvent


	ShutdownPlugins ()

	IF hWsaEvent THEN _CloseEvent (hWsaEvent): hWsaEvent = 0
	IF #MSGThread THEN CloseHandle (#MSGThread): #MSGThread = 0
	IF #hThread THEN CloseHandle (#hThread): #hThread = 0
	IF hWS2Lib THEN FreeLibrary (hWS2Lib): hWS2Lib = 0
	
	WSACleanup ()
	
END FUNCTION


FUNCTION InitConsoleTimer ()
 	SHARED wTimerRes
	TIMECAPS tc
	
	 
	IF (timeGetDevCaps(&tc, SIZE(TIMECAPS)) != $$TIMERR_NOERROR) THEN
       	RETURN RETURN $$FALSE
    END IF
    
	wTimerRes = MIN(MAX(tc.wPeriodMin, XLONG($$TARGET_RESOLUTION)), tc.wPeriodMax)  
	timeBeginPeriod(wTimerRes)
	'SetTimerCallback($$TimerKeepAlive,$$KeepAliveTime) 
	
	RETURN $$TRUE
END FUNCTION 

FUNCTION SetTimerCallback (udata, msInterval)          ' Sequencer data         ' Event interval  
	SHARED wTimerRes
 
	RETURN timeSetEvent (msInterval, wTimerRes, &TimerCallback(), udata, $$TIME_PERIODIC)	' or use $$TIME_ONESHOT
END FUNCTION

FUNCTION SetTimerCallbackSingle (udata, msInterval)          ' Sequencer data         ' Event interval  
	SHARED wTimerRes
 
	RETURN timeSetEvent (msInterval, wTimerRes, &TimerCallback(), udata, $$TIME_ONESHOT)
END FUNCTION

FUNCTION TimerCallback (wtimerid, msg, dwUser, dw1, dw2) 
	SHARED LastSockSendT
	SHARED CONNECTED
	SHARED tplugin
	

	'PRINT wtimerid, msg, dwUser, dw1, dw2
	
	IF WaitForSingleObject (#hMuteTimerB,$$INFINITE) != $$WAIT_OBJECT_0 THEN
		RETURN 0
	END IF
	
	SELECT CASE dwUser
		CASE $$TimerKeepAlive	:
			IF ((GetTickCount()-LastSockSendT) > $$KeepAliveTime) THEN
				IF ((CONNECTED == $$TRUE) && GetConSocket()) THEN
					'SendBin (GetConSocket(),&$$KeepAliveString,1)
					SendMsg (socket,"$Version 1,0091")
					DispatchDCTMessage ($$MDCT_Error,GetTime(),@"keep alive")
				END IF
			END IF

		CASE $$TimerUnload			:
			UnLoadPlugin (tplugin)
			IF #timerplugin THEN
				DestroyTimer (#timerplugin)
				#timerplugin = 0
			END IF
			
		CASE $$SendHubShare	:
			'WriteQueueMsg (1,$$MDCT_HubShareTotal,CalcHubShare(),STRING$(GetTotalHubUsers()))
	END SELECT

	ReleaseMutex (#hMuteTimerB)
	RETURN 1
END FUNCTION

FUNCTION DestroyTimer (wTimerID)
	
	
	'timeEndPeriod(wTimerRes)
    IF (wTimerID) THEN
    	timeKillEvent(wTimerID)   ' Cancel the event  
        wTimerID = 0  
        RETURN $$TRUE
	ELSE
		RETURN $$FALSE
    END IF
    
END FUNCTION

END PROGRAM
