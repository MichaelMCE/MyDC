

cd dcUtils
call dcutils.bat
copy dcutils.dll ../
cd..

cd MyDCMoodll
call moodll.bat
copy moo.dll ../
cd..

cd MyDCPluginTemplate
call dcptemplate.bat
cd..

cd MyDCPubCmdBots
call PubCmdBots.bat
cd ..

rem cd MyDCZip
rem call MyDCZip.bat
rem copy szip.dll ../
rem cd ..

cd MyDCProxy
call MyDCProxy.bat
cd..

cd MyDCProxyUI
call MyDCProxyUI.bat
copy MyDCProxyUI.exe ..\
cd..


cd MyDCHTTP
call MyDCHTTP.bat
cd..


call ___MyDC.bat
