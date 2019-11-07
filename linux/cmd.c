
#define WIN32_LEAN_AND_MEAN
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <pthread.h>

#include "mydc.h"
#include "cmd.h"
#include "userlistmanager.h"


TCmd RCmds[MAX_CMDS] = {0};
TCmd *pRCmds = RCmds;
int CmdTotal = 0;

int cmdRegister (unsigned char *cmd, void *pfunc, int state)
{
	if (pfunc == NULL || cmd == NULL){
		LOG("cmdRegister(): invalid function specified");
		return 0;
	}
		
	if (CmdTotal < MAX_CMDS){
		ifstrcpy (pRCmds->cmd,cmd);
		pRCmds->pfunc = pfunc;
		pRCmds->data1 = NULL;
		pRCmds->data2 = NULL;
		pRCmds->state = state;
		pRCmds++;
		return ++CmdTotal;
	}
	else {
		LOG("cmdRegister(): out of RCmd slots");
		return 0;
	}
};

int cmdExecute (TMyDCHub *m, ubyte *cmd, ubyte *msg)
{
	int (*pfunc) (TMyDCHub *m, ubyte *msg) = CmdToAddr(cmd);

	if (pfunc)
		return pfunc(m,msg);
	else
		return 2;
}

void *CmdToAddr (unsigned char *c)
{
	TCmd *pcmd = RCmds;
	int i = 0;
	
	do{
		if (!ifstrcmp(c,pcmd->cmd))
			return pcmd->pfunc;
		else
			pcmd++;
	}
	while (++i < CmdTotal);
	return 0;
};


int cmdCleanUp (TMyDCHub *m)
{
//	printf ("\ncmdCleanUp %i\n",destroyULAll(first));
	//first = NULL;
};

int cmdSetState (unsigned char *cmd, int state)
{
};

int cmdGetState (unsigned char *cmd)
{
};




int cmdConnect (TMyDCHub *m, unsigned char *msg)
{
	if (strlen(msg) < 2) return 1;
	ubyte buff[strlen(msg)+1];
	ubyte Port[strlen(msg)+1];
	int iPort = 0;

	memset (buff,0,sizeof(buff));
	memset (Port,0,sizeof(Port));
	if (!ifstrcpy (buff,msg)) return 1;

	ubyte *Addr = (ubyte *)strtok(buff," :\0");
	if (!Addr) return 1;
	else if (strlen(Addr) < 2) return 1;

	ubyte *tmp = (ubyte *)strtok(NULL,"\0");
	if (tmp) iPort = atoi(tmp);
	if ((iPort<1) || (iPort>65535)) iPort = 411;
	sprintf (Port,"%i\0",iPort);
	
	sendMDCT (m,MDCT_ConnectToAddress,Addr,Port);
	return 1;
};


int cmdProxy (TMyDCHub *m, unsigned char *msg)
{
	if (m->clientSocket != SOCKET_ERROR){		// still connected, disconnect first
		printf ("\ndisconnect before connecting\n");
		return 1;
	}
	
	if (strlen(msg) < 2) return 1;
	ubyte buff[strlen(msg)+1];
	memset (buff,0,sizeof(buff));
	if (!ifstrcpy (buff,msg)) return 1;

	ubyte *Addr = (ubyte *)strtok(buff," :\0");
	if (!Addr)
		return 1;
	else if (strlen(Addr) < 2) return 1;
	ifstrcpy (m->clientAddress,Addr);

	int iPort = 0;
	ubyte *tmp = (ubyte *)strtok(NULL,"\0");
	if (tmp) iPort = atoi(tmp);
	if ((iPort<1) || (iPort>65535)) iPort = 401;
	m->clientPort = iPort;
		
	printf ("\njoining host at %s:%i\n",m->clientAddress, m->clientPort);

	m->clientSocket = connectTo (m->clientAddress, m->clientPort);
	if (m->clientSocket != SOCKET_ERROR){
		printf ("connected to host\n");
		//pthread_attr_t attributes;
		//pthread_attr_init(&attributes);
		RECVMYDC_LOCK ();
		pthread_create ((pthread_t *)&m->recvMDCT_ID, NULL, (void *)recvMDCT, 0);
		RECVMYDC_UNLOCK ();
	}
	else
		printf ("unable to connect\n");

	return 1;
};

int cmdDisconnect (TMyDCHub *m, unsigned char *msg)
{
	sendMDCT (m,MDCT_Disconnect,"","");
	return 1;
};


int cmdPart (TMyDCHub *m, unsigned char *msg)
{
	m->connState = MDCT_Disconnected;
	ifclose (&m->clientSocket);
	return 1;
};

int cmdQuit (TMyDCHub *m, unsigned char *msg)
{
	m->connState = MDCT_Disconnected;
	ifclose (&m->clientSocket);
	return 0;
};

int cmdMe (TMyDCHub *m, unsigned char *msg)
{
	ubyte *me = calloc(1,sizeof(msg)+5);
	me = strcat(me,"!me ");
	me = strcat(me,msg);
	sendMDCT (m,MDCT_SendPubTxt,me,"");
	ifree (me);
	return 1;
};

int cmdPM (TMyDCHub *m, unsigned char *msg)
{
	ubyte *to = NULL, *txt = NULL;
	ubyte *tmp = ifstrdup(NULL,msg);
	if (tmp)
		to = (ubyte *)strtok(tmp," \0");
		if (to)
			txt = (ubyte *)strtok(NULL,"\0");
			if (txt)
				sendMDCT (m,MDCT_SendPMsg,to,txt);
	ifree (tmp);
	return 1;
};

int cmdNick (TMyDCHub *m, unsigned char *msg)
{
	if ((strlen(msg) > 1) && (m->connState != MDCT_Disconnected)){
		ubyte altnick[MAX_NICKLEN+1];
		memset (altnick,0,MAX_NICKLEN+1);

		ubyte *nick1 =(ubyte *)strtok(msg," :");
		ubyte *nick2 =(ubyte *)strtok(NULL," ");
		if (!nick2){
			ifstrcpy (altnick,nick1);
			strcat (altnick,"-");
			nick2 = altnick;
		}

		printf ("nick %s %s\n",nick1,nick2);
		sendMDCT (m,MDCT_SetNick,nick1,nick2);
	}
	return 1;
};

int cmdNickList (TMyDCHub *m, unsigned char *msg)
{
	sendMDCT (m,MDCT_GetIntNickListFull,"","");
	return 1;
};

int cmdShare (TMyDCHub *m, unsigned char *msg)
{
	if (strlen(msg) > 1)
		sendMDCT (m,MDCT_SetMyShareSize,msg,"");
	else
		sendMDCT (m,MDCT_SetMyShareSize,DEFAULT_SHARE,"");
	return 1;
};

int cmdOpList (TMyDCHub *m, unsigned char *msg)
{
	sendMDCT (m,MDCT_GetOpList,"","");
	return 1;
};

int cmdRefresh (TMyDCHub *m, unsigned char *msg)
{
	return 2;
};

int cmdShutdown (TMyDCHub *m, unsigned char *msg)
{
	sendMDCT (m,MDCT_RequestShutDown,"","");
	return 1;
};

int cmdUserList (TMyDCHub *m, unsigned char *msg)
{
	if (!m->root->next) return 1;
	
	TUList *current = m->root->next;
	int i = 0;
	do{
		printf ("%s  ",current->name);
		current = current->next;
		i++;
	}
	while (current);
	printf ("\ntotal %i %i\n",i,ulCount(m->root->next));
	return 1;
};

int cmdUserInfo (TMyDCHub *m,ubyte *msg)
{
	ubyte *list = ifstrdup(NULL,m->IntNickList);
	ubyte *n = list, *i = NULL;
	int ct = 0;

	if (!list){
		LOG("int nicklist empty");
		return 1;
	}
	
	n = (ubyte *)strtok(list,"\5");
	while (n){
		i = (ubyte *)strtok(NULL,"\5");
		if (i){
			printf("%s  %s\n",n,i);
			ct++;
		}
		n = (ubyte *)strtok(NULL,"\5");
	}
	
	printf ("%i total\n",ct);
	ifree (list);
	return 1;
}

#define min(a, b) ((a) < (b) ? (a) : (b))

int cmdTest (TMyDCHub *m)
{
	printf ("count %i\n",ulCount(m->root->next));
	printf ("sortforward %i\n",ulSortForward(m, m->root->next));

	return 1;
}

