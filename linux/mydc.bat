@echo off

echo compiling....
C:\Dev-Cpp5\bin\gcc.exe -c mydc.c dispatch.c net.c cmd.c lock.c userlistmanager.c

echo linking....
C:\Dev-Cpp5\bin\gcc mydc.o dispatch.o net.o cmd.o lock.o userlistmanager.o -o mydc.exe -L"C:/Dev-Cpp5/lib" c:/Dev-Cpp5/lib/libws2_32.a -lpthreadGC -llcd

rem linux:
rem gcc -c mydc.c dispatch.c net.c cmd.c
rem gcc mydc.o dispatch.o net.o cmd.o lock.o -O -o mydc -Wl,"/usr/lib/libpthread.so"

rem echo cleaning....
del mydc.o
del dispatch.o
del net.o
del cmd.o
del lock.o
del userlistmanager.o



