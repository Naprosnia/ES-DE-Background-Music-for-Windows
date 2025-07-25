@echo off

setlocal EnableDelayedExpansion

pushd "%~dp0"

for /f "tokens=1,2 delims==" %%a in (config.ini) do (
	set "%%a=%%b"
)

if /I "%MUSIC%"=="false" (
	endlocal
	goto :eof
)

set CALC=Tools\math\calc

if /I "%PLAYER%"=="vlc" (
	
	set PORT=12345
	
	for /f "delims=" %%A in ('%CALC% %MUSIC_VOLUME% * 256 / 100') do set STARTVOL=%%A
	
) else (
	
	for /f "delims=" %%A in ('%CALC% %MUSIC_VOLUME% * 1 / 100') do set STARTVOL=%%A

)

set ENDVOL=0
	
)

if /I "%FADE_TIME%"=="fast" (

	set FADE_MS=1000
	
) else if /I "%FADE_TIME%"=="normal" (

	set FADE_MS=2500
	
) else if /I "%FADE_TIME%"=="slow" (

	set FADE_MS=5000
	
) else (

	set FADE_MS=1000
	
)

rem time in milliseconds for each step
set /A INTERVAL=100

for /f "delims=" %%A in ('%CALC% %FADE_MS% / %INTERVAL%') do set STEPS=%%A

echo WScript.Sleep %INTERVAL% > sleep.vbs

for /L %%i in (1,1,%STEPS%) do (

	for /f "delims=" %%A in ('%CALC% %STARTVOL% + ^(^(%ENDVOL% - %STARTVOL%^) * %%i / %STEPS%^)') do set NEWVOL=%%A
	
	rem echo Step %%i: !NEWVOL!
	
	if /I "%PLAYER%"=="vlc" (
	
		Tools\nircmd\nircmd execmd "echo volume !NEWVOL! | Tools\ncat\ncat localhost %PORT%"
		
	) else (
	
		Tools\nircmd\nircmd setappvolume fmedia.exe !NEWVOL!
		
	)
	
	cscript //NoLogo sleep.vbs
	
)

if /I "%PLAYER%"=="vlc" (

	Tools\nircmd\nircmd execmd "echo quit | Tools\ncat\ncat localhost %PORT%"

) else (

	Tools\nircmd\nircmd execmd "Tools\fmedia\fmedia --globcmd=quit --globcmd.pipe-name=fmedia"

)


del sleep.vbs

endlocal