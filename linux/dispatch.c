
#define WIN32_LEAN_AND_MEAN
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

#include "mydc.h"
#include "dispatch.h"
#include "userlistmanager.h"


// process one token
int dispatchMDCT (TMyDCHub *m, int token, unsigned char *msg1, unsigned char *msg2)
{

	//printf ("\n-%i- -%s- -%s-\n",token,msg1,msg2);

	switch (token) {
		case MDCT_InitiatingConn		: _MDCT_InitiatingConn (m, msg2); break;
		case MDCT_InitiatingDisconn		: _MDCT_InitiatingDisconn (m, msg1); break;
		case MDCT_Disconnected			: _MDCT_Disconnected (m); break;
		case MDCT_RequestShutDown		:break;
		case MDCT_ClientConnected		: _MDCT_ClientConnected (m, msg2); break;
		case DCT_Search					:break;
		case DCT_SR						:break;
		case MDCT_PubCmdMsg				: _MDCT_PubCmdMsg (msg1,msg2); break;
		case MDCT_PrvTxtMsg				: _MDCT_PrvTxtMsg (msg1,msg2); break;
		case MDCT_PubTxtMsg				: _MDCT_PubTxtMsg (msg1,msg2); break;
		case MDCT_PMTxtMsg				: _MDCT_PMTxtMsg (msg1,msg2); break;
		case MDCT_PMCmdMsg				: _MDCT_PMCmdMsg (msg1,msg2); break;
		case MDCT_SendPMsg				:break;
		case MDCT_NickList				: _MDCT_NickList (m, msg1,msg2); break;
		case MDCT_ClientJoinAll			: _MDCT_ClientJoinAll (m,msg1,msg2); break;
		case DCT_Quit					: _DCT_Quit (m,msg1); break;
		case MDCT_NickListTotal			: _MDCT_NickListTotal (m, msg1); break;
		case MDCT_HubShareTotal			: _MDCT_HubShareTotal	(m, msg1); break;
		case MDCT_HubUsers				: _MDCT_HubUsers (m, msg1); break;
		case DCT_HubName				: _DCT_HubName(m, msg1); break;
		case MDCT_MyShareSize			: _MDCT_MyShareSize (m, msg1); break;
		case MDCT_ClientOpJoin			: _MDCT_ClientOpJoin (m, msg1); break;
		case MDCT_IntNickList			: _MDCT_IntNickList (m, msg1,msg2); break;
		case MDCT_Plugin				: _MDCT_Plugin (m, msg2); break;
		case MDCT_PluginLoaded			: _MDCT_PluginLoaded (m, msg1, msg2); break;
		case MDCT_PluginUnloaded		: _MDCT_PluginUnloaded (m, msg1, msg2); break;
		case MDCT_Error					:break;
		case MDCT_Debug					:break;
		case MDCT_UnknownCmd			:break;
		case DCT_UserCommand			: _DCT_UserCommand (msg1,msg2); break;
		case DCT_Unknown				: _MDCT_PubTxtMsg (msg1,msg2); break;
		case DCT_HubINFO				:break;
	}
	
	fflush(stdout);
	return 0;
};


int _DCT_UserCommand (unsigned char *msg1, unsigned char *msg2)
{
	printf(":::: %s %s\n",msg1,msg2);
};

int _MDCT_InitiatingConn (TMyDCHub *m, unsigned char *msg)
{
	m->connState = MDCT_InitiatingConn;
	printf ("Connecting to: %s\n",msg);
};

int _MDCT_InitiatingDisconn (TMyDCHub *m, unsigned char *msg)
{
	m->connState = MDCT_InitiatingDisconn;
	printf ("Disconnecting from Hub ....\n");
};

int _MDCT_Disconnected (TMyDCHub *m)
{
	m->connState = MDCT_Disconnected;
	printf ("Disconnected from Hub\n");
};

int _MDCT_RequestShutDown (TMyDCHub *m)
{
	m->connState = MDCT_RequestShutDown;
	printf ("Disconnected from MyDC Proxy\n");
};

int _MDCT_ClientConnected (TMyDCHub *m, unsigned char *msg)
{
	ubyte *buff = (char *)strdup (msg);
	ifstrcpy (m->myNickName,(char *)strtok(buff,":"));
	ifstrcpy (m->HubAddress,(char *)strtok(NULL,":"));
	m->HubPort = atoi((char *)strtok (NULL,":"));
	m->connState = MDCT_ClientConnected;
	printf ("Connected as %s on %s:%i\n",m->myNickName,m->HubAddress,m->HubPort);
	ifree (buff);
};

int _MDCT_PubCmdMsg	(unsigned char *msg1, unsigned char *msg2)
{
	printf ("(%s) %s\n",msg1,msg2);
	//Print2LCD (msg1,msg2);
};

int _MDCT_PrvTxtMsg (unsigned char *msg1, unsigned char *msg2)
{
	printf ("PrvM: %s\n",msg2);
	//Print2LCD (msg2,"");
};

int _MDCT_PubTxtMsg	(unsigned char *msg1, unsigned char *msg2)
{
	printf ("(%s) %s\n",msg1,msg2);
	ubyte text[strlen(msg1)+2];
	//sprintf (text,"(%s)",msg1);
	//Print2LCD (text,"");
	//Print2LCD ("  ",msg2);
};

int _MDCT_PMTxtMsg (unsigned char *msg1, unsigned char *msg2)
{
	printf ("PM: (%s) %s\n",msg1,msg2);
	//Print2LCD (msg1,msg2);
};

int _MDCT_PMCmdMsg (unsigned char *msg1, unsigned char *msg2)
{
	printf ("PM: (%s) %s\n",msg1,msg2);
	//Print2LCD (msg1,msg2);
};

int _MDCT_ClientJoinAll (TMyDCHub *m, unsigned char *msg1, unsigned char *msg2)
{
	TUList *u;
	if (!ulSearch(m->root,msg1))
		if (u = ulAddUserSorted(m->root->next,msg1)){
			if (u->prev == m->last) m->last = u;
			//printf ("Join: %s\n",msg1);
		}
		else
			printf ("\nunable to add user: %s\n",msg1);
};

int _DCT_Quit (TMyDCHub *m,unsigned char *msg)
{
	if (!ulRemoveUser(m,msg)){
	//	printf ("Quit: %s\n",msg);
	//else
		printf ("unable to remove user %s\n",msg);
	};
};

int _MDCT_HubShareTotal (TMyDCHub *m, unsigned char *msg)
{
	m->THubShare = (float)atof(msg);
	// printf ("Hub share: %4.2f Tb\n",m->THubShare);
};

int _DCT_HubName (TMyDCHub *m, unsigned char *msg)
{
	ifstrcpy (m->HubName,msg);
	printf ("Hub title: %s\n",m->HubName);
};

int _MDCT_MyShareSize (TMyDCHub *m, unsigned char *msg)
{
	ifstrcpy (m->myShareSize,msg);
	printf ("Share set to: %s\n",m->myShareSize);
};
	
int _MDCT_ClientOpJoin (TMyDCHub *m, unsigned char *msg)
{
	m->HubOpList = ifstrdup (m->HubOpList,msg);
	printf ("Operators are:%s\n",m->HubOpList);
	ulUpdateOps(m->root->next,msg);
};

int _MDCT_NickListTotal (TMyDCHub *m, unsigned char *msg)
{
	m->THubUsers = atoi((char *)msg);
};

int _MDCT_HubUsers (TMyDCHub *m, unsigned char *msg)
{
	m->THubUsers = atoi((char *)msg);
};

int _MDCT_NickList (TMyDCHub *m, unsigned char *msg1, unsigned char *msg2)
{
	ulDestroyNext(m->root->next);
	m->HubNickList = ifstrdup (m->HubNickList,msg1);
	m->THubUsers = atoi((char *)msg2);
	m->root->next = m->root->prev = (TUList *)0;
	m->last = m->root;

	printf ("%i users on hub\n",ulAddHubNickListSorted(&m->last,m->HubNickList,m->THubUsers));
};

int _MDCT_IntNickList (TMyDCHub *m, unsigned char *msg1, unsigned char *msg2)
{
	m->IntNickList = ifstrdup(m->IntNickList,msg1);
	m->THubUsers = atoi((char *)msg2);

	printf("\ninternal nicklist %i\n",m->THubUsers);
};

int _MDCT_Plugin (TMyDCHub *m, unsigned char *msg)
{
	int ct = 0;
	for (ct = 0;ct<MAX_TPLUGIN;ct++) {
	  if (m->Plugins[ct] != NULL) {
		if (strcmp (m->Plugins[ct],msg) == 0 ){
			printf ("Plugin %s\n",m->Plugins[ct]);
			return 0;
		}
	  }
	}

	for (ct = 0;ct<MAX_TPLUGIN;ct++) {
		if (m->Plugins[ct] == NULL) {
			m->Plugins[ct] = (char *)strdup(msg);
			printf ("Plugin %s\n",m->Plugins[ct]);
			return 1;
		}
	}
	return 0;
};

int _MDCT_PluginUnloaded (TMyDCHub *m, unsigned char *msg1, unsigned char *msg2)
{
	int i = 0;
	ubyte *tmp1;

	for (i = 0;i<MAX_TPLUGIN;i++) {
		if (m->Plugins[i]){
			tmp1 = (char *)strdup(m->Plugins[i]);
			if (atoi((unsigned char *)strtok(tmp1,":")) == atoi(msg2)){
				printf ("Plugin unloaded: #%s\n",m->Plugins[i]);
				ifree(m->Plugins[i]);
				ifree (tmp1);
				return 1;
			}
			ifree (tmp1);
		};
	}
	return 0;
};

int _MDCT_PluginLoaded (TMyDCHub *m, unsigned char *msg1, unsigned char *msg2)
{
	int ct = 0;
	ubyte *tmp1, *tmp2;
	
	for (ct = 0;ct<MAX_TPLUGIN;ct++) {
		if (m->Plugins[ct] == NULL) {
			tmp2 = (unsigned char *)strdup(msg2);
			tmp1 = strcat ((unsigned char *)strtok(tmp2,":"),":");
			m->Plugins[ct] = strcat(tmp1,msg1);
			printf ("Plugin %s\n",m->Plugins[ct]);
			return 1;
		}
	}
	return 0;
};

