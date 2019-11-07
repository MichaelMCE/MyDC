
#if !defined(__mydc_h)     // Sentry, use file only if it's not already included.
#define __mydc_h


typedef unsigned char ubyte;

// message position flags
#define PCCA		4 //250		// start of packet, token id follows
#define PCCB		6 //251		// end of token id, beginning of msg1
#define PCCC		11 //252		// end of msg1, beginning of msg2
#define PCCD		14 //253		// end of msg2, end of packet

#ifndef SOCKET_ERROR
	#define SOCKET_ERROR	-1
#endif

#define MYDCPORT		401			// default port for the MyDC proxy plugin.
#define DEFAULT_SHARE	"147198295245"


#define MAX_STDINBUFF	1024*8		// max stdin input buffer
#define MAX_SBUFF		4024*4		// max byte size of incomming (socket) read buffer
#define MAX_TMSG		100			// max number parsable tokens per pass per read
#define MAX_TPLUGIN		32
#define MAX_NICKLEN		31

#define MDCTH_Error				0
#define MDCTH_HandledStop		1		// MyDc server token handler
#define MDCTH_HandledCont		2
#define MDCTH_UnhandledStop		3
#define MDCTH_UnhandledCont		4

#define DCT_UserCommand			1000
#define DCT_Lock				1100
#define DCT_Hello				1101
#define DCT_HubName				1102
#define DCT_OpList				1103
#define DCT_NickList			1104
#define DCT_MyINFO				1105
#define DCT_MyNick				1106
#define DCT_Direction			1107
#define DCT_Search				1108
#define DCT_Error				1109
#define DCT_HubINFO				1110
#define DCT_Get					1111
#define DCT_Send				1112
#define DCT_HubIsFull			1113
#define DCT_BadPass				1114
#define DCT_SR					1115
#define DCT_Cancel				1116
#define DCT_Canceled			1117
#define DCT_GetNetInfo			1118
#define DCT_Key					1119
#define DCT_ValidateNick		1120
#define DCT_ValidateDenide		1121
#define DCT_MyPass				1122
#define DCT_Supports			1123
#define DCT_GetNickList			1124
#define DCT_GetINFO				1125
#define DCT_MultiSearch			1126
#define DCT_To					1127
#define DCT_ConnectToMe			1128
#define DCT_RevConnectToMe		1129
#define DCT_MultiConnectToMe	1130
#define DCT_Kick				1131
#define DCT_OpForceMove			1132
#define DCT_ForceMove			1133
#define DCT_GetPass				1134
#define DCT_LogedIn				1135
#define DCT_Quit				1136
#define DCT_UserIP				1137
#define DCT_HubTopic			1138
#define DCT_Unknown				1139


#define MDCT_ConnectToAddress	1140		// request a connect[ion] to hub
#define MDCT_Disconnect			1141		// request a disconnect from hub
#define MDCT_GetConSocket		1142		// dispatch current WinSock //socket// handle  message
#define MDCT_GetConnStatus		1143		// dispatch connection status message(s) ie connected, disconnected, connecting or disconnecting.
#define MDCT_ConSocket			1144		// msg1  connection winsock[et] handle
#define MDCT_SendPubTxt			1145		// send public chat message (msg1) to hub, to all
#define MDCT_SendPMsg			1146		// send private chat message (msg2) to person msg1 via hub
#define MDCT_SetMyShareSize		1147		// set share size, in bytes.
#define MDCT_GetMyShareSize		1148		// dispatch share size message
#define MDCT_SetNick			1149		// set first choice nickname, only active upon next connection to hub.
#define MDCT_GetNick			1150		// dispatch nick (msg1) and alt-nick (msg2) message.
#define MDCT_Nick				1151		// nick has been set (msg1)
#define MDCT_GetHubShareTotal 	1152		// dispatch total size of hub share message
#define MDCT_SetHubShareTotal 	1153		// dispatch hub share total message
#define MDCT_HubShareTotal		1154		// hub share message, msg1  total hub share
#define MDCT_MyShareSize		1155		// current share size in bytes

#define MDCT_HubUsers			1158		// msg1  total users on hub

#define MDCT_InitiatingConn		1165
#define MDCT_InitiatingDisconn 	1166

#define MDCT_ClientOpTotal		1171
#define MDCT_ClientOpJoin		1172
#define MDCT_ClientJoin			1105		// ( DCT_MyINFO) a client has joined. note: one join message per client even though some hubs like to send multiple MyINFO messages.
#define MDCT_ClientQuit			1136
#define MDCT_RemoveClients		1173
#define MDCT_PMCmdMsg			1174
#define MDCT_PMTxtMsg			1175
#define MDCT_PubCmdMsg			1176
#define MDCT_PubTxtMsg			1177
#define MDCT_PrvTxtMsg			1170

#define MDCT_Disconnected		1178
#define MDCT_ClientConnected	1179
#define MDCT_ClientCmdMsg		1180
#define MDCT_ClientTxtMsg		1181
#define MDCT_ClientJoinAll		1182
// #define MDCT_CPrint			1183
#define MDCT_PluginLoaded		1184
#define MDCT_PluginUnloaded		1185
// #define MDCT_ConStatus		1186

#define MDCT_SendBin			1187
#define MDCT_SendMsg			1188

#define MDCT_NickListTotal		1190
#define MDCT_NickList			1191
#define MDCT_GetIntNickList		1192
#define MDCT_IntNickList		1193
#define MDCT_GetIntNickListFull 1194

#define MDCT_RequestShutDown	1195
#define MDCT_ShuttingDown		1196

#define MDCT_SendFileSearch		1199
#define MDCT_UnknownCmd			1200

#define MDCT_Plugin				1201
#define MDCT_SetPassword		1202	// set hub password
#define MDCT_GetPassword		1203	// dispatch a password message
#define MDCT_Password			1204	// msg1  password

#define MDCT_Unload				1205	// unload [this] plug-in request

#define MDCT_IsUserConnected	1210
#define MDCT_IsUserAnOp			1211
#define MDCT_GetUserInfoAll		1212
#define MDCT_GetOpList			1213
#define MDCT_UpdateNewPlugin	1215

#define MDCT_Debug				1300
#define MDCT_Error				9999


typedef struct TMessage{
	int			   token;
	unsigned char *msg1;
	unsigned char *msg2;
} TMessage;

typedef struct TMyDCHub{
	unsigned char	 clientAddress[32];	// address of MyDC proxy
	unsigned int	 clientPort;		// port		^^
	unsigned int	 clientSocket;		// socket (fd) of this client to MyDC proxy
	unsigned long int recvMDCT_ID;
	
	unsigned char	 HubName[128];		// hub title as returned by hub 
	unsigned char	 HubAddress[32];	// address of hub currently connected to
	unsigned int	 HubPort;			// port		^^
	
	unsigned char	*HubTitle;			// HubTitle = HubName + HubUsers + HubShare
	int				 THubUsers;			// total users on hub
	float			 THubShare;			// current hub share

	unsigned char 	 myNickName[MAX_NICKLEN+1];	// my nick name on hub
	unsigned char 	 myShareSize[32];	// my share size on hub

	struct TUList	*root;
	struct TUList	*last;
	
	unsigned int	 NickListTotal;		// total names in HubNickList (unreliable but can be used to set THubUsers).
	unsigned char	*HubNickList;		// nick list as received from Hub - without tag info
	unsigned char	*IntNickList;		// MyDC internally cached and parsed user list - with tag info
	unsigned char	*HubOpList;			// parsed op list from HubNickList
	
	unsigned char	*Plugins[MAX_TPLUGIN];	// list of installed MyDC plugins

	int				 connState;			// connection status flag
}TMyDCHub;


TMyDCHub *createMyDC ();
TMyDCHub *destroyMyDC(TMyDCHub *m);

int extractMDCT (unsigned char *sockbuff, int total, TMessage *m, int *mtotal);
int formatMDCT (int token, unsigned char *msg1, unsigned char *msg2, unsigned char *buff);
int sendMDCT (TMyDCHub *m, int token, unsigned char *msg1, unsigned char *msg2);
void recvMDCT (void *p);

ubyte *ifstrdup (unsigned char *d, unsigned char *s);
int ifstrcmp (unsigned char *t1,unsigned char *t2);
int ifstrcpy (unsigned char *d, unsigned char *s);
void ifclose (int *socket);
int strcmp2 (register ubyte *s1,register  ubyte *s2);
int strrep (ubyte *src, int n, int o);
int getstr (ubyte *buffer, int size);
ubyte *strcpycat(ubyte *d, ubyte *s, int dlen, int slen);
ubyte *_strndup (ubyte *s, int n);

void LOG(unsigned char *t);
void LOGi(void *i);
void *ifree (void *p);
int registerCmds ();
void _exit_ ();

void Print2LCD ();
int LCDinit ();

#endif
