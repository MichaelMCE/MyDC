@ECHO OFF
SET XBLDIR=C:\xblite
SET PATH=C:\xblite\bin;%PATH%
SET LIB=C:\xblite\lib
SET INCLUDE=C:\xblite\include
nmake -f dcutils.mak all clean