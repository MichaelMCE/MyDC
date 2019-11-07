
#if !defined(__cmd_h)     // Sentry, use file only if it's not already included.
#define __cmd_h

#define MAX_CMDS	32
#define MAX_CMDLEN	32


typedef struct {
	unsigned char cmd[MAX_CMDLEN+1];
	int (*pfunc) (TMyDCHub *m, unsigned char *msg);		// pointer to function
	void *data1;		// storage for cmd
	void *data2;
	int	 state;			// cmd state, ie, enabled or disabled
}TCmd;

int cmdRegister (unsigned char *cmd,void *pfunction, int state);
int cmdExecute (TMyDCHub *m, unsigned char *cmd, unsigned char *msg);
int cmdCleanUp (TMyDCHub *m);
int cmdSetState (unsigned char *cmd, int state);
int cmdGetState (unsigned char *cmd);

int cmdConnect (TMyDCHub *m, unsigned char *msg);
int cmdDisconnect (TMyDCHub *m, unsigned char *msg);
int cmdQuit (TMyDCHub *m, unsigned char *msg);
int cmdPart (TMyDCHub *m, unsigned char *msg);
int cmdMe (TMyDCHub *m, unsigned char *msg);
int cmdPM (TMyDCHub *m, unsigned char *msg);
int cmdNick (TMyDCHub *m, unsigned char *msg);
int cmdShare (TMyDCHub *m, unsigned char *msg);
int cmdOpList (TMyDCHub *m, unsigned char *msg);
int cmdNickList (TMyDCHub *m, unsigned char *msg);
int cmdShutdown (TMyDCHub *m, unsigned char *msg);
int cmdRefresh (TMyDCHub *m, unsigned char *msg);
int cmdProxy (TMyDCHub *m, unsigned char *msg);
int cmdUserList (TMyDCHub *m, unsigned char *msg);
int cmdUserInfo (TMyDCHub *m, unsigned char *msg);

void *CmdToAddr (unsigned char *c);

int cmdTest (TMyDCHub *m);



#endif
