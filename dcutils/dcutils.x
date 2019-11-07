

PROGRAM "dcutils"
VERSION "001"
MAKEFILE "xdll.xxx"


	IMPORT "gdi32"
	IMPORT "kernel32"
	IMPORT "shell32"
	IMPORT "msvcrt"
	IMPORT "xst"
	IMPORT "wsock32.dec"


DECLARE FUNCTION DllEntry ()

EXPORT

$$LUF_ERROR				= -1		' fine not found
$$SUF_ERROR				= -1		' unable to save file


'$$RD                  = 0x0000
'$$WR                  = 0x0001
'$$RW                  = 0x0002
'$$WRNEW               = 0x0003
'$$RWNEW               = 0x0004
'$$NOSHARE             = 0x0000
'$$RDSHARE             = 0x0010
'$$WRSHARE             = 0x0020
'$$RWSHARE             = 0x0030

DECLARE FUNCTION LoadUnixFile (STRING filepath,STRING text[])	' load text file in to string array
DECLARE FUNCTION SaveUnixFile (STRING filepath,STRING text[])	' save string array to file

DECLARE FUNCTION STRING WSAErrorToName (errorcode)				' convert WSA error code to string name
DECLARE FUNCTION STRING trim (STRING str,char)					' trim char from string
DECLARE FUNCTION STRING replace (STRING str,oldc,newc)			' replace oldchar with newchar
DECLARE FUNCTION STRING GetTokenEx (STRING text,term,offset)	' return and subtract left most word from string beginning at offset
DECLARE FUNCTION STRING GetTokenExB (STRING text,term,offset)	' use for token extraction.
DECLARE FUNCTION STRING GetTokenEx2 (STRING text,term)
DECLARE FUNCTION STRING GetTime ()								' return system time - mm:hh:ss GMT
DECLARE FUNCTION STRING GetDate ()								' return date - dd/mm/yyyy
DECLARE FUNCTION STRING textInsert (STRING text, STRING string, offset)	' insert text into string at offset
DECLARE FUNCTION STRING textRemove (STRING string,chars,offset)	' remove n chars from string beginning at offset
DECLARE FUNCTION STRING Replace (STRING source,STRING find,STRING replace)
DECLARE FUNCTION STRING GetLastErrorStr ()
DECLARE FUNCTION GetToken (STRING str,STRING token,term)		' return and subtract left most word(token) from string
END EXPORT

FUNCTION VOID DllEntry ()


END FUNCTION


FUNCTION STRING GetDate()
	SYSTEMTIME systemTime

	GetSystemTime (&systemTime)
	RETURN STRING$(systemTime.day)+"/"+STRING$(systemTime.month)+"/"+STRING$(systemTime.year)
END FUNCTION

FUNCTION STRING GetTime()
	SYSTEMTIME systemTime


	GetSystemTime (&systemTime)
	RETURN STRING$(systemTime.hour)+":"+STRING$(systemTime.minute)+":"+STRING$(systemTime.second)
END FUNCTION


FUNCTION STRING textInsert (STRING insert, STRING text, offset)

	text = LEFT$(text,offset) + insert + RIGHT$(text,LEN(text)-offset)
	RETURN text
END FUNCTION

FUNCTION STRING Replace (STRING source,STRING find,STRING replace)


	IFZ source THEN RETURN ""
	IFZ find THEN RETURN source
	IFZ replace THEN RETURN source

'	x = INSTR (source, find)
'	IFZ x THEN RETURN source

	y = LEN (find) - 1
	r = LEN (replace)
	x = 1

	DO WHILE  (x != 0)
		x = INSTR (source, find, x)
		IF x > 0 THEN
			source = LEFT$(source, x-1) + replace + RIGHT$(source, LEN(source) - x - y)
			x = x + r
		END IF
	LOOP

	RETURN source
END FUNCTION


FUNCTION STRING replace (STRING text,oldc,newc)


	IFZ text THEN RETURN ""

	FOR p = 0 TO LEN(text)-1
		IF (text{p} == oldc) THEN text{p} = newc
	NEXT p

	RETURN text
END FUNCTION

FUNCTION STRING textRemove (STRING text,chars,offset)


	text = LEFT$(text,offset) + RIGHT$(text,LEN(text)-offset-chars)
	RETURN text
END FUNCTION

FUNCTION STRING trim (str$,char)


	IFZ str$ THEN RETURN ""
	out$=""

	FOR p = 0 TO LEN (str$)-1
		IF str${p} != char THEN out$ = out$ + CHR$(str${p})
	NEXT p

	str$ = out$
	RETURN str$

END FUNCTION

FUNCTION STRING GetTokenEx (str$,term,offset)


	IFZ str$ THEN RETURN ""

	len = LEN(str$)
	msg$=""
	IF (offset >= len-1) THEN RETURN ""

	FOR p = offset TO len-1
		IF str${p} == term THEN
			INC p
			str$ = RIGHT$(str$,len-p)
			RETURN msg$
		ELSE
			msg$ = msg$ + CHR$(str${p})
		END IF
	NEXT p

	str$ = ""
	RETURN msg$
END FUNCTION

FUNCTION GetToken (str$,msg$,term)		' legacy code, use 'GetTokenEx2()' instead


	IFZ str$ THEN RETURN $$FALSE

	len = LEN(str$)
	msg$=""

	FOR p = 0 TO len-1
		IF str${p} = term THEN
			INC p
			str$ = RIGHT$(str$,len-p)
			RETURN p
		ELSE
			msg$ = msg$ + CHR$(str${p})
		END IF
	NEXT p

	str$ = ""
	RETURN p
END FUNCTION


FUNCTION SaveUnixFile (STRING file,STRING text[])
	STRING line
	

	IFZ file THEN RETURN $$FALSE
	IF (UBOUND(text[]) == -1) THEN RETURN $$FALSE
	
	hfile = OPEN (file,$$WRNEW)
	IF hfile < 3 THEN RETURN -1	
	
	FOR l = 0 TO UBOUND(text[])
		line = TRIM$(text[l])
		IF line THEN
			line = line + CHR$(0x0A)
			WRITE [hfile],line
		END IF
	NEXT l
	
	CLOSE (hfile)
	
	RETURN $$TRUE
END FUNCTION

FUNCTION LoadUnixFile (STRING file,STRING text[])
	STRING data
	STRING line
	

	IFZ file THEN RETURN -1
	
	hfile = OPEN (file,$$RD)
	IF hfile < 3 THEN RETURN -1
	
	data = NULL$(LOF(hfile))
	READ [hfile],data	
	CLOSE (hfile)
	
	count = -1
	DIM text[100]

	offset = 0
	'trim (@data,0x0D)
	DO 
		line = GetTokenExB (@data,0x0A,@offset)
		IF line THEN
			INC count
			
			IF count > UBOUND(text[]) THEN
				REDIM text[count + 100]
			END IF
			
			text[count] = line
		ELSE
			EXIT DO
		END IF
	LOOP UNTIL (line == "")

	REDIM text[count]
	RETURN count
END FUNCTION

FUNCTION STRING GetLastErrorStr ()
	STRING text

	x = GetLastError()
	FormatMessageA ($$FORMAT_MESSAGE_FROM_SYSTEM  | $$FORMAT_MESSAGE_ALLOCATE_BUFFER,0, x, 0,&hLocal, 0,0)
	LocalLock(hLocal)
	text = RTRIM$(CSTRING$(hLocal))
	LocalFree(hLocal)
	RETURN text
END FUNCTION

FUNCTION STRING WSAErrorToName (errorcode)
	STRING wsaname


	SELECT CASE errorcode
		CASE $$WSABASEERR   		:wsaname = "WSA BASEERR"
		CASE $$WSAEINTR      		:wsaname = "WSAE INTR"
		CASE $$WSAEBADF 			:wsaname = "WSAE BADF"
		CASE $$WSAEACCES    		:wsaname = "WSAE ACCES"
		CASE $$WSAEFAULT    		:wsaname = "WSAE FAULT"
		CASE $$WSAEINVAL  			:wsaname = "WSAE INVAL"
		CASE $$WSAEMFILE  			:wsaname = "WSAE MFILE"
		CASE $$WSAEWOULDBLOCK 		:wsaname = "WSAE WOULDBLOCK"
		CASE $$WSAEINPROGRESS 		:wsaname = "WSAE INPROGRESS"
		CASE $$WSAEALREADY			:wsaname = "WSAE ALREADY"
		CASE $$WSAENOTSOCK			:wsaname = "WSAE NOTSOCK"
		CASE $$WSAEDESTADDRREQ 		:wsaname = "WSAE DESTADDRREQ"
		CASE $$WSAEMSGSIZE 			:wsaname = "WSAE MSGSIZE"
		CASE $$WSAEPROTOTYPE 		:wsaname = "WSAE PROTOTYPE"
		CASE $$WSAENOPROTOOPT		:wsaname = "WSAE NOPROTOOPT"
		CASE $$WSAEPROTONOSUPPORT	:wsaname = "WSAE PROTONOSUPPORT"
		CASE $$WSAESOCKTNOSUPPORT	:wsaname = "WSAE SOCKTNOSUPPORT"
		CASE $$WSAEOPNOTSUPP		:wsaname = "WSAE OPNOTSUPP"
		CASE $$WSAEPFNOSUPPORT		:wsaname = "WSAE PFNOSUPPORT"
		CASE $$WSAEAFNOSUPPORT 		:wsaname = "WSAE PFNOSUPPORT"
		CASE $$WSAEADDRINUSE		:wsaname = "WSAE ADDRINUSE"
		CASE $$WSAEADDRNOTAVAIL		:wsaname = "WSAE ADDRNOTAVAIL"
		CASE $$WSAENETDOWN 			:wsaname = "WSAE NETDOWN"
		CASE $$WSAENETUNREACH 		:wsaname = "WSAE NETUNREACH"
		CASE $$WSAENETRESET 		:wsaname = "WSAE NETRESET"
		CASE $$WSAECONNABORTED		:wsaname = "WSAE CONNABORTED"
		CASE $$WSAECONNRESET		:wsaname = "WSAE CONNRESET"
		CASE $$WSAENOBUFS			:wsaname = "WSAE NOBUFS"
		CASE $$WSAEISCONN 			:wsaname = "WSAE ISCONN"
		CASE $$WSAENOTCONN 			:wsaname = "WSAE NOTCONN"
		CASE $$WSAESHUTDOWN 		:wsaname = "WSAE SHUTDOWN"
		CASE $$WSAETOOMANYREFS 		:wsaname = "WSAE TOOMANYREFS"
		CASE $$WSAETIMEDOUT			:wsaname = "WSAE TIMEDOUT"
		CASE $$WSAECONNREFUSED 		:wsaname = "WSAE CONNREFUSED"
		CASE $$WSAELOOP				:wsaname = "WSAE LOOP"
		CASE $$WSAENAMETOOLONG		:wsaname = "WSAE NAMETOOLONG"
		CASE $$WSAEHOSTDOWN			:wsaname = "WSAE HOSTDOWN"
		CASE $$WSAEHOSTUNREACH		:wsaname = "WSAE HOSTUNREACH"
		CASE $$WSAENOTEMPTY			:wsaname = "WSAE NOTEMPTY"
		CASE $$WSAEPROCLIM 			:wsaname = "WSAE PROCLIM"
		CASE $$WSAEUSERS      		:wsaname = "WSAE USERS"
		CASE $$WSAEDQUOT     		:wsaname = "WSAE DQUOT"
		CASE $$WSAESTALE      		:wsaname = "WSAE STALE"
		CASE $$WSAEREMOTE			:wsaname = "WSAE REMOTE"
		CASE $$WSAESYSNOTREADY		:wsaname = "WSAE SYSNOTREADY"
		CASE $$WSAEVERNOTSUPPORTED	:wsaname = "WSAE VERNOTSUPPORTED"
		CASE $$WSAENOTINITILISED	:wsaname = "WSAE NOTINITILISED"
		CASE $$WSAENOTINITILIZED	:wsaname = "WSAE NOTINITILIZED"
		CASE $$WSAEDISCON			:wsaname = "WSAE DISCON"

		CASE $$WSAHOST_NOT_FOUND	:wsaname = "WSA HOST_NOT_FOUND"
		CASE $$WSATRY_AGAIN			:wsaname = "WSA HOST_NOT_FOUND"
		CASE $$WSANO_RECOVERY		:wsaname = "WSA NO_RECOVERY"
		CASE $$WSANO_DATA			:wsaname = "WSA NO_DATA"
		CASE $$WSANO_ADDRESS		:wsaname = "WSA NO_ADDRESS"
	
		CASE ELSE					:wsaname = HEXX$(errorcode)+" - "+STRING$(errorcode)
	END SELECT
	
	RETURN wsaname
END FUNCTION

FUNCTION STRING GetTokenExB (STRING text,term,offset)	' does not modify input text.


	IFZ text THEN RETURN ""
	len = LEN(text)
	msg$=""
	
	IF (offset >= len-1) THEN RETURN ""

	FOR p = offset TO len-1
		IF (text{p} == term) THEN
			offset = p+1
			RETURN msg$
		ELSE
			msg$ = msg$ + CHR$(text{p})
		END IF
	NEXT p

	offset = p
	RETURN msg$
END FUNCTION

FUNCTION STRING GetTokenEx2 (STRING text,term)
	STRING token


	IFZ text THEN RETURN ""
	len = LEN(text)

	FOR p = 0 TO len-1
		IF (text{p} == term) THEN
			token = LEFT$(text,p)
			INC p
			text = RIGHT$(text,len-p)
			RETURN token
		END IF
	NEXT p

	token = text
	text = ""
	RETURN token
END FUNCTION

END PROGRAM

