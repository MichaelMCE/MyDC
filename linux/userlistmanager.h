
#if !defined(__userlistmanager_h)     // Sentry, use file only if it's not already included.
#define __userlistmanager_h


typedef struct TUList{
	//status: 1 enabled  - contains valid data, 0 disabled - invalid struct.
	/* int			status; */
	//op: is user an op; 1 yes, 0 no.
	int			op;
	ubyte		name[MAX_NICKLEN+1];
	ubyte		share[16];
	ubyte		comment[64];
	ubyte		connection[16];
	ubyte		email[32];

	struct TUList *prev, *next;
}TUList;


void ulLink (TUList *ul,TUList *p,TUList *n);
void ulUnLink (TUList *ul);
int ulSwap (register TUList *p, TUList *n);

TUList *newUList (ubyte *name);
TUList *ulAddUser (TUList *u, ubyte *name);
TUList *ulFindUser (TUList *u, ubyte *name);
TUList *ulGetLastLink (TUList *u);
TUList *ulAddUserSorted (TUList *u, ubyte *name);

int ulDestroy (TUList *ul);
int ulDestroyAll (TUList *ul);
int ulDestroyPrev (TUList *ul);
int ulDestroyNext (TUList *l);

int ulCmpare (TUList *u1, TUList *u2);
int ulSearch (TUList *u, ubyte *name);

int ulAddHubNickList (TMyDCHub *m, ubyte *list, int total);
int ulAddHubNickListSorted (TUList **here, ubyte *list, int total);

int ulUpdateOps (TUList *u, ubyte *msg);
int ulResetOps (TUList *u);

int ulRemoveUser (TMyDCHub *m, ubyte *name);
int ulCount (TUList *u);
int ulSortForward (TMyDCHub *m, TUList *u);
int ulSortBack (TMyDCHub *m, TUList *u);
int ulQSortForward (TMyDCHub *m, TUList *u);
int ulQSort_Callback (ubyte **s1, ubyte **s2);



#endif
