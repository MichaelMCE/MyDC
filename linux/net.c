
#define WIN32_LEAN_AND_MEAN
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

#ifndef _WIN32
  #include <sys/socket.h>
  #include <netinet/in.h>
  #include <arpa/inet.h>
  #include <netdb.h>
#else
//  #include <winsock.h>
  #include <winsock2.h>
#endif

#include "mydc.h"
#include "net.h"


int closeSocket (int socket)
{
	shutdown (socket,2);
	#ifdef _WIN32
		return closesocket(socket);
	#else
		return close(socket);
	#endif
};

int sendSocket (int socket,char *buffer,int *bsize)
{
	if (socket == SOCKET_ERROR){
		LOG("not connected");
		return SOCKET_ERROR;
	}

	int sent = 0, total = 0;
	for (total = 0; total < *bsize;){
		#ifdef _WIN32
			sent = send(socket, buffer+total, *bsize-total,0);
		#else
			sent = write(socket, buffer+total, *bsize-total);
		#endif
		if (sent == SOCKET_ERROR){
			LOG ("error writting to socket");
			*bsize = total;		// return total bytes sent
			return SOCKET_ERROR;
		}
		else
			total += sent;
	};
	*bsize = total;		// return total bytes sent
	return total;
};

int readSocket (int socket,char *buffer,int bsize)
{
	#ifdef _WIN32
    	return recv(socket, buffer, bsize,0);    	
	#else
    	return read(socket, buffer, bsize);
	#endif
};

void initSocket ()
{
	#ifdef _WIN32
		WSADATA wsa;
		WSAStartup (MAKEWORD (2,2),&wsa);
	#endif
}

int connectTo (char *addr, int port)
{
    struct hostent *hostPtr = NULL;
    struct sockaddr_in serverName = {0};
    int fdsocket = SOCKET_ERROR;

	if (port > 65535 || port < 0 || !addr){
		LOG("invalid address specified\n");
		return SOCKET_ERROR;
	}
	
    fdsocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (fdsocket == SOCKET_ERROR) {
        perror("can not create fd/socket");
        return SOCKET_ERROR;
    }

    hostPtr = gethostbyname(addr);
    if (hostPtr == NULL) {
        hostPtr = gethostbyaddr(addr, strlen(addr), PF_INET);
        if (hostPtr == NULL) {
        	printf("unable to resolve address '%s' to an IP\n",addr);
        	return SOCKET_ERROR;
        }
    }

    serverName.sin_family = PF_INET;
    serverName.sin_port = htons(port);
    (void)memcpy(&serverName.sin_addr, hostPtr->h_addr, hostPtr->h_length);

    if (connect(fdsocket,(struct sockaddr*)&serverName, sizeof(serverName)) == SOCKET_ERROR) {
        printf("unable to connect to host '%s:%i'\n",addr,port);
        return SOCKET_ERROR;
    }
    return fdsocket;
};


