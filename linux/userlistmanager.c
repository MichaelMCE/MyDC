
#define WIN32_LEAN_AND_MEAN
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

#include "mydc.h"
#include "userlistmanager.h"


/*	create a user object
*/
TUList *newUList (ubyte *name)
{
	TUList *u = (TUList *)malloc(sizeof(TUList));
	if (!u) return (TUList *)0;

	memset (u,0,sizeof(TUList));
	ifstrcpy (u->name,name);
/*
	u->status = 0;
	u->op = 0;
	u->name[0] = 0;
	u->share[0] = 0;
	u->comment[0] = 0;
	u->email[0] = 0;
*/
	return u;
};

/*	link u between n and p
*/
void ulLink (TUList *u, TUList *p, TUList *n)
{
	if (p){
		u->prev = p;
		p->next = u;
	}
	else
		u->prev = (TUList *)0;
	
	if (n){
		u->next = n;
		n->prev = u;
	}
	else
		u->next = (TUList *)0;
};

/*	swap p and n
*/
int ulSwap (TUList *p, TUList *n)
{
//	if ((!p) || (!n)) return 0;
	
/*
	if (p->prev == n) LOG ("p->prev == n");
	if (p->next == n) LOG ("p->next == n");
	if (n->prev == p) LOG ("n->prev == p");
	if (n->next == p) LOG ("n->next == p");
*/	
	if ((p->prev == n) || (p->next == n) || (n->prev == p) || (n->next == p)){
		TUList *tmp;
		if (p->next != n){
			tmp = p;
			p = n;
			n = tmp;
		}
	
		tmp = p->prev;
		if (p->prev) p->prev->next = n;
		p->prev = n;
		p->next = n->next;	
	
		if (n->next) n->next->prev = p;
		n->prev = tmp;
		n->next = p;
		return 1;
	}
	else {
		TUList *pn = p->next;
		TUList *pp = p->prev;
		ulLink (p,n->prev,n->next);
		ulLink (n,pp,pn);
		if (n->prev) n->prev->next = n;
		if (p->next) p->next->prev = p;
		return 1;
	}
};

/*	remove u from list and link adjacent links to each other
*/
void ulUnLink (TUList *u)
{
	if (u->next) u->next->prev = u->prev;
	if (u->prev) u->prev->next = u->next;
	u->prev = (TUList *)0;
	u->next = (TUList *)0;
};

/*	delete this user and free its resources
*/
int ulDestroy (TUList *u)
{
	if (u){
		ifree (u);
		return 1;
	}
	else
		return 0;
};

/*	delete this and all users to the right
*/
int ulDestroyNext (TUList *u)
{
	if (!u) return 0;
	TUList *next = u;
	TUList *n;

	int i = 0;
	do
	{
		n = next->next;
		ulDestroy (next);
		next = n;
		i++;
	}
	while (next);
	return i;
};

/*	delete this and all users to the left
*/
int ulDestroyPrev (TUList *u)
{
	if (!u) return 0;
	TUList *prev = u;
	TUList *p;

	int i = 0;
	do
	{
		p = prev->prev;
		ulDestroy (prev);
		prev = p;
		i++;
	}
	while (prev);
	return i;
};

/*	delete every user
	returns total users (objects) deleted
*/
int ulDestroyAll (TUList *u)
{
	if (!u) return 0;
	int c = ulDestroyPrev(u->prev) + ulDestroyNext(u->next);
	c += ulDestroy (u);
	return c;
};

/*	compare name of user u1 with user u2
	returns:
	<0 if u1 is less than u2
	0 if u1 equals u2
	>0 if u1 is greater than u2
*/
int ulCmpare (TUList *u1, TUList *u2)
{
	if ((!u1) || (!u2)) return 2;
	return strcmp2(u1->name,u2->name);
};

/*	create new user list from buffer
	names in buffer are seperated \5
*/
int ulAddHubNickList (TMyDCHub *m, ubyte *list, int total) // ,sep)
{
	if (!list){
		LOG("[ulAddHubNickList empty");
		return 0;
	}

/*
	this should be performed before entry
	//ulDestroyNext(m->root->next);
	//m->last = m->root;
	//m->last->next = m->last->prev = (TUList *)0;
*/
	TUList *u;
	ubyte *n = ifstrdup(NULL,list);
	ubyte *name = (ubyte *)strtok(n,"\5");

	int i = 0;
	while (name){
		if (u = ulAddUser(m->last,name)){
			if (u->prev == m->last) m->last = u;
			i++;
		}
		name = (ubyte *)strtok(NULL,"\5");
	}
	ifree (n);
	return i;
};

/*	create and add user to list
*/
TUList *ulAddUser (TUList *u, ubyte *name)
{
	if ((!u) || (!name)) return (TUList *)0;
	
	TUList *current = newUList(name);
	if (current){
		ulLink (current,u,u->next);
		return current;
	}
	else
		return (TUList *)0;
};

/*	removes a user from list
*/
int ulRemoveUser (TMyDCHub *m, ubyte *name)
{
	if (!name) return 0;
	
	TUList *current = m->root->next;
	do{
		if (current->name[0] == name[0])
			if (!strcmp2(current->name,name)){
				if (current == m->last) m->last = current->prev;
				ulUnLink (current);
				return 1;
			}
		current = current->next;
	}
	while (current);
	
	return 0;
};

/*	search for a user, return 1 if exists
*/
int ulSearch (TUList *u, ubyte *name)
{
	if ((!u) || (!name)) return -1;
	
	TUList *current = u;
	do{
		if (current->name[0] == name[0])
			if (!strcmp2(current->name,name)) return 1;
		current = current->next;
	}
	while (current);
	return 0;
};


TUList *ulFindUser (TUList *u, ubyte *name)
{
	if (!u) return(TUList *)0;
	
	TUList *current = u;
	do{
		if (current->name[0] == name[0])
			if (!strcmp2(name,current->name)) return current;
		
	}
	while (current = current->next);
	return (TUList *)0;
};

/*	count total number of users to the right
	and including u
*/
int ulCount (TUList *u)
{
	if (!u) return -1;
	
	int i = 1;
	TUList *current = u;
	while (current = current->next)
		i++;
	return i;
};

/*	perform a complete exchange sort
	sorting backwards from u
*/
int ulSortBack (TMyDCHub *m, TUList *u)
{
	if (!u) return -1;
	
	int exchange, total = 0;
	TUList *current;
	do{
		exchange = 0;
		current = u;
		do{
			if (current->prev){
				if (strcmp(current->name,current->prev->name) == -1){
					ulSwap(current,current->prev);
					exchange = 1;
					total++;
				}
			}
			current = current->prev;
		}
		while (current);
	}
	while (exchange);
	return total;
};

/*	perform a complete exchange sort
	sorting forward from u to last
*/
int ulSortForward (TMyDCHub *m, TUList *u)
{
	if (!u) return -1;
	
	int exchange, total = 0;
	register TUList *current,*p,*n;
	TUList *tmp;

	do{
		exchange = 0;
		current = u;
		do{
			if (current->name[0] > current->next->name[0]){
				if (strcmp(current->name,current->next->name)){
					ulSwap(current,current->next);
					exchange = 1;
					total++;
				}
			}
			current = current->next;
		}
		while ((current) && (current->next));
	}
	while (exchange);
	
	m->last = ulGetLastLink(m->root);
	return total;
};

/*	return last user in list beginning at u
*/
TUList *ulGetLastLink(TUList *u)
{
	TUList *n = u;
	do{
		if (!n->next) return n;
		n = n->next;
	}
	while (n);
	
	LOG("\nulGetLastLink() error: last link not found");
};

/*	create and add then sort user in to position
*/
TUList *ulAddUserSorted (TUList *u, ubyte *name)
{
	if ((!u) || (!name)) return (TUList *)0;
	
	TUList *current = u;
	TUList *n;

	do
		if (name[0] > current->name[0]) break;
	while (current = current->next);

	if (!current) current = u; //return 0;

	do{
		if (strcmp2(name,current->name) < 0){
			if (n = ulAddUser(current->prev,name))
				return n;
			else
				return (TUList *)0;
		}
	}
	while (current = current->next);

	// add user to last position
	if (n = ulAddUser(ulGetLastLink(u),name))
		return n;
	else
		return (TUList *)0;
};

/*	create and sort a new user list from buffer
	each name from buffer should be seperated by \5
*/
int ulAddHubNickListSorted (TUList **here, ubyte *list, int total)
{
	if (!(list && total)) {
		LOG("::AddHubNickListSorted: list empty");
		return 0;
	}

	ubyte *names[total];
	ubyte *n = ifstrdup(NULL,list);
	int i;

	names[0] = (ubyte *)strtok(n,"\5");
	for (i = 1;i < total;i++)
		names[i] = (ubyte *)strtok(NULL,"\5");
	
	qsort (names,total, sizeof(int),(void *)ulQSort_Callback);

	TUList *u;
	int count = 0;
	for (i = 0;i < total;i++){
		if(u = ulAddUser(*here,names[i])){
			//if (u->prev == m->last)
				*here = u;
			count++;
		}
	}
	ifree (n);
	return count;
};

/*	perform a complete qsort() of users
	sorting forward from root to last
*/
int ulQSortForward (TMyDCHub *m, TUList *u)
{
	TUList *n = u;
	int total = ulCount(n);
	ubyte *names[total];

	int i = 0;
	for (i = 0;i < total;i++,n = n->next)
		names[i] = strdup(n->name);

	qsort (names,total, sizeof(int),(void *)ulQSort_Callback);

	m->last = u->prev;
	m->last->next = (TUList *)0;
	ulDestroyNext(u);
	
	TUList *l;
	int count = 0;
	for (i = 0;i < total;i++){
		if (l = ulAddUser(m->last,names[i])){
			if (l->prev == m->last) m->last = l;
			count++;
		}
		ifree (names[i]);
	}

	return count;
}

int ulQSort_Callback (ubyte **p, ubyte **n)
{
	register ubyte *s1 = *p;
	register ubyte *s2 = *n;

	while (*s1 == *s2++)
		if (*s1++ == 0) return (0);

	return (*s1 - *(--s2));
	//return strcmp2 (p->name, n->name);
};


int ulResetOps (TUList *u)
{
	if (!u) return 0;

	TUList *current = u;
	do{
		current->op = 0;
	}
	while (current = current->next);
	return 1;
};


int ulUpdateOps (TUList *u, ubyte *msg)
{
	if (!u) return 0;

	TUList *current;
	ubyte *buff = strdup(msg);
	ubyte *name = (ubyte *)strtok(buff," ");
	int total = 0;
	
	ulResetOps (u);	
	do{
		current = u;
		do{
			if (current->name[0] == name[0])
				if (!strcmp2(name,current->name)){
					current->op = 1;
					total ++;
					break;
				};
		}
		while (current = current->next);
	}
	while (name = (ubyte *)strtok(NULL," "));
	
	ifree (buff);
	return total;
};
