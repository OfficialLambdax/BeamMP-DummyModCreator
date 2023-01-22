:: Made by Neverless
:: Will no longer be required if this is implemented
:: https://github.com/BeamMP/BeamMP/issues/288
:: Please leave a upvote or comment there

@echo off
echo Waiting for Dummy Program to exit
cd source
:: Opens the script in the Signed Interpreter exe and waits for it to close
call AutoIt3_x64.exe Create_Dummy_Mod.au3

cd output
set /A found = 0
:: move Dummy mods to dummy mods dir
for %%f in (*) do move %%f ..\..\dummy_mods\%%f && set /A found = 1

:: if no file is in the Output folder then assume the process failed
if %found% == 0 goto :error

:: otherwise success
goto :success


:success
mshta javascript:alert("Success. File is located in dummy_mods");close();
exit

:error
mshta javascript:alert("Error. The dummy zip could not be created. try again");close();
exit