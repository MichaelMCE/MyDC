moodll.dll is a plugin+wrapper DLL to this mIRC plugin DLL


Moo.dll
=======

Addon for mIRC, reports various statistics.

Change log:
===========
16/10/02 - [4.0.4.01] : Updated to work with latest motherboard monitor
27/04/01 - [4.0.2.65] : AMD Cache fix.
27/04/01 - [4.0.2.17] : P4 Fix (I hope)
			Cache calculation code changed
25/04/01 - [4.0.2.09] : Changed version structure! (again) (nobody cares:p)
			Added some IPHelper API functions (kudos to thlx@hotpop.com for concept and example implementation)
			Added ability to use the old CPU Speed calculation method, see .mrc file for explanation
			Added L2 Cache size... however, I've only done extremely limited testing on this, and to be
			perfectly honest, I don't think it will work properly on all CPUs :p
			N.B. transfer count will wrap around at 4GB
			I will add throughput counters later, and a pseudo fix for the 4GB issue.
20/04/01 - [4.0.0.01] : Changed version structure! (more realistic)
			Changed the CPU MHz calculation routine and some updated the CPU database.
			Also note: YOU NEED MBM5 FOR THE MBM5 STUFF! (mbm.livewiredev.com)
10/03/01 - [0.0.3.04] : Modified shared memory reader output to be fully customisable via mIRC script
                        NB: you will receive *NO* output if MBM5 is not loaded, and are likely to 
                        receive totally fucked up output if MBM5 isn't configured properly
09/03/00 - [0.0.3.03] : Added MBM5 Shared memory reader
18/12/00 - [0.0.3.02] : Added uploaded + downloaded counters
13/12/00 - [0.0.3.01] : Added RAS statistics, however the output will depend
                        upon which operating system you are using;
                        NT4 = dialup name + modem name
                        Win98 = dialup name + modem name + connection speed
                        Win2K = dialup name + modem name + connection speed + duration
                        This is because some of the OS's lack the features to 
                        get some of the values (obviously).
                        Warning: I wouldn't try using this feature if you haven't
                        actually got an active dialup connection, mIRC will probably
                        crash.
                        I've tested it in Win98a and Win2K SP1 on a modem, and it works.
                        Should work with ISDN, won't report on multi link connections,
                        just the first ras connection it finds.
			Added Screen statistics, horizonalxvertical res + BPP.

31/08/00 - [0.0.2.13] : Made rambar optional, defaults to 10 bars though.
			Rewrote dll to make use of C++ classes, also fixed
			some bugs which should've caused it to crash, but didn't :P

20/08/00 - [0.0.2.01] : 'final'.
                        Decreased RamBar© back to 10 bars, made it less 'bright'
                        , though it will look shite on anything but a white/gray
                        background.
                        Removed additional CPU info to make it shorter, i.e. die
                        size, model number.

18/08/00 - [0.0.1.26] : Updated OS code a bit, still not got full Windows 2000
                        recognition, downloading the latest Platform SDK as I 
                        type this.
                        Increased the RamBar© to 20 bars ;) I could actually make
                        it customisable, but I like it hard-coded ¦D
                        
17/08/00 - [0.0.0.19] : Mostly done, except for OS code.

Loading:
1) stick both the .dll and .mrc files in your main mirc directory
2) fire up mirc, /load -rs moodll.mrc
3) use any of the following commands:

/gfx
/mbm
/ni /net
/stat
/connstat
/screenstat
/uptime

the first command after the alias is used as an output destination, 
e.g. /gfx msg marky will /msg marky the output
     /gfx echo will echo the output on the screen

Unloading:
Should the script annoy you or something, you may unload it as follows:
1) in mirc, type /unload -rs moodll.mrc

Feel free to customise the appearance of the .mrc file output.