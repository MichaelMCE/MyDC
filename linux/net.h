#if !defined(__net_h)     // Sentry, use file only if it's not already included.
#define __net_h

int closeSocket (int socket);
int sendSocket (int socket,char *buffer,int *bsize);
int readSocket (int socket,char *buffer,int bsize);
int connectTo (char *addr, int port);
void initSocket ();



#endif
