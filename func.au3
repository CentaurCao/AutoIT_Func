#include <file.au3>

Func Show($Message)
;显示提示信息

   MsgBox(0,"",$Message)
EndFunc


Func WriteLog($Logs)
;默认写在脚本文件下log文件夹下，脚本名称-日期.Log 文件中

   Local $LogFileName = @ScriptDir & "\log\"& StringLeft(@ScriptName,stringlen(@ScriptName)-4) &"-"   &@YEAR&@MON&@MDAY&".log"
   If Not FileExists($LogFileName)  Then
	  _FileCreate($LogFileName)
   EndIf

   Local $LogFile = FileOpen($LogFileName,1)
   _FileWriteLog($LogFile, $Logs,-1)
   FileClose($LogFile)

EndFunc


Func CompletePath($Path)
;将路径最后的\补齐，返回完整路径，如果非路径返回-1

   If StringInStr(FileGetAttrib($Path),"D") = 0 Then
	  Return("-1")
	  WriteLOg("无此目录：" & $Path)
   EndIf

   If StringRight($Path,1) <> "\" Then
	  $Path = $Path & "\"
	  Return($Path)
   Else
	  Return($Path)
   EndIf

EndFunc


Func CheckFile($Name)
;检测文件是否存在，存在返回1，否则返回-1

   If FileExists($Name) = 0 Or StringInStr(FileGetAttrib($Name),"D") <> 0 Then
	  Return(-1)
   Else
	  Return(1)
   EndIf
EndFunc

;检测路径是否存在，存在返回1，否则返回-1
Func CheckPath($Name)

   If FileExists($Name) = 0 Or StringInStr(FileGetAttrib($Name),"D") = 0 Then
	  WriteLog("路径有问题:" &$Name )
	  Return(-1)
   Else
	  Return(1)
   EndIf
EndFunc

;获得对象路径，成功返回完整路径，失败返回-1
Func GetPath($name)

   If FileExists($Name) = 0 Then
	  Return(-1)
	  WriteLog($Name & "不存在")
   Else
	  Local $i = StringInStr ( $name, "\",1)
	  Local $Path = StringLeft($name,$i)

	  While $i < StringLen($Name)
		 $i = $i +1
		 If StringInStr ($Name, "\", 0 ,1 , $i) <> 0 Then
			$i = StringInStr ($Name, "\", 0 ,1 , $i)
			$Path = StringLeft($Name,$i)
		 EndIf
	  WEnd
	  Return($Path)
   EndIf
EndFunc

;获取文件全名，成功返回全名，失败返回-1
Func GetFileName($Name)

   If CheckFile($Name) = -1 Then
	  Return(-1)
	  WriteLog($Name & "不存在")
   Else
	  Local $result = StringRight($Name, StringLen($Name)-StringLen(GetPath($Name)))
	  Return($result)
   EndIf
EndFunc


;拷贝文件到指定文件夹下，如果目标文件夹不存在则会新建
;拷贝成功返回1，拷贝失败返回-1,文件相同返回2
Func  CompCopy($OriFile,$DestPath)

   If CheckFile($OriFile) = -1 Then
	  Return(-1)
   Else
	  $DestPath = CompletePath($DestPath)
	  $OriPath = GetPath($OriFile)
	  Local $DestFileName = $DestPath & GetFilename ($OriFile)
	  Local $Result=""
	  If  FileExists($DestFileName) =0 Then
		 FileCopy($OriFile,$DestPath,9)
		 WriteLog("第一次拷贝 " & GetFileName($OriFile) & "  " & $OriPath & " ===>  " & $DestPath)
		 Return(1)
	  Else
		 if FileGetTime($DestFileName, 0 ,1) <> FileGetTime($OriFile, 0 ,1) Then
			FileMove($DestFileName, $DestFileName&"."&@HOUR&@MIN&@SEC)
			FileCopy($OriFile,$DestPath,9)
			WriteLog("更新文件 " & GetFileName($OriFile) & "  " & $OriPath & " ===>  " & $DestPath)
			Return(1)
		 Else
			if FileGetTime($DestFileName, 0 ,1) = FileGetTime($OriFile, 0 ,1) Then
			   Return(2)
			Else
			   Return(-1)
			EndIf
		 EndIf
	  EndIf
   EndIf
EndFunc


Func BulkCopyDir($Ori,$Dest,$mode=0,$ok=0)
;拷贝不会深入到原目录的子目录下，仅限于本层目录
;mode = 0 原目录下所有文件拷贝至目标目录下
;mode = 1 原目录整个儿拷贝至目标目录下成为子目录
;ok = 1 拷贝文件后都生成一个对应的.ok文件


   $Ori = CompletePath($Ori);
   If FileExists($Dest) = 0 Then
	  DirCreate($Dest)
   EndIf
   $Dest =CompletePath($Dest);

   If CheckPath($Ori)= -1 Or CheckPath($Dest) = -1 Then
	  Sleep(1000)
   Else
	  Local $hSearch = FileFindFirstFile($Ori & "*.*")
	  Local $sFileName = ""
	  Local $Result = ""

	  While 1
		 $sFileName = FileFindNextFile($hSearch)
		 If @error Then ExitLoop

		 If StringInStr(FileGetAttrib($Ori&$sFileName),"D")=0 And StringInStr(FileGetAttrib($Ori&$sFileName),"S")=0 Then
			If CompCopy($Ori&$sFileName, $Dest) =1 And  $ok = 1 Then
			   _FileCreate($Dest&$sFileName & ".ok")
			   WriteLog("生成" & $Dest&$sFileName & ".ok")
			EndIf
		 EndIf
	  WEnd
   EndIf
;   Return()

EndFunc




;z:\ 如何处理
Func BackDelZip($Target,$Dest,$Del,$Compress)
;备份文件或目录至目标文件夹下
;不支持通配符*、？等
;$Del=1 删除原文件   Del=0 保留原文件
;Compress=1 压缩文件 Compress=0不压缩

   If FileExists($Target) =0 Then
	  WriteLog("无此文件/目录：" & $Target)
   Else
	  If CheckPath($Dest) = -1 Then
		 DirCreate($Dest)
		 $Dest = CompletePath($Dest)
	  Else
		 $Dest = CompletePath($Dest)
	  EndIf
	  If CheckFile($Target) =1 Then		;目标是文件
		 $FileName = GetFileName($Target)
		 $ZipName = $Dest & $FileName & ".zip"
		 CompCopy($Target,$Dest)
		 If $Del = 1 Then
			FileDelete($Target)
		 EndIf
		 If $Compress = 1 Then
			ShellExecute("HaoZipC", " a -tzip " & $ZipName & " " & $Dest & $FileName)
			ProcessWaitClose("HaoZipC.exe")
			FileDelete($Dest&$FileName)
		 EndIf
	  EndIf

	  If CheckPath($Target) = 1 Then	;备份目录
		 $Target = CompletePath($Target)
		 $Dest = CompletePath($Dest)

		 ;子目录名称取出,用于拼接压缩包文件名
		 Local $i = StringInStr ( $Target, "\",1)
			Local $Path = StringLeft($Target,$i)
			While $i < StringLen($Target)
			   $i = $i +1
			   If StringInStr ($Target, "\", 0 ,1 , $i) <> 0 Then
				  $i = StringInStr ($Target, "\", 0 ,1 , $i)
				  If $i< stringlen($Target) then
					 $SubDir = StringMid($Target,$i+1,StringLen($Target)-$i-1)
				  EndIf
			   EndIf
			WEnd
		 If $del = 1 Then
			DirMove($Target,$Dest,1)
		 EndIf
		 If $Del=0 Then
			DirCopy($Target,$Dest&$SubDir&"\",1)
		 EndIf

		 If $Compress = 1 Then
			$Zipname = $Dest & $SubDir & ".zip"
			ShellExecute("HaoZipC", " a -tzip " & $ZipName & " " & $Dest & $SubDir & "\*.*")
			ProcessWaitClose("HaoZipC.exe")
			DirRemove($Dest & $SubDir & "\",1)
		 EndIf
	  EndIf
   EndIf

EndFunc

Func TestPing($IPAdd)

   If ping($IPAdd)= 0 then
	  if @error = "1" Then
		 WriteLog("Ping Wrong! IP: "& $IPAdd &" Reason: Host is offline")
	  ElseIf @error = "2" Then
		 WriteLog("Ping Wrong! IP: "& $IPAdd &" Reason: Host is unreachable")
	  ElseIf @error = "3" Then
		 WriteLog("Ping Wrong! IP: "& $IPAdd &" Reason: Host is Bad destination")
	  ElseIf @error = "4" Then
		 WriteLog("Ping Wrong! IP: "& $IPAdd &" Reason: Other errors ")
	  EndIf
   EndIf

EndFunc

Func DataRead($filename,$type,$IniFile)
#cs
DataCenter.exe -b1 D:\mgr\ACCO_20180416.TXT
DataCenter.exe -b2 D:\mgr\ACCONET_20180416.TXT
DataCenter.exe -b3 D:\mgr\SHARE_20180416.TXT
DataCenter.exe -b4 D:\mgr\SHAREDETAIL_20180416.TXT
DataCenter.exe -b5 D:\mgr\ACCOREQUEST_20180416.TXT
DataCenter.exe -b6 D:\mgr\REQUEST_20180416.TXT
DataCenter.exe -b7 D:\mgr\CONFIRM_20180416.TXT
DataCenter.exe -b8 D:\mgr\CONFIRMDETAIL_20180416.TXT
DataCenter.exe -b9 D:\mgr\FUNDSHARE_20180416.TXT
DataCenter.exe -ba D:\mgr\FUNDINFO_20180416.TXT
#ce
;Local $IniFile = "ImportData.ini"
   If FileExists($filename) And ( FileGetTime($filename,0,1) <> IniRead($IniFile,"DataFileTime",$type,0) ) Then
	  Select
	  Case $type = "Valuation"
		 WriteLog("Begin Valuation read...")
		 ShellExecuteWait ("d:\DataCenter.exe", " -a "& $filename ,"d:\")
		 WriteLog("Done Valuation read...")
	  Case $type = "AccountInfo"
		 WriteLog("Begin AccountInfo read...")
		 ShellExecuteWait ("d:\DataCenter.exe", " -b1 "& $filename ,"d:\")
		 WriteLog("Done AccountInfo read...")
	  Case $type = "AccountTAInfo"
		 WriteLog("Begin AccountTAInfo read...")
		 ShellExecuteWait ("d:\DataCenter.exe", " -b2 "& $filename ,"d:\")
		 WriteLog("Done AccountTAInfo read...")
	  Case $type = "Share"
		 WriteLog("Begin Share read...")
		 ShellExecuteWait ("d:\DataCenter.exe", " -b3 "& $filename ,"d:\")
		 WriteLog("Done Share read...")
	  Case $type = "ShareDetail"
		 WriteLog("Begin ShareDetail read...")
		 ShellExecuteWait ("d:\DataCenter.exe", " -b4 "& $filename ,"d:\")
		 WriteLog("Done ShareDetail read...")
	  Case $type = "AccountRequest"
		 WriteLog("Begin AccountRequest read...")
		 ShellExecuteWait ("d:\DataCenter.exe", " -b5 "& $filename ,"d:\")
		 WriteLog("Done AccountRequest read...")
	  Case $type = "Request"
		 WriteLog("Begin Request read...")
		 ShellExecuteWait ("d:\DataCenter.exe", " -b6 "& $filename ,"d:\")
		 WriteLog("Done Request read...")
	  Case $type = "Confirm"
		 WriteLog("Begin Confirm read...")
		 ShellExecuteWait ("d:\DataCenter.exe", " -b7 "& $filename ,"d:\")
		 WriteLog("Done Confirm read...")
	  Case $type = "ConfirmDetail"
		 WriteLog("Begin ConfirmDetail read...")
		 ShellExecuteWait ("d:\DataCenter.exe", " -b8 "& $filename ,"d:\")
		 WriteLog("Done ConfirmDetail read...")
	  Case $type = "FundShare"
		 WriteLog("Begin FundShare read...")
		 ShellExecuteWait ("d:\DataCenter.exe", " -b9 "& $filename ,"d:\")
		 WriteLog("Done FundShare read...")
	  Case $type = "FundInfo"
		 WriteLog("Begin FundInfo read...")
		 ShellExecuteWait ("d:\DataCenter.exe", " -ba "& $filename ,"d:\")
		 WriteLog("Done FundInfo read...")
	  EndSelect
	  ;WriteLog(   FileGetTime($filename,0,1)  &" | " &IniRead($IniFile,"DataFileTime",$type,0))
	  IniWrite($IniFile,"DataFileTime",$type, (FileGetTime($filename,0,1)) )
   EndIf
EndFunc