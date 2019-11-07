'
'	command bots with public commands
'	type "!okio" on hub to view commands or simply read below
'
'
PROGRAM	"pubcmdbots"
VERSION	"0.40"
MAKEFILE "xdll.xxx"


	IMPORT "gdi32"
	IMPORT "kernel32"
'	IMPORT "shell32"
	IMPORT "user32"
	IMPORT "msvcrt"
	IMPORT "dcutils"
	IMPORT "MyDC.dec"
	

$$FN_PATH			= "datafiles/"

$$FN_LastSeen		= "lastseen"
$$FN_Dubya			= "dubya"
$$FN_BOFH			= "bofh"
$$FN_Country		= "country"
$$FN_CountryCode	= "countrycode"
$$FN_Duke			= "duke"
$$FN_Dutch			= "dutch"
$$FN_Facts			= "facts"
$$FN_Insult1		= "insult1"
$$FN_Insult2		= "insult2"
$$FN_Insult3		= "insult3"
$$FN_Insult4		= "insult4"
$$FN_MOI			= "moi"
$$FN_Morbid			= "morbid"
$$FN_Zodiac			= "zodiac"

$$PluginTitle		= "MyDC Command Bots 0.50"

PACKED TPubCmd
	STRING * 20		.CmdName
	FUNCADDR		.CmdAddr (XLONG,STRING,STRING)
	XLONG			.CmdStatus
END TYPE



DECLARE FUNCTION VOID DllEntry ()

EXPORT
DECLARE FUNCTION DllExit ()
DECLARE FUNCTION DllStartup (TDCPlugin dcp)
DECLARE FUNCTION DllProc (token, STRING msg1, STRING msg2)
END EXPORT

DECLARE FUNCTION STRING LastSeen (STRING user)					' return date - time of when user was last seen on hub
DECLARE FUNCTION STRING Country (STRING code)					' returns internet country codes. eg, code = ie will return ireland
DECLARE FUNCTION STRING MOI()									' return a random quote form the minister of information
DECLARE FUNCTION STRING Duke()									' return a random duke nukem quote
DECLARE FUNCTION STRING Insult ()								' return a random insult
DECLARE FUNCTION STRING BOFHQuote()								' return a random bastard operator from hell quote
DECLARE FUNCTION STRING DubyaQuote()							' return an actual random GWB jr quote
DECLARE FUNCTION STRING DutchInsult()							' return a random insult in dutch
DECLARE FUNCTION STRING Fact(socket)							' return a random fact
DECLARE FUNCTION STRING Morbid(socket)							' return a random morbid fact
DECLARE FUNCTION STRING Zodiac(year)							' return chinese birth year(animal) and meaning

DECLARE FUNCTION LoadDutch ()									' load dutch insult file
DECLARE FUNCTION LoadInsult ()									' load english insult files
DECLARE FUNCTION LoadBOFH ()									' load BOFH quotes
DECLARE FUNCTION LoadDubya ()									' load GWB jr. quotes
DECLARE FUNCTION LoadMOI ()										' load MOI quotes
DECLARE FUNCTION LoadDuke ()									' load Duke Nukem quotes
DECLARE FUNCTION LoadCountry ()									' load country code files
DECLARE	FUNCTION LoadFact ()									' load fact file
DECLARE	FUNCTION LoadMorbid ()									' load morbid fact file
DECLARE	FUNCTION LoadZodiac()									' load zodiac data file

DECLARE FUNCTION SaveLastSeenList ()
DECLARE FUNCTION UpdateSeenStatus (STRING user)					' update seen record file with date/time for user
DECLARE FUNCTION addfact (socket,STRING text)
DECLARE FUNCTION removefact (socket,fact)

DECLARE FUNCTION ProcessClientCmd (cmd$,msg$)
DECLARE FUNCTION TxtCommand (socket,STRING user,STRING text)

DECLARE FUNCTION PubCmdExecute (socket,STRING cmd,STRING user, STRING text)
DECLARE FUNCTION PubCmdRegister (STRING cmdname,fncaddr,status)
DECLARE FUNCTION PubCmdGetIndex (STRING cmd)
DECLARE FUNCTION PubCmdSetStatus (STRING cmd,cmdstatus)
DECLARE FUNCTION PubCmdGetStatus (STRING cmd)
DECLARE FUNCTION PubCmdGetAddr (STRING cmd)
DECLARE FUNCTION PubCmdGetTotal ()
DECLARE FUNCTION STRING PubCmdGetName(index)

DECLARE FUNCTION PubCmdOkio		(socket, STRING user, STRING text)			' pubic command call functions
DECLARE FUNCTION PubCmdFact		(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdZodiac	(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdMorbid	(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdSeen		(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdBOFH		(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdInsult	(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdDutch	(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdDuke		(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdMOI		(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdDubya	(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdCountry	(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdAddfact	(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdOn		(socket, STRING user, STRING text)
DECLARE FUNCTION PubCmdOff		(socket, STRING user, STRING text)

DECLARE FUNCTION InvertPubCmdStatus (socket,STRING cmd)					' invert the status of a public command, eg, $$TRUE -> $$FALSE

DECLARE FUNCTION CPrint (edit,STRING text)
DECLARE FUNCTION IsUserConnected (STRING user)
DECLARE FUNCTION IsUserAnOp (STRING nick)

DECLARE FUNCTION SendMsg ( STRING msg)
DECLARE FUNCTION CCmdMsg (STRING touser,STRING msg)
DECLARE FUNCTION STRING GetHubNick ()
DECLARE FUNCTION STRING GetNick ()
DECLARE FUNCTION SetOpList (STRING msg1)

DECLARE FUNCTION DispatchDCTMsg (token, STRING msg1, STRING msg2)

FUNCTION VOID DllEntry ()
		
END FUNCTION

FUNCTION DllExit ()

	DispatchDCTMsg ($$MDCT_PrvTxtMsg,STRING$($$Hub),":: "+$$PluginTitle+": shutting down")
	SaveLastSeenList ()	' ensure lastseen file is updated
END FUNCTION

FUNCTION DllStartup (TDCPlugin dcp)
	SHARED FUNCADDR DDCTM (XLONG,STRING,STRING)
	SHARED UpdateSeenListPeriod
	SHARED STRING SeenList[]
	SHARED SEENLISTUPDATED
	SHARED InsultAll,BOTS
	SHARED LastSeenSave
	SHARED STRING Nick
	SHARED tuser
	SHARED ENTERONCE


	IF ENTERONCE THEN
		RETURN $$FALSE
	ELSE
		ENTERONCE = 1
	END IF
	
'	Server = CSTRING$(dcp.lpserver)
	Nick = CSTRING$(dcp.lpnick)
'	Port = dcp.port

	dcp.pDllExit = &DllExit()
	dcp.pDllFunc = &DllProc()
	dcp.lpPluginTitle = &$$PluginTitle
	DDCTM = dcp.lpDDCTM

	InsultAll	= $$TRUE
	BOTS		= $$TRUE
	SEENLISTUPDATED = $$FALSE
	
	UpdateSeenListPeriod = 5*60*1000	'	 5 minutes
	LastSeenSave = GetTickCount()
	tuser = LoadUnixFile ($$FN_PATH + $$FN_LastSeen,@SeenList[])


'	PubCmdRegister (GetNick(),&PubCmdOkio(),$$TRUE)			' register public commands with a callback function 
	PubCmdRegister ("Okio",&PubCmdOkio(),$$TRUE)			' register public commands with a callback function 
	PubCmdRegister ("Dubya",&PubCmdDubya(),$$TRUE)			' and set initial status
	PubCmdRegister ("Insult",&PubCmdInsult(),$$TRUE)
	PubCmdRegister ("BOFH",&PubCmdBOFH(),$$TRUE)
	PubCmdRegister ("Country",&PubCmdCountry(),$$TRUE)
	PubCmdRegister ("MOI",&PubCmdMOI(),$$TRUE)
	PubCmdRegister ("Duke",&PubCmdDuke(),$$TRUE)
	PubCmdRegister ("Dutch",&PubCmdDutch(),$$TRUE)
	PubCmdRegister ("Seen",&PubCmdSeen(),$$FALSE)		' causing lag. seen parser needs to be rewritten
	PubCmdRegister ("Fact",&PubCmdFact(),$$TRUE)
	PubCmdRegister ("Morbid",&PubCmdMorbid(),$$TRUE)
	PubCmdRegister ("Addfact",&PubCmdAddfact(),$$TRUE)
	PubCmdRegister ("Zodiac",&PubCmdZodiac(),$$FALSE)		' incomplete
	
	PubCmdRegister ("On",&PubCmdOn(),$$TRUE)
	PubCmdRegister ("Off",&PubCmdOff(),$$TRUE)

	RETURN $$TRUE
END FUNCTION

FUNCTION DllProc (token, STRING msg1, STRING msg2)
	'SHARED STRING Server
	SHARED STRING Nick
	SHARED socket
	'SHARED Port
	STRING tmp
	

	SELECT CASE token
		CASE $$MDCT_ClientConnected	:
			Nick = GetTokenEx (@msg2,':',0)
			UpdateSeenStatus (Nick)
		'	Server = GetTokenEx (@msg2,':',0)
		'	Port = XLONG(GetTokenEx (@msg2,':',0))
			socket = XLONG(msg1)
			RETURN $$MDCTH_HandledCont
	
		CASE $$MDCT_Nick			:
			Nick = msg1
			RETURN $$MDCTH_HandledCont

		CASE $$MDCT_ClientJoin,$$MDCT_ClientJoinAll		:
			UpdateSeenStatus (@msg1)
			RETURN $$MDCTH_HandledCont

		CASE $$DCT_Quit		:
			UpdateSeenStatus (@msg1)
			RETURN $$MDCTH_HandledCont
			
		CASE $$MDCT_ClientCmdMsg		:
			IFT ProcessClientCmd (@msg1,@msg2) THEN
				RETURN $$MDCTH_HandledStop
			ELSE
				RETURN $$MDCTH_UnhandledCont
			END IF

		CASE $$MDCT_PMCmdMsg			:
			TxtCommand (socket,@msg1,@msg2)
			'IFT TxtCommand (socket,@msg1,@msg2) THEN
			'	RETURN $$MDCTH_HandledStop
			'ELSE
			'	RETURN $$MDCTH_UnhandledCont
			'END IF

		CASE $$MDCT_PubCmdMsg			:
			TxtCommand (socket,@msg1,@msg2)
		'	IFT TxtCommand (socket,@msg1,@msg2) THEN
		'		RETURN $$MDCTH_HandledStop
		'	ELSE
		'		RETURN $$MDCTH_UnhandledCont
		'	END IF

		CASE $$DCT_OpList		:
			SetOpList (@msg1)
	END SELECT
	
	RETURN $$MDCTH_UnhandledCont
END FUNCTION

FUNCTION LoadZodiac ()
	SHARED TZodiac
	SHARED STRING Zodiac[]
	

	TZodiac = LoadUnixFile ($$FN_PATH + $$FN_Zodiac,@Zodiac[])
	IF (TZodiac == $$LUF_ERROR) THEN
		PubCmdSetStatus ("zodiac", $$FALSE)
		RETURN $$FALSE
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION LoadMorbid ()
	SHARED TMorbid
	SHARED STRING Morbid[]
	

	TMorbid = LoadUnixFile ($$FN_PATH + $$FN_Morbid,@Morbid[])
	IF (TMorbid == $$LUF_ERROR) THEN
		PubCmdSetStatus ("Morbid", $$FALSE)
		RETURN $$FALSE
	END IF

	RETURN $$TRUE
END FUNCTION


FUNCTION LoadFact ()
	SHARED TFact
	SHARED STRING Fact[]
	

	TFact = LoadUnixFile ($$FN_PATH + $$FN_Facts,@Fact[])
	IF (TFact == $$LUF_ERROR) THEN
		PubCmdSetStatus ("Fact", $$FALSE)
		RETURN $$FALSE
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION LoadBOFH ()
	SHARED TBOFH
	SHARED STRING BOFHQuotes[]
	

	TBOFH = LoadUnixFile ($$FN_PATH + $$FN_BOFH,@BOFHQuotes[])
	IF (TBOFH == $$LUF_ERROR) THEN
		PubCmdSetStatus ("BOFH", $$FALSE)
		RETURN $$FALSE
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION LoadDubya ()
	SHARED TDubya
	SHARED STRING DubyaQuotes[]
	

	TDubya = LoadUnixFile ($$FN_PATH + $$FN_Dubya,@DubyaQuotes[])
	IF (TDubya == $$LUF_ERROR) THEN
		PubCmdSetStatus ("Dubya", $$FALSE)
		RETURN $$FALSE
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION LoadMOI ()
	SHARED TMOI
	SHARED STRING MOI[]
	

	TMOI = LoadUnixFile ($$FN_PATH + $$FN_MOI,@MOI[])
	IF (TMOI == $$LUF_ERROR) THEN
		PubCmdSetStatus ("MOI", $$FALSE)
		RETURN $$FALSE
	END IF
	
	RETURN $$TRUE
END FUNCTION

FUNCTION LoadDuke ()
	SHARED TDuke
	SHARED STRING Duke[]
	

	TDuke = LoadUnixFile ($$FN_PATH + $$FN_Duke,@Duke[])
	IF (TDuke == $$LUF_ERROR) THEN
		PubCmdSetStatus ("Duke", $$FALSE)
		RETURN $$FALSE
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION LoadCountry ()
	SHARED TCountry,TCountryCode
	SHARED STRING country[],countrycode[]
	

	TCountry = LoadUnixFile ($$FN_PATH + $$FN_Country,@country[])
	TCountryCode = LoadUnixFile ($$FN_PATH + $$FN_CountryCode,@countrycode[])
		
	IF (TCountry == $$LUF_ERROR) OR (TCountryCode == $$LUF_ERROR) THEN
		PubCmdSetStatus ("Country", $$FALSE)
		RETURN $$FALSE
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION LoadInsult ()
	SHARED TInsult1,TInsult2,TInsult3,TInsult4
	SHARED STRING InsultP1[],InsultP2[],InsultP3[],InsultP4[]


	TInsult1 = LoadUnixFile ($$FN_PATH + $$FN_Insult1,@InsultP1[])
	TInsult2 = LoadUnixFile ($$FN_PATH + $$FN_Insult2,@InsultP2[])
	TInsult3 = LoadUnixFile ($$FN_PATH + $$FN_Insult3,@InsultP3[])
	TInsult4 = LoadUnixFile ($$FN_PATH + $$FN_Insult4,@InsultP4[])
		
	IF (TInsult1 == $$LUF_ERROR) OR (TInsult2 == $$LUF_ERROR) OR (TInsult3 == $$LUF_ERROR) OR (TInsult4 == $$LUF_ERROR) THEN
		PubCmdSetStatus ("Insult", $$FALSE)
		RETURN $$FALSE
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION LoadDutch ()
	SHARED TDutch
	SHARED STRING Dutch[]


	TDutch = LoadUnixFile ($$FN_PATH + $$FN_Dutch,@Dutch[])
	IF (TDutch == $$LUF_ERROR) THEN
		PubCmdSetStatus ("Dutch", $$FALSE)
		RETURN $$FALSE
	END IF
	
	RETURN $$TRUE
END FUNCTION

FUNCTION ProcessClientCmd (cmd$,msg$)
	SHARED socket
	SHARED BOTS
	SHARED InsultAll 


	cmd$ = LCASE$(cmd$)
	SELECT CASE cmd$
		CASE "addfact"		:InvertPubCmdStatus (socket,cmd$)
		CASE "fact"			:InvertPubCmdStatus (socket,cmd$)
		CASE "morbid"		:InvertPubCmdStatus (socket,cmd$)
		CASE "zodiac"		:InvertPubCmdStatus (socket,cmd$)
		CASE "seen"			:InvertPubCmdStatus (socket,cmd$)
		CASE "dutch"		:InvertPubCmdStatus (socket,cmd$)
		CASE "dubya"		:InvertPubCmdStatus (socket,cmd$)
		CASE "insult"		:InvertPubCmdStatus (socket,cmd$)
		CASE "duke"			:InvertPubCmdStatus (socket,cmd$)
		CASE "moi"			:InvertPubCmdStatus (socket,cmd$)
		CASE "country"		:InvertPubCmdStatus (socket,cmd$)
		CASE "bofh"			:InvertPubCmdStatus (socket,cmd$)

		CASE "removefact"	:removefact (socket,XLONG(TRIM$(msg$)))				

		CASE "bots"			:IFT BOTS THEN
							 	BOTS = $$FALSE
							 	CPrint ($$Hub,"* all bots off")
							 ELSE
								BOTS = $$TRUE
								CPrint ($$Hub,"* all bots on")
							 END IF

		CASE "insultall"	:IFT InsultAll THEN
							 	InsultAll = $$FALSE
							 	CPrint ($$Hub,"* insult all off")
							 ELSE
							 	InsulAllt = $$TRUE
							 	CPrint ($$Hub,"* insult all on")
							 END IF
		CASE ELSE			:RETURN $$FALSE
	END SELECT

	RETURN $$TRUE
END FUNCTION

FUNCTION STRING LastSeen (STRING user)
	SHARED STRING SeenList[]
	STRING text,name,date,time,seen
	SHARED tuser

	
	IFT IsUserConnected(user) THEN RETURN user +" is right here!"
	IFZ tuser THEN
		tuser = LoadUnixFile ($$FN_PATH + $$FN_LastSeen,@SeenList[])
'		IF (tuser == -1) THEN RETURN ""
	END IF

	user = LCASE$(user)
	FOR u = 0 TO UBOUND(SeenList[])	' check if user is in list, if so update seen details
		IF SeenList[u] THEN
			IF (user == LCASE$(GetTokenEx(SeenList[u],32,0))) THEN
				seen = SeenList[u]
				name = GetTokenEx(@seen,32,0)
				date = GetTokenEx(@seen,32,0)
				time = GetTokenEx(@seen,32,0)
			
				IF (TRIM$(date) == GetDate()) THEN
					date = "today"
				ELSE
					date = "on "+date
				END IF
				RETURN user +" was last seen "+date+" at "+time+" GMT"
			END IF
		END IF
	NEXT u
	
	RETURN user +" has not been seen"
END FUNCTION

FUNCTION UpdateSeenStatus (STRING user)
	SHARED STRING SeenList[]
	SHARED SEENLISTUPDATED
	SHARED LastSeenSave,UpdateSeenListPeriod
	SHARED tuser

'RETURN
	IFF PubCmdGetStatus ("seen") THEN RETURN $$FALSE
	IFZ user THEN RETURN $$FALSE
	IFZ tuser THEN
		tuser = LoadUnixFile ($$FN_PATH + $$FN_LastSeen,@SeenList[])
		'IF (tuser == -1) THEN RETURN $$FALSE
	END IF
	
	found = $$FALSE
	upper = UBOUND(SeenList[])
	FOR u = 0 TO tuser ' upper		' check if user is in list, if so update seen details
		IF SeenList[u] THEN
			IF (user == GetTokenEx(SeenList[u],32,0)) THEN
				SeenList[u] = user +" "+ GetDate()+" "+GetTime()
				found = $$TRUE
				EXIT FOR
			END IF
		END IF
	NEXT u
	
	IFF found THEN	' user is not in datafile so create a new entry
		slot = 0
		FOR s = tuser TO upper
			IF SeenList[s] == "" THEN
				slot = s
				EXIT FOR
			END IF
		NEXT s
		
		IFZ slot THEN
			REDIM SeenList[upper+100]
			slot = upper + 1
		END IF
		
		INC tuser		
		SeenList[slot] = user +" "+ GetDate()+" "+GetTime()
	END IF

	SEENLISTUPDATED = $$TRUE
	
	IF (GetTickCount()-LastSeenSave) > UpdateSeenListPeriod THEN
		SaveLastSeenList ()
	END IF

	RETURN $$TRUE
END FUNCTION

FUNCTION SaveLastSeenList ()
	SHARED STRING SeenList[]
	SHARED LastSeenSave
	SHARED SEENLISTUPDATED
	
	
	IFF SEENLISTUPDATED THEN RETURN $$FALSE
	
	IFT SaveUnixFile ($$FN_PATH + $$FN_LastSeen,@SeenList[]) THEN
		LastSeenSave = GetTickCount()
	'	CPrint ($$Hub,"* "+GetTime()+": seen list updated")
		SEENLISTUPDATED = $$FALSE
	ELSE
		CPrint ($$Hub,"* "+GetTime()+": unable to save seen list")
		Sleep(1000)
	END IF
	
	RETURN $$TRUE
END FUNCTION

FUNCTION TxtCommand (socket,STRING user,STRING text)
	SHARED BOTS
	STATIC t0
	STRING cmd
	
	
	IFF BOTS THEN RETURN $$FALSE
	
	DO		' don't spam the server
		IF (GetTickCount()-t0) > 1000 THEN
			EXIT DO
		ELSE
			RETURN $$FALSE
		END IF
	LOOP

	' add case sensitive flag
	cmd = LCASE$(GetTokenEx2(@text,32))
	IFZ cmd THEN RETURN $$FALSE
	
	SELECT CASE cmd{0}
		CASE '!'		:trim (@cmd,'!')
		CASE '+'		:trim (@cmd,'+')
		CASE '~'		:trim (@cmd,'~')
		CASE '?'		:trim (@cmd,'?')
		CASE ELSE		:RETURN $$FALSE
	END SELECT

	IFT PubCmdGetStatus (cmd) THEN
		ret = PubCmdExecute (socket,cmd,user,text)
		t0 = GetTickCount()	
		RETURN ret
	ELSE
		t0 = GetTickCount()	
		RETURN $$TRUE
	END IF
	
END FUNCTION


FUNCTION PubCmdExecute (socket,STRING cmd,STRING user, STRING text)
	FUNCADDR pubcmd (XLONG ,STRING ,STRING)

	
	pubcmd = PubCmdGetAddr(cmd)
	IFZ pubcmd THEN
		RETURN $$FALSE
	ELSE
		ret = @pubcmd (socket,user,text)
		RETURN $$TRUE
	END IF

END FUNCTION

FUNCTION PubCmdRegister (STRING cmdname,fncaddr,cmdstatus)
	SHARED TPubCmd PubCmd[]
	SHARED total
	STATIC once
	
	
	IFZ once THEN
		DIM PubCmd[0]
		total = 0
		once = 1
	ELSE
		INC total
		REDIM PubCmd[total]
	END IF

	PubCmd[total].CmdName = LCASE$(cmdname)
	PubCmd[total].CmdAddr = fncaddr
	PubCmd[total].CmdStatus = cmdstatus
	
	RETURN total
END FUNCTION

FUNCTION PubCmdGetIndex (STRING cmd)
	

	cmd = LCASE$(cmd)
	FOR c = 0 TO PubCmdGetTotal()
		IF (PubCmdGetName(c) == cmd) THEN RETURN c
	NEXT c
	
	RETURN -1
END FUNCTION


FUNCTION InvertPubCmdStatus (socket,STRING cmd)
	

	'cmd = TRIM$ (cmd) 
	IFT PubCmdGetStatus (cmd) THEN
		PubCmdSetStatus (cmd,$$FALSE)
		CPrint ($$Hub,"* "+cmd+" disabled")
	ELSE
		PubCmdSetStatus (cmd,$$TRUE)
		CPrint ($$Hub,"* "+cmd+" enabled")
	END IF
	
	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdSetStatus (STRING cmd,cmdstatus)
	SHARED TPubCmd PubCmd[]

	
	i = PubCmdGetIndex (LCASE$(cmd))
	IF (i == -1) THEN RETURN $$FALSE
	PubCmd[i].CmdStatus = cmdstatus

	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdGetStatus (STRING cmd)
	SHARED TPubCmd PubCmd[]

	
	i = PubCmdGetIndex (cmd)
	IF (i == -1) THEN RETURN $$FALSE
	RETURN PubCmd[i].CmdStatus
END FUNCTION

FUNCTION PubCmdGetAddr (STRING cmd)
	SHARED TPubCmd PubCmd[]

	i = PubCmdGetIndex(cmd)
	IF (i == -1) THEN
		RETURN 0
	ELSE
		RETURN PubCmd[i].CmdAddr
	END IF
	
END FUNCTION

FUNCTION STRING PubCmdGetName (i)
	SHARED TPubCmd PubCmd[]

	RETURN PubCmd[i].CmdName
END FUNCTION

FUNCTION PubCmdGetTotal ()
	SHARED total

	RETURN total
END FUNCTION


FUNCTION PubCmdOn (socket, STRING user, STRING cmd)


	cmd = trim (cmd,'!')
	
	IFF IsUserAnOp (user) THEN
		CCmdMsg (user,"* you must be an operator to use this command")
		RETURN $$FALSE
	END IF

	IFT PubCmdSetStatus (GetTokenEx (cmd,32,0),$$TRUE)
		CCmdMsg (user,"* "+cmd+" enabled")
	ELSE
		' command not found
		CCmdMsg (user,"* unknown command")
	END IF
	
	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdOff (socket, STRING user, STRING cmd)

	
	cmd = trim (cmd,'!')
	IFF IsUserAnOp (user) THEN
		CCmdMsg (user,"* you must be an operator to use this command")
		RETURN $$FALSE
	END IF
	
	IFT PubCmdSetStatus (GetTokenEx (cmd,32,0),$$FALSE)
		CCmdMsg (user,"* "+cmd+" disabled")
	ELSE
		' command not found
		CCmdMsg (user,"* unknown command")
	END IF
	
	RETURN $$TRUE
END FUNCTION


FUNCTION PubCmdOkio (socket,STRING user, STRING text)


	SendMsg ("commands (!,~,+ or ?): fact, addfact fact, bofh, morbid, seen nick, dutch nick, insult nick, dubya, duke, moi, country code")
	SendMsg ("example: +fact")
	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdFact (socket,STRING user, STRING text)

	SendMsg ("Fact: "+Fact(socket))
	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdZodiac (socket,STRING user, STRING text)
	
	
	year = XLONG(GetTokenEx (text,32,0))
	IF year < 1950 THEN RETURN $$FALSE
	SendMsg (Zodiac(year))
	
	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdMorbid (socket,STRING user, STRING text)

	
	SendMsg ("Morbid: "+Morbid(socket))
	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdSeen (socket,STRING user, STRING text)
	
	
	text = GetTokenEx(text,32,0)
	IFZ text THEN
		SendMsg ("could "+trim(trim(user,'<'),'>')+" really be Said53?")
		RETURN $$FALSE
	END IF
	
	IF (LCASE$(user) == ("<"+LCASE$(text)+">")) THEN 
		SendMsg (user+" stop wasting my time!")
	ELSE
		SendMsg (LastSeen(text))
	END IF
	
	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdBOFH (socket,STRING user, STRING text)

	
	SendMsg ("BOFH: \""+BOFHQuote()+"\"")
	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdInsult (socket,STRING user, STRING text)
	SHARED InsultAll
	STRING who

	
	GetToken (text,@who,32)
	'who = TRIM$(who)
	'IF (LCASE$(who) == LCASE$(GetNick())) THEN RETURN $$FALSE	'don't insult Nick
	IF INSTRI(who,GetNick()) THEN RETURN $$FALSE
'	i = INCHR(who,"!") 
'	IF i THEN
'		RETURN $$FALSE
'		who{i} = 32
'		who = TRIM$(who)
'	END IF
	
	IF user != (GetHubNick()) THEN
		IF who == "me" THEN
			who = user
		ELSE
			IFF InsultAll THEN
				IFF IsUserConnected(who) THEN RETURN $$FALSE
			END IF
		END IF
	END IF
								
	SendMsg (who+" "+Insult())

	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdDutch (socket,STRING user, STRING text)
	SHARED InsultAll
	STRING who
	
	
	GetToken (text,@who,32)
	'who = TRIM$(who)
	'IF (LCASE$(who) == LCASE$(GetNick())) THEN RETURN $$FALSE	'don't insult Nick
	IF INSTRI(who,GetNick()) THEN RETURN $$FALSE
'	i = INCHR(who,"!") 
'	IF i THEN
'		RETURN $$FALSE
'		who{i} = 32
'		who = TRIM$(who)
'	END IF

	IF user != (GetHubNick()) THEN
		IF who == "me" THEN
			who = user
		ELSE
			IFF InsultAll THEN
				IFF IsUserConnected(who) THEN RETURN $$FALSE
			END IF
		END IF
	END IF
								
	SendMsg (who+" "+DutchInsult())

	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdDuke (socket,STRING user, STRING text)
	
	
	SendMsg ("Duke says: "+Duke())
	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdMOI (socket,STRING user, STRING text)

	
	SendMsg ("MOI: "+MOI())
	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdDubya (socket,STRING user, STRING text)
	
	
	SendMsg ("Dubya: "+DubyaQuote())
	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdCountry (socket,STRING user, STRING text)

	
	GetToken (text,@code$,32)
	SendMsg (Country(code$))

	RETURN $$TRUE
END FUNCTION

FUNCTION PubCmdAddfact (socket,STRING user, STRING text)


	addfact (socket,text)
	RETURN $$TRUE
END FUNCTION

FUNCTION STRING Zodiac (year)
	SHARED TZodiac
	SHARED STRING Zodiac[]


	IF TZodiac < 1 THEN
		IFF LoadZodiac() THEN RETURN "not today"
	END IF
	
	srand (clock()): srand (GetTickCount())
	RETURN Zodiac[rand() MOD TZodiac]
END FUNCTION

FUNCTION STRING Morbid(socket)
	SHARED TMorbid
	SHARED STRING Morbid[]
		

	IF TMorbid < 1 THEN
		IFF LoadMorbid() THEN RETURN "not today"
	END IF
	
	srand (clock()): srand (GetTickCount())
	RETURN Morbid[rand() MOD TMorbid]
END FUNCTION


FUNCTION removefact (socket,fact)
	SHARED TFact
	SHARED STRING Fact[]


	IF (fact < 2212) OR (fact > TFact) THEN RETURN $$FALSE
	Fact[fact] = ""
	SaveUnixFile ($$FN_PATH + $$FN_Facts,@Fact[])
	IFF LoadFact() THEN RETURN $$FALSE
	
	SendMsg ("Fact "+STRING$(fact)+" removed")

	RETURN $$TRUE
END FUNCTION

FUNCTION addfact (socket,STRING text)
	SHARED TFact
	SHARED STRING Fact[]
	

	IFZ text THEN RETURN $$FALSE
	IF TFact < 1 THEN
		IFF LoadFact() THEN RETURN $$FALSE
	END IF
	
	INC TFact
	REDIM Fact[TFact]
	Fact[TFact] = "\""+text+"\""
	SendMsg ("Added Fact "+STRING$(TFact)+": "+Fact[TFact])
	SaveUnixFile ($$FN_PATH + $$FN_Facts,@Fact[])
	
	RETURN $$TRUE
END FUNCTION

FUNCTION STRING Fact(socket)
	SHARED TFact
	SHARED STRING Fact[]


	IF TFact < 1 THEN
		IFF LoadFact() THEN RETURN "not today"
	END IF
	
	srand (clock()): srand (GetTickCount())
	RETURN Fact[rand() MOD TFact]
END FUNCTION

FUNCTION STRING BOFHQuote()
	SHARED TBOFH
	SHARED STRING BOFHQuotes[]
	

	IF TBOFH < 1 THEN
		IFF LoadBOFH () THEN RETURN "not today"
	END IF
	
	srand (clock()): srand (GetTickCount())
	RETURN BOFHQuotes[rand() MOD TBOFH]
END FUNCTION


FUNCTION STRING Country (STRING code)
	SHARED TCountry,TCountryCode
	SHARED STRING country[],countrycode[]
	STRING text
	

	IF TCountry < 1 THEN
		IFF LoadCountry () THEN RETURN "not today"
	END IF
	
	code = UCASE$(code)
	FOR c = 0 TO TCountryCode
		IF UCASE$(countrycode[c]) == code THEN
			text = "Country code '" + code +"' = '" + country[c] + "'"
			RETURN text
		END IF
	NEXT c

	RETURN "Country code unrecognized"	
END FUNCTION

FUNCTION STRING Insult()
	SHARED STRING InsultP1[],InsultP2[],InsultP3[],InsultP4[]
	SHARED TInsult1,TInsult2,TInsult3,TInsult4
	STRING part1,part2,part3,part4
	STRING text


	IF (TInsult1 < 1) OR (TInsult2 < 1) OR (TInsult3 < 1) OR (TInsult4 < 1) THEN
		IFF LoadInsult () THEN RETURN "not today"
	END IF
	
	srand (clock()): srand (GetTickCount())

	part1 = InsultP1[rand() MOD TInsult1]
	part2 = InsultP2[rand() MOD TInsult2]
	part3 = InsultP3[rand() MOD TInsult3]
	part4 = InsultP4[rand() MOD TInsult4]
	text = "you "+part1+" "+part2+" "+part3+" "+part4+"!"
	
	RETURN text
END FUNCTION

FUNCTION STRING DutchInsult()
	SHARED TDutch
	SHARED STRING Dutch[]
	STRING text,part1,part2
	
	
	IF TDutch < 1 THEN
		IFF LoadDutch () THEN RETURN "not today"
	END IF
	
	srand (clock()): srand (GetTickCount())
	
	part1 = Dutch[rand() MOD TDutch]
	part2 = Dutch[rand() MOD TDutch]
	text = "jij "+part1+" "+part2+"!"
	RETURN text
END FUNCTION

FUNCTION STRING DubyaQuote()
	SHARED TDubya
	SHARED STRING DubyaQuotes[]


	IF TDubya < 1 THEN
		IFF LoadDubya () THEN RETURN "not today"
	END IF
	
	srand (clock()): srand (GetTickCount())
	RETURN DubyaQuotes[rand() MOD TDubya]
END FUNCTION

FUNCTION STRING Duke()
	SHARED TDuke
	SHARED STRING Duke[]


	IF TDuke < 1 THEN
		IFF LoadDuke () THEN RETURN "not today"
	END IF
	
	srand (clock()): srand (GetTickCount())
	RETURN Duke[rand() MOD TDuke]
END FUNCTION

FUNCTION STRING MOI()
	SHARED TMOI
	SHARED STRING MOI[]
	
	
	IF TMOI < 1 THEN
		IFF LoadMOI () THEN RETURN "not today"
	END IF
	
	srand (clock()): srand (GetTickCount())
	RETURN MOI[rand() MOD TMOI]
END FUNCTION

FUNCTION DispatchDCTMsg (token, STRING msg1, STRING msg2)
	SHARED FUNCADDR DDCTM (XLONG,STRING,STRING)

	IFZ token THEN RETURN 0
	RETURN @DDCTM (token,@msg1,@msg2)
END FUNCTION

FUNCTION CPrint (edit,STRING msg)
	
	'msg = TRIM$(msg)
	IFZ msg THEN RETURN $$FALSE
	DispatchDCTMsg ($$MDCT_PrvTxtMsg,STRING$(edit),@msg) 
END FUNCTION

FUNCTION SetOpList (STRING ops)
	SHARED STRING OpList
	
	IF ops THEN OpList = "$"+ops+"$"
END FUNCTION

FUNCTION IsUserAnOp (STRING nick)
	SHARED STRING OpList
	
	nick = trim(nick,'$')
	IFZ nick THEN RETURN $$FALSE

	IF INSTR (OpList,"$"+nick+"$") THEN
		RETURN $$TRUE
	ELSE
		RETURN $$FALSE
	END IF
END FUNCTION

FUNCTION IsUserConnected (STRING nick)

	'nick = TRIM$(nick)
	IFZ nick THEN RETURN $$FALSE
	RETURN DispatchDCTMsg ($$MDCT_IsUserConnected,@nick,"")
END FUNCTION

FUNCTION SendMsg (STRING msg)

	'msg = TRIM$(msg)
	DispatchDCTMsg ($$MDCT_SendPubTxt,@msg,"")
END FUNCTION

FUNCTION CCmdMsg (STRING touser,STRING msg)

	'msg = TRIM$(msg)
	'touser = TRIM$(touser)
	DispatchDCTMsg ($$MDCT_SendPMsg,@touser,@msg)
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

