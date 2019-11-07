'
'	a proxy server for MyDC
'	this allows one to connect to a Direct Connect hub from behind a firewall aslong as an open port exists
'	multiple proxy's can be loaded in to the daemon to allow multiple GUI's to connect via a different port
'	default port is 401, if this is taken the proxy will then try to bind 402 and then 403 if 402 is taken, etc..
'	load the proxy by either (or both) by adding its path to the pluginlist file or typing
'	"/load pathtodll.dll port" port = desired tcp listening port (default is 401)
'
'	i recommend using this proxy by default, use proxygui to connect to this proxy then connect to your desired hub
'	if the mydc daemon should ever crash it will not affect the proxy client.
'
'	note: if you're unsure which port was bound type "netstat -a -n" in an msdos console and look for tcp ports around 401
'
PROGRAM	"mydcproxy"
VERSION	"0.45"
MAKEFILE "xdll.xxx"
'CONSOLE


	IMPORT "gdi32"
	IMPORT "user32"
	IMPORT "wsock32"
	IMPORT "kernel32"
	IMPORT "msvcrt"
'	IMPORT "zlib"
	IMPORT "MyDC.dec"
	IMPORT "dcutils"
'	IMPORT "xio"

'	IMPORT "kernel32"
'	IMPORT "shell32"
'	IMPORT "msvcrt"


'DECLARE FUNCTION DllMain (a,b,c)
DECLARE FUNCTION DllEntry ()

EXPORT
DECLARE FUNCTION DllExit ()
DECLARE FUNCTION DllStartup (TDCPlugin dcp)
DECLARE FUNCTION SendDCTMsg (token, STRING msg1, STRING msg2)
DECLARE FUNCTION DllProc (token, STRING msg1, STRING msg2)
END EXPORT

DECLARE FUNCTION SendMsgToHub (STRING msg)
DECLARE FUNCTION DispatchDCTMsg (token, STRING msg1, STRING msg2)
DECLARE FUNCTION CPrint (edit,STRING msg)
DECLARE FUNCTION STRING GetHubNick ()
DECLARE FUNCTION STRING GetNick ()
DECLARE FUNCTION STRING GetNumIPAddr (IPName$)

DECLARE FUNCTION MessagePump (socket, STRING message)		' each message ends with |
DECLARE FUNCTION MessagePumpB (socket, STRING message)		' each message ends with 0x0D 0x0A (\r\n)
DECLARE FUNCTION ProcessToken (socket, STRING message)

DECLARE FUNCTION ListenBin (socket,ANY,tbytes)
DECLARE FUNCTION ListenMsg (socket)
DECLARE FUNCTION SendBin (socket,bufferaddr,tbytes)
DECLARE FUNCTION SendMsg (socket,STRING buffer)

DECLARE FUNCTION SocketInitWinSock()
DECLARE FUNCTION SocketOpen (sockettype)
DECLARE FUNCTION SocketConnect (socket,STRING address,port)
DECLARE FUNCTION SocketRecv (socket,address,totalbytes)
DECLARE FUNCTION SocketSend (socket,address,totalbytes)
DECLARE FUNCTION SocketClose (socket)
DECLARE FUNCTION SocketBind (socket,STRING address,port)
DECLARE FUNCTION SocketListen (socket)
DECLARE FUNCTION SocketAccept (socket,STRING claddress,clport)

DECLARE FUNCTION Main (arg)
DECLARE FUNCTION InitPortBind (port)
DECLARE FUNCTION Shutdown ()
DECLARE FUNCTION SendShutdownMsg ()

DECLARE FUNCTION zsend (socket,address,totalBytes)

$$defaultport = 401

$$LBUFFER_MAX = 131000		' listening buffer size.
							' size of buffer really depends on data expected from host.
							' eg, IRC protocol states buffersize of 512 bytes

$$SOCK_TCP = $$SOCK_STREAM
$$SOCK_UDP = $$SOCK_DGRAM


'FUNCTION DllMain (a,reason,c)
FUNCTION DllEntry ()

	RETURN 1	
END FUNCTION

FUNCTION DllExit ()
	SHARED STRING PluginTitle
	SHARED socket,client
	SHARED CONNECTED
	
'	WSACleanup ()

	IF client THEN
		SendShutdownMsg ()
		SendDCTMsg ($$MDCT_RequestShutDown,"MyDC Shutting down","")
	ELSE
		DispatchDCTMsg ($$MDCT_PrvTxtMsg,STRING$($$Hub),":: "+PluginTitle+": Shutting down")
	END IF
	
	Sleep (50)
	IFF #SHUTDOWN THEN Shutdown ()
END FUNCTION

FUNCTION SendShutdownMsg ()
	SHARED STRING PluginTitle
	STATIC once


	IFZ once THEN
		once = 1
		SendDCTMsg ($$MDCT_PrvTxtMsg,STRING$($$Hub),":: "+PluginTitle+": Shutting down")
	END IF

END FUNCTION

FUNCTION Shutdown ()
	SHARED socket,client
	SHARED CONNECTED
	

	#SHUTDOWN = $$TRUE
	CONNECTED = $$FALSE

	IF client THEN SocketClose (client): client = 0
	IF socket THEN SocketClose (socket): socket = 0
	IF #htdListen THEN CloseHandle (#htdListen): #htdListen = 0
	IF #hThread THEN CloseHandle (#hThread ): #hThread = 0

	Sleep(50)

END FUNCTION

FUNCTION DllStartup (TDCPlugin dcp)
	SHARED FUNCADDR DDCTM (XLONG,STRING,STRING)
	SHARED STRING Server,Nick
	SHARED STRING PluginTitle
	SHARED Port,socket


	#SHUTDOWN = $$FALSE
	'#winMain = dcp.hWinMain
	'#winproc = dcp.lpWinProc
	
	Server = CSTRING$(dcp.lpserver)
	Port = dcp.port
	Nick = CSTRING$(dcp.lpnick)
	#hplugin = dcp.hInst
	
	dcp.pDllExit = &DllExit()
	dcp.pDllFunc = &DllProc()
	DDCTM = dcp.lpDDCTM

	IF (dcp.udata1 > 0) && (dcp.udata1 < 0xFFFF) THEN
		Listen_Port = dcp.udata1
	ELSE
		Listen_Port = $$defaultport
	END IF

	socket = InitPortBind (@Listen_Port)
	PluginTitle = "MyDC HTTP Proxy Server (port "+STRING$(Listen_Port)+")"
	dcp.lpPluginTitle = &PluginTitle
	#hThread = _beginthreadex (0, 0, &Main(),Listen_Port, 0, &tid)
	
END FUNCTION

FUNCTION Main (Listen_Port)
	SHARED CONNECTED
	SHARED socket
	SHARED client


	' initiate the wsock32 library before doing anything
	'IFF SocketInitWinSock() THEN RETURN 0
	
	Sleep (10)
	#hSemListen = CreateSemaphoreA (0,0,1,0)
	'WaitForSingleObject (#hSemListen,$$INFINITE)
	'ReleaseSemaphore (#hSemListen,1,NULL)
	
	CPrint ($$Hub,":: Proxy listening on port "+STRING$(Listen_Port))

	IFF SocketListen (socket) THEN RETURN 0

	DO UNTIL (#SHUTDOWN  == $$TRUE)
		client = SocketAccept (socket,@caddress$,@cport)
		IF (#SHUTDOWN  == $$TRUE) THEN RETURN 0

		IF client THEN
			CONNECTED = $$TRUE
			
			#htdListen = _beginthreadex (0, 0, &ListenMsg(), client, 0, &tid)
			
			SendMsg (client,"HTTP/1.0 200 OK\n\n<html>")
			SendMsg (client,"<BODY bgcolor=\"#AAAAAA\"")
			'SendMsg (client,"<form target=\"somethingtopickitup\"><input type=\"text\" name=\"mytext\" value=\"currentval\"><input type=\"submit\"></form>")
			
			CPrint ($$Hub,":: Welcome "+caddress$+":"+STRING$(cport))
			DispatchDCTMsg ($$MDCT_UpdateNewPlugin,STRING$(#hplugin),"")

			WaitForSingleObject (#hSemListen,$$INFINITE)
			Sleep (1)
			IF #htdListen THEN CloseHandle (#htdListen): #htdListen = 0
			CONNECTED = $$FALSE
			IF (#SHUTDOWN == $$TRUE) THEN EXIT DO
		
			CPrint ($$Hub,":: "+caddress$+":"+STRING$(cport)+" disconnected")
		END IF 
	LOOP WHILE (#SHUTDOWN == $$FALSE)

	DllExit ()
END FUNCTION

FUNCTION DllProc (token, STRING msg1, STRING msg2)
	SHARED STRING PluginTitle
	STRING text,list,buffer

	
	SELECT CASE token
	'	CASE $$MDCT_ClientJoinAll	:SendDCTMsg (token, "Join: "+msg1,"")
		'CASE $$DCT_Search			:SendDCTMsg (token, @msg1, @msg2)
	'	CASE $$DCT_Quit				:SendDCTMsg (token, "Quit: "+msg1,"")
		CASE $$DCT_SR				:SendDCTMsg (token, @msg1, @msg2)
		CASE $$MDCT_RequestShutDown	:SendShutdownMsg ()
									'SendDCTMsg ($$MDCT_PrvTxtMsg,"MyDC Shutting down","")
									'SendDCTMsg ($$MDCT_PrvTxtMsg,STRING$($$Hub),":: "+PluginTitle+": Shutting down")
									'SendDCTMsg (token,"MyDC Shutting down",""): Sleep (10)
									' DllExit ()
									 'Shutdown ()
		CASE $$MDCT_InitiatingConn	:SendDCTMsg (token, msg1, msg2)
		CASE $$MDCT_InitiatingDisconn :SendDCTMsg (token, msg1, msg2)
		CASE $$MDCT_Disconnected	:SendDCTMsg (token, msg1, msg2)
		CASE $$MDCT_ClientConnected	:SendDCTMsg (token, "User "+GetTokenEx2(@msg2,':')+" connected to",@msg2)
		CASE $$MDCT_PubCmdMsg		:SendDCTMsg (token, "("+msg1+")", @msg2)
		CASE $$MDCT_PrvTxtMsg		:SendDCTMsg (token,"->"+msg2,"")
		CASE $$MDCT_PubTxtMsg		:SendDCTMsg (token, "("+msg1+")", @msg2)
		CASE $$MDCT_PMTxtMsg		:SendDCTMsg (token, @msg1, @msg2)
		CASE $$MDCT_SendPMsg		:SendDCTMsg (token, @msg1, @msg2)
		CASE $$MDCT_PMCmdMsg		:SendDCTMsg (token, @msg1, @msg2)
		CASE $$MDCT_NickList		:
			i = 0
			list = "Users: <SELECT>"
			list = list + "<OPTION SELECTED=\"selected\" VALUE=\""+STRING$(i)+"\">"+GetTokenEx2(@msg1,5)
			DO
				list = list + "<OPTION VALUE=\""+STRING$(i)+"\">"+GetTokenEx2(@msg1,5)
				INC i
				IF LEN(msg1) < 2 EXIT DO
			LOOP
			SendDCTMsg (token,@list,"</SELECT><BR/>")
		CASE $$MDCT_NickListTotal	:SendDCTMsg (token, msg1, msg2)
	'	CASE $$MDCT_HubShareTotal	:SendDCTMsg (token, "Hub share: "+msg1, "Users:"+msg2)
		CASE $$MDCT_HubUsers		:SendDCTMsg (token, msg1, msg2)
		CASE $$DCT_HubINFO			:SendDCTMsg (token, @msg1, @msg2)
		CASE $$DCT_HubName			:SendDCTMsg (token, "Hub name: "+msg1, @msg2)
									 SendDCTMsg (token, "<HEAD><TITLE>"+msg1+"</TITLE></HEAD>","")
		CASE $$MDCT_MyShareSize		:SendDCTMsg (token, msg1, msg2)
		CASE $$MDCT_ClientOpJoin	:SendDCTMsg (token, "Operators:"+msg1,"<BR />")
		CASE $$MDCT_IntNickList		:
			replace(@msg1,'$',32)
			i = 0
			list = "Users: <SELECT>"
			list = list + "<OPTION SELECTED=\"selected\" VALUE=\""+STRING$(i)+"\">"+GetTokenEx2(@msg1,254)+" "+GetTokenEx2(@msg1,254)
			DO
				list = list + "<OPTION VALUE=\""+STRING$(i)+"\">"+GetTokenEx2(@msg1,254)+" "+GetTokenEx2(@msg1,254)
				INC i
				IF LEN(msg1) < 2 EXIT DO
			LOOP
			SendDCTMsg (token,@list,"</SELECT><BR />")
		CASE $$MDCT_UnknownCmd		:SendDCTMsg (token, msg1, msg2)
		CASE $$MDCT_PluginLoaded	:SendDCTMsg (token, msg1, msg2)
		CASE $$MDCT_PluginUnloaded	:SendDCTMsg (token, msg1, msg2)
		CASE $$MDCT_Error			:SendDCTMsg (token, msg1, msg2)
		CASE $$MDCT_Plugin			:SendDCTMsg (token, "Plugin ","#"+msg2)
		CASE $$MDCT_Debug			:SendDCTMsg (token, msg1, msg2)
		CASE $$DCT_Unknown			:SendDCTMsg (token, msg1, msg2)
		'CASE $$DCT_UserCommand		:SendDCTMsg (token, msg1, msg2)
	END SELECT

	RETURN $$MDCTH_UnhandledCont
END FUNCTION

FUNCTION SendDCTMsg (token, STRING msg1, STRING msg2)
	SHARED CONNECTED
	SHARED client
	STATIC STRING buffer


	IFF CONNECTED THEN RETURN $$MDCTH_UnhandledCont
	IFZ client THEN RETURN $$MDCTH_UnhandledCont
	
'	IFZ msg1 THEN msg1 = " "
'	IFZ msg2 THEN msg2 = " "
'	buffer = CHR$($$PCCA) + STRING$(token)+ CHR$($$PCCB)+msg1+ CHR$($$PCCC)+msg2+ CHR$($$PCCD)
	'buffer = msg1+"  "+msg2+"\r\n"
	SendMsg (client,Replace(msg1+"  "+msg2,"\r\n","<BR />"))
	'SendBin (client,&buffer,SIZE(buffer))

	RETURN $$MDCTH_UnhandledCont
END FUNCTION

FUNCTION CPrint (edit,STRING msg)

	IFZ msg THEN RETURN $$FALSE
	DispatchDCTMsg ($$MDCT_PrvTxtMsg,STRING$(edit),@msg) 
END FUNCTION

FUNCTION SendMsgToHub (STRING msg)

	DispatchDCTMsg ($$MDCT_SendPubTxt,@msg,"")
END FUNCTION

FUNCTION DispatchDCTMsg (token, STRING msg1, STRING msg2)
	SHARED FUNCADDR DDCTM (XLONG,STRING,STRING)

	
	IFZ token THEN RETURN $$MDCTH_UnhandledCont
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


FUNCTION SocketListen (socket)

	IF (listen (socket, 1) == $$SOCKET_ERROR) THEN
		'CPrint (0,"* SocketListen:listen error: "+WSAErrorToName(WSAGetLastError()))
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
		'CPrint (0,"* SocketBind:bind error: "+WSAErrorToName(WSAGetLastError()))
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
'	
'	DO UNTIL (CONNECTED == $$FALSE)
'		tbytes = tbytes - bytessent
		bytessent = send (socket,pbuffer + bytessent,tbytes,0)
		
'		IF (bytessent == $$SOCKET_ERROR) THEN
'			'CPrint ($$Hub,"* SendBin:send error: "+WSAErrorToName(WSAGetLastError()))
'			RETURN $$FALSE
'		END IF
'	LOOP WHILE (bytessent < tbytes) AND (CONNECTED == $$TRUE)
	
	RETURN $$TRUE
END FUNCTION

FUNCTION zsend (socket,address,totalBytes)
	TZPASS zpass
	STRING dbuffer


	dbufferlen = totalBytes+32
	dbuffer = NULL$(dbufferlen)
	
'	compress2 (&dbuffer,&dbufferlen,address,totalBytes,$$Z_BEST_COMPRESSION)
	zpass.uncompsize = totalBytes
	zpass.compsize = dbufferlen
	send (socket,&zpass,SIZE(zpass),0)
	send (socket,&dbuffer,dbufferlen,0)
	
	PRINT zpass.uncompsize,zpass.compsize
	
	RETURN totalBytes
END FUNCTION


FUNCTION SocketRecv (socket,address,totalBytes)

	RETURN recv (socket, address, totalBytes, 0)
END FUNCTION

FUNCTION SocketClose (socket)
	
	RETURN closesocket (socket)
END FUNCTION

FUNCTION SocketOpen (sockettype)


	IFZ sockettype THEN RETURN 0
	
	socket = socket ($$AF_INET, sockettype, 0)
	IFZ socket THEN
		'CPrint (0,"* SocketOpen:socket error: "+WSAErrorToName(WSAGetLastError()))
		RETURN 0
	END IF
	
	RETURN socket
	
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
	
	IF (connect (socket, &udtSocket, SIZE(udtSocket)) == $$SOCKET_ERROR) THEN
		'CPrint (0,"* SocketConnect:connect error: "+WSAErrorToName(WSAGetLastError()))
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
		'CPrint (0,"* SocketInitWinSock:wsa error: "+WSAErrorToName(WSAGetLastError()))
		WSACleanup ()
		RETURN $$FALSE
	END IF

	IF wsadata.wVersion != version THEN
		'CPrint (0,"* SocketInitWinSock:wsa error: "+WSAErrorToName(WSAGetLastError()))
		WSACleanup ()
		RETURN $$FALSE
	END IF
	
	RETURN $$TRUE
	
END FUNCTION

FUNCTION SendMsg (socket,STRING buffer)
	SHARED CONNECTED
	
	
	IFT CONNECTED THEN
		buffer = buffer + "<BR/>\r\n"
		'buffer = buffer + "\r\n"
		'buffer = buffer + "<P>"
		'buffer = buffer + "|"
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
			EXIT DO
		ELSE		
			read = read + thisRead
			rover = rover + thisRead
		END IF
	LOOP WHILE (CONNECTED == $$TRUE)
	
	tbytes = read
	RETURN $$TRUE

END FUNCTION

FUNCTION ListenMsg (socket)
	SHARED CONNECTED
	STRING buffer
	SHARED client
	
	
	buffer = NULL$ ($$LBUFFER_MAX)
	
	DO WHILE socket
		bytesRead = SocketRecv (socket,&buffer, $$LBUFFER_MAX)
		IF (bytesRead == $$SOCKET_ERROR) || (bytesRead == 0) THEN
			EXIT DO
		END IF

		'MessagePump (socket,LEFT$(buffer,bytesRead)) 	' send message to queue
		'DispatchDCTMsg ($$MDCT_SendPubTxt,LEFT$(buffer,bytesRead),"")
	LOOP WHILE (CONNECTED == $$TRUE) && (#SHUTDOWN == $$FALSE)

	SocketClose (client)
	client = 0
	CONNECTED = $$FALSE
	
	ReleaseSemaphore (#hSemListen,1,NULL)
	RETURN $$TRUE
END FUNCTION

FUNCTION MessagePumpB (socket, STRING message)		' each message terminates with ASCI |
	SHARED CONNECTED
	STATIC cmd$
	

	message = cmd$ + message
	msglen = LEN(message)
	p = LEN (cmd$)
	start = 1
	flag = $$FALSE

	DO
		IF message{p} == '|' THEN
			cmd$ = MID$(message,start,p-start+1)
			IF cmd$ THEN ProcessToken (socket,@cmd$)
			cmd$ = ""
			start = p+2
		END IF

		INC p
	LOOP WHILE ((p < msglen) AND (CONNECTED == $$TRUE))
	
	cmd$ = MID$(message,start,p-start+1)
	message = ""
	
	RETURN 0
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
							 	IF token THEN DispatchDCTMsg (token, @msg1,@msg2)
							 	msg1 = ""
							 	msg2 = ""
							 	flag = 0x00
							 	start = p+2
							 END IF
		END SELECT

		INC p	
	LOOP WHILE ((p < msglen) AND (CONNECTED == $$TRUE))
	
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
	DispatchDCTMsg (token, @msg1,@msg2)
	
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

FUNCTION InitPortBind (port)

	socket = SocketOpen ($$SOCK_TCP)		' create a TCP socket
	IFZ socket THEN	RETURN 0
	
	DO
		IFT SocketBind (socket, "",port) THEN
			EXIT DO
		ELSE
			INC port
			Sleep (2)
		END IF
	LOOP WHILE (#SHUTDOWN == $$FALSE)
	
	RETURN socket
END FUNCTION

END PROGRAM

