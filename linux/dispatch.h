
#if !defined(__dispatch_h)     // Sentry, use file only if it's not already included.
#define __dispatch_h

int dispatchMDCT (TMyDCHub *m, int token, unsigned char *msg1, unsigned char *msg2);

int _MDCT_Disconnected (TMyDCHub *m);
int _MDCT_RequestShutDown (TMyDCHub *m);
int _MDCT_InitiatingConn (TMyDCHub *m, unsigned char *msg);
int _MDCT_InitiatingDisconn (TMyDCHub *m, unsigned char *msg);
int _MDCT_ClientConnected (TMyDCHub *m, unsigned char *msg);
int _MDCT_PubCmdMsg	(unsigned char *msg1, unsigned char *msg2);
int _MDCT_PubTxtMsg	(unsigned char *msg1, unsigned char *msg2);
int _MDCT_PrvTxtMsg (unsigned char *msg1, unsigned char *msg2);
int _MDCT_NickListTotal (TMyDCHub *m, unsigned char *msg);
int _MDCT_IntNickList (TMyDCHub *m, unsigned char *msg1, unsigned char *msg2);
int _MDCT_NickList (TMyDCHub *m, unsigned char *msg1, unsigned char *msg2);
int _MDCT_ClientJoinAll (TMyDCHub *m, unsigned char *msg1, unsigned char *msg2);
int _MDCT_ClientOpJoin (TMyDCHub *m, unsigned char *msg);
int _MDCT_MyShareSize (TMyDCHub *m, unsigned char *msg);
int _DCT_Quit (TMyDCHub *m,unsigned char *msg);
int _MDCT_HubUsers (TMyDCHub *m, unsigned char *msg);
int _MDCT_HubShareTotal (TMyDCHub *m, unsigned char *msg);
int _DCT_HubName (TMyDCHub *m,unsigned char *msg);
int _MDCT_Plugin (TMyDCHub *m,unsigned char *msg);
int _MDCT_PluginLoaded (TMyDCHub *m, unsigned char *msg1, unsigned char *msg2);
int _MDCT_PluginUnloaded (TMyDCHub *m, unsigned char *msg1, unsigned char *msg2);
int _DCT_UserCommand (unsigned char *msg1, unsigned char *msg2);
int _MDCT_PMCmdMsg (unsigned char *msg1, unsigned char *msg2);
int _MDCT_PMTxtMsg (unsigned char *msg1, unsigned char *msg2);


#endif
