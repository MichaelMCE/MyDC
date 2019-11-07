




'	___MyDC.x

'	A 'Direct Connect' client
'	(a daemon with plugin support for the DC P2P protocol.)
'	v0.50
'	updated 8/Feb/2006
'
'	by Michael McElligott
'
'

Quick start:
1) run BUILDALL_FIRST.BAT
2) run ___MyDC.exe
3) run MyDCProxyUI.exe
4) connect to the proxy be entering either local machine name or ip.
   eg, type /proxy NameOrIP 401
5a) type /big to automatically connect to a Direct Connect hub
5b) OR type /server IP PORT 


closing will disconnect MyDCProxyUI.exe from the proxy plugin, exiting
MyDCProxyUI.exe only and leaving ___MyDC.exe to run which will maintain the 
connection and protocol requests.
try closing MyDCProxyUI.exe then restart form step 4.


furthermore you can use your internet browser to view DC chat text.
goto: http://MachineName:402
machine name being the name of the machine where ___MyDC.exe is running.


Note:	to register a .DLL with MyDC add the plugin path to 'pluginlist' file.
	see current 'pluginlist' as an example.
	Or type "/load name" within the GUI client.




'	added a basic HTML interface proxy (tested using IE5 & 6 only) plugin.
'	rewrote MyDcUiProxy interface, using RichText as output medium.
'	added ability to download or open url's from within the MyDcProxyUi client.
'	added multi line input support for the MyDcUI proxy plugin.
' 	imporved dc++ v401 emulation.
'	other misc stabilty fixes for both server and client.
'	'MyDCUI.x' is nolonger supported nor up to date.
	

'	[almost] completely rewrote the client enabling an expandable plugin based server <> client.
'	completely seperated client from a gui (see above)
'	rewrote the $$mydc message handling routines and added a message queue system
'	client is now a fully message driven daemon.
'	added mydcproxy.x and mydcproxygui.x
'	plugins are now fully independant of gui support (unless of course it 'is' the gui)
'	6/04/2004
'
'	implemented external DLL Plug-in support.
'	MyDC plugin template created
'	all !cmd bots have been removed and implemented as a plugin.
'	added moodll.dll plugin, a wrapper to the mIRC moo.dll plugin
'	24/1/2004
'
'	added !dutch,!fact, !addfact, !morbid and !seen bots
'	2/1/2004
'
'	extensively updated:
'	added support for bots, including !bofh,!dubya,!insult,!country,!moi and !duke
'	added search and result support
'	relayed the gui.
'	added auto name fill support, eg, typing \\du will automaticly search the user database then replace \\du with the first user whose name begins with 'du'
'	increased stability
'	added word filtering support
'	added url filtering, every url type in main $$Hub window is logged and given a number. type /url x will open url number x
'	28/12/2003
'
'	a list of hubs can be found here: http://www.pedher.net/dc/list/
'	if using a 56k modem or less modem then try to stick to a hub with less than 50 users
'	this client can be unstable on hubs with more than 1500 users
'
'
'
'	initial release
'	13/12/2003


