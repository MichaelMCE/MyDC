
// MyDC proxy proof of concept for Linux

	/* compile:
	 * gcc -o mydc mydc.c dispatch.c net.c cmd.c lock.c userlistmanager.c
	 * gcc mydc.o dispatch.o net.o cmd.o lock.o userlistmanager.o -O -o mydc -lpthread 
	 */

/* Michael McElligott */

#define WIN32_LEAN_AND_MEAN
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <pthread.h>


#include "mydc.h"
#include "userlistmanager.h"
#include "net.h"
#include "dispatch.h"
#include "cmd.h"
#include "lock.h"
//#include "../lcd/lcd.h"

TMyDCHub *mydc;
ubyte *msgbuff = NULL;
//int LCDStatus = 0;


int main(int argc, char *argv[])
{
	LOG ("\tMyDC by Michael McElligott  25/03/2005\n");

	//ifree(malloc(1024*1024*5));
	
	atexit(_exit_);
	//LCDStatus = LCDinit();
	registerCmds();
	initSocket();
	TMYDCHUB_LOCK_CREATE ();
	RECVMYDC_LOCK_CREATE ();

	mydc = createMyDC();

	ubyte buffer[MAX_STDINBUFF+1];
	int state = 1;
	do{
	 	// delete previous command
		memset(buffer,0,MAX_STDINBUFF+1);

		if (getstr(buffer,MAX_STDINBUFF)){
			// check if it's a command
			if ((buffer[0] == '/') && (buffer[1] != 0)){  // fix me
				ubyte *msg = (ubyte *)strtok(buffer,"/");
				if (msg[0] != 0){
					TMYDCHUB_LOCK ();
					state = commandProcesser(mydc,msg);
					TMYDCHUB_UNLOCK ();
				}
			}
			else{
			// is not a command, send to host as hub chat
				TMYDCHUB_LOCK ();
				sendMDCT(mydc,MDCT_SendPubTxt,buffer,"");
				TMYDCHUB_UNLOCK ();
			}
		}
	}
	while (state);

	RECVMYDC_LOCK ();
    RECVMYDC_LOCK_DELETE();
	TMYDCHUB_LOCK ();
    TMYDCHUB_LOCK_DELETE ();
    cmdCleanUp (mydc);
    //if (LCDStatus) LCD_CLOSE ();
    ifree(msgbuff);
	mydc = destroyMyDC(mydc);
    exit(EXIT_SUCCESS);
};


void Print2LCD (ubyte *msg1, ubyte *msg2)
{
	//if (LCDStatus) PrintLCD (msg1,msg2);
};

int LCDinit ()
{
	/*
	int ret;
	if (ret = LCD_OPEN(0x378)){
		ClearLCD ();
		LoadBmp ("m.bmp",0);
		RefreshLCD();
	}
	return ret;
	*/
	return 1;
}

void _exit_ ()
{
	LOG(" _exit_()");
	//system ("");
};


int commandProcesser (TMyDCHub *m, unsigned char *text)
{
	if (!strlen(text)) return 1;
	
	ubyte cmd[strlen(text)+1];
	ubyte msg[strlen(text)+1];
	memset (cmd,0,sizeof(cmd));
	memset (msg,0,sizeof(msg));
	ifstrcpy (cmd,(char *)strtok(text," \0"));
	ifstrcpy (msg,(char *)strtok(NULL,"\0"));
	if (!strlen(msg)) ifstrcpy (msg," \0");

	switch (cmdExecute(m, cmd, msg)){
		case 0		:return 0;		// cmd found, quit status returned
		case 1		:return 1;		// cmd found, continue status returned
		default		:				// cmd not found - pass to host for processing
			sendMDCT (m,MDCT_ClientCmdMsg,cmd,msg);
			return 1;
	};
}


int registerCmds ()
{
	// cmd::Regsiter (blah blah)
	cmdRegister ("quit",cmdQuit,1);
	cmdRegister ("part",cmdPart,1);
	cmdRegister ("connect",cmdConnect,1);
	cmdRegister ("disconnect",cmdDisconnect,1);
	cmdRegister ("me",cmdMe,1);
	cmdRegister ("msg",cmdPM,1);
	cmdRegister ("pm",cmdPM,1);
	cmdRegister ("nick",cmdNick,1);
	cmdRegister ("share",cmdShare,1);
	cmdRegister ("oplist",cmdOpList,1);
	cmdRegister ("shutdown",cmdShutdown,1);
	cmdRegister ("nicklist",cmdNickList,1);
	cmdRegister ("refresh",cmdRefresh,1);
	cmdRegister ("proxy",cmdProxy,1);
	cmdRegister ("join",cmdProxy,1);
	cmdRegister ("userlist",cmdUserList,1);
	cmdRegister ("userinfo",cmdUserInfo,1);
	
	cmdRegister ("test",cmdTest,1);
	return 1;
};

void recvMDCT (void *p)
{
    int ct = 0, mtotal = MAX_TMSG;
    int bytesRecv = 0, ret = 0;
    char sockbuff[MAX_SBUFF];
    TMessage msg[MAX_TMSG];
    TMessage *tk = NULL;
	int clientSocket = SOCKET_ERROR;
	
    TMYDCHUB_LOCK ();
	clientSocket = mydc->clientSocket;
	TMYDCHUB_UNLOCK ();
	
	if (clientSocket == SOCKET_ERROR){
		LOG("::: recvMDCT() exited: socket not ready");
		pthread_exit(0);
	}
	
    RECVMYDC_LOCK ();
    do {
    	memset(sockbuff,0,sizeof(sockbuff));
		bytesRecv = readSocket(clientSocket,sockbuff, sizeof(sockbuff)-1);

		if ((bytesRecv != SOCKET_ERROR) && (bytesRecv != 0)) {
			ret = 0;
			do {
				tk = msg;
				mtotal = MAX_TMSG;

				if (ret == -1)
					ret = extractMDCT(NULL,0,tk,&mtotal);
				else
					ret = extractMDCT(sockbuff,bytesRecv,tk,&mtotal);

				for (ct = 0; ct<mtotal; ct++,tk++) {
					if (tk->token){
						TMYDCHUB_LOCK ();
						dispatchMDCT (mydc, tk->token, tk->msg1,tk->msg2);
						TMYDCHUB_UNLOCK ();
						tk->msg1 = ifree(tk->msg1);
						tk->msg2 = ifree(tk->msg2);
						tk->token = 0;
					}
				}
			} while (ret == -1);
		} else break;
    }
    while ((bytesRecv != SOCKET_ERROR) && (bytesRecv != 0));

	TMYDCHUB_LOCK ();
	ifclose (&mydc->clientSocket);
	TMYDCHUB_UNLOCK ();

	LOG("::: recvMDCT() exited");
	RECVMYDC_UNLOCK();
	pthread_exit(0);
}

int extractMDCT (ubyte *buff, int total, TMessage *m, int *mtotal)
{
	int iPCCA = 0, iPCCB = 0, iPCCC = 0, iPCCD = 0;
	static unsigned int msgbuffs = 0;
	int readFromTokenBuffer = 0;
	

  	if (total){
  		// add string buff to msgbuff
		if (msgbuffs){
			ubyte *tmp = strcpycat(msgbuff,buff,msgbuffs,total);
			ifree (msgbuff);
			msgbuff = tmp;

			total += msgbuffs;
			msgbuffs = total;
			readFromTokenBuffer = 0;
		} else {
			msgbuff = buff;
			msgbuffs = total;
			readFromTokenBuffer = 1;
		}
	} else{
  		total = msgbuffs;
  		msgbuff = msgbuff;
  		readFromTokenBuffer = 0;
  	}

	int count, flag = 0, cttotal = 0;
	for (count = 0;(count <= total) && (cttotal <= *mtotal);count++) {
		switch (msgbuff[count]) {
			case PCCA:
				if (flag != 0) break;
				flag = PCCB;
				iPCCA = count+1;
				break;

			case PCCB:
				if (flag != PCCB) break;
				flag = PCCC;
				iPCCB = count+1;
				break;
				
			case PCCC:
				if (flag != PCCC) break;
				flag = PCCD;
				iPCCC = count+1;
				break;
				
			case PCCD:
				if (flag != PCCD) {
					flag = 0;
					break;
				}
				else
					iPCCD = count+1;

				m->token = atoi(&msgbuff[iPCCA]);
				if ((m->token > 0) && (iPCCC-iPCCB > 0) && (iPCCD-iPCCC > 0)){
					m->msg1 = (ubyte *)malloc(iPCCC-iPCCB);
					m->msg2 = (ubyte *)malloc(iPCCD-iPCCC);
					memcpy (m->msg1,&msgbuff[iPCCB],(iPCCC-iPCCB)-1);
					memcpy (m->msg2,&msgbuff[iPCCC],(iPCCD-iPCCC)-1);
					m->msg1[(iPCCC-iPCCB)-1] = 0;
					m->msg2[(iPCCD-iPCCC)-1] = 0;
					//strncpy (m->msg1,&msgbuff[iPCCB],(iPCCC-iPCCB)-1);
					//strncpy (m->msg2,&msgbuff[iPCCC],(iPCCD-iPCCC)-1);
					cttotal++;
					m++;
				}
				else
					m->token = 0;

				// reset flags for next message
				iPCCA = 0;
				iPCCB = 0;
				iPCCC = 0;
				iPCCD = 0;
				flag = 0;
				break;
		}
	}

	if (count < total) iPCCA = count;
	*mtotal = cttotal;
	
	if ((iPCCA != 0) && (msgbuff != NULL)) {	
		ubyte *tmp = (ubyte *)_strndup(&msgbuff[iPCCA-1],total-iPCCA+1);
		if (!readFromTokenBuffer) ifree(msgbuff);
		
		msgbuff = tmp;
		msgbuffs = total-iPCCA+1;
		if (count < total)
			return -1;		// not enough TMessage space
		else
			return 0;		// unprocessed message remains
	}
	else {
		if (!readFromTokenBuffer) ifree(msgbuff);
		msgbuff = NULL;
		msgbuffs = 0;
		return 1;		// message queue is processed + empty.
	}
}

TMyDCHub *destroyMyDC (TMyDCHub *m)
{
	if (m) {
		printf ("\nulDestroyAll %i\n",ulDestroyAll(m->root));
		ifree(m->HubTitle);
		ifree(m->HubOpList);
		ifree(m->HubNickList);
		ifree(m->IntNickList);
		int i = 0;
		for (i;i<MAX_TPLUGIN;i++)
			ifree(m->Plugins[i]);
		
		m = ifree (m);
		return m;
	}
	else
		return NULL;
};

TMyDCHub *createMyDC ()
{
	TMyDCHub *m = calloc(1,sizeof(TMyDCHub));
	//memset (m,0,sizeof(TMyDCHub));

	m->clientSocket = SOCKET_ERROR;
	m->root = m->last = newUList ("\0\0");
	return m;
};

int sendMDCT (TMyDCHub *m, int token, unsigned char *msg1, unsigned char *msg2)
{
	int len = strlen(msg1)+strlen(msg2)+100;
	ubyte buffer[len]; // 5 = PCCA/D + \0;
	memset (buffer,0,len);
	if (formatMDCT(token, msg1, msg2, buffer) > 5)
		return sendSocket (m->clientSocket,buffer,&len);
	else
		return 0;
}

int formatMDCT (int token, unsigned char *msg1, unsigned char *msg2, unsigned char *buff)
{
	sprintf (buff,"%c%i%c%s%c%s%c\0",PCCA,token,PCCB,msg1,PCCC,msg2,PCCD);
	return strlen(buff);
}

void LOG(unsigned char *t)
{
	puts(t);
	fflush (stdout);
};

void LOGi(void *i)
{
	printf("%i\n",i);
	fflush (stdout);
};

void *ifree (void *p)
{
	//assert (p);
	if (p) free (p);
	return NULL;
};

ubyte *ifstrdup (unsigned char *d, unsigned char *s)
{
	if (s == NULL)
		return NULL;
	else {
		ifree (d);
		d = (ubyte *)strdup(s);
		return d;
	}
};

int ifstrcpy (unsigned char *d, unsigned char *s)
{
	if ((d == NULL) || (s == NULL))
		return 0;
	else {
		//if (strlen(d) < strlen (s)) {
			strcpy (d,s);
			return 1;
		//}
		//else
			//return 0;
	}
};

int ifstrcmp (unsigned char *t1, unsigned char *t2)
{
	if ((t1 == NULL) || (t2 == NULL)) return 2;
	if (strlen(t1) != strlen(t2)) return 1;
	return strncmp(t1,t2,strlen(t1));
}

void ifclose (int *socket)
{
	if ((*socket != 0) && (*socket != SOCKET_ERROR)){
		closeSocket (*socket);
		*socket = SOCKET_ERROR;
		LOG("::: socket closed");
	}
};


int strrep (ubyte *src, int n, int o)
{
	ubyte *tmp = src;
	int ct = 0;

	do{
		if (*tmp == o) *tmp = n;
		tmp++;
		ct++;
	} while (*tmp != 0);
	return ct;
};

int getstr (ubyte *buffer, int size)
{
	char *pbuff = buffer;
	int ch = 0;

	while ((ch=getchar()) != '\n') {
		if (((unsigned int)pbuff-(unsigned int)buffer)< size){
			*pbuff = ch;
			pbuff++;
		} else break;
	}
	return (unsigned int)pbuff-(unsigned int)buffer;
};

ubyte *strcpycat(ubyte *d, ubyte *s, int dlen, int slen)
{
	ubyte *tmp = (ubyte *)malloc(dlen+slen+1);
	memcpy (tmp,d,dlen);
	memcpy (tmp+dlen,s,slen);
	tmp[dlen+slen] = 0;
	return tmp;
};

ubyte *_strndup (ubyte *s, int n)
{
	#ifndef _WIN32
		return (ubyte *)strndup(s,n);
	#else
		ubyte *d = (ubyte *)malloc(n+1);
		memcpy (d,s,n);
		d[n] = 0;
		return d;
	#endif
};


int strcmp2 (register ubyte *s1, register  ubyte *s2)
{
	while (*s1 == *s2++)
		if (*s1++ == 0) return (0);
	
	return (*s1 - *(--s2));
};
