#include <file.au3>

Func Show($Message)
;��ʾ��ʾ��Ϣ

   MsgBox(0,"",$Message)
EndFunc


Func WriteLog($Logs)
;Ĭ��д�ڽű��ļ���log�ļ����£��ű�����-����.Log �ļ���

   Local $LogFileName = @ScriptDir & "\log\"& StringLeft(@ScriptName,stringlen(@ScriptName)-4) &"-"   &@YEAR&@MON&@MDAY&".log"
   If Not FileExists($LogFileName)  Then
	  _FileCreate($LogFileName)
   EndIf

   Local $LogFile = FileOpen($LogFileName,1)
   _FileWriteLog($LogFile, $Logs,-1)
   FileClose($LogFile)

EndFunc


Func CompletePath($Path)
;��·������\���룬��������·���������·������-1

   If StringInStr(FileGetAttrib($Path),"D") = 0 Then
	  Return("-1")
	  WriteLOg("�޴�Ŀ¼��" & $Path)
   EndIf

   If StringRight($Path,1) <> "\" Then
	  $Path = $Path & "\"
	  Return($Path)
   Else
	  Return($Path)
   EndIf

EndFunc


Func CheckFile($Name)
;����ļ��Ƿ���ڣ����ڷ���1�����򷵻�-1

   If FileExists($Name) = 0 Or StringInStr(FileGetAttrib($Name),"D") <> 0 Then
	  Return(-1)
   Else
	  Return(1)
   EndIf
EndFunc

;���·���Ƿ���ڣ����ڷ���1�����򷵻�-1
Func CheckPath($Name)

   If FileExists($Name) = 0 Or StringInStr(FileGetAttrib($Name),"D") = 0 Then
	  WriteLog("·��������:" &$Name )
	  Return(-1)
   Else
	  Return(1)
   EndIf
EndFunc

;��ö���·�����ɹ���������·����ʧ�ܷ���-1
Func GetPath($name)

   If FileExists($Name) = 0 Then
	  Return(-1)
	  WriteLog($Name & "������")
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

;��ȡ�ļ�ȫ�����ɹ�����ȫ����ʧ�ܷ���-1
Func GetFileName($Name)

   If CheckFile($Name) = -1 Then
	  Return(-1)
	  WriteLog($Name & "������")
   Else
	  Local $result = StringRight($Name, StringLen($Name)-StringLen(GetPath($Name)))
	  Return($result)
   EndIf
EndFunc


;�����ļ���ָ���ļ����£����Ŀ���ļ��в���������½�
;�����ɹ�����1������ʧ�ܷ���-1,�ļ���ͬ����2
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
		 WriteLog("��һ�ο��� " & GetFileName($OriFile) & "  " & $OriPath & " ===>  " & $DestPath)
		 Return(1)
	  Else
		 if FileGetTime($DestFileName, 0 ,1) <> FileGetTime($OriFile, 0 ,1) Then
			FileMove($DestFileName, $DestFileName&"."&@HOUR&@MIN&@SEC)
			FileCopy($OriFile,$DestPath,9)
			WriteLog("�����ļ� " & GetFileName($OriFile) & "  " & $OriPath & " ===>  " & $DestPath)
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
;�����������뵽ԭĿ¼����Ŀ¼�£������ڱ���Ŀ¼
;mode = 0 ԭĿ¼�������ļ�������Ŀ��Ŀ¼��
;mode = 1 ԭĿ¼������������Ŀ��Ŀ¼�³�Ϊ��Ŀ¼
;ok = 1 �����ļ�������һ����Ӧ��.ok�ļ�


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
			   WriteLog("����" & $Dest&$sFileName & ".ok")
			EndIf
		 EndIf
	  WEnd
   EndIf
;   Return()

EndFunc




;z:\ ��δ���
Func BackDelZip($Target,$Dest,$Del,$Compress)
;�����ļ���Ŀ¼��Ŀ���ļ�����
;��֧��ͨ���*������
;$Del=1 ɾ��ԭ�ļ�   Del=0 ����ԭ�ļ�
;Compress=1 ѹ���ļ� Compress=0��ѹ��

   If FileExists($Target) =0 Then
	  WriteLog("�޴��ļ�/Ŀ¼��" & $Target)
   Else
	  If CheckPath($Dest) = -1 Then
		 DirCreate($Dest)
		 $Dest = CompletePath($Dest)
	  Else
		 $Dest = CompletePath($Dest)
	  EndIf
	  If CheckFile($Target) =1 Then		;Ŀ�����ļ�
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

	  If CheckPath($Target) = 1 Then	;����Ŀ¼
		 $Target = CompletePath($Target)
		 $Dest = CompletePath($Dest)

		 ;��Ŀ¼����ȡ��,����ƴ��ѹ�����ļ���
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