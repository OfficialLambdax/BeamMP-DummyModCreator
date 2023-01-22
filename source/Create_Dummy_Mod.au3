#cs
	Made by Neverless

	No longer required if this comes true. Please leave a comment there or upvote
	https://github.com/BeamMP/BeamMP/issues/288
#ce


#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


Global Const $SF_WORKDIR = @ScriptDir & "\workdir"
Global Const $SF_DUMMYBIN = $SF_WORKDIR & "\dummy.bin"
Global Const $S_DUMMYBIN = "dummy.bin"
Global Const $SF_DUMMYZIP = $SF_WORKDIR & "\dummy.zip"
Global Const $S_DUMMYZIP = "dummy.zip"
Global Const $SF_OUTPUT = @ScriptDir & "\output"
Global Const $SF_7Z = $SF_WORKDIR & "\7z.exe"
Global Const $SF_7ZDLL = $SF_WORKDIR & "\7z.exe"
Global Const $SF_CONFIG = @ScriptDir & "\config.ini"
Global $N_OFFSET = Int(IniRead($SF_CONFIG, "Offset", "Offset", "0"))
Global Const $N_10MB = 1048576 * 10

_Log("Checking necessary files")
If Not FileExists($SF_WORKDIR) Then DirCreate($SF_WORKDIR)
If Not FileExists($SF_OUTPUT) Then DirCreate($SF_OUTPUT)
If Not FileExists($SF_7Z) Then Exit MsgBox(16, "Error", "7z.exe does not exist")
If Not FileExists($SF_7ZDLL) Then Exit MsgBox(16, "Error", "7z.dll does not exist")


_Log("Creating 10 Megabytes of Trash Data")
Global Const $S_TRASHDATA = _Create10MBTrashData()

_Log("Select Mod to Replicate")
Local $sfFileToReplicate = FileOpenDialog("Select Mod to Replicate", @ScriptDir, "Zip (*.zip)", 1 + 2)
If @error Then Exit
Local $sfOutput = $SF_OUTPUT & "\" & StringTrimLeft($sfFileToReplicate, StringInStr($sfFileToReplicate, '\', 1, -1))

_Log("Creating Dummy Mod")
_CreateDummyMod($sfFileToReplicate, $sfOutput)

_Log("Checking Dummy Mod")
Local $nModSize = FileGetSize($sfFileToReplicate)
Local $nDummySize = FileGetSize($sfOutput)

;~ If $nModSize == $nDummySize Then Exit MsgBox(64, "Success", "Success")
If $nModSize == $nDummySize Then Exit

_Log("Check failed (Happens always on the first creation)")
$N_OFFSET = $nModSize - $nDummySize
IniWrite($SF_CONFIG, "Offset", "Offset", String($N_OFFSET))

_Log("Creating Dummy Mod again")
_CreateDummyMod($sfFileToReplicate, $sfOutput)

$nModSize = FileGetSize($sfFileToReplicate)
$nDummySize = FileGetSize($sfOutput)

;~ If $nModSize == $nDummySize Then Exit MsgBox(64, "Success", "Success")
If $nModSize == $nDummySize Then Exit
IniWrite($SF_CONFIG, "Offset", "Offset", "0")
;~ MsgBox(16, "Error", "Cannot create Dummy mod. Try again")


Func _CreateDummyMod($sfFileToReplicate, $sfOutput)

	Local $nModSize = FileGetSize($sfFileToReplicate) + $N_OFFSET
	Local $n10MBWrite = Int($nModSize / $N_10MB)

	Local $hOpenDummyBin = FileOpen($SF_DUMMYBIN, 18)
	If $hOpenDummyBin == -1 Then Exit MsgBox(16, "Error", "Cannot open " & $S_DUMMYBIN)

	_Log("Writing Trash Data")
	For $i = 1 To $n10MBWrite
		FileWrite($hOpenDummyBin, $S_TRASHDATA)
	Next

	FileWrite($hOpenDummyBin, _CreateTrashData($nModSize - ($N_10MB * $n10MBWrite)))
	FileClose($hOpenDummyBin)

	FileSetTime($SF_DUMMYBIN, "20230101010000", 0)
	FileSetTime($SF_DUMMYBIN, "20230101010000", 1)
	FileSetTime($SF_DUMMYBIN, "20230101010000", 2)

	_Log("Packing dummfiles into zip")
	ShellExecuteWait($SF_7Z, 'a -mx=0 ' & $S_DUMMYZIP & ' ' & $S_DUMMYBIN, $SF_WORKDIR, "open", @SW_HIDE)

	_Log("Moving zip to output")
	FileMove($SF_DUMMYZIP, $sfOutput, 1)
	FileDelete($SF_DUMMYBIN)

EndFunc

Func _CreateTrashData($nLen)
	Local $sData = ""
	For $i = 1 To $nLen
		$sData &= "1"
	Next
	Return $sData
EndFunc

Func _Create10MBTrashData()
	Local $sData = ""
	For $i = 1 To 1048576
		$sData &= "1"
	Next

	Local $sTrashData = ""
	For $i = 1 To 10
		$sTrashData &= $sData
	Next

	Return $sTrashData
EndFunc

Func _Log($sText)
	ConsoleWrite(@HOUR & ':' & @MIN & ':' & @SEC & @TAB & @TAB & $sText & @CRLF)
EndFunc