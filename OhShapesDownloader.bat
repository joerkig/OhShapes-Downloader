@echo off
title OhShapes Downloader
IF EXIST .\jq-win64.exe ( echo Found jq ) ELSE ( echo Missing dependency jq! && GOTO :end)
IF EXIST .\fnr.exe ( echo Found fnr ) ELSE ( echo Missing dependency fnr! && GOTO :end)
IF EXIST .\fnr.lnk ( echo Found fnr shortcut ) ELSE ( echo Missing required fnr shortcut! contact joerkig#1337 on discord! && GOTO :end)

cd %USERPROFILE%\Documents\OhShape\Songs\
mkdir OSDTemp
:: Looks up how many pages and songs there are.
curl -s http://ohshapes.com/api/maps/latest/0? | .\jq-win64.exe ".lastPage" >OSDTemp\lastpage.txt
set /p lastpage=<OSDTemp\lastpage.txt
curl -s http://ohshapes.com/api/maps/latest/0? | .\jq-win64.exe ".totalDocs" >OSDTemp\amount.txt
set /p amount=<OSDTemp\amount.txt
echo Continuing will download %amount% files from OhShapes.com
pause

1>NUL copy nul "OSDTemp\dwnldurl.txt"

:: Finds directDownload suffix for songs
for /l %%x in (0, 1, %lastpage%) do (
    curl -s http://ohshapes.com/api/maps/latest/%%x? | .\jq-win64.exe ".docs[].directDownload" >>"OSDTemp\dwnldurl.txt"
)

:: Remove already downloaded songs
for /f "delims=/. tokens=4" %%h in (cache.txt) DO (
	findstr /v /c:%%h %USERPROFILE%\Documents\OhShape\Songs\OSDTemp\dwnldurl.txt >"OSDTemp\dwnldurltemp.txt"
	1>NUL copy "OSDTemp\dwnldurltemp.txt" "OSDTemp\dwnldurl.txt"
)

:: Downloads all the songs
for /f "delims=" %%a in (OSDTemp\dwnldurl.txt) DO (
	curl -O -s -C - http://ohshapes.com%%~a
	echo %%a >> cache.txt
	call :hash %%a
)
goto :endhash:

:hash
for /f "delims=/. tokens=3" %%b in (%1) do call :rename %%b
goto :eof
:endhash

goto :endrename
:rename
curl -s http://ohshapes.com/api/search/advanced/0?q=%1 | .\jq-win64.exe -r ".docs[].name" > "OSDTemp\songname.txt"
curl -s http://ohshapes.com/api/search/advanced/0?q=%1 | .\jq-win64.exe -r ".docs[].key" > "OSDTemp\songkey.txt"
curl -s http://ohshapes.com/api/search/advanced/0?q=%1 | .\jq-win64.exe -r ".docs[].uploader.username" > "OSDTemp\songuploader.txt"
:: I hate asterisks
:: Remove asterisks in the files created above
call fnr.lnk
set /p songname=<OSDTemp\songname.txt
set /p songkey=<OSDTemp\songkey.txt
set /p songuploader=<OSDTemp\songuploader.txt

echo Done downloading %songkey% - %songuploader% - %songname%
ren %1.zip "%songkey% - %songuploader% - %songname%.zip"
goto :eof
:endrename

echo Finished downloading %amount% files

:: Cleanup
1>NUL del OSDTemp\dwnldurl.txt
1>NUL del OSDTemp\dwnldurltemp.txt
1>NUL del OSDTemp\lastpage.txt
1>NUL del OSDTemp\amount.txt
1>NUL del OSDTemp\songname.txt
1>NUL del OSDTemp\songkey.txt
1>NUL del OSDTemp\songuploader.txt

pause