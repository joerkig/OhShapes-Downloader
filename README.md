# OhShapes-Downloader
Will probably rewrite this in Python at some point in the future.

fnr.lnk is a shortcut to fnr with the right commandline options to bypass the fact that batch does not handle asterisks. The target of the shortcut should be as follows.

```%USERPROFILE%\Documents\OhShape\Songs\fnr.exe --cl --silent --dir "%USERPROFILE%\Documents\OhShape\Songs\OSDTemp" --fileMask "song*.txt" --useRegEx --find "([\\/:\*?""<>|&])" --replace ""```

Disclaimer:
This is in no way endorsed by the creators of fnr and/or jq
