#tag Module
Protected Module LLMod
	#tag Method, Flags = &h0
		Function ChDirSet(myPath As String) As Boolean
		  Dim err As Integer
		  Dim Success As Boolean
		  
		  MyPath = NoSlash(MyPath) 'Remove trailing Slash
		  
		  #If TargetMachO
		    Const chdirLib = "System.framework"
		    Soft Declare Function chdir Lib chdirLib (path As CString) As Integer
		    
		    Dim myPath As String = "/tmp/"
		    
		    err = chdir(myPath)
		    Success = True
		    If Not err = 0 Then
		      System.DebugLog("ERROR " + Str(err))
		      Success = False
		    End
		    
		  #ElseIf TargetLinux
		    Const chdirLib = "libc"
		    Soft Declare Function chdir Lib chdirLib (path As CString) As Integer
		    
		    err = chdir(myPath)
		    Success = True
		    If Not err = 0 Then
		      Success = False
		      System.DebugLog("ERROR " + Str(err))
		      'MsgBox Str(err)
		    End
		    
		  #ElseIf TargetWin32
		    Soft Declare Function SetCurrentDirectoryA Lib "Kernel32" ( dir As CString ) As Boolean 'x86
		    Soft Declare Function SetCurrentDirectoryW Lib "Kernel32" ( dir As WString ) As Boolean 'x64
		    
		    'Set the directory
		    If System.IsFunctionAvailable( "SetCurrentDirectoryW", "Kernel32" ) Then
		      Success = SetCurrentDirectoryW( myPath )
		      Success = SetCurrentDirectoryA( myPath )
		    Else
		      Success = SetCurrentDirectoryA( myPath )
		    End If
		  #EndIf
		  
		  If Debugging Then Debug("ChDirSet: "+myPath)
		  
		  Return Success
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CleanTemp()
		  If Debugging Then Debug("--- Starting Clean Temp ---")
		  
		  If TmpPath <> "" Then
		    If Exist(TmpPath) Then
		      
		      Deltree(Slash(TmpPath)+"items")
		      Deltree(Slash(TmpPath)+"LLShorts")
		      Deltree(Slash(TmpPath)+"*.cmd")
		      Deltree(Slash(TmpPath)+"*.sh")
		      Deltree(Slash(TmpPath)+"*")
		      
		      'Old Method
		      'If TargetWindows Then
		      'RunCommand ("rmdir /q /s " + Chr(34)+TmpPath+"/items"+Chr(34))
		      'RunCommand ("rmdir /q /s " + Chr(34)+TmpPath+"/LLShorts"+Chr(34))
		      'RunCommand ("rmdir /q " + Chr(34)+TmpPath+"/*.cmd"+Chr(34)) 'Remove Scripts from Temp
		      'Else
		      'ShellFast.Execute ("rm -rf " + Chr(34)+TmpPath+"/items"+Chr(34))
		      'ShellFast.Execute ("rm -rf " + Chr(34)+TmpPath+"/LLShorts"+Chr(34))
		      'ShellFast.Execute ("rm -f " + Chr(34)+TmpPath+"/*.sh"+Chr(34)) 'Remove Scripts from Temp
		      'End If
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CompPath(PathIn As String, SkipAppPath As Boolean = False) As String
		  If Debugging Then Debug("CompPath: " + PathIn)
		  
		  If SkipAppPath =False Then
		    PathIn = PathIn.ReplaceAll(ItemLLItem.PathApp.ReplaceAll("\","/"),"%AppPath%") ' Convert Windows paths to Linux paths, makes the DB cross platform compatible
		    PathIn = PathIn.ReplaceAll(ItemLLItem.PathINI.ReplaceAll("\","/"),"%INIPath%")
		  End If
		  
		  PathIn = PathIn.ReplaceAll(Slash(HomePath)+"LLGames", "%LLGames%")
		  PathIn = PathIn.ReplaceAll(Slash(HomePath)+"LLApps", "%LLApps%")
		  
		  PathIn = PathIn.ReplaceAll(NoSlash(ppGames.ReplaceAll("\","/")),"%ppGames%") 'This should fix the path not working right for ppGames and Apps
		  PathIn = PathIn.ReplaceAll(NoSlash(ppApps.ReplaceAll("\","/")), "%ppApps%")
		  
		  If TargetWindows Then
		    PathIn = PathIn.ReplaceAll(Left(ppGames,2),"%ppGamesDrive%")
		    PathIn = PathIn.ReplaceAll(Left(ppApps,2),"%ppAppsDrive%")
		    PathIn = PathIn.ReplaceAll(Win7z,"%Extract%")
		  Else
		    PathIn = PathIn.ReplaceAll(HomePath +  "/.wine/drive_c","%ppGamesDrive%")
		    PathIn = PathIn.ReplaceAll(HomePath +  "/.wine/drive_c", "%ppAppsDrive%")
		    PathIn = PathIn.ReplaceAll(Win7z,"%Extract%") 'This is only used by Wine Scripts, I'll make another method for Linux
		  End If
		  
		  'Do This Last so can conver subpaths above first
		  PathIn = PathIn.ReplaceAll(NoSlash(HomePath), "$HOME")
		  
		  Return PathIn
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Copy(FileIn As String, FileOut As String)
		  If Debugging Then Debug("Copy "+ FileIn +" To " + FileOut)
		  'I may update this routune to new methods, but works for now using Xojo method - Glenn 2027
		  
		  Dim F, G As FolderItem
		  
		  'MsgBox FileIn + " "+ FileOut
		  If Exist(FileIn) Then
		    #Pragma BreakOnExceptions Off
		    Try
		      F=GetFolderItem(FileIn, FolderItem.PathTypeShell)
		      If Not F.Parent.Exists Then MakeFolder(F.Parent.ShellPath) ' Make sure folder exists before copying to it
		      
		      G=GetFolderItem(FileOut, FolderItem.PathTypeShell)
		      'MakeFolder(G.Parent.ShellPath) 'Makes sure the output path parent exists before trying to copy to it. 'leaving this out for now, causes issues with Try Catch, if access denied
		      If G.Exists And G.IsWriteable Then G.Remove
		      F.CopyTo(G)
		    Catch
		    End Try
		    #Pragma BreakOnExceptions On
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CreateShortcut(TitleName As String, Target As String, WorkingDir As String, LinkFolder As String)
		  If Debugging Then Debug("--- Starting Create Shortcuts ---")
		  
		  Dim scWorkingDir As FolderItem
		  
		  'Dim scTarget As FolderItem
		  'scTarget = GetFolderItem(Target, FolderItem.PathTypeShell)
		  scWorkingDir = GetFolderItem(WorkingDir, FolderItem.PathTypeShell)
		  
		  'Making Links fails if no folder made for it, we don't want it to crash a store when a shortcut fails.
		  #Pragma BreakOnExceptions Off
		  Try
		    If TargetWindows Then
		      Dim lnkObj As OLEObject
		      Dim scriptShell As New OLEObject("{F935DC22-1CF0-11D0-ADB9-00C04FD58A0B}")
		      
		      If scriptShell <> Nil then
		        lnkObj = scriptShell.CreateShortcut(LinkFolder  + TitleName + ".lnk")
		        If lnkObj <> Nil then
		          lnkObj.Description = TitleName
		          'lnkObj.TargetPath = scTarget.NativePath
		          lnkObj.TargetPath = Target 'Target may also have some Arguments, so use text not folder item.
		          lnkObj.WorkingDirectory = Slash(FixPath(scWorkingDir.NativePath))
		          lnkObj.Save
		          'Return SpecialFolder.Desktop.TrueChild(scName + ".lnk")
		        Else
		          'Return Nil
		        End If
		      Else
		        'Return Nil
		      End If
		    End If
		  Catch
		  End Try
		  
		  #Pragma BreakOnExceptions On
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Debug(Debugger As String)
		  #Pragma BreakOnExceptions Off
		  Try
		    Var d As DateTime = DateTime.Now
		    DebugOutput.WriteLine (d.Hour.ToString("00")+":"+d.Minute.ToString("00")+":"+d.Second.ToString("00")+Chr(9)+Debugger)
		    DebugOutput.Flush ' Actually Write to file after each thing
		  Catch
		  End Try
		  #Pragma BreakOnExceptions On
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Deltree(S As String)
		  Dim Sh As New Shell
		  Sh.TimeOut = -1
		  Sh.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  
		  If S = "" Or S.Length <= 4 Then Return 'Don't remove short paths, it's dangerous to do them as mistakes happen
		  
		  If TargetWindows Then S = S.ReplaceAll("/","\") 'rmdir needs backslash in Windows
		  
		  S = S.Trim
		  
		  If Debugging Then Debug("Deltree: " + S)
		  
		  'Delete Folders
		  If TargetWindows Then
		    Sh.Execute ("rmdir /q /s " + Chr(34)+S+Chr(34)) 'Don't use RunCommand or it becomes recursive as it uses this routine to clean up
		  Else
		    Sh.Execute ("rm -rf " + Chr(34)+S+Chr(34))
		  End If
		  
		  While Sh.IsRunning
		    App.DoEvents(4)
		  Wend
		  
		  'Delete File
		  If TargetWindows Then
		    Sh.Execute ("del /f /q " + Chr(34)+S+Chr(34)) 'Don't use RunCommand or it becomes recursive as it uses this routine to clean up
		  Else
		    Sh.Execute ("rm -f " + Chr(34)+S+Chr(34))
		  End If
		  While Sh.IsRunning
		    App.DoEvents(4)
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EnableSudoScript()
		  If Debugging Then Debug("--- Starting Enable Sudo Script ---")
		  
		  Dim F As FolderItem
		  Dim Test As Boolean
		  
		  If HasLinuxSudo = True Then ' Don't do this unless it's needed
		    If Not TargetWindows Then 'Only make Sudo in Linux
		      If SudoEnabled = False Then
		        ShellFast.Execute ("rm -f /tmp/LLSudoDone") ' Remove it so will only quit once recreated
		        ShellFast.Execute ("echo "+Chr(34)+"Unlock"+Chr(34)+" > /tmp/LLSudo")
		        
		        'Don't do below line, if the Sudo Script needs a file, it'll have to use the full path, else it's changes out of the Installers Path to run Sudo script.
		        'Test = ChDirSet(ToolPath) 'Make sure in the right folder to run script etc
		        
		        If SysTerminal.Trim = "gnome-terminal" Then
		          SudoShellLoop.Execute(SysTerminal.Trim+" --wait -e "+"'sudo "+Chr(34)+ToolPath+"LLStore_Sudo.sh"+Chr(34)+"'") 'A fix for the Folder Item not working as expected is to make it trimmed, it's having problems with Extra Spaces etc?
		        Else
		          SudoShellLoop.Execute(SysTerminal.Trim+" -e "+"sudo "+Chr(34)+ToolPath+"LLStore_Sudo.sh"+Chr(34)) 
		        End If
		        
		        While  Exist("/tmp/LLSudo") 'First thing Sudo script does is delete this file, so we know it's ran ok
		          if SudoShellLoop.IsRunning = False Then Exit 'MsgBox "Closed Shell?"
		          App.DoEvents(10)
		        Wend
		        
		        if SudoShellLoop.IsRunning = True Then
		          SudoEnabled = True
		          
		          If Debugging Then Debug("Sudo Enabled: " +SudoEnabled.ToString)
		        Else
		          SudoEnabled = False
		          
		          If Debugging Then Debug("Sudo Enabled: " +SudoEnabled.ToString)
		        End If
		      End If
		    End If
		  Else
		    SudoEnabled = False
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Exist(FileIn As String) As Boolean
		  Dim F As FolderItem
		  FileIn = FileIn.Trim
		  If FileIn = "" Then Return False
		  'MsgBox "Is "+ FileIn
		  #Pragma BreakOnExceptions Off
		  Try
		    F = GetFolderItem(FileIn, FolderItem.PathTypeShell)
		    If F <> Nil Then
		      'MsgBox "FOUND!"
		      'If Debugging Then Debug("Exist: "+FileIn +" = True")  'Too many calls to log it really
		      If F.Exists Then Return True
		    End If
		    'If Debugging Then Debug("Exist: "+FileIn +" = False") 'Too many calls to log it really
		    Return False
		  Catch
		    'If Debugging Then Debug("Exist: "+FileIn +" = False") 'Too many calls to log it really
		    Return False
		  End Try
		  
		  #Pragma BreakOnExceptions On
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExpPath(PathIn As String, WinPaths As Boolean = False) As String
		  'If Debugging Then Debug("ExpPath = " +PathIn) 'Too Many calls to bother logging
		  
		  Dim UserName As String
		  
		  PathIn = PathIn.ReplaceAll("\", "/")
		  
		  If TargetLinux Then UserName = Right( NoSlash(HomePath), Len( NoSlash(HomePath)) - InStrRev( NoSlash(HomePath), "/"))
		  
		  PathIn = PathIn.ReplaceAll("%LLGames%", Slash(HomePath)+"LLGames")
		  PathIn = PathIn.ReplaceAll("%LLApps%", Slash(HomePath)+"LLApps")
		  
		  'Below will only be used in Windows and Wine, so can use Disk Letters
		  If TargetWindows Then
		    PathIn = PathIn.ReplaceAll("%USBDrive%", Left(AppPath,2)) 'Convert USB/DVD your running off  to correct Path
		    PathIn = PathIn.ReplaceAll("%AppPath%", ItemLLItem.PathApp)
		    PathIn = PathIn.ReplaceAll("%ppGames%", NoSlash(ppGames))
		    PathIn = PathIn.ReplaceAll("%ppApps%", NoSlash(ppApps))
		    
		    PathIn = PathIn.ReplaceAll("%INIPath%", ItemLLItem.PathINI)
		    PathIn = PathIn.ReplaceAll("%ProgramFiles%", NoSlash(SysProgramFiles))
		    PathIn = PathIn.ReplaceAll("%ProgramFiles(x86)%", NoSlash(SysProgramFiles)+" (x86)")
		    PathIn = PathIn.ReplaceAll("%ProgramData%", NoSlash(SysDrive)+"/ProgramData")
		    PathIn = PathIn.ReplaceAll("%SystemDrive%", NoSlash(SysDrive))
		    PathIn = PathIn.ReplaceAll("%SystemRoot%", NoSlash(SysRoot))
		    PathIn = PathIn.ReplaceAll("%WinDir%", NoSlash(SysRoot))
		    
		    PathIn = PathIn.ReplaceAll("%LocalAppData%", FixPath(NoSlash(SpecialFolder.ApplicationData.Parent.NativePath)+"/Local"))
		    
		    PathIn = PathIn.ReplaceAll("%ppGamesDrive%", Left(ppGames,2))
		    PathIn = PathIn.ReplaceAll("%ppAppsDrive%", Left(ppApps,2))
		    PathIn = PathIn.ReplaceAll("%Extract%", Win7z+" -mtc -aoa x ")
		    
		    PathIn = PathIn.ReplaceAll("%Desktop%",  FixPath(NoSlash(SpecialFolder.Desktop.NativePath)))
		    PathIn = PathIn.ReplaceAll("%AppData%",  FixPath(NoSlash(SpecialFolder.ApplicationData.NativePath)))
		    
		  Else 'Use Linux full paths instead (So can detect if installed etc first).
		    If WinPaths Then
		      PathIn = PathIn.ReplaceAll("%AppPath%", "z:"+ItemLLItem.PathApp)
		      PathIn = PathIn.ReplaceAll("%ppGames%", "C:/ppGames")
		      PathIn = PathIn.ReplaceAll("%ppApps%", "C:/ppApps")
		      
		      PathIn = PathIn.ReplaceAll("%INIPath%", "z:"+ItemLLItem.PathINI)
		      PathIn = PathIn.ReplaceAll("%ProgramFiles%", "C:/Program Files")
		      PathIn = PathIn.ReplaceAll("%ProgramFiles(x86)%", "C:/Program Files (x86)")
		      PathIn = PathIn.ReplaceAll("%ProgramData%", "C:/ProgramData")
		      PathIn = PathIn.ReplaceAll("%SystemDrive%", "C:")
		      PathIn = PathIn.ReplaceAll("%SystemRoot%", "C:/windows")
		      PathIn = PathIn.ReplaceAll("%WinDir%", "C:/windows")
		      
		      PathIn = PathIn.ReplaceAll("%LocalAppData%", "C:/users/"+UserName+"/AppData/Local")
		      
		      PathIn = PathIn.ReplaceAll("%ppGamesDrive%", "C:")
		      PathIn = PathIn.ReplaceAll("%ppAppsDrive%", "C:")
		      
		      PathIn = PathIn.ReplaceAll("%Extract%", "z:"+Win7z+" -mtc -aoa x ") 'This is only used by Wine Scripts, I'll make another method for Linux as needed for Bash Scripts
		      
		      PathIn = PathIn.ReplaceAll("%Desktop%",  FixPath("z:"+NoSlash(SpecialFolder.Desktop.NativePath)))
		      PathIn = PathIn.ReplaceAll("%AppData%",  "C:/users/"+UserName+"/AppData/Roaming")
		    Else
		      PathIn = PathIn.ReplaceAll("%AppPath%", ItemLLItem.PathApp)
		      PathIn = PathIn.ReplaceAll("%ppGames%", NoSlash(ppGames))
		      PathIn = PathIn.ReplaceAll("%ppApps%", NoSlash(ppApps))
		      
		      PathIn = PathIn.ReplaceAll("%INIPath%", ItemLLItem.PathINI)
		      PathIn = PathIn.ReplaceAll("%ProgramFiles%", HomePath +  ".wine/drive_c/Program Files")
		      PathIn = PathIn.ReplaceAll("%ProgramFiles(x86)%", HomePath +  ".wine/drive_c/Program Files (x86)")
		      PathIn = PathIn.ReplaceAll("%ProgramData%", HomePath +  ".wine/drive_c/ProgramData")
		      PathIn = PathIn.ReplaceAll("%SystemDrive%", HomePath +  ".wine/drive_c")
		      PathIn = PathIn.ReplaceAll("%SystemRoot%", HomePath +  ".wine/drive_c/windows")
		      PathIn = PathIn.ReplaceAll("%WinDir%", HomePath +  ".wine/drive_c/windows")
		      
		      PathIn = PathIn.ReplaceAll("%LocalAppData%", HomePath +  ".wine/drive_c/users/"+UserName+"/AppData/Local")
		      
		      PathIn = PathIn.ReplaceAll("%ppGamesDrive%", HomePath +  ".wine/drive_c")
		      PathIn = PathIn.ReplaceAll("%ppAppsDrive%", HomePath +  ".wine/drive_c")
		      
		      PathIn = PathIn.ReplaceAll("%Extract%", Linux7z+" -mtc -aoa x ") 'This is only used by Wine Scripts, I'll make another method for Linux as needed for Bash Scripts
		      
		      PathIn = PathIn.ReplaceAll("%Desktop%", FixPath(NoSlash(SpecialFolder.Desktop.NativePath)))
		      PathIn = PathIn.ReplaceAll("%AppData%", FixPath(NoSlash(SpecialFolder.ApplicationData.NativePath)))
		      
		    End If
		  End If
		  
		  'Do This Last so can conver subpaths above first
		  PathIn = PathIn.ReplaceAll("$HOME", NoSlash(HomePath))
		  
		  'Change Flatpak --user to --system Or Vice Versa as set (Defaults to User)
		  If FlatPakAsUser = True Then
		    PathIn = PathIn.ReplaceAll("--system", "--user")
		  Else 'Must be System Wide
		    PathIn = PathIn.ReplaceAll("--user", "--system")
		  End If
		  
		  Return PathIn
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExpPathReg(PathIn As String, WinPaths As Boolean = False) As String
		  If Debugging Then Debug("ExpReg = " +PathIn)
		  
		  Dim UserName As String
		  
		  If TargetLinux Then UserName = Right( NoSlash(HomePath), Len( NoSlash(HomePath)) - InStrRev( NoSlash(HomePath), "/"))
		  
		  'MsgBox UserName
		  Dim Dat As String
		  Dat = Slash(HomePath)+"LLGames"
		  Dat = Dat.ReplaceAll("/","\")
		  Dat = Dat.ReplaceAll("\","\\")
		  PathIn = PathIn.ReplaceAll("%LLGames%", Dat)
		  Dat = Slash(HomePath)+"LLApps"
		  Dat = Dat.ReplaceAll("/","\")
		  Dat = Dat.ReplaceAll("\","\\")
		  PathIn = PathIn.ReplaceAll("%LLApps%", Dat)
		  
		  'Below will only be used in Windows and Wine, so can use Disk Letters
		  If TargetWindows Then
		    Dat = ItemLLItem.PathApp
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%AppPath%", Dat)
		    Dat = NoSlash(ppGames)
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%ppGames%", Dat)
		    Dat = NoSlash(ppApps)
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%ppApps%", Dat)
		    Dat = ItemLLItem.PathINI
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%INIPath%", Dat)
		    Dat = NoSlash(SysProgramFiles)
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%ProgramFiles%", Dat)
		    Dat = NoSlash(SysProgramFiles)+" (x86)"
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%ProgramFiles(x86)%", Dat)
		    Dat = NoSlash(SysDrive)+"\ProgramData"
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%ProgramData%", Dat)
		    Dat = NoSlash(SysDrive)
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%SystemDrive%", Dat)
		    Dat = NoSlash(SysRoot)
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%SystemRoot%", Dat)
		    Dat = NoSlash(SysRoot)
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%WinDir%", Dat)
		    
		    Dat = NoSlash(SpecialFolder.ApplicationData.Parent.NativePath)+"\Local"
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%LocalAppData%", Dat)
		    
		    Dat = NoSlash(SpecialFolder.ApplicationData.NativePath)
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%AppData%", Dat)
		    Dat = "z:"+NoSlash(SpecialFolder.Desktop.NativePath)
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%Desktop%",  Dat)
		    
		    Dat = Left(ppGames,2)
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%ppGamesDrive%", Dat)
		    Dat = Left(ppApps,2)
		    Dat = Dat.ReplaceAll("/","\")
		    Dat = Dat.ReplaceAll("\","\\")
		    PathIn = PathIn.ReplaceAll("%ppAppsDrive%", Dat)
		    
		    PathIn = PathIn.ReplaceAll("%USBDrive%", Left(AppPath,2)) 'Convert USB/DVD your running off  to correct Path
		    
		    'Use one from ssWPI for this path
		    'Dat = "C:\Users\"+UserName+"\Desktop"
		    'Dat = 
		    'Dat = Dat.ReplaceAll("\","\\")
		    'PathIn = PathIn.ReplaceAll("%Desktop%", Dat)
		    
		  Else 'Use Linux full paths instead (So can detect if installed etc first).
		    If WinPaths Then
		      Dat = "z:"+ItemLLItem.PathApp
		      Dat = Dat.ReplaceAll("/","\")
		      Dat = Dat.ReplaceAll("\","\\")
		      PathIn = PathIn.ReplaceAll("%AppPath%", Dat)
		      Dat = "C:\ppGames"
		      Dat = Dat.ReplaceAll("/","\")
		      Dat = Dat.ReplaceAll("\","\\")
		      PathIn = PathIn.ReplaceAll("%ppGames%", Dat)
		      Dat = "C:\ppApps"
		      Dat = Dat.ReplaceAll("/","\")
		      Dat = Dat.ReplaceAll("\","\\")
		      PathIn = PathIn.ReplaceAll("%ppApps%", Dat)
		      Dat = "z:"+ItemLLItem.PathINI
		      Dat = Dat.ReplaceAll("/","\")
		      Dat = Dat.ReplaceAll("\","\\")
		      PathIn = PathIn.ReplaceAll("%INIPath%", Dat)
		      Dat = "C:\Program Files"
		      Dat = Dat.ReplaceAll("/","\")
		      Dat = Dat.ReplaceAll("\","\\")
		      PathIn = PathIn.ReplaceAll("%ProgramFiles%", Dat)
		      Dat = "C:\Program Files (x86)"
		      Dat = Dat.ReplaceAll("/","\")
		      Dat = Dat.ReplaceAll("\","\\")
		      PathIn = PathIn.ReplaceAll("%ProgramFiles(x86)%", Dat)
		      Dat = "C:\ProgramData"
		      Dat = Dat.ReplaceAll("/","\")
		      Dat = Dat.ReplaceAll("\","\\")
		      PathIn = PathIn.ReplaceAll("%ProgramData%", Dat)
		      Dat = "C:"
		      Dat = Dat.ReplaceAll("/","\")
		      Dat = Dat.ReplaceAll("\","\\")
		      PathIn = PathIn.ReplaceAll("%SystemDrive%", Dat)
		      Dat = "C:\windows"
		      Dat = Dat.ReplaceAll("/","\")
		      Dat = Dat.ReplaceAll("\","\\")
		      PathIn = PathIn.ReplaceAll("%SystemRoot%", Dat)
		      Dat = "C:\windows"
		      Dat = Dat.ReplaceAll("/","\")
		      Dat = Dat.ReplaceAll("\","\\")
		      PathIn = PathIn.ReplaceAll("%WinDir%", Dat)
		      
		      Dat = "C:\users\"+UserName+"\AppData\Roaming"
		      Dat = Dat.ReplaceAll("/","\")
		      Dat = Dat.ReplaceAll("\","\\")
		      PathIn = PathIn.ReplaceAll("%AppData%", Dat)
		      Dat = "C:\users\"+UserName+"\AppData\Local"
		      Dat = Dat.ReplaceAll("/","\")
		      Dat = Dat.ReplaceAll("\","\\")
		      PathIn = PathIn.ReplaceAll("%LocalAppData%", Dat)
		      Dat = "C:"
		      PathIn = PathIn.ReplaceAll("%ppGamesDrive%", Dat)
		      Dat = "C:"
		      PathIn = PathIn.ReplaceAll("%ppAppsDrive%", Dat)
		      
		      PathIn = PathIn.ReplaceAll("%USBDrive%", "z:") 'Convert USB/DVD your running off  to correct Path
		      
		      'Dat = "z:/home/"+UserName+"/Desktop"
		      'Dat = Dat.ReplaceAll("/","\")
		      'Dat = Dat.ReplaceAll("/","//")
		      'PathIn = PathIn.ReplaceAll("%Desktop%", Dat)
		      
		    Else
		      'Unused
		    End If
		  End If
		  
		  Return PathIn
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExpPathScript(PathIn As String, WinPaths As Boolean = False) As String
		  If Debugging Then Debug("ExpPathScript = " +PathIn)
		  Dim UserName As String
		  If TargetLinux Then UserName = Right( NoSlash(HomePath), Len( NoSlash(HomePath)) - InStrRev( NoSlash(HomePath), "/"))
		  
		  PathIn = PathIn.ReplaceAll("%LLGames%", Slash(HomePath)+"LLGames")
		  PathIn = PathIn.ReplaceAll("%LLApps%", Slash(HomePath)+"LLApps")
		  
		  'Below will only be used in Windows and Wine, so can use Disk Letters
		  If TargetWindows Then
		    PathIn = PathIn.ReplaceAll("%USBDrive%", Left(AppPath,2)) 'Convert USB/DVD your running off  to correct Path
		    
		    PathIn = PathIn.ReplaceAll("%AppPath%", ItemLLItem.PathApp)
		    PathIn = PathIn.ReplaceAll("%ppGames%", NoSlash(ppGames))
		    PathIn = PathIn.ReplaceAll("%ppApps%", NoSlash(ppApps))
		    
		    PathIn = PathIn.ReplaceAll("%INIPath%", ItemLLItem.PathINI)
		    PathIn = PathIn.ReplaceAll("%ProgramFiles%", NoSlash(SysProgramFiles))
		    PathIn = PathIn.ReplaceAll("%ProgramFiles(x86)%", NoSlash(SysProgramFiles)+" (x86)")
		    PathIn = PathIn.ReplaceAll("%ProgramData%", NoSlash(SysDrive)+"/ProgramData")
		    PathIn = PathIn.ReplaceAll("%SystemDrive%", NoSlash(SysDrive))
		    PathIn = PathIn.ReplaceAll("%SystemRoot%", NoSlash(SysRoot))
		    PathIn = PathIn.ReplaceAll("%WinDir%", NoSlash(SysRoot))
		    
		    PathIn = PathIn.ReplaceAll("%LocalAppData%", FixPath(NoSlash(SpecialFolder.ApplicationData.Parent.NativePath)+"/Local"))
		    
		    PathIn = PathIn.ReplaceAll("%ppGamesDrive%", Left(ppGames,2))
		    PathIn = PathIn.ReplaceAll("%ppAppsDrive%", Left(ppApps,2))
		    PathIn = PathIn.ReplaceAll("%Extract%", Win7z+" -mtc -aoa x ")
		    
		    PathIn = PathIn.ReplaceAll("%Desktop%",  FixPath(NoSlash(SpecialFolder.Desktop.NativePath)))
		    PathIn = PathIn.ReplaceAll("%AppData%",  FixPath(NoSlash(SpecialFolder.ApplicationData.NativePath)))
		    
		  Else 'Use Linux full paths instead (So can detect if installed etc first).
		    If WinPaths Then
		      PathIn = PathIn.ReplaceAll("%USBDrive%", "z:") 'Convert USB/DVD your running off  to correct Path
		      
		      PathIn = PathIn.ReplaceAll("%AppPath%", "z:"+ItemLLItem.PathApp)
		      PathIn = PathIn.ReplaceAll("%ppGames%", "C:/ppGames")
		      PathIn = PathIn.ReplaceAll("%ppApps%", "C:/ppApps")
		      
		      PathIn = PathIn.ReplaceAll("%INIPath%", "z:"+ItemLLItem.PathINI)
		      PathIn = PathIn.ReplaceAll("%ProgramFiles%", "C:/Program Files")
		      PathIn = PathIn.ReplaceAll("%ProgramFiles(x86)%", "C:/Program Files (x86)")
		      PathIn = PathIn.ReplaceAll("%ProgramData%", "C:/ProgramData")
		      PathIn = PathIn.ReplaceAll("%SystemDrive%", "C:")
		      PathIn = PathIn.ReplaceAll("%SystemRoot%", "C:/windows")
		      PathIn = PathIn.ReplaceAll("%WinDir%", "C:/windows")
		      
		      PathIn = PathIn.ReplaceAll("%LocalAppData%", "C:/users/"+UserName+"/AppData/Local")
		      
		      PathIn = PathIn.ReplaceAll("%ppGamesDrive%", "C:")
		      PathIn = PathIn.ReplaceAll("%ppAppsDrive%", "C:")
		      
		      PathIn = PathIn.ReplaceAll("%Extract%", "z:"+Win7z+" -mtc -aoa x ") 'This is only used by Wine Scripts, I'll make another method for Linux as needed for Bash Scripts
		      
		      PathIn = PathIn.ReplaceAll("%Desktop%", FixPath("z:"+NoSlash(SpecialFolder.Desktop.NativePath)))
		      PathIn = PathIn.ReplaceAll("%AppData%", "C:/users/"+UserName+"/AppData/Roaming")
		      
		    Else
		      PathIn = PathIn.ReplaceAll("%AppPath%", ItemLLItem.PathApp)
		      PathIn = PathIn.ReplaceAll("%ppGames%", NoSlash(ppGames))
		      PathIn = PathIn.ReplaceAll("%ppApps%", NoSlash(ppApps))
		      
		      PathIn = PathIn.ReplaceAll("%INIPath%", ItemLLItem.PathINI)
		      PathIn = PathIn.ReplaceAll("%ProgramFiles%", HomePath +  ".wine/drive_c/Program Files")
		      PathIn = PathIn.ReplaceAll("%ProgramFiles(x86)%", HomePath +  ".wine/drive_c/Program Files (x86)")
		      PathIn = PathIn.ReplaceAll("%ProgramData%", HomePath +  ".wine/drive_c/ProgramData")
		      PathIn = PathIn.ReplaceAll("%SystemDrive%", HomePath +  ".wine/drive_c")
		      PathIn = PathIn.ReplaceAll("%SystemRoot%", HomePath +  ".wine/drive_c/windows")
		      PathIn = PathIn.ReplaceAll("%WinDir%", HomePath +  ".wine/drive_c/windows")
		      
		      PathIn = PathIn.ReplaceAll("%LocalAppData%", HomePath +  ".wine/drive_c/users/"+UserName+"/AppData/Local")
		      
		      PathIn = PathIn.ReplaceAll("%ppGamesDrive%", HomePath +  ".wine/drive_c")
		      PathIn = PathIn.ReplaceAll("%ppAppsDrive%", HomePath +  ".wine/drive_c")
		      
		      PathIn = PathIn.ReplaceAll("%Extract%", Win7z) 'This is only used by Wine Scripts, I'll make another method for Linux as needed for Bash Scripts
		      
		      PathIn = PathIn.ReplaceAll("%Desktop%",  FixPath(NoSlash(SpecialFolder.Desktop.NativePath)))
		      PathIn = PathIn.ReplaceAll("%AppData%",  FixPath(NoSlash(SpecialFolder.ApplicationData.NativePath)))
		    End If
		  End If
		  
		  'Do This Last so can conver subpaths above first
		  PathIn = PathIn.ReplaceAll("$HOME", NoSlash(HomePath))
		  
		  
		  'Add MSI installer to lines that have a .msi in them
		  If Left(PathIn.Lowercase,3) = "rem" Then 'skip rem lines, incase it's not suposed to run.
		  Else
		    If PathIn.IndexOf(".msi") >=1 Then
		      If Left(PathIn,7) <> "msiexec" Then
		        'If Left(PathIn,1)<>Chr(34) Then 'Need to check for end of .msi and remove /qb if it's an issue
		        PathIn = "msiexec /quiet /norestart /i "+PathIn
		      Else
		      End If
		    End If
		  End If
		  
		  'Change Flatpak --user to --system Or Vice Versa as set (Defaults to User)
		  If FlatpakAsUser = True Then
		    PathIn = PathIn.ReplaceAll("--system", "--user")
		  Else 'Must be System Wide
		    PathIn = PathIn.ReplaceAll("--user", "--system")
		  End If
		  
		  
		  Return PathIn
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExpReg(OrigScript As String) As String
		  Dim F As FolderItem
		  Dim RL As String
		  Dim I As Integer
		  
		  Dim ScriptContent As String
		  Dim ScriptFile As String
		  Dim SP() As String
		  
		  F = GetFolderItem(OrigScript, FolderItem.PathTypeShell)
		  
		  'ScriptFile = Slash(FixPath(F.Parent.NativePath)+"Expanded_Registry.reg") 'Use InstallFrom Drive, not Temp
		  ScriptFile = Slash(FixPath(TmpPath))+"Expanded_Script.cmd"
		  
		  'Load in whole file at once (Fastest Method)
		  inputStream = TextInputStream.Open(F)
		  
		  While Not inputStream.EndOfFile 'If Empty file this skips it
		    RL = inputStream.ReadAll.ConvertEncoding(Encodings.ASCII)
		  Wend
		  inputStream.Close
		  RL = RL.ReplaceAll(Chr(13), Chr(10))
		  Sp()=RL.Split(Chr(10))
		  If Sp.Count <= 0 Then Return OrigScript ' Empty File or no header
		  For I = 0 To Sp().Count -1
		    ScriptContent = ScriptContent + ExpPathReg(Sp(I), True) + Chr(10)
		  Next I
		  
		  SaveDataToFile (ScriptContent, ScriptFile)
		  
		  Return ScriptFile
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExpScript(OrigScript As String, MakeSudo As Boolean = False) As String
		  Dim F As FolderItem
		  Dim RL As String
		  Dim I As Integer
		  
		  Dim ScriptContent As String
		  Dim ScriptFile As String
		  Dim SP() As String
		  
		  F = GetFolderItem(OrigScript, FolderItem.PathTypeShell)
		  
		  If Right(OrigScript,3) = ".sh" Then
		    ScriptFile = Slash(FixPath(TmpPath))+"Expanded_Script.sh"
		  Else
		    'ScriptFile = Slash(FixPath(F.Parent.NativePath)+"Expanded_Script.cmd") 'Use InstallFrom folder, not Temp
		    ScriptFile = Slash(FixPath(TmpPath))+"Expanded_Script.cmd"
		  End If
		  
		  If MakeSudo Then 'Make it ready to run from Sudo directly
		    ScriptFile = "/tmp/Expanded_Script.sh"
		  End If
		  
		  'Load in whole file at once (Fastest Method)
		  inputStream = TextInputStream.Open(F)
		  
		  While Not inputStream.EndOfFile 'If Empty file this skips it
		    RL = inputStream.ReadAll.ConvertEncoding(Encodings.ASCII)
		  Wend
		  inputStream.Close
		  RL = RL.ReplaceAll(Chr(13), Chr(10))
		  Sp()=RL.Split(Chr(10))
		  If Sp.Count <= 0 Then Return OrigScript ' Empty File or no header
		  For I = 0 To Sp().Count -1
		    If InstallToPath <> "" Then 'Only add CD if it's a valid path given ' We use InstallToPath even on NoInstalls as I set that path to be InstallFromPath.
		      If I = 1 Then
		        If Sp(I) <> "" Then
		          ScriptContent = ScriptContent + Chr(10) 'Adds space Line
		          If ItemLLItem.BuildType = "ssApp"Then
		            ScriptContent = ScriptContent + "cd "+Chr(34)+InstallFromPath+Chr(34)+Chr(10) 'Add cd to top of scripts so it runs from the right locations
		          Else
		            ScriptContent = ScriptContent + "cd "+Chr(34)+InstallToPath+Chr(34)+Chr(10) 'Add cd to top of scripts so it runs from the right locations
		          End If
		        Else
		          ScriptContent = ScriptContent + Chr(10) 'Adds space Line
		          If ItemLLItem.BuildType = "ssApp"Then
		            ScriptContent = ScriptContent + "cd "+Chr(34)+InstallFromPath+Chr(34)+Chr(10) 'Add cd to top of scripts so it runs from the right locations
		          Else
		            ScriptContent = ScriptContent + "cd "+Chr(34)+InstallToPath+Chr(34)+Chr(10) 'Add cd to top of scripts so it runs from the right locations
		          End If
		          Continue 'No Need to add a 2nd space line below
		        End If
		      End If
		    End If
		    ScriptContent = ScriptContent + ExpPathScript(Sp(I), True) + Chr(10)
		  Next I
		  
		  SaveDataToFile (ScriptContent, ScriptFile)
		  
		  MakeAllExec(ScriptFile)
		  
		  Return ScriptFile
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Extract(Archive As String, OutPath As String, ExcludesIncludes As String, Fast As Boolean = False) As Boolean
		  If Debugging Then Debug("--- Starting Extract ---")
		  Dim Commands As String
		  Dim F As FolderItem
		  Dim AssemblyFile, AssemblyContent As String
		  
		  If Not Exist(Archive) Then Return False 'Failed, not found
		  If OutPath = "" Then Return False 'No Dest set
		  
		  Dim Sh As New Shell
		  Sh.TimeOut = -1 'Give it All the time it needs
		  Sh.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  
		  Dim Zip As String
		  Zip = Linux7z
		  if TargetWindows Then Zip = Win7z
		  
		  'Make sure there is a space in the excludes/includes
		  If ExcludesIncludes <> "" Then
		    If Left(ExcludesIncludes,1) <>" " Then ExcludesIncludes = " "+ ExcludesIncludes
		  End If
		  
		  'Make the OutPath so it has somewhere to extract in to
		  If Not Exist(OutPath) Then MakeFolder(OutPath)
		  If Exist(OutPath) Then 'Only do it if somewhere to go
		    If Right(Archive,4) = ".tar" Then
		      Sh.Execute (Zip + " -mtc -aoa x "+Chr(34)+Archive+Chr(34)+ " -o"+Chr(34) + OutPath+Chr(34)+ExcludesIncludes)
		      Do
		        App.DoEvents(7)  ' used to be 50, trying 7 to see if more responsive. - It is
		      Loop Until Sh.IsRunning = False
		      If Debugging Then Debug(Sh.Result)
		    Else
		      If Right(Archive,3) = ".gz" Then
		        Sh.Execute ("tar -xf " + Chr(34) + Archive + Chr(34) + " -C " + Chr(34) + OutPath + Chr(34) + ExcludesIncludes)
		        Do
		          App.DoEvents(7)  ' used to be 50, trying 7 to see if more responsive. - It is
		        Loop Until Sh.IsRunning = False
		        If Debugging Then Debug(Sh.Result)
		      Else 'Just treat it as a standard non Linux zip, 7z etc works fine for this as it doesn't need to handle symlinks (7z can't extract tar.gz files)
		        Commands = Zip + " -mtc -aoa x "+Chr(34)+Archive+Chr(34)+ " -o"+Chr(34) + OutPath+Chr(34)+ExcludesIncludes
		        If TargetWindows Then
		          RunCommand (Commands)
		        Else'Linux
		          Sh.Execute (Commands)
		          Do
		            App.DoEvents(7)  ' used to be 50, trying 7 to see if more responsive. - It is
		          Loop Until Sh.IsRunning = False
		          If Debugging Then Debug(Sh.Result)
		        End If
		      End If
		    End If
		    MakeAllExec(OutPath)
		    Return True 'Succeeded maybe?
		  End If
		  
		  Return False 'Failed <- For now to save trying to load dead items, return True to load them
		  
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FileExists(InTXT As String) As Boolean
		  'Returns a True or False of if a File or Folder exists, only in Windows
		  
		  If InTXT <> "" Then
		    Declare Function GetFileAttributes Lib "kernel32" Alias "GetFileAttributesA" (lpFileName As CString) As Integer
		    
		    If GetFileAttributes (InTXT) <> -1 Then
		      Return True
		    End If
		  End If
		  Return False 'Return False if Empty file given or Not found
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FixCatalog(CatIn As String) As String
		  CatIn = CatIn.ReplaceAll("Games"+Chr(92), "")
		  CatIn = CatIn.ReplaceAll("Gamess", "Games")
		  CatIn = CatIn.ReplaceAll("|", "; ")
		  CatIn = CatIn.Trim
		  If Right (CatIn,1) <>";" Then CatIn=CatIn+";"
		  CatIn = CatIn.ReplaceAll("Games;", "Game;")
		  If Left(CatIn, 6) = "Game; " Then CatIn = Right (CatIn, Len(CatIn) -6) 'Remove Game; from the start so looks nicer in the MetaData fields, Gets Added to end below too
		  If Left(CatIn, 5) = "Game " Then CatIn = Right (CatIn, Len(CatIn) -5) 'Remove Game  from the start of some cats (Not sure what adds them, but take them out)
		  CatIn = CatIn.ReplaceAll("  ", " ") 'Remove Double Spaces
		  
		  CatIn = CatIn.ReplaceAll("First-Person Shooter", "FirstPersonShooter")
		  CatIn = CatIn.ReplaceAll("Third-Person Shooter", "ThirdPersonShooter")
		  CatIn = CatIn.ReplaceAll("Hidden Object", "HiddenObject")
		  CatIn = CatIn.ReplaceAll("Role Playing", "RolePlaying")
		  CatIn = CatIn.ReplaceAll("RollPlaying", "RolePlaying")
		  CatIn = CatIn.ReplaceAll("Racing-Driving", "Racing; Driving")
		  CatIn = CatIn.ReplaceAll("Tower Defense", "TowerDefense")
		  CatIn = CatIn.ReplaceAll("Farming & Crafting", "Farming; Crafting")
		  
		  Return CatIn
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FixGameCats(CatIn As String) As String
		  CatIn = CatIn.ReplaceAll("Games"+Chr(92), "")
		  CatIn = CatIn.ReplaceAll("Gamess", "Games")
		  CatIn = CatIn.ReplaceAll("|", "; ")
		  CatIn = CatIn.Trim
		  If Right (CatIn,1) <>";" Then CatIn=CatIn+";"
		  CatIn = CatIn.ReplaceAll("Games;", "Game;")
		  If Left(CatIn, 6) = "Game; " Then CatIn = Right (CatIn, Len(CatIn) -6) 'Remove Game; from the start so looks nicer in the MetaData fields, Gets Added to end below too
		  If Left(CatIn, 5) = "Game " Then CatIn = Right (CatIn, Len(CatIn) -5) 'Remove Game  from the start of some cats (Not sure what adds them, but take them out)
		  CatIn = CatIn.ReplaceAll("  ", " ") 'Remove Double Spaces
		  
		  CatIn = CatIn.ReplaceAll("First-Person Shooter", "FirstPersonShooter")
		  CatIn = CatIn.ReplaceAll("Third-Person Shooter", "ThirdPersonShooter")
		  CatIn = CatIn.ReplaceAll("Hidden Object", "HiddenObject")
		  CatIn = CatIn.ReplaceAll("Role Playing", "RolePlaying")
		  CatIn = CatIn.ReplaceAll("RollPlaying", "RolePlaying")
		  CatIn = CatIn.ReplaceAll("Racing-Driving", "Racing; Driving")
		  CatIn = CatIn.ReplaceAll("Tower Defense", "TowerDefense")
		  CatIn = CatIn.ReplaceAll("Farming & Crafting", "Farming; Crafting")
		  
		  Return CatIn
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FixPath(InnPath As String) As String
		  InnPath = InnPath.ReplaceAll("\","/")
		  Return InnPath
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetCatalogRedirects()
		  Dim F As FolderItem
		  Dim Sp() As String
		  Dim RL As String
		  Dim I, J As Integer
		  Dim LineID, LineData As String
		  Dim LDSplit() As String
		  
		  Dim Test As String
		  
		  RedirectAppCount = 0
		  
		  F = GetFolderItem (Slash(ToolPath)+"MenuCatalogApps_Redirects.ini", FolderItem.PathTypeShell)
		  
		  'Load in whole file at once (Fastest Method)
		  If F.Exists Then
		    inputStream = TextInputStream.Open(F)
		    While Not inputStream.EndOfFile 'If Empty file this skips it
		      RL = inputStream.ReadAll.ConvertEncoding(Encodings.ASCII)
		    Wend
		    inputStream.Close
		    RL = RL.ReplaceAll(Chr(13), Chr(10))
		    RL = RL.ReplaceAll(Chr(10)+Chr(10), Chr(10)) ' Remove Duplicate Chr(10)'s
		    Sp()=RL.Split(Chr(10))
		    If Sp.Count >= 1 Then 
		      For I = 0 To Sp.Count - 1
		        Sp(I) = Sp(I).Trim
		        If Sp(I)<>"" Then 'Don't do Empty Lines
		          If InStrRev(Sp(I),"=") >=1 Then
		            LineID = Left(Sp(I),InStrRev(Sp(I),"="))
		            LineData = Right(Sp(I),Len(Sp(I))-InStrRev(Sp(I),"="))
		            LineData=LineData.Trim
		            LineID = Left(LineID, Len(LineID)-1) 'Remove Equals
		            LDSplit() =LineData.Split("|") 
		            If LDSplit.Count >= 1 Then
		              For J = 0 To LDSplit.Count - 1
		                RedirectsApp(RedirectAppCount,0) = LDSplit(J)
		                RedirectsApp(RedirectAppCount,1) = LineID
		                RedirectAppCount = RedirectAppCount + 1
		              Next J
		              
		            Else 'Only one item
		              RedirectsApp(RedirectAppCount,0) = LineData
		              RedirectsApp(RedirectAppCount,1) = LineID
		              RedirectAppCount = RedirectAppCount + 1
		            End If
		            
		          Else 'No Equals, just add itself and make it = Itself
		            RedirectsApp(RedirectAppCount,0) = Sp(I)
		            RedirectsApp(RedirectAppCount,1) = Sp(I)
		            RedirectAppCount = RedirectAppCount + 1
		          End If
		        End If
		      Next I
		    End If
		  End If
		  
		  F = GetFolderItem (Slash(ToolPath)+"MenuCatalogGames_Redirects.ini", FolderItem.PathTypeShell)
		  
		  RedirectGameCount = 0
		  
		  'Load in whole file at once (Fastest Method)
		  If F.Exists Then
		    inputStream = TextInputStream.Open(F)
		    While Not inputStream.EndOfFile 'If Empty file this skips it
		      RL = inputStream.ReadAll.ConvertEncoding(Encodings.ASCII)
		    Wend
		    inputStream.Close
		    RL = RL.ReplaceAll(Chr(13), Chr(10))
		    RL = RL.ReplaceAll(Chr(10)+Chr(10), Chr(10)) ' Remove Duplicate Chr(10)'s
		    Sp()=RL.Split(Chr(10))
		    If Sp.Count >= 1 Then 
		      For I = 0 To Sp.Count - 1
		        Sp(I) = Sp(I).Trim
		        If Sp(I)<>"" Then 'Don't do Empty Lines
		          If InStrRev(Sp(I),"=") >=1 Then
		            LineID = Left(Sp(I),InStrRev(Sp(I),"="))
		            LineData = Right(Sp(I),Len(Sp(I))-InStrRev(Sp(I),"="))
		            LineData=LineData.Trim
		            LineID = Left(LineID, Len(LineID)-1) 'Remove Equals
		            LDSplit() =LineData.Split("|") 
		            If LDSplit.Count >= 1 Then
		              For J = 0 To LDSplit.Count - 1
		                RedirectsGame(RedirectGameCount,0) = LDSplit(J)
		                RedirectsGame(RedirectGameCount,1) = LineID
		                RedirectGameCount = RedirectGameCount + 1
		              Next J
		              
		            Else 'Only one item
		              RedirectsGame(RedirectGameCount,0) = LineData
		              RedirectsGame(RedirectGameCount,1) = LineID
		              RedirectGameCount = RedirectGameCount + 1
		            End If
		            
		          Else 'No Equals, just add itself and make it = Itself
		            RedirectsGame(RedirectGameCount,0) = Sp(I)
		            RedirectsGame(RedirectGameCount,1) = Sp(I)
		            RedirectGameCount = RedirectGameCount + 1
		          End If
		        End If
		      Next I
		    End If
		  End If
		  
		  
		  
		  MenuWindowsCount = 0
		  F = GetFolderItem (Slash(ToolPath)+"MenuWindows.ini", FolderItem.PathTypeShell)
		  
		  'Load in whole file at once (Fastest Method)
		  If F.Exists Then
		    inputStream = TextInputStream.Open(F)
		    While Not inputStream.EndOfFile 'If Empty file this skips it
		      RL = inputStream.ReadAll.ConvertEncoding(Encodings.ASCII)
		    Wend
		    inputStream.Close
		    RL = RL.ReplaceAll(Chr(13), Chr(10))
		    RL = RL.ReplaceAll(Chr(10)+Chr(10), Chr(10)) ' Remove Duplicate Chr(10)'s
		    Sp()=RL.Split(Chr(10))
		    If Sp.Count >= 1 Then 
		      For I = 0 To Sp.Count - 1
		        Sp(I) = Sp(I).Trim
		        If Sp(I)<>"" Then 'Don't do Empty Lines
		          If InStrRev(Sp(I),"=") >=1 Then
		            LineID = Left(Sp(I),InStrRev(Sp(I),"="))
		            LineData = Right(Sp(I),Len(Sp(I))-InStrRev(Sp(I),"="))
		            LineData=LineData.Trim
		            LineID = Left(LineID, Len(LineID)-1) 'Remove Equals
		            LDSplit() =LineData.Split("|") 
		            If LDSplit.Count >= 1 Then
		              For J = 0 To LDSplit.Count - 1
		                MenuWindows(MenuWindowsCount,0) = LineID
		                MenuWindows(MenuWindowsCount,1) = LDSplit(J)
		                MenuWindowsCount = MenuWindowsCount + 1
		              Next J
		              
		            Else 'Only one item
		              MenuWindows(MenuWindowsCount,0) = LineID
		              MenuWindows(MenuWindowsCount,1) = LineData
		              MenuWindowsCount = MenuWindowsCount + 1
		            End If
		            
		          Else 'No Equals, just add itself and make it = Itself
		            MenuWindows(MenuWindowsCount,0) = Sp(I)
		            MenuWindows(MenuWindowsCount,1) = Sp(I)
		            MenuWindowsCount = MenuWindowsCount + 1
		          End If
		        End If
		      Next I
		    End If
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetFullParent(PatIn As String) As String
		  PatIn = PatIn.ReplaceAll("\","/") 'If using Linux paths, use linux paths
		  PatIn = Left(PatIn,InStrRev(PatIn,"/")) 'Gets Parent Path
		  
		  Return PatIn
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetLongPath(InPath As String) As String
		  'Returns a Long Path from a Short path
		  
		  Declare Function GetLongPathNameA Lib "Kernel32" ( lpShortPath As CString, lpLongPath As Ptr, bufferLength As Integer ) As Integer
		  Dim Buff As New MemoryBlock (4096)
		  Dim BuffLen As Integer
		  Dim Ret As String
		  
		  BuffLen = GetLongPathNameA (InPath, Buff, 4096)
		  Ret = Buff
		  
		  Ret = Left(Ret, BuffLen)
		  If  Ret = "" Then Ret = InPath 'if it already was a long path, just return the in path
		  
		  Return Ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InstallLLFile(FileIn As String) As Boolean
		  If Debugging Then Debug("--- Starting Install LLFile ---")
		  If TargetWindows Then
		    FileIn = FileIn.ReplaceAll("/","\") 'Make it more windowsy so it works better when installing from windows
		  End If
		  
		  'App.DoEvents(1) 'Redraw Forms
		  
		  Dim Success As Boolean
		  Dim Shelly As New Shell
		  
		  'Dim TmpNumber As Integer = Randomiser.InRange(10000, 20000)
		  Dim FileToExtract As String
		  
		  Shelly.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  Shelly.TimeOut = -1
		  
		  'Clear Temp Path incase it fails to load
		  ItemTempPath = ""
		  
		  'Load in the LLFile
		  Success = LoadLLFile(FileIn, "", True) '"" Means it will generate a new Temp folder and return it as TempInstall Globally and the True means Install Item, will extract whole archive, not just LLFile resources
		  If Debugging Then Debug("Install Loading in File: "+FileIn + " ItemTempPath: " + ItemTempPath +" Good: "+Success.ToString)
		  
		  
		  'SaveDataToFile("Loading "+FileIn+" "+Str(Success)+Chr(10)+TempInstall+Chr(10)+ItemTempPath, SpecialFolder.Desktop.NativePath+"/Debug1.txt")
		  
		  If Success = False Then
		    If Debugging Then Debug("* Error: Failed - Aborting Install")
		    Return False ' Couldn't Load Item
		  End If
		  
		  'Make sure Sudo is available during ANY install (if not required for instaling one item then can skip it)
		  If InstallOnly Then
		    Select Case ItemLLItem.BuildType 
		    Case "ssApp", "ppApp", "ppGame"
		    Case Else 'Linux Item, may need script so always run it
		      EnableSudoScript
		    End Select
		  Else 'MiniInstaller method should always run the script in Linux
		    EnableSudoScript
		  End If
		  
		  
		  If TempInstall = "" Then 'Uncompressed item, no temp folder used
		    InstallFromPath = GetFullParent(FileIn) 'Removes .lla .app etc file ' just keep path
		  Else
		    InstallFromPath = ItemTempPath 'Use the Temp Path from extracting the Item for everything it needs
		  End If
		  
		  If Debugging Then Debug("Installing From Path: "+ InstallFromPath)
		  
		  If ItemLLItem.NoInstall = False Then 'Has a Destination Path
		    
		    InstallToPath = Slash(ExpPath(ItemLLItem.PathApp))
		    
		    If Debugging Then Debug("Installing To Path: "+ InstallToPath)
		    
		    'Change to App/Games INI Path to run Assemblys from
		    'MsgBox "Current Path: " + InstallFromPath
		    If ChDirSet(InstallFromPath) = True Then ' Was successful
		    End If
		    
		    'Run Assemblies from ssApps, ppApps and ppGames etc
		    RunAssembly
		    
		    'Check InstallToPath Is correct or change if available
		    Dim Inst2 As String
		    If Not Exist(InstallToPath) Then
		      Inst2 = InstallToPath.ReplaceAll("Program Files", "Program Files (x86)")
		      If  Exist(Inst2) Then
		        InstallToPath = Inst2 'Change Program Files to (x86) if it does exist, that way it'll be in one place
		      End If
		    End If
		    
		    'Extract Files from Archives (Where applicable)
		    MakeFolder (InstallToPath) 'Make sure the folder exists or it can't copy files to it.
		    
		    If ItemLLItem.BuildType = "LLApp" Then FileToExtract = Slash(InstallFromPath)+ "LLApp.tar.gz"
		    If ItemLLItem.BuildType = "LLGame" Then FileToExtract = Slash(InstallFromPath)+ "LLGame.tar.gz"
		    
		    If ItemLLItem.BuildType = "ppApp" Then FileToExtract = Slash(InstallFromPath) + "ppApp.7z"
		    If ItemLLItem.BuildType = "ppGame" Then FileToExtract = Slash(InstallFromPath) + "ppGame.7z"
		    If FileToExtract <> "" Then
		      If Exist(FileToExtract) Then
		        Success = Extract(FileToExtract, InstallToPath, "")
		        If Not Success Then 'Clean Up And Return (This is required, else it'll not work anyway, so abort)
		          Return False ' Failed to extract
		        End If
		      End If
		    End If
		    
		    'Extract Patch Files
		    FileToExtract = Slash(InstallFromPath) + "Patch.7z"
		    If FileToExtract <> "" Then
		      If Exist(FileToExtract) Then
		        Success = Extract(FileToExtract, InstallToPath, "")
		        If Not Success Then 'Clean Up And Return
		          'Return False ' Failed to extract 'Disabled for now, if the patch fails, it'll still run, just not pre configured
		        End If
		      End If
		    End If
		    
		    
		    'Copy LLFiles to the Install folder (So Games Launcher has the Link Info and Screenshots/Fader etc 'This will copy all but archives, Need to manually copy the ssApp and ppApp files after this
		    If TargetWindows Then
		      'Find another way to copy in Windows? (RoboCopy)
		      'https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy
		      
		      Copy(Slash(InstallFromPath) +ItemLLItem.BuildType+".app", Slash(InstallToPath) +ItemLLItem.BuildType+ ".app")
		      Copy(Slash(InstallFromPath) +ItemLLItem.BuildType+".ppg", Slash(InstallToPath) +ItemLLItem.BuildType+ ".ppg")
		      Copy(Slash(InstallFromPath) + ItemLLItem.BuildType+".reg", Slash(InstallToPath) +ItemLLItem.BuildType+ ".reg")
		      Copy(Slash(InstallFromPath) + ItemLLItem.BuildType+".cmd", Slash(InstallToPath) + ItemLLItem.BuildType+".cmd")
		      Copy(Slash(InstallFromPath) + ItemLLItem.BuildType+".jpg", Slash(InstallToPath) +ItemLLItem.BuildType+ ".jpg")
		      Copy(Slash(InstallFromPath) + ItemLLItem.BuildType+".png", Slash(InstallToPath) +ItemLLItem.BuildType+ ".png")
		      Copy(Slash(InstallFromPath) + ItemLLItem.BuildType+".ico", Slash(InstallToPath) +ItemLLItem.BuildType+ ".ico")
		      Copy(Slash(InstallFromPath) + ItemLLItem.BuildType+".mp4", Slash(InstallToPath) +ItemLLItem.BuildType+ ".mp4")
		      
		    Else 'Linux Mode
		      'Ignore LLApps???
		      If ItemLLItem.BuildType = "LLGame"  Then
		        Shelly.Execute ("rsync -a " + Chr(34) + Slash(InstallFromPath) + "." + Chr(34) + " " + Chr(34) + InstallToPath + Chr(34) + " --exclude=LLApp.tar.gz"+" --exclude=LLGame.tar.gz" +" --exclude=*.7z")
		        Do
		          App.DoEvents(7)  'Used to be 50, trying 7 to see if more responsive. - It is
		        Loop Until Shelly.IsRunning = False
		      End If
		      If ItemLLItem.BuildType = "ppGame"  Then
		        Shelly.Execute ("rsync -a " + Chr(34) + Slash(InstallFromPath) + "." + Chr(34) + " " + Chr(34) + InstallToPath + Chr(34) + " --exclude=LLApp.tar.gz"+" --exclude=LLGame.tar.gz" +" --exclude=*.7z")
		        Do
		          App.DoEvents(7)  'Used to be 50, trying 7 to see if more responsive. - It is
		        Loop Until Shelly.IsRunning = False
		      End If
		      If ItemLLItem.BuildType = "ppApp"  Then
		        Shelly.Execute ("rsync -a " + Chr(34) + Slash(InstallFromPath) + "." + Chr(34) + " " + Chr(34) + InstallToPath + Chr(34) + " --exclude=LLApp.tar.gz"+" --exclude=LLGame.tar.gz" +" --exclude=*.7z")
		        Do
		          App.DoEvents(7)  'Used to be 50, trying 7 to see if more responsive. - It is
		        Loop Until Shelly.IsRunning = False
		      End If
		      If ItemLLItem.BuildType = "ssApp" Then
		        Copy(Slash(InstallFromPath) + "ssApp.app", Slash(InstallToPath) + "ssApp.app")
		        Copy(Slash(InstallFromPath) + "ssApp.reg", Slash(InstallToPath) + "ssApp.reg")
		        Copy(Slash(InstallFromPath) + "ssApp.cmd", Slash(InstallToPath) + "ssApp.cmd")
		        Copy(Slash(InstallFromPath) + "ssApp.jpg", Slash(InstallToPath) + "ssApp.jpg")
		        Copy(Slash(InstallFromPath) + "ssApp.png", Slash(InstallToPath) + "ssApp.png")
		        Copy(Slash(InstallFromPath) + "ssApp.ico", Slash(InstallToPath) + "ssApp.ico")
		        
		        if Not TargetWindows Then 'Only Linux needs this, Win doesn't
		          ShellFast.Execute ("chmod 775 "+Chr(34)+Slash(InstallToPath) + "*.cmd"+Chr(34)) 'Change Read/Write/Execute to defaults
		          If Debugging Then Debug("Shell Fast Execute: "+"chmod 775 "+Chr(34)+Slash(InstallToPath) + "*.cmd"+Chr(34)+Chr(10)+"Results: " + ShellFast.Result )
		          ShellFast.Execute ("chmod 775 "+Chr(34)+Slash(InstallToPath) + "*.sh"+Chr(34)) 'Change Read/Write/Execute to defaults
		          If Debugging Then Debug("Shell Fast Execute: "+"chmod 775 "+Chr(34)+Slash(InstallToPath) + "*.sh"+Chr(34)+Chr(10)+"Results: " + ShellFast.Result )
		        End If
		      End If
		    End If
		    
		    'Change to App/Games Path to run scripts from
		    If ItemLLItem.BuildType = "ssApp" Then 
		      If ChDirSet(InstallFromPath) = True Then ' Was successful - ssApp path set
		      End If
		    Else
		      If ChDirSet(InstallToPath) = True Then ' Was successful - ppApp/Game path set
		      End If
		    End If
		    
		    'Run Scripts ' Still need to expand path here Glenn 2027
		    RunScripts
		    
		    'Run Registry Enteries
		    RunRegistry
		    
		    'Run Sudo Scripts
		    RunSudoScripts
		    
		    'Move ssApp Shortcuts to their sorted locations (Need to try in Linux to see if they get moved in there or I'll have to edit the .desktop files as well) Do this first so MakeLinks can use LLShorts to source the links
		    If ItemLLItem.BuildType = "ssApp" Then MoveLinks
		    
		    'Make Links
		    MakeLinks
		    
		    'Do Delete Temp Path here? if TempInstall has a path (Make sure it's in .lltemp
		    
		    
		  Else' NoInstall -  Just Run Scripts etc from Source folder (or Temp if Extracts it to one)
		    
		    'InstallToPath = InstallFromPath when a NoInstall item
		    InstallToPath = InstallFromPath
		    If Debugging Then Debug("Installing From/ No Output To Path: "+ InstallFromPath)
		    
		    'Change to App/Games INI Path to run Assemblys from
		    If ChDirSet(InstallFromPath) = True Then ' Was successful
		      'MsgBox "InstallTo Path: " + InstallToPath + " InstallFrom Path: " + InstallFromPath
		    End If
		    
		    'Run Assemblys
		    RunAssembly
		    
		    'No need to do Registry Stuff for linux items, but will see if any is in there anyway
		    RunRegistry
		    
		    'Run Scripts ' Still need to expand path here Glenn 2027
		    RunScripts
		    
		    'Run Sudo Scripts
		    '*** Make sure to add CD to the top of the script so it does it from the correct folder
		    RunSudoScripts
		    
		    'Make Links
		    MakeLinks
		    
		    
		  End If
		  
		  Return True ' Successfully Installed
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InStrRev(SourceString As String, FindString As String, Start As Integer = -1) As Integer
		  Dim k, LastFound, Length As Integer
		  
		  If SourceString = "" Then Return 0
		  If FindString = "" Then Return Start
		  k = Instr(SourceString, FindString)
		  LastFound = k
		  Length = Len(SourceString)
		  If Start = -1 Then Start = Length
		  If k > Start Or Start > Length Then Return 0
		  
		  While k > 0
		    LastFound = k
		    If k < Start Then k = Instr(LastFound+1, SourceString, FindString) Else Exit While
		  Wend
		  Return LastFound
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsAdmin() As Boolean
		  'Checks if running as admin by accessing a folder/file only admins can access.
		  
		  If TargetWindows Then
		    
		    Dim TMPShell As New Shell
		    'TMPShell.TimeOut = -1
		    TMPShell.Execute "echo Hi > "+Chr(34)+"%windir%\system32\AdminMode_LLStore.ini"+Chr(34) '+" >nul"
		    
		    If TMPShell.ErrorCode = 1 Then Return False 'No it's not Admin
		    
		    TMPShell.Execute "del /q /f "+Chr(34)+"%windir%\system32\AdminMode_LLStore.ini"+Chr(34) '+" >nul"
		    Return True 'Yes it is Admin
		  Else
		    Return False
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsFolder(TestPath As String) As Boolean
		  Dim F As FolderItem
		  #Pragma BreakOnExceptions Off
		  Try
		    F = GetFolderItem(TestPath, FolderItem.PathTypeShell)
		    If F <> Nil Then
		      If F.Exists Then
		        If F.IsFolder Then Return True
		      End If
		    End If
		  Catch
		  End Try
		  #Pragma BreakOnExceptions On
		  
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsTrue(Inn As String) As Boolean
		  Dim IsTrue As Boolean
		  IsTrue = False
		  Select Case Inn.Lowercase
		  Case "y", "tes",  "t", "true","1","on"
		    IsTrue = True
		  End Select
		  
		  Return IsTrue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LoadDataFromFile(FileIn As String) As String
		  If TargetWindows Then
		    FileIn = FileIn.ReplaceAll("/","\")
		  Else
		    FileIn = FileIn.ReplaceAll("\","/")
		  End If
		  
		  If FileIn <> "" Then
		    
		    If Debugging Then Debug("Load Data From File: "+ FileIn)
		    
		    Dim F As FolderItem
		    Dim T As TextInputStream
		    
		    #Pragma BreakOnExceptions Off
		    
		    Try
		      F = GetFolderItem(FileIn, FolderItem.PathTypeShell)
		      If F <> Nil Then
		        If F.Exists And F.IsReadable Then
		          T = TextInputStream.Open(F)
		          While Not T.EndOfFile 'If Empty file this skips it
		            Return T.ReadAll '.ConvertEncoding(Encodings.ASCII)
		          Wend
		          T.Close
		        End If
		      End If
		    Catch
		    End Try
		    Return ""
		    #Pragma BreakOnExceptions On
		  End If
		  
		  Return ""
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LoadLLFile(ItemInn As String, InnTmp As String = "", InstallItem As Boolean = False) As Boolean
		  'MsgBox "LoadLLFile: "+ ItemInn
		  
		  App.DoEvents(1)
		  ItemLLItem = BlankItem 'Clear All Data
		  InstallFromIni = ""
		  
		  If ItemInn = "" Then Return False 'Nothing given
		  
		  Dim I As Integer
		  Dim F As FolderItem
		  Dim SP() As String
		  Dim Exten As String
		  Dim Lin As String
		  Dim LineID, OrigLine As String
		  Dim LineData As String
		  Dim EqPos As Integer
		  Dim ReadMode As Integer
		  Dim Compressed As Boolean = False
		  Dim ActualIni As String
		  
		  Dim Success As Boolean
		  
		  Dim TmpItem As String
		  
		  TmpItemCount = TmpItemCount + 1
		  TmpItem = Slash(TmpPathItems+"tmp" + TmpItemCount.ToString) 'I think 30k Items will do, just in case
		  
		  'Don't make folder,7z makes it MUCH faster than a Shell call
		  'MakeFolder(TmpItem) 'Make items temp path
		  
		  For I = 0 To LnkCount + 1 'Clear all Links for items - Uses old LnkCount just to add a little speed up
		    ItemLnk(I) = BlankItemLnk
		  Next I
		  LnkCount = 0
		  
		  ItemIcon = Nil
		  ItemFader = Nil
		  ItemScreenshot = Nil
		  
		  TempInstall = ""
		  
		  'Removed Exist (If it's made it this far then assume it's really there
		  Exten = Right(ItemInn,4).Lowercase
		  
		  Select Case Exten
		  Case ".lla"
		    ItemLLItem.PathINI = Left(ItemInn,InStrRev(ItemInn,"/"))
		    ItemLLItem.BuildType = "LLApp"
		    Success = True
		  Case ".llg"
		    ItemLLItem.PathINI = Left(ItemInn,InStrRev(ItemInn,"/"))
		    ItemLLItem.BuildType = "LLGame"
		    Success = True
		  Case ".app"
		    ItemLLItem.PathINI = Left(ItemInn,InStrRev(ItemInn,"/"))
		    Success = True
		  Case ".ppg"
		    ItemLLItem.PathINI = Left(ItemInn,InStrRev(ItemInn,"/"))
		    ItemLLItem.BuildType = "ppGame"
		    Success = True
		  Case ".tar"
		    ItemLLItem.PathINI = ItemInn
		    If InnTmp <>"" Then
		      TmpItem = InnTmp
		      Success = True
		    Else
		      If InstallItem = False Then
		        Success = Extract(ItemInn, TmpItem, " LLApp.lla LLGame.llg LLScript.sh LLScript_Sudo.sh LLFile.sh LLApp.jpg LLApp.png LLApp.ico LLApp.svg LLGame.jpg LLGame.png LLGame.ico LLGame.svg LLApp1.jpg LLGame1.jpg LLApp2.jpg LLGame2.jpg LLApp3.jpg LLGame3.jpg LLApp4.jpg LLGame4.jpg LLApp5.jpg LLGame5.jpg LLApp6.jpg LLGame6.jpg")
		        If Debugging Then Debug ("Extracting Partial tar: "+ ItemInn+" TempInstallPath: "+ TmpItem + " Success: "+ Success.ToString)
		      Else ' Extract Everything
		        Success = Extract(ItemInn, TmpItem, "")
		        If Debugging Then Debug ("Extracting tar: "+ ItemInn+" TempInstallPath: "+ TmpItem + " Success: "+ Success.ToString)
		      End If
		    End If
		    TempInstall = TmpItem
		    Compressed = True
		  Case".apz"
		    ItemLLItem.PathINI = ItemInn
		    If InnTmp <>"" Then
		      TmpItem = InnTmp
		      Success = True
		    Else
		      If InstallItem = False Then
		        Success = Extract(ItemInn, TmpItem, " ssApp.app ppApp.app ssApp.jpg ppApp.jpg ssApp.png ppApp.png ssApp.ico ppApp.ico ppApp1.jpg ppApp2.jpg ppApp3.jpg ppApp4.jpg ppApp5.jpg ppApp6.jpg ssApp1.jpg ssApp2.jpg ssApp3.jpg ssApp4.jpg ssApp5.jpg ssApp6.jpg") ', True) '<- True means Fast, not using Execute, just Shell (trying without to see if it locks up the GUI in Xojo First).
		        If Debugging Then Debug ("Extracting Partial apz: "+ ItemInn+" TempInstallPath: "+ TmpItem + " Success: "+ Success.ToString)
		      Else ' Extract Everything
		        Success = Extract(ItemInn, TmpItem, "")
		        If Debugging Then Debug ("Extracting apz: "+ ItemInn+" TempInstallPath: "+ TmpItem + " Success: "+ Success.ToString)
		      End If
		    End If
		    TempInstall = TmpItem
		    Compressed = True
		  Case ".pgz"
		    ItemLLItem.PathINI = ItemInn
		    ItemLLItem.BuildType = "ppGame"
		    If InnTmp <>"" Then
		      TmpItem = InnTmp
		      Success = True
		    Else
		      If InstallItem = False Then
		        Success = Extract(ItemInn, TmpItem, " ppGame.ppg ppGame.jpg ppGame.png ppGame.ico ppGame1.jpg ppGame2.jpg ppGame3.jpg ppGame4.jpg ppGame5.jpg ppGame6.jpg") ', True) '<- True means Fast, not using Execute, just Shell (trying without to see if it locks up the GUI in Xojo First).
		        If Debugging Then Debug ("Extracting Partial pgz: "+ ItemInn+" TempInstallPath: "+ TmpItem + " Success: "+ Success.ToString)
		      Else ' Extract Everything
		        Success = Extract(ItemInn, TmpItem, "")
		        If Debugging Then Debug ("Extracting pgz: "+ ItemInn+" TempInstallPath: "+ TmpItem + " Success: "+ Success.ToString)
		      End If
		    End If
		    TempInstall = TmpItem
		    Compressed = True
		  End Select
		  
		  If Success = False Then Return False 'Abort, Don't load dud Items
		  ItemLLItem.FileINI = ItemInn 'Set FileINI for item, has full path, also includes compressed file if is one
		  
		  If Compressed = False Then
		    ActualIni = ItemInn ' Sets to this as Default, Compressed below will change it
		    If ActualIni = "" Then Return False 'Failed to set the item
		    #Pragma BreakOnExceptions Off
		    Try
		      F = GetFolderItem(ActualIni,FolderItem.PathTypeShell)
		    Catch
		      Return False'Failed to set the item
		    End Try
		    #Pragma BreakOnExceptions On
		    If Not F.Exists Then Return False'Failed to set the item
		  Else
		    'Grab the uncompressed temp folder to load from
		    ActualIni = ""
		    If Exist(TmpItem + "LLApp.lla") Then
		      ActualIni = TmpItem + "LLApp.lla"
		    ElseIf Exist(TmpItem + "LLGame.llg") Then
		      ActualIni = TmpItem + "LLGame.llg"
		    ElseIf Exist(TmpItem + "ssApp.app") Then
		      ActualIni = TmpItem + "ssApp.app"
		    ElseIf Exist(TmpItem + "ppApp.app") Then
		      ActualIni = TmpItem + "ppApp.app"
		    ElseIf Exist(TmpItem + "ppGame.ppg") Then
		      ActualIni = TmpItem + "ppGame.ppg"
		    End If
		    
		    If ActualIni = "" Then Return False 'Failed to set the item
		    F = GetFolderItem(ActualIni,FolderItem.PathTypeShell)
		    If Not F.Exists Then Return False'Failed to set the item, did it fail to extract
		  End If
		  
		  InstallFromIni = ActualIni
		  
		  'Load in whole file at once (Fastest Method)
		  inputStream = TextInputStream.Open(F)
		  
		  Dim RL As String
		  While Not inputStream.EndOfFile 'If Empty file this skips it
		    RL = inputStream.ReadAll.ConvertEncoding(Encodings.ASCII)
		  Wend
		  inputStream.Close
		  
		  RL = RL.ReplaceAll(Chr(13), Chr(10))
		  Sp()=RL.Split(Chr(10))
		  If Sp.Count <= 0 Then Return False ' Empty File or no header
		  Lin = Sp(0).Trim
		  Lin = Lin.Lowercase
		  If Lin = "[llfile]" Or Lin = "[setups]" Then 'Only work with files that are really our files
		    ItemLLItem.BuildType = "LLApp" 'Default to LLApps
		    ItemLLItem.Priority = 5 'Default Priority
		    LnkEditing = 0
		    ReadMode = 0
		    For I = 1 To Sp().Count -1
		      Lin = Sp(I).Trim
		      OrigLine = Lin
		      EqPos = Lin.IndexOf(1,"=")
		      LineID = ""
		      LineData = ""
		      If  EqPos >= 1 Then
		        LineID = Left(Lin,EqPos)
		        LineData = Right(Lin,Len(Lin)-Len(LineID)-1)
		        LineID=LineID.Trim.Lowercase
		        LineData=LineData.Trim
		      Else 'No Equals, probably a shortcut
		        LineID = Lin.Trim
		      End If
		      
		      'MsgBox LineID +" = " + LineData 'Glenn 2030
		      
		      If ReadMode = 0 Then  'Only if ReadMode = 0
		        Select Case LineID
		        Case "title"
		          If LineData = "" Then Return False
		          'MsgBox "Data is = "+ LineData
		          ItemLLItem.TitleName = LineData
		          'MsgBox "This one should be set 2: "+ItemLLItem.TitleName
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "version"
		          ItemLLItem.Version = LineData
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "description"
		          ItemLLItem.Descriptions = LineData '.ReplaceAll(Chr(30),Chr(13)) 'Disabled converting the Data to CRLF to speed up loading and to make writing the DB files easier
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "apppath"
		          ItemLLItem.PathApp = ExpPath(LineData)
		          If TargetWindows Then
		            ItemLLItem.PathApp = ItemLLItem.PathApp.ReplaceAll("/","\")
		            If StoreMode = 1 And Not Exist(ItemLLItem.PathApp) Then ItemLLItem.PathApp = ItemLLItem.PathINI ' make sure it's valid (Especially for Launcher, Glenn 2027 - will need to confirm installer works)
		          Else
		            ItemLLItem.PathApp = ItemLLItem.PathApp.ReplaceAll("\","/")
		          End If
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "url"
		          ItemLLItem.URL = LineData '.ReplaceAll("|",Chr(13)) 'Leep condensed for now
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "category"
		          ItemLLItem.Categories = FixGameCats(LineData)
		          
		          'Fix Categories
		          If ItemLLItem.BuildType = "ppGame" Or ItemLLItem.BuildType = "LLGame" Then
		            If Left(ItemLLItem.Categories, 5) <>"Game;" And ItemLLItem.Categories.IndexOf(" Game;") <= 0 Then  ItemLLItem.Categories=ItemLLItem.Categories+" Game;"
		          End If
		          ItemLLItem.Categories = ItemLLItem.Categories.Trim
		          
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "buildtype"
		          If LineData <> "" Then ItemLLItem.BuildType = LineData
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "assembly"
		          ItemLLItem.Assembly = LineData
		        Case "shortcutnameskeep"
		          ItemLLItem.ShortCutNamesKeep = LineData
		        Case "catalog"
		          ItemLLItem.Catalog = FixCatalog(LineData)
		          'Fix Catalog
		          If ItemLLItem.BuildType = "ppGame" Or ItemLLItem.BuildType = "LLGame" Then
		            If Left(ItemLLItem.Catalog, 5) <>"Game;" And ItemLLItem.Catalog.IndexOf(" Game;") <= 0 Then  ItemLLItem.Catalog=ItemLLItem.Catalog+" Game;"
		          End If
		          ItemLLItem.Catalog = ItemLLItem.Catalog.Trim
		        Case "startmenulegacyprimary"
		          ItemLLItem.StartMenuLegacyPrimary = LineData
		        Case "startmenusourcepath"
		          ItemLLItem.StartMenuSourcePath = LineData
		        Case "flags"
		          ItemLLItem.Flags = LineData.Lowercase
		          
		          If ItemLLItem.Flags.IndexOf("alwayshide") >=0 Then
		            ItemLLItem.Hidden = True
		            ItemLLItem.HiddenAlways = True
		          Else
		            ItemLLItem.Hidden = False
		            ItemLLItem.HiddenAlways = False
		          End If
		          If ItemLLItem.Flags.IndexOf("hidden") >=0 Then
		            ItemLLItem.Hidden = True
		            ItemLLItem.HiddenAlways = True
		          Else
		            ItemLLItem.Hidden = False
		            ItemLLItem.HiddenAlways = False
		          End If
		          
		          If ItemLLItem.Flags.IndexOf("showsetuponly") >=0 Then
		            ItemLLItem.ShowSetupOnly = True
		            If StoreMode <> 0 Then 'Only hide if not Setup/install mode
		              ItemLLItem.Hidden = True
		            Else
		              ItemLLItem.Hidden = False
		            End If
		          Else
		            ItemLLItem.ShowSetupOnly = False
		          End If
		          If ItemLLItem.Flags.IndexOf("internetrequired") >=0 Then ItemLLItem.InternetRequired = True Else ItemLLItem.InternetRequired = False
		          If ItemLLItem.Flags.IndexOf("noinstall") >=0 Then
		            ItemLLItem.NoInstall = True
		          Else
		            ItemLLItem.NoInstall = False
		          End If
		          
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "priority"
		          ItemLLItem.Priority = Val(LineData)
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "priorityorder"
		          ItemLLItem.Priority = Val(LineData)
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "tags"
		          ItemLLItem.Tags = LineData
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "publisher"
		          ItemLLItem.Publisher = LineData
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "language"
		          ItemLLItem.Language = LineData
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "arch","architecture"
		          ItemLLItem.Arch = LineData
		        Case "os"
		          ItemLLItem.OS = LineData
		        Case "rating"
		          ItemLLItem.Rating = Val(LineData)
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "players"
		          ItemLLItem.Players = Val(LineData)
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "license"
		          ItemLLItem.License = Val(LineData)
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "licensetype"
		          ItemLLItem.License = Val(LineData)
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "releaseversion"
		          ItemLLItem.ReleaseVersion = LineData
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "releasedate"
		          ItemLLItem.ReleaseDate = LineData
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "builder"
		          ItemLLItem.Builder = LineData
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "installedsize"
		          ItemLLItem.InstallSize = Val(LineData)
		          Continue 'Once used Data no need to process the rest, The other lines will cause the lower things to be tested per line
		        Case "oscompatible"
		          ItemLLItem.OSCompatible = LineData
		        Case "decompatible"
		          ItemLLItem.DECompatible = LineData
		        Case "pmcompatible"
		          ItemLLItem.PMCompatible = LineData
		        Case "archcompatible"
		          ItemLLItem.ArchCompatible = LineData
		        Case "dependencies"
		          ItemLLItem.Dependencies = LineData
		        End Select
		        
		      End If 'Only if ReadMode = 0
		      
		      If Right(LineID, 9) = ".desktop]" Then 'Found Shortcut
		        LnkCount = LnkCount + 1
		        LnkEditing = LnkCount
		        ItemLnk(LnkEditing).Title = Left(LineID, Len(LineID)-9)
		        ItemLnk(LnkEditing).Title = Right(ItemLnk(LnkEditing).Title, Len(ItemLnk(LnkEditing).Title) - 1)
		        
		        ItemLnk(LnkEditing).Active = True
		        ReadMode = 1
		      End If
		      
		      If Right(LineID, 5) = ".lnk]" Then 'Found Shortcut
		        LnkCount = LnkCount + 1
		        LnkEditing = LnkCount
		        ItemLnk(LnkEditing).Title = Left(LineID, Len(LineID)-5)
		        ItemLnk(LnkEditing).Title = Right(ItemLnk(LnkEditing).Title, Len(ItemLnk(LnkEditing).Title) - 1)
		        ItemLnk(LnkEditing).Description = ItemLLItem.Descriptions 'Use main Items description, gets replaced if another is given
		        ItemLnk(LnkEditing).Active = True
		        ReadMode = 1
		      End If
		      
		      If ReadMode = 1 Then 'Fix the exp paths (they are in the AddItem now)
		        'If ItemLnk(LnkEditing).Categories = "" Then ItemLnk(LnkEditing).Categories = ItemLLItem.Categories
		        If ItemLnk(LnkEditing).Categories = "" Then ItemLnk(LnkEditing).Categories = ItemLLItem.Catalog 'Try using Catalog , may break Sorting in LLStore, so might need to add a new field
		        
		        Select Case LineID
		        Case "exec"
		          ItemLnk(LnkEditing).Exec = LineData
		        Case "target"
		          ItemLnk(LnkEditing).Exec = LineData
		        Case "arguments"
		          ItemLnk(LnkEditing).Arguments = LineData
		        Case "comment"
		          ItemLnk(LnkEditing).Comment = LineData
		        Case "description"
		          If LineData <> "" Then ItemLnk(LnkEditing).Description = Replace(LineData, Chr(30), Chr(10)) 'Replace RS lines ASAP to avoid issues, save will make sure to put them back
		        Case "path"
		          ItemLnk(LnkEditing).RunPath = Trim(LineData)
		          If ItemLnk(LnkEditing).RunPath = "" Then ItemLnk(LnkEditing).RunPath= Slash(ItemLLItem.PathApp)
		        Case "icon"
		          ItemLnk(LnkEditing).Icon = Trim(LineData)
		          If ItemLnk(LnkEditing).Icon = "" Then ItemLnk(LnkEditing).Icon = Slash(ItemLLItem.PathApp) + ItemLLItem.BuildType + ".png"
		        Case "categories"
		          ItemLnk(LnkEditing).Categories = FixGameCats(LineData)
		          'Fix Categories, Can do here because the type is set above
		          If ItemLLItem.BuildType = "ppGame" Or ItemLLItem.BuildType = "LLGame" Then
		            If Left(ItemLnk(LnkEditing).Categories, 5) <>"Game;" And ItemLnk(LnkEditing).Categories.IndexOf(" Game;") <= 0 Then  ItemLnk(LnkEditing).Categories=ItemLnk(LnkEditing).Categories+" Game;"
		          End If
		          
		        Case "extensions"
		          ItemLnk(LnkEditing).Associations = LineData
		        Case "flags"
		          ItemLnk(LnkEditing).Flags = LineData
		        Case "terminal"
		          If LineData = "True" Then ItemLnk(LnkEditing).Terminal= True Else ItemLnk(LnkEditing).Terminal= False
		          
		        Case "showon"
		          If OrigLine.IndexOf("desktop") >= 1 Then ItemLnk(LnkEditing).Desktop = True Else ItemLnk(LnkEditing).Desktop = False
		          If OrigLine.IndexOf("panel") >= 1  Then ItemLnk(LnkEditing).Panel = True Else ItemLnk(LnkEditing).Panel = False
		          If OrigLine.IndexOf("favorite") >= 1 Then ItemLnk(LnkEditing).Favorite = True Else ItemLnk(LnkEditing).Favorite = False
		        Case "lnkoscompatible"
		          ItemLnk(LnkEditing).LnkOSCompatible = LineData
		        Case "lnkdecompatible"
		          ItemLnk(LnkEditing).LnkDECompatible = LineData
		        Case "lnkpmcompatible"
		          ItemLnk(LnkEditing).LnkPMCompatible = LineData
		        Case "lnkarchcompatible"
		          ItemLnk(LnkEditing).LnkArchCompatible = LineData
		        End Select
		      End If 'End ReadMode 1
		    Next
		    
		    ItemLLItem.LnkCount = LnkCount
		  End If
		  
		  'MsgBox "This one should be set: "+ItemLLItem.TitleName
		  
		  Dim MediaPath As String
		  MediaPath = Slash(ExpPath(ItemLLItem.PathINI)) 
		  If Compressed = True Then
		    ItemLLItem.Compressed = True
		    MediaPath = TmpItem
		  End If
		  
		  'Load Items Screenshot and Fader
		  'Screenshot
		  ItemLLItem.FileScreenshot =  MediaPath+ItemLLItem.BuildType+".jpg"
		  F = GetFolderItem(ItemLLItem.FileScreenshot, FolderItem.PathTypeNative)
		  If Not F.Exists Then ItemLLItem.FileScreenshot =  "" 'None
		  
		  'Fader
		  ItemLLItem.FileFader =  MediaPath +ItemLLItem.BuildType+".png"
		  F = GetFolderItem(ItemLLItem.FileFader, FolderItem.PathTypeNative)
		  If Not F.Exists Then
		    ItemLLItem.FileFader =  MediaPath+ItemLLItem.BuildType+".svg"
		    F = GetFolderItem(ItemLLItem.FileIcon, FolderItem.PathTypeNative)
		    If Not F.Exists Then 
		      ItemLLItem.FileFader =  MediaPath +ItemLLItem.BuildType+".ico"
		      F = GetFolderItem(ItemLLItem.FileFader, FolderItem.PathTypeNative)
		      If Not F.Exists Then
		        ItemLLItem.FileFader =  "" 'None
		        ItemIcon = Nil
		      End If
		    End If
		  End If
		  
		  'Icon
		  ItemLLItem.FileIcon =  MediaPath +ItemLLItem.BuildType+".svg"
		  F = GetFolderItem(ItemLLItem.FileIcon, FolderItem.PathTypeNative)
		  If Not F.Exists Then
		    'Disabled .ico because Linux doesn't always display them right
		    'ItemLLItem.FileIcon =  MediaPath +ItemLLItem.BuildType+".ico"
		    'F = GetFolderItem(ItemLLItem.FileIcon, FolderItem.PathTypeNative)
		    'If Not F.Exists Then 
		    ItemLLItem.FileIcon =  MediaPath +ItemLLItem.BuildType+".png"
		    F = GetFolderItem(ItemLLItem.FileIcon, FolderItem.PathTypeNative)
		    If Not F.Exists Then
		      ItemLLItem.FileIcon =  "" 'None
		      ItemIcon = Nil
		    End If
		    'End If
		  End If
		  
		  'Add Item to Cache if found
		  If  ItemLLItem.FileIcon <>  "" Then
		    Try
		      ItemIcon = Picture.Open(F)
		    Catch
		    End Try
		  End If
		  
		  'Movie
		  ItemLLItem.FileMovie =  MediaPath +ItemLLItem.BuildType+".mp4"
		  F = GetFolderItem(ItemLLItem.FileMovie, FolderItem.PathTypeNative)
		  If Not F.Exists Then
		    ItemLLItem.FileMovie =  "" 'None
		  End If
		  
		  ItemTempPath = MediaPath ' Media Path is inipath if not compressed and temp path if is compressed
		  
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MakeAllExec(PathIn As String)
		  If Debugging Then Debug("Make All Exec: "+ PathIn)
		  
		  Dim Sh As New Shell
		  Sh.TimeOut = -1 'Give it All the time it needs
		  Sh.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  
		  if TargetLinux Then 'Only Linux needs this, Win doesn't
		    Sh.Execute ("chmod -R 775 "+Chr(34)+PathIn+Chr(34)) +" ; "+ "chmod 775 "+Chr(34)+PathIn+Chr(34) 'Change Read/Write/Execute to defaults
		    While Sh.IsRunning
		      App.DoEvents(2)  ' used to be 50, trying 7 to see if more responsive. - It is
		    Wend
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MakeFileType(APP As String, EXT As String, COMMENT As String, EXECU As String, PathIn As String, LOGO As String)
		  If Debugging Then Debug("--- Starting Make Associations ---")
		  Dim OrigAppName As String
		  Dim FileOut As String
		  Dim FileContent As String
		  Dim Typs() As  String
		  Dim J As Integer
		  Dim CurrentIconTheme As String
		  Dim Shelly As New Shell
		  Dim Res As String
		  Dim TypeName As String
		  
		  If TargetWindows Then
		    Typs = Split(EXT, " ")
		    If Typs.Count >= 1 Then
		      For J = 0 To Typs.Count - 1
		        ''FileContent = FileContent + "        <glob pattern=" + Chr(34) + "*." + Typs(J) + Chr(34) + "/>" + Chr(10)
		        'Shelly.Execute ("assoc "+"." + Typs(J)+"="+Chr(34)+EXECU+Chr(34)) 'Test this works in Windows, Glenn 2027
		        
		        EXECU = EXECU.ReplaceAll("/","\") 'I think Assoc requires windows paths and not linux slashes
		        TypeName = Replace(APP, "(", "") 'Remove Brackets
		        TypeName = Replace(TypeName.Trim, ")", "") 'Remove Brackets
		        TypeName = Replace(TypeName, " ", ".") 'Remove Spaces
		        Res = RunCommandResults("assoc "+"." + Typs(J)+"="+Chr(34)+TypeName+Chr(34)+Chr(10)+"ftype "+TypeName+"="+Chr(34)+EXECU+Chr(34)+" %1 %*")
		        'If Debugging Then Debug("Win Assoc: ." + Typs(J)+"="+Chr(34)+EXECU+Chr(34)+ Chr(10)+ Shelly.Result)
		        If Debugging Then Debug("Win Assoc: ." + Typs(J)+"="+Chr(34)+TypeName+Chr(34)+"|"+"ftype "+TypeName+"="+Chr(34)+EXECU+Chr(34)+" %1 %*"+ Chr(10)+ Res)
		      Next
		    End If
		    
		    
		    'assoc .txt="C:\Program Files\Windows\System32\notepad.exe"
		  Else 'Linux
		    OrigAppName = APP
		    APP = Replace(APP, " (Linux)", "") 'Remove Bracketed Linux
		    APP = Replace(APP, "(", "") 'Remove Brackets
		    APP = Replace(APP.Lowercase.Trim, ")", "") 'Remove Brackets
		    APP = Replace(APP, " ", ".") 'Remove Spaces
		    
		    
		    If Not Exist(TmpPath) Then Shelly.Execute ("mkdir -p " + Chr(34) + TmpPath + Chr(34))
		    'MIME Type
		    'Print "MIME Output"
		    
		    Shelly.Execute ("gsettings get org.gnome.desktop.interface icon-theme")
		    CurrentIconTheme = Shelly.Result
		    CurrentIconTheme = Replace(CurrentIconTheme, "'", "")  
		    Shelly.Execute ("xdg-icon-resource install --context mimetypes --size 48 --theme " + CurrentIconTheme + " " + LOGO + " application-x-" + APP)
		    
		    Shelly.Execute ("xdg-icon-resource install --context mimetypes --size 48 " + LOGO + " application-x-" + APP)
		    
		    FileOut = Slash(TmpPath) + APP + "-mime.xml"
		    FileContent = "<?xml version=" + Chr(34) + "1.0" + Chr(34) + " encoding=" + Chr(34) + "UTF-8" + Chr(34) + "?>" + Chr(10)
		    FileContent = FileContent + "<mime-info xmlns=" + Chr(34) + "http://www.freedesktop.org/standards/shared-mime-info" + Chr(34) + ">" + Chr(10)
		    FileContent = FileContent + "    <mime-type type=" + Chr(34) + "application/x-" + APP + Chr(34) + ">" + Chr(10)
		    FileContent = FileContent + "        <comment>" + COMMENT + "</comment>" + Chr(10)
		    FileContent = FileContent + "        <icon name=" + Chr(34) + "application-x-" + APP + Chr(34) + "/>" + Chr(10)
		    Typs = Split(EXT, " ")
		    If Typs.Count >= 1 Then
		      For J = 0 To Typs.Count - 1
		        FileContent = FileContent + "        <glob pattern=" + Chr(34) + "*." + Typs(J) + Chr(34) + "/>" + Chr(10)
		      Next
		    Else
		      FileContent = FileContent + "        <glob pattern=" + Chr(34) + "*.nonegiven" + Chr(34) + "/>" + Chr(10)
		    End If
		    'FileContent = FileContent + "        <glob pattern=" + Chr(34) + "*." + EXT + Chr(34) + "/>" + Chr(10)  
		    FileContent = FileContent + "    </mime-type>" + Chr(10)
		    FileContent = FileContent + "</mime-info>" + Chr(10)
		    SaveDataToFile(FileContent, FileOut)
		    Shelly.Execute ("xdg-mime install " + FileOut)
		    Shelly.Execute (" rm " + FileOut)
		    Shelly.Execute ("update-mime-database $HOME/.local/share/mime")
		    
		    
		    If EXECU.Left(5) = "wine " Then
		      'Glenn 2030
		      'I use the 2nd one below to make it more system compatible, but may change to installing the python requirements and script to make it perfect on every OS?
		      ''EXECU = "python3 "+Slash(ToolPath)+"wine-launcher.py " + Chr(34) + Right(EXECU, Len(EXECU) - 5) + Chr(34) + " %f" 'Works Perfect But requirtes external and Pythos on the OS, will test more
		      EXECU = "wine " + Chr(34) + Right(EXECU, Len(EXECU) - 5) + Chr(34) 'Works ok
		    Else 'Linux one
		      EXECU = EXECU + " %U"
		    End If
		    
		    If Right(PathIn, 1) = "/" Then PathIn = Left(PathIn, Len(PathIn) - 1) 'Remove Slash
		    
		    'Print "Desktop Output"
		    'Desktop Association
		    FileOut = Slash(TmpPath) + APP + "_filetype.desktop"
		    FileContent = "[Desktop Entry]" + Chr(10)
		    FileContent = FileContent + "Name=" + OrigAppName + Chr(10)
		    FileContent = FileContent + "Exec=" + EXECU + Chr(10)
		    FileContent = FileContent + "Path=" + PathIn + Chr(10)
		    FileContent = FileContent + "MimeType=application/x-" + APP + Chr(10)
		    FileContent = FileContent + "Icon=application-x-" + APP + Chr(10)
		    FileContent = FileContent + "Terminal=false" + Chr(10)
		    FileContent = FileContent + "NoDisplay=true" + Chr(10)
		    FileContent = FileContent + "Type=Application" + Chr(10)
		    FileContent = FileContent + "Categories=" + Chr(10)
		    FileContent = FileContent + "Comment=" + COMMENT + Chr(10)
		    SaveDataToFile(FileContent, FileOut)
		    Shelly.Execute ("desktop-file-install --dir=$HOME/.local/share/applications " + FileOut)
		    Shelly.Execute (" rm " + FileOut)
		    Shelly.Execute ("update-desktop-database $HOME/.local/share/applications")
		    Shelly.Execute ("xdg-mime default " + APP + ".desktop application/x-" + APP)
		    Shelly.Execute ("update-icon-caches $HOME/.local/share/icons/*")
		    'Print "MIME Done"
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MakeFolder(Txt as String)
		  If Debugging Then Debug("Make Folder Path In: "+Txt)
		  Dim F As FolderItem
		  Dim Path As String
		  Dim Sh As New Shell
		  Dim Res As String
		  Sh.TimeOut = -1 'Give it All the time it needs
		  Dim S As string
		  Path = FixPath(Txt)
		  Try
		    if TargetMacOS then
		      s = "mkdir -p " + chr(34) + "/Volumes/" + replaceall(Txt,":","/") + chr(34)
		    elseif TargetWindows then
		      Path = Path.ReplaceAll("/","\")
		      S = "mkdir " + chr(34) + Path + chr(34)
		    elseif TargetLinux then
		      Path = Path.ReplaceAll("\","/")
		      S = "mkdir -p " + chr(34) + Path + chr(34)
		    end if
		    
		    If TargetWindows Then 'Only windows has the stupid shell bug, so only it needs an external script called instead
		      'Sh.Execute(S)
		      'If Debugging Then Debug ("Make Folder: "+Path+" = " + Sh.Result)
		      'Sh.Execute ("icacls"+ NoSlash(Path)+ " /grant "+ "Users:F /t /c /q")
		      Res = RunCommandResults (S + Chr(10) + "icacls "+Chr(34)+ NoSlash(Path)+Chr(34)+ " /grant "+ "Users:F /t /c /q") 'Using Chr(10) instead of ; as scripts don't allow them, only the prompt does
		      If Debugging Then Debug ("Make Folder: "+Path+" = " + Res)
		    Else
		      'RunCommand (S + " ; " + "chmod 775 "+Chr(34)+Txt+Chr(34)) 'Linux doesn't make a script, but using ; will wait and do the next command after it's done, Can't do this here as it doesn't have a tmpPath folder to make the Script to make TmpPath
		      Sh.Execute(S)
		      If Debugging Then Debug ("Make Folder: "+Path+" = " + Sh.Result)
		      Sh.Execute("chmod 775 "+Chr(34)+Path+Chr(34)) 'Change Read/Write/Execute to defaults, -R would do all files and folders, but we might not want this here
		    End If
		  Catch
		    If Debugging Then Debug ("* Failed to Make Folder: "+Path)
		  End Try
		  'SaveDataToFile(S+Chr(10)+Sh.Result, SpecialFolder.Desktop.NativePath+"/DebugMakeFolder.txt")
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MakeLinks()
		  If Debugging Then Debug("--- Starting Make Links ---")
		  
		  Dim I, J, K, L As Integer
		  Dim Target As String
		  Dim DesktopFile, DesktopContent, DesktopOutPath As String
		  Dim Catalog() As String
		  Dim CatalogCount As Integer
		  Dim TestLen As Integer
		  Dim LinkOutPath As String
		  Dim DaBugs As String
		  Dim StartPath As String
		  Dim ExecName As String
		  
		  'Sort Catalog to Shortcuts - Windows ItemsOnly
		  'Get the StartMenu Stuff for ssApps and then for ppApps/Games
		  If ItemLLItem.Catalog <> "" Then
		    Catalog = ItemLLItem.Catalog.Split("|")
		    CatalogCount = Catalog.Count - 1
		    For I = 0 To CatalogCount
		      Catalog(I) = Catalog(I).Trim
		      IF RedirectAppCount >= 1 Then
		        Select Case ItemLLItem.BuildType
		        Case "ssApp","ppApp"
		          For J = 0 To RedirectAppCount -1
		            If Catalog(I)  = RedirectsApp (J,0) Then ItemLLItem.Catalog = ItemLLItem.Catalog.ReplaceAll(RedirectsApp (J,0),RedirectsApp (J,1))'Replace with new App Catalog
		          Next J
		        Case Else 'Game
		          For J = 0 To RedirectGameCount -1
		            If Catalog(I)  = RedirectsGame (J,0) Then ItemLLItem.Catalog = ItemLLItem.Catalog.ReplaceAll(RedirectsGame (J,0),RedirectsGame (J,1))'Replace with new Game Catalog
		          Next J
		        End Select
		      End If
		    Next I
		  End If
		  
		  'Do Link Catalog
		  If LnkCount > 0 Then
		    For L = 1 To LnkCount
		      If  ItemLnk(L).Categories <> "" Then
		        Catalog = ItemLnk(L).Categories.Split(";")
		        CatalogCount = Catalog.Count - 1
		        IF RedirectGameCount >= 1 Then
		          For I = 0 To CatalogCount
		            Catalog(I) = Catalog(I).Trim
		            Select Case ItemLLItem.BuildType
		            Case "ssApp","ppApp"
		              For J = 0 To RedirectAppCount -1
		                If Catalog(I)  = RedirectsApp (J,0) Then ItemLnk(L).Categories = ItemLnk(L).Categories.ReplaceAll(RedirectsApp (J,0),RedirectsApp (J,1)) 'Replace with new App Catalog
		              Next J
		            Case Else 'Game
		              For J = 0 To RedirectGameCount -1
		                If Catalog(I)  = RedirectsGame (J,0) Then ItemLnk(L).Categories = ItemLnk(L).Categories.ReplaceAll(RedirectsGame (J,0),RedirectsGame (J,1)) 'Replace with new Game Catalog
		              Next J
		            End Select
		          Next I
		          'Replace Game to start of Catalog
		          If Len( ItemLnk(L).Categories) > Len( ItemLnk(L).Categories.ReplaceAll("; Game;",";")) Then ' Drop the Game back to start
		            ItemLnk(L).Categories = "Game; " + ItemLnk(L).Categories.ReplaceAll("; Game;",";")
		          End If
		        End If
		      End If
		    Next L
		  End If
		  
		  
		  'For All
		  If LnkCount > 0 Then
		    If TargetLinux Then
		      For I = 1 To LnkCount
		        'If ItemLnk(I).Title.IndexOf(1, "{#2}") >= 1 Then Continue 'Skip dual arch shortcuts, just keep 1st one, which is usually x64 anyway
		        If ItemLnk(I).Flags.IndexOf(0, "Is_x64") < 0 And ItemLnk(I).Title.IndexOf(1, "{#1}") >= 1 Then Continue ' Only skip replacing items if the items isn't the x64 one
		        If ItemLnk(I).Flags.IndexOf(0, "Is_x64") < 0 And ItemLnk(I).Title.IndexOf(1, "{#2}") >= 1 Then Continue ' Only skip replacing items if the 2nd items isn't the x64 one
		        
		        ItemLnk(I).Title = ItemLnk(I).Title.ReplaceAll("{#2}", "") 'Remove Dual Arch leftovers
		        ItemLnk(I).Title = ItemLnk(I).Title.ReplaceAll("{#1}", "") 'Remove Dual Arch leftovers
		        DesktopFile = ItemLnk(I).Title.ReplaceAll(" ", ".") + ".desktop" 'Remove Spaces and add .desktop back to file name
		        
		        ItemLnk(I).Icon = ExpPath(ItemLnk(I).Icon)
		        If Not Exist(ItemLnk(I).Icon) Then ItemLnk(I).Icon = "" 'Remove Dodgy Icon and use something
		        If ItemLnk(I).Icon = "" Then
		          If Exist(InstallToPath + "ppGame.png") Then ItemLnk(I).Icon = InstallToPath + "ppGame.png"
		          If Exist(InstallToPath + "ppApp.png") Then ItemLnk(I).Icon = InstallToPath + "ppApp.png"
		          If Exist(InstallToPath + "ssApp.png") Then ItemLnk(I).Icon = InstallToPath + "ssApp.png"
		          If Exist(InstallToPath + "LLGame.png") Then ItemLnk(I).Icon = InstallToPath + "LLGame.png"
		          If Exist(InstallToPath + "LLApp.png") Then ItemLnk(I).Icon = InstallToPath + "LLApp.png"
		        End If
		        
		        'Correct Exec if missing Quotes (May neen to test/disable if breaks things)
		        If Left(ItemLnk(I).Exec,1) <> Chr(34) Then ItemLnk(I).Exec = Chr(34)+ItemLnk(I).Exec+Chr(34)
		        
		        DesktopContent = "[Desktop Entry]" + Chr(10)
		        DesktopContent = DesktopContent + "Type=Application" + Chr(10)
		        DesktopContent = DesktopContent + "Version=1.0" + Chr(10)
		        DesktopContent = DesktopContent + "Name=" + ItemLnk(I).Title + Chr(10)
		        ExecName = ExpPath(ItemLnk(I).Exec)
		        If ItemLLItem.BuildType = "LLApp" Or ItemLLItem.BuildType = "LLGame" Then
		          DesktopContent = DesktopContent + "Exec=" + ExecName + Chr(10)
		        Else
		          DesktopContent = DesktopContent + "Exec=" + "wine " + ExecName + Chr(10) 'Quotes are checked for above, so only added once
		        End If
		        
		        If ItemLLItem.BuildType = "ssApp" Then
		          If InstallToPath <> "" Then 'Only use it if good
		            ItemLnk(I).RunPath = Slash(InstallToPath) 'This path would be better for 99% of ssApps, there may be some dodgy one that require the sub paths still though
		          Else
		            ItemLnk(I).RunPath = ExpPath(ItemLnk(I).RunPath)
		            If ItemLnk(I).RunPath = "" Then
		              ItemLnk(I).RunPath = ExpPath(ItemLLItem.PathApp) 'If not one set, use Apps install to path of Main Item (ppGames and apps don't usualy have a path set at all)
		            End If
		          End If
		        Else
		          ItemLnk(I).RunPath = ExpPath(ItemLnk(I).RunPath)
		          If ItemLnk(I).RunPath = "" Then
		            ItemLnk(I).RunPath = ExpPath(ItemLLItem.PathApp) 'If not one set, use Apps install to path of Main Item (ppGames and apps don't usualy have a path set at all)
		          End If
		        End If
		        
		        DesktopContent = DesktopContent + "Path=" + ExpPath(ItemLnk(I).RunPath) + Chr(10)
		        DesktopContent = DesktopContent + "Comment=" + ItemLnk(I).Comment + Chr(10)
		        DesktopContent = DesktopContent + "Icon=" + ItemLnk(I).Icon + Chr(10)
		        DesktopContent = DesktopContent + "Categories=" + ItemLnk(I).Categories + Chr(10)
		        DesktopContent = DesktopContent + "Terminal=" + Str(ItemLnk(I).Terminal) + Chr(10)
		        
		        'Linux Associations Glenn 2030
		        If ItemLnk(I).Associations.Trim <> "" Then
		          MakeFileType(ItemLnk(I).Title, ItemLnk(I).Associations, ItemLnk(I).Comment, ExecName, ExpPath(ItemLnk(I).RunPath), ItemLnk(I).Icon)
		        End If
		        
		        DesktopOutPath = Slash(HomePath)+".local/share/applications/"
		        SaveDataToFile(DesktopContent, DesktopOutPath+DesktopFile)
		        ShellFast.Execute ("chmod 775 "+Chr(34)+DesktopOutPath+DesktopFile+Chr(34)) 'Change Read/Write/Execute to defaults
		        
		        If ItemLnk(I).Desktop = True Then
		          SaveDataToFile(DesktopContent, Slash(HomePath)+"Desktop/"+DesktopFile) 'Also save to Desktop
		          ShellFast.Execute ("chmod 775 "+Chr(34)+Slash(HomePath)+"Desktop/"+DesktopFile+Chr(34)) 'Change Read/Write/Execute to defaults
		        End If
		        
		      Next I
		    End If
		    
		    If TargetWindows Then 'TargetWindows Glenn 2027 - Change back once tested
		      
		      If AdminEnabled Then 'If Admin apply to All users, else only has access to current user
		        StartPath = StartPathAll 'All Users
		      Else
		        StartPath = StartPathUser 'Current User
		      End If
		      
		      For I = 1 To LnkCount
		        If ItemLnk(I).Flags.IndexOf(0, "Is_x64") < 0 And ItemLnk(I).Title.IndexOf(1, "{#1}") >= 1 Then Continue ' Only skip replacing items if the items isn't the x64 one
		        If ItemLnk(I).Flags.IndexOf(0, "Is_x64") < 0 And ItemLnk(I).Title.IndexOf(1, "{#2}") >= 1 Then Continue ' Only skip replacing items if the 2nd items isn't the x64 one
		        
		        ItemLnk(I).Title = ItemLnk(I).Title.ReplaceAll("{#2}", "") 'Remove Dual Arch leftovers
		        ItemLnk(I).Title = ItemLnk(I).Title.ReplaceAll("{#1}", "") 'Remove Dual Arch leftovers
		        
		        DesktopFile = ItemLnk(I).Title.ReplaceAll(" ", ".") + ".desktop" 'Remove Spaces and add .desktop back to file name
		        
		        ItemLnk(I).Icon = ExpPath(ItemLnk(I).Icon)
		        If Not Exist(ItemLnk(I).Icon) Then ItemLnk(I).Icon = "" 'Remove Dodgy Icon and use something
		        If ItemLnk(I).Icon = "" Then
		          If Exist(InstallToPath + "ppGame.png") Then ItemLnk(I).Icon = InstallToPath + "ppGame.png"
		          If Exist(InstallToPath + "ppApp.png") Then ItemLnk(I).Icon = InstallToPath + "ppApp.png"
		          If Exist(InstallToPath + "ssApp.png") Then ItemLnk(I).Icon = InstallToPath + "ssApp.png"
		          If Exist(InstallToPath + "LLGame.png") Then ItemLnk(I).Icon = InstallToPath + "LLGame.png"
		          If Exist(InstallToPath + "LLApp.png") Then ItemLnk(I).Icon = InstallToPath + "LLApp.png"
		        End If
		        
		        ItemLnk(I).RunPath = ExpPath(ItemLnk(I).RunPath)
		        If ItemLnk(I).RunPath = "" Then
		          ItemLnk(I).RunPath = ExpPath(ItemLLItem.PathApp) 'If not one set, use Apps install to path of Main Item (ppGames and apps don't usualy have a path set at all)
		        End If
		        
		        Target = ExpPath(ItemLnk(I).Exec)
		        
		        If Not Exist(Target) Then Target = ExpPath(Slash(ItemLnk(I).RunPath) + ItemLnk(I).Exec) 'Target needs to be full path, so if above isn't found it will use the RunPath, BUT if it has Arguments it may fail and still point to the wrong place.
		        
		        'Do main Folder Creation here to put Link file into
		        'Do Link Catalog
		        If  ItemLnk(I).Categories <> "" Then
		          Catalog = ItemLnk(I).Categories.Split(";")
		          CatalogCount = Catalog.Count - 1
		          For J = 0 To CatalogCount
		            Catalog(J) = Catalog(J).Trim
		            If Catalog(J) <> "" Then ' Only do Valid Link Catalogs
		              If MenuWindowsCount >= 1 Then
		                For K = 0 To MenuWindowsCount -1
		                  If Catalog(J)  = MenuWindows (K,0) Then
		                    'DaBugs = DaBugs+ Catalog(J)+"=>"+ MenuWindows (K,0)+Chr(10)
		                    If CatalogCount > 1 Then 'If more than one Category then Remove Games standalone
		                      If J = 0 Then 
		                        If Catalog(J) <> "Game" Then ' Only the first one as that is only Game (set to first above)
		                          
		                          LinkOutPath = StartPath+MenuWindows (K,1) 'StartPath is where Writable
		                          If ItemLLItem.Flags.IndexOf("keepinfolder") >=0 Then LinkOutPath=Slash(LinkOutPath)+ItemLLItem.StartMenuSourcePath 'Put in Subfolder if Chosen
		                          MakeFolder(LinkOutPath)
		                          CreateShortcut(ItemLnk(I).Title, Target, Slash(FixPath(ItemLnk(I).RunPath)), Slash(FixPath(LinkOutPath)))
		                          'SaveDataToFile (LinkOutPath+Chr(10)+"---"+Chr(10)+DaBugs ,Slash(FixPath(SpecialFolder.Desktop.NativePath))+"Test.txt")
		                          
		                          Exit 'Found and made, exit
		                        End If
		                      Else 'All but the first Item
		                        LinkOutPath = StartPath+MenuWindows (K,1) 'StartPath is where Writable
		                        If ItemLLItem.Flags.IndexOf("keepinfolder") >=0 Then LinkOutPath=Slash(LinkOutPath)+ItemLLItem.StartMenuSourcePath 'Put in Subfolder if Chosen
		                        MakeFolder(LinkOutPath)
		                        CreateShortcut(ItemLnk(I).Title, Target, Slash(FixPath(ItemLnk(I).RunPath)), Slash(FixPath(LinkOutPath)))
		                        'SaveDataToFile (LinkOutPath+Chr(10)+"---"+Chr(10)+DaBugs ,Slash(FixPath(SpecialFolder.Desktop.NativePath))+"Test.txt")
		                        
		                        Exit 'Found and made, Exit
		                      End If
		                    Else 'All others that are single item but not Games
		                      
		                      LinkOutPath = StartPath+MenuWindows (K,1) 'StartPath is where Writable
		                      If ItemLLItem.Flags.IndexOf("keepinfolder") >=0 Then LinkOutPath=Slash(LinkOutPath)+ItemLLItem.StartMenuSourcePath 'Put in Subfolder if Chosen
		                      MakeFolder(LinkOutPath)
		                      CreateShortcut(ItemLnk(I).Title, Target, Slash(FixPath(ItemLnk(I).RunPath)), Slash(FixPath(LinkOutPath)))
		                      'SaveDataToFile (LinkOutPath+Chr(10)+"---"+Chr(10)+DaBugs ,Slash(FixPath(SpecialFolder.Desktop.NativePath))+"Test.txt")
		                      
		                      Exit 'Found and made, Exit
		                      
		                    End If
		                    Exit 'Found the Item, jump out of the Loop, no need to keep going if it's found
		                  End If
		                Next K
		              End If
		            End If
		          Next J
		        End If
		        
		        ''Create Link file Example
		        ''LinkName, Exec, WorkingDir, LinkDestinationPath
		        ''CreateShortcut(ItemLnk(I).Title, Target, Slash(ItemLnk(I).RunPath), Slash(FixPath(SpecialFolder.Desktop.NativePath)))
		        
		        
		        'Do Associations? Glenn 2027 'Linux is done above in it's section as it only requires adding it to the .desktop file
		        ''Do Associations - It's in InstallLLFile for now
		        
		        'Windows (Not Wine) Associations Glenn 2030
		        If ItemLnk(I).Associations.Trim <> "" Then
		          MakeFileType(ItemLnk(I).Title, ItemLnk(I).Associations, ItemLnk(I).Comment, Target, ExpPath(ItemLnk(I).RunPath), ItemLnk(I).Icon)
		        End If
		        
		        
		        'If ItemLnk(I).Associations.Trim <> "" Then
		        ''assoc .txt="C:\Program Files\Windows\System32\notepad.exe"
		        'End If
		        
		        
		        'From LOSStore -
		        ''Add ability to Associate Filetypes
		        'If LnkFileTypes[I] <> "" Then
		        'MakeFileType(LnkDisplayName[I], LnkFileTypes[I], LnkComment[I], "wine " & LLMod.ExpPath(LnkExec[I]), LLMod.ExpPath(LnkRunInPath[I]), LnkIcon[I])
		        'End If
		        'Next
		        
		        
		        
		        'Make Desktop Shortcut also if picked
		        If ItemLnk(I).Desktop = True Then
		          CreateShortcut(ItemLnk(I).Title, Target, Slash(ItemLnk(I).RunPath), Slash(FixPath(SpecialFolder.Desktop.NativePath)))
		        End If
		        
		      Next I
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MkDir(InPath As String)
		  MakeFolder (InPath) 'Forward it on to the good one
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Move(Source As String, Dest As String)
		  If Debugging Then Debug("Move: "+Source + " To "+Dest)
		  If Source = "" Or Source.Length <= 4 Then Return 'Don't remove short paths, it's dangerous to do them as mistakes happen
		  If Dest = "" Or Dest.Length <= 4 Then Return 'Don't remove short paths, it's dangerous to do them as mistakes happen
		  
		  
		  Dim Sh As New Shell
		  Sh.TimeOut = -1
		  Sh.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  
		  Dim Parent As String
		  
		  Dim OutFile As String
		  
		  'Source = Slash(Source)
		  Dest = Slash(Dest) 'Must have Slash at the end or will fail (asking for is file or folder)
		  
		  If TargetWindows Then Source = Source.ReplaceAll("/","\") 'move needs backslash in Windows
		  If TargetWindows Then Dest = Dest.ReplaceAll("/","\") 'move needs backslash in Windows
		  
		  
		  Source = Source.Trim
		  Dest = Dest.Trim
		  
		  
		  If Right(Source,4) <> ".lnk" Then
		    Parent = NoSlash(Source).Trim
		    Parent = Right(Source,Len(Source)-InStrRev(Source,"\"))
		    MakeFolder (Slash(Dest)+Parent) 'Make Dest exist before copy/move to it
		  End If
		  
		  'Move Files and Folders
		  If TargetWindows Then
		    'Method 1
		    'ShellFast.Execute ("move /y " + Chr(34)+Source+Chr(34)+" "+ Chr(34)+Dest+Chr(34))
		    
		    'Method 2 - Try copy and Deltree methods (Will work for now)
		    If Parent <> "" Then
		      ShellFast.Execute ("xcopy /e /c /q /h /r /y " + Chr(34)+Source+Chr(34)+" "+ Chr(34)+Dest+"\"+Parent+"\"+Chr(34)) 'Keep Parent Folder Name
		    Else
		      ShellFast.Execute ("xcopy /e /c /q /h /r /y " + Chr(34)+Source+Chr(34)+" "+ Chr(34)+Dest+"\"+Chr(34)) 'Keep Parent Folder Name
		    End If
		    Deltree (Source) 'Remove once xcopied
		    
		    ''Method 3 'Untested, but need to rewrite the method for bulding a script, running it and deleting it
		    'If Parent <> "" Then
		    'OutFile = "xcopy /e /c /q /h /r /y " + Chr(34)+Source+Chr(34)+" "+ Chr(34)+Dest+"\"+Parent+"\"+Chr(34)
		    'Else
		    'OutFile = "xcopy /e /c /q /h /r /y " + Chr(34)+Source+Chr(34)+" "+ Chr(34)+Dest+"\"+Chr(34)
		    'End If
		    'SaveDataToFile(OutFile, Slash(TmpPath)+"MoveIt.cmd")
		    'Sh.Execute (Slash(TmpPath)+"MoveIt.cmd") 'Run script file instead of command, works perfect in win
		    'While Sh.IsRunning
		    'App.DoEvents(1)
		    'Wend
		    'Deltree (Source) 'Remove once xcopied
		    
		  Else 'linux, no problems with running shell
		    ShellFast.Execute ("mv -f " + Chr(34)+Source+Chr(34)+" "+ Chr(34)+Dest+Chr(34))
		  End If
		  
		  ''Move File, very old method, fails in Win due to wrong slashes etc
		  'If TargetWindows Then
		  'ShellFast.Execute ("move /y " + Chr(34)+Source+Chr(34)+" "+ Chr(34)+Dest+Chr(34))
		  'Else
		  'ShellFast.Execute ("mv -f " + Chr(34)+Source+Chr(34)+" "+ Chr(34)+Dest+Chr(34))
		  'End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveLinks()
		  If Debugging Then Debug("--- Starting Move Links ---")
		  Dim DaBugs As String
		  
		  Dim Debugger As String
		  
		  Dim DestStartPath As String
		  
		  Dim Catalog() As String
		  Dim CatalogCount As Integer
		  Dim I,J, K As Integer
		  Dim M As Integer
		  Dim Sp() As String
		  
		  
		  If Not TargetWindows Then 'Linux and Mac
		    'Clean up Temp LLShorts Folder
		    Deltree (Slash(TmpPath)+"LLShorts")
		    MakeFolder (Slash(TmpPath)+"LLShorts")
		    
		    If ItemLLItem.Flags.IndexOf("desktop") < 0 Then 'Not found, so Move it to the destination folder or delete it if exist
		      Sp() = ItemLLItem.ShortCutNamesKeep.Split("|")
		      For M = 0 To Sp.Count-1
		        Move (Slash(FixPath(SpecialFolder.Desktop.NativePath)) + Sp(M).Trim +".desktop", Slash(TmpPath)+"LLShorts/")
		        'Move (Slash(FixPath(SpecialFolder.SharedDesktop.NativePath)) + Sp(M).Trim +".desktop", Slash(TmpPath)+"LLShorts/") 'No Shared Desktop in Linux
		      Next M
		    End If
		  End If
		  
		  If TargetWindows Then
		    
		    'Clean up Temp LLShorts Folder
		    Deltree (Slash(TmpPath)+"LLShorts")
		    MakeFolder (Slash(TmpPath)+"LLShorts")
		    
		    'Get the StartMenu Stuff for ssApps and then for ppApps/Games
		    If ItemLLItem.Catalog <> "" Then
		      Catalog = ItemLLItem.Catalog.Split(";")
		      CatalogCount = Catalog.Count - 1
		      For I = 0 To CatalogCount
		        Catalog(I) = Catalog(I).Trim
		        IF RedirectAppCount >= 1 Then
		          Select Case ItemLLItem.BuildType
		          Case "ssApp","ppApp"
		            For J = 0 To RedirectAppCount -1
		              
		              If Catalog(I) = RedirectsApp (J,0) Then
		                'Debugger=Debugger + Catalog(I)+" >"+ RedirectsApp (J,0)+" >>"+RedirectsApp (J,1)+ Chr(10)
		                ItemLLItem.Catalog = ItemLLItem.Catalog.ReplaceAll(RedirectsApp (J,0),RedirectsApp (J,1))'Replace with new App Catalog
		                Exit 'Found, no need to continue
		              End If
		            Next J
		          Case Else 'Game
		            For J = 0 To RedirectGameCount -1
		              If Catalog(I) = RedirectsGame (J,0) Then ItemLLItem.Catalog = ItemLLItem.Catalog.ReplaceAll(RedirectsGame (J,0),RedirectsGame (J,1))'Replace with new Game Catalog
		            Next J
		          End Select
		        End If
		      Next I
		    End If
		    
		    
		    If ItemLLItem.Catalog <> "" Then
		      Catalog = ItemLLItem.Catalog.Split(";")
		      CatalogCount = Catalog.Count - 1
		      For J = 0 To CatalogCount
		        Catalog(J) = Catalog(J).Trim
		        If Catalog(J) <> "" Then ' Only do Valid Link Catalogs
		          If MenuWindowsCount >= 1 Then
		            For K = 0 To MenuWindowsCount -1
		              'Debugger=Debugger + Catalog(J)+" >"+ MenuWindows (K,0)+" >>"+MenuWindows (K,1)+ Chr(10)
		              If Catalog(J) = MenuWindows (K,0) Then
		                DestStartPath = MenuWindows (K,1)
		                'Debugger=Debugger + DestStartPath+Chr(10)
		              End If
		            Next
		          End If
		        End If
		      Next
		    End If
		    
		    'Do Desktop First
		    If ItemLLItem.Flags.IndexOf("desktop") < 0 Then 'Not found, so Move it to the destination folder or delete it if exist
		      'Delete for now, will use Move once I make a function
		      Sp() = ItemLLItem.ShortCutNamesKeep.Split("|")
		      For M = 0 To Sp.Count-1
		        Move (Slash(FixPath(SpecialFolder.Desktop.NativePath)) + Sp(M).Trim +".lnk", Slash(TmpPath)+"LLShorts/")
		        Move (Slash(FixPath(SpecialFolder.SharedDesktop.NativePath)) + Sp(M).Trim +".lnk", Slash(TmpPath)+"LLShorts/")
		      Next M
		      
		      'Deltree (Slash(FixPath(SpecialFolder.Desktop.NativePath)) + ItemLLItem.ShortCutNamesKeep +".lnk") 'Remove it, clean up Current User
		      'Deltree (Slash(FixPath(SpecialFolder.SharedDesktop.NativePath)) + ItemLLItem.ShortCutNamesKeep +".lnk") 'Remove it, clean up All Users
		    End If
		    
		    
		    'Now Do Start Menu
		    If ItemLLItem.Flags.IndexOf("keepinfolder") >=0 Then
		      
		      '
		      If AdminEnabled Then
		        Move (StartPathAll+ItemLLItem.StartMenuSourcePath, StartPathAll+DestStartPath) 'Remove it, clean up
		        Move (StartPathUser+ItemLLItem.StartMenuSourcePath, StartPathAll+DestStartPath) 'Remove it, clean up
		      Else
		        Move (StartPathAll+ItemLLItem.StartMenuSourcePath, StartPathUser+DestStartPath) 'Remove it, clean up
		        Move (StartPathUser+ItemLLItem.StartMenuSourcePath, StartPathUser+DestStartPath) 'Remove it, clean up
		      End If
		      
		      'Below is the original, to temp, need to dest
		      'Move (StartPathAll+ItemLLItem.StartMenuSourcePath, Slash(TmpPath)+"LLShorts/") 'Remove it, clean up
		      'Move (StartPathUser+ItemLLItem.StartMenuSourcePath, Slash(TmpPath)+"LLShorts/") 'Remove it, clean up
		      
		    Else 'Just keep some and delete folder
		      Sp() = ItemLLItem.ShortCutNamesKeep.Split("|")
		      For M = 0 To Sp.Count-1
		        If AdminEnabled Then
		          Move (StartPathAll+ItemLLItem.StartMenuSourcePath+"/"+ Sp(M).Trim +".lnk", StartPathAll+DestStartPath) 'Remove it, clean up
		          Move (StartPathUser+ItemLLItem.StartMenuSourcePath+"/"+ Sp(M).Trim +".lnk", StartPathAll+DestStartPath) 'Remove it, clean up
		        Else
		          Move (StartPathAll+ItemLLItem.StartMenuSourcePath+"/"+ Sp(M).Trim+".lnk", StartPathUser+DestStartPath) 'Remove it, clean up
		          Move (StartPathUser+ItemLLItem.StartMenuSourcePath+"/"+ Sp(M).Trim +".lnk", StartPathUser+DestStartPath) 'Remove it, clean up
		        End If
		      Next M
		      
		      'Below is Orig works, but went to temp
		      'Move (StartPathAll+ItemLLItem.StartMenuSourcePath+"/"+ ItemLLItem.ShortCutNamesKeep +".lnk", Slash(TmpPath)+"LLShorts/") 'Remove it, clean up
		      'Move (StartPathUser+ItemLLItem.StartMenuSourcePath+"/"+ ItemLLItem.ShortCutNamesKeep +".lnk", Slash(TmpPath)+"LLShorts/") 'Remove it, clean up
		      
		      'Below is needed to clear the empty or dregs
		      If ItemLLItem.StartMenuSourcePath <> "" Then ' Careful deleting folders from start menu ' May need a 2nd look
		        Deltree (StartPathAll+ItemLLItem.StartMenuSourcePath) 'Remove it, clean up
		        Deltree (StartPathUser+ItemLLItem.StartMenuSourcePath) 'Remove it, clean up
		      End If
		      
		      
		    End If
		    
		    DaBugs = StartPathAll+ItemLLItem.StartMenuSourcePath+"/"+ ItemLLItem.ShortCutNamesKeep +".lnk"+">>>"+ StartPathAll+DestStartPath
		    'SaveDataToFile (DaBugs+Chr(10)+"------"+Chr(10)+Debugger ,Slash(FixPath(SpecialFolder.Desktop.NativePath))+"Test.txt")
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NoSlash(Inn As String) As String
		  If Inn <> "" Then
		    If Right(Inn,1)="/" Or Right(Inn,1)="\" Then Inn = Left(Inn,Len(Inn)-1)
		  End If
		  Return Inn
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OpenDialog(FileTyp As FileType, Title As String, InitialPath As String) As String
		  Dim Init, F As FolderItem
		  Dim dlg As OpenDialog
		  
		  If InitialPath = "" Then InitialPath = SpecialFolder.Desktop.NativePath
		  
		  Init = GetFolderItem(InitialPath, FolderItem.PathTypeShell)
		  dlg = New OpenDialog
		  dlg.InitialDirectory = Init
		  dlg.Title = Title
		  dlg.Filter = FileTyp
		  F = dlg.ShowModal()
		  
		  If F = Nil Then Return "" Else Return F.NativePath
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PreQuitApp()
		  If Debugging Then Debug("--- Starting Pre Quit LLStore ---")
		  'MsgBox "Pre Quitting"
		  
		  Loading.SaveSettings
		  
		  DebugOutput.Flush ' Actually Write to file after each thing
		  DebugOutput.Close 'Close File when quiting
		  If Debugging Then Copy(DebugFile.NativePath, Slash(SpecialFolder.Desktop.NativePath)+"LLStore_Debug.txt") 'Copy Debug to Desktop
		  
		  'Clean Up Temp
		  CleanTemp
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub QuitApp()
		  If Debugging Then Debug("--- Quitting LLStore ---")
		  ForceQuit = True
		  Quit ' This Works on Compiled Versions, test if Windows is OK too, dont know why it was being so problematic.
		  'was 24 r4 causing issues
		  
		  'I added the Quit timer to the Loading Form, it now seems to quit when it's called, I only make the Editor set it to ForceQuit and hide iteself and let the QuitApp routine do the rest.
		  
		  ''Should never get here
		  
		  ForceQuit = True
		  'MsgBox "Quitting"
		  
		  'Close other forms
		  'If EditorOnly = True Then
		  
		  
		  'Old Method
		  'Editor.Close
		  'Data.Close
		  'ScreenResolution.Close
		  'MiniInstaller.Close
		  'Settings.Close
		  'Main.Close
		  ''Do this last as it's the main form
		  'Loading.Close
		  
		  'MsgBox "Should quit now"
		  'Quit
		  
		  
		  //manually close all windows
		  while window(0) <> nil
		    'dim s as string = window(0).Title
		    window(0).close
		  wend
		  
		  Quit
		  
		  'Exception err
		  'select case err
		  'case isa EndException
		  'MsgBox "EndException"
		  'end select
		  
		  
		  ''Dim I As Integer
		  
		  'For i As Integer = WindowCount - 1 DownTo 0
		  'Var w As Window = Window(i)
		  'If w <> Nil then w.close
		  'Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RunAssembly()
		  If Debugging Then Debug("--- Starting Run Assembly ---")
		  
		  Dim Shelly As New Shell
		  Dim StillActive As Boolean = True
		  
		  Dim Sp() As String
		  Dim F As FolderItem
		  Dim I As Integer
		  
		  Dim AssemblyFile, AssemblyContent As String
		  
		  Shelly.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  Shelly.TimeOut = -1
		  
		  'Change to App/Games INI Path to run Assemblys from
		  If ChDirSet(InstallFromPath) = True Then ' Was successful
		  End If
		  
		  Sp = Split(ItemLLItem.Assembly, Chr(30))
		  If Sp.Count >=1 Then
		    For I = 0 To Sp.Count -1
		      If Sp(I).IndexOf(0, "#Is_x86#") >= 0 Then Continue 'Skip x86 lines, we will only do x64 for now
		      Sp(I) = Sp(I).ReplaceAll("#Is_x64#","") 'Clean unrequired text
		      If Sp(I) <> "" Then
		        
		        'Add MSI installer to lines that have a .msi in them - May Need to remove for Windows Target
		        If Sp(I).IndexOf(".msi") >=1 Then
		          If Left(Sp(I),7) <> "msiexec" Then
		            'If Left(Sp(I),1)<>Chr(34) Then 'Need to check for end of .msi and remove /qb if it's an issue
		            Sp(I)= "msiexec /quiet /norestart /i "+Sp(I)
		          Else
		          End If
		        End If
		        
		        AssemblyContent = AssemblyContent + Sp(I)+ Chr(10)
		      End If
		    Next
		  Else ' Single Line?
		    ItemLLItem.Assembly = ItemLLItem.Assembly.ReplaceAll("#Is_x86#","") 'Clean unrequired text
		    ItemLLItem.Assembly = ItemLLItem.Assembly.ReplaceAll("#Is_x64#","") 'Clean unrequired text
		    If ItemLLItem.Assembly <> "" Then
		      
		      'Add MSI installer to lines that have a .msi in them - May Need to remove for Windows Target
		      If ItemLLItem.Assembly.IndexOf(".msi") >=1 Then
		        If Left(ItemLLItem.Assembly,7) <> "msiexec" Then
		          'If Left(Sp(I),1)<>Chr(34) Then 'Need to check for end of .msi and remove /qb if it's an issue
		          ItemLLItem.Assembly = "msiexec /quiet /norestart /i "+ItemLLItem.Assembly
		        Else
		        End If
		      End If
		      
		      AssemblyContent = AssemblyContent + ItemLLItem.Assembly + Chr(10)
		    End If
		  End If
		  
		  If AssemblyContent <> "" Then 'Generate Script and Run it all from a .cmd
		    'MkDir(InstallToPath) ' 'Let the Setup install the folder so I can detect where it goes.
		    AssemblyFile = Slash(TmpPath)+"Assembly.cmd"
		    SaveDataToFile(AssemblyContent, AssemblyFile)
		    
		    F = GetFolderItem(AssemblyFile, FolderItem.PathTypeShell)
		    If TargetWindows Then
		      Shelly.Execute ("cd " + Chr(34) + InstallFromPath + Chr(34) + " && " + Chr(34) + FixPath(F.NativePath) + Chr(34)) ' Use && Here because if path fails, then script will anyway
		    Else
		      Shelly.Execute("cd " + Chr(34) + InstallFromPath + Chr(34) + " && wine " + Chr(34) + FixPath(F.NativePath) + Chr(34)) ' Use && Here because if path fails, then script will anyway
		    End If
		    While Shelly.IsRunning 
		      App.DoEvents(7)
		    Wend
		    If Debugging Then Debug("Assembly Return: "+ Shelly.Result)
		    
		    'Delete the temp script I run
		    #Pragma BreakOnExceptions Off
		    Try
		      F.Remove
		    Catch
		    End Try
		    #Pragma BreakOnExceptions On
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RunCommand(CmdIn As String, FoldIn As String = "")
		  If Debugging Then Debug("--- Starting Run Command ---")
		  
		  Dim Sh As New Shell
		  Dim Success As Boolean
		  
		  Sh.TimeOut = -1
		  Sh.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  
		  Dim F As FolderItem
		  Dim ScriptFile As String = Slash(TmpPath)+"LLRunner.cmd"
		  If CmdIn <> "" Then
		    
		    If FoldIn <> "" Then Success = ChDirSet(FoldIn)
		    
		    If TargetWindows Then
		      SaveDataToFile(CmdIn, ScriptFile)
		      
		      F = GetFolderItem(ScriptFile, FolderItem.PathTypeShell)
		      If F.Exists Then
		        'Run Script
		        Sh.Execute (F.NativePath)
		        
		        'Wait For Completion
		        While Sh.IsRunning
		          App.DoEvents(1)
		        Wend
		      End If
		      F = Nil
		      'Delete Temp Script
		      Deltree ScriptFile
		    Else ''Linux Command, doesn't need to go to script file to work (it just does)
		      'Run Script
		      Sh.Execute (CmdIn)
		      
		      'Wait For Completion
		      While Sh.IsRunning
		        App.DoEvents(1)
		      Wend
		      If Debugging Then Debug(Sh.Result)
		      
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RunCommandResults(CmdIn As String, FoldIn As String = "") As String
		  If Debugging Then Debug("--- Starting Run Command Results ---")
		  Dim Sh As New Shell
		  Dim Success As Boolean
		  
		  Sh.TimeOut = -1
		  Sh.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  
		  Dim F As FolderItem
		  Dim ScriptFile As String = Slash(TmpPath)+"LLRunner.cmd"
		  If CmdIn <> "" Then
		    
		    If FoldIn <> "" Then Success = ChDirSet(FoldIn)
		    
		    If TargetWindows Then
		      SaveDataToFile(CmdIn, ScriptFile)
		      
		      F = GetFolderItem(ScriptFile, FolderItem.PathTypeShell)
		      If F.Exists Then
		        'Run Script
		        Sh.Execute (F.NativePath)
		        
		        'Wait For Completion
		        While Sh.IsRunning
		          App.DoEvents(1)
		        Wend
		        If Debugging Then Debug(Sh.Result)
		        
		        'Delete Temp Script
		        F.Remove
		      End If
		      F = Nil
		      
		    Else 'Linux Command, doesn't need to go to script file to work (it just does)
		      'Run Script
		      Sh.Execute (CmdIn)
		      
		      'Wait For Completion
		      While Sh.IsRunning
		        App.DoEvents(1)
		      Wend
		      If Debugging Then Debug(Sh.Result)
		    End If
		    
		    'For Both
		    Return Sh.Result
		  End If
		  
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RunRegistry()
		  If Debugging Then Debug("--- Starting Run Registry ---")
		  
		  Dim FileToUse As String
		  Dim ScriptFile As String
		  
		  Dim Shelly As New Shell
		  Shelly.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  Shelly.TimeOut = -1
		  
		  Dim F As FolderItem
		  
		  FileToUse = InstallToPath + ItemLLItem.BuildType+".reg"
		  If Exist(FileToUse) Then 
		    If TargetWindows Then
		      ScriptFile = ExpReg (InstallToPath + ItemLLItem.BuildType+".reg")
		      
		      F = GetFolderItem(ScriptFile, FolderItem.PathTypeShell)
		      
		      Shelly.Execute ("cmd.exe /c", "regedit.exe /s " + Chr(34) + FixPath(F.NativePath) + Chr(34)) 'Trying this way as it seem more compatible
		      While Shelly.IsRunning
		        App.DoEvents(7)
		      WEnd
		    Else
		      ScriptFile = ExpReg (InstallToPath + ItemLLItem.BuildType+".reg")
		      Shelly.Execute("wine regedit.exe /s " + Chr(34) + ScriptFile+ Chr(34))
		      While Shelly.IsRunning
		        App.DoEvents(7)
		      WEnd
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RunScripts()
		  If Debugging Then Debug("--- Starting Run Scripts ---")
		  
		  Dim ScriptFile As String
		  
		  Dim Shelly As New Shell
		  Shelly.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  Shelly.TimeOut = -1
		  
		  Dim StillActive As Boolean = True
		  
		  Dim F As FolderItem
		  
		  'Change to App/Games Install To path to run scripts from (NoInstall sets to InstallFrom)
		  If ItemLLItem.BuildType = "ssApp" Then 
		    If ChDirSet(InstallFromPath) = True Then ' Was successful - ssApp path set
		    End If
		  Else
		    If ChDirSet(InstallToPath) = True Then ' Was successful - ppApp/Game path set
		    End If
		  End If
		  
		  If TargetLinux Then
		    F = GetFolderItem(InstallToPath + "LLScript.sh")
		    If F.Exists Then  ' Run Linux Script
		      
		      ScriptFile = ExpScript (InstallToPath + "LLScript.sh")
		      F = GetFolderItem(ScriptFile, FolderItem.PathTypeShell)
		      Shelly.Execute("cd " + Chr(34) + InstallToPath + Chr(34) + " ; bash " + Chr(34) + FixPath(F.NativePath) + Chr(34)) 'Glenn 2027 - Check bash is suitable over sh. I think it is ' Use && Here because if path fails, then script will anyway
		      While Shelly.IsRunning
		        App.DoEvents(7)
		      Wend
		      If Debugging Then Debug("Script Return (.sh): "+ Shelly.Result)
		    End If
		    
		  End If
		  If  ItemLLItem.BuildType = "ssApp" Then 'Run the Scripts from the InstallFromPath
		    F = GetFolderItem(InstallFromPath + ItemLLItem.BuildType+".cmd")
		    If Exist(InstallFromPath + ItemLLItem.BuildType+".cmd") Then 
		      ScriptFile = ExpScript (InstallFromPath + ItemLLItem.BuildType+".cmd")
		      
		      F = GetFolderItem(ScriptFile, FolderItem.PathTypeShell)
		      If TargetWindows Then
		        Shelly.Execute ("cmd.exe /c",Chr(34)+FixPath(F.NativePath)+Chr(34))
		      Else
		        Shelly.Execute("cd " + Chr(34) + InstallFromPath + Chr(34) + " ; wine " + Chr(34) + ScriptFile + Chr(34)) ' Use && Here because if path fails, then script will anyway
		      End If
		      While Shelly.IsRunning
		        App.DoEvents(7)
		      Wend
		      If Debugging Then Debug("Script Return (ssApp.cmd): "+ Shelly.Result)
		    Else ' ppApp or ppGame, runs script from the InstallTo Folder
		      F = GetFolderItem(InstallToPath + ItemLLItem.BuildType+".cmd")
		      If Exist(InstallToPath + ItemLLItem.BuildType+".cmd") Then 
		        ScriptFile = ExpScript (InstallToPath + ItemLLItem.BuildType+".cmd")
		        
		        F = GetFolderItem(ScriptFile, FolderItem.PathTypeShell)
		        If TargetWindows Then
		          Shelly.Execute ("cmd.exe /c",Chr(34)+FixPath(F.NativePath)+Chr(34))
		        Else
		          Shelly.Execute("cd " + Chr(34) + InstallToPath + Chr(34) + " ; wine " + Chr(34) + ScriptFile + Chr(34)) ' Use && Here because if path fails, then script will anyway
		        End If
		        While Shelly.IsRunning
		          App.DoEvents(7)
		        Wend
		        If Debugging Then Debug("Script Return ("+ItemLLItem.BuildType+".cmd): "+ Shelly.Result)
		      End If
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RunSudo(Command As String)
		  If Debugging Then Debug("--- Starting Run Sudo Command ---")
		  
		  Dim Sh As New Shell
		  
		  Sh.ExecuteMode = Shell.ExecuteModes.Synchronous
		  Sh.TimeOut = -1
		  
		  Dim ScriptFile As String
		  
		  If Not TargetWindows Then
		    if SudoShellLoop.IsRunning = True Then ' Check still running
		      SudoEnabled = True
		    Else
		      SudoEnabled = False
		    End If
		    If SudoEnabled = True Then ' Only bother if the script is running, else ignore it
		      
		      SaveDataToFile (Command, "/tmp/Expanded_Script.sh")
		      
		      Sh.Execute("mv -f /tmp/Expanded_Script.sh /tmp/LLScript_Sudo.sh") 'Do it the solid way, not with Xojo
		      
		      While Exist ("/tmp/LLScript_Sudo.sh") 'This script gets removed after it completes, do not continue the processing until this happens
		        App.DoEvents(7)
		      Wend
		    End If
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RunSudoScripts()
		  If Debugging Then Debug("--- Starting Run Sudo Scripts ---")
		  
		  Dim Sh As New Shell
		  
		  Sh.ExecuteMode = Shell.ExecuteModes.Synchronous
		  Sh.TimeOut = -1
		  
		  Dim ScriptFile As String
		  
		  '*** Make sure to add CD to the top of the script so it does it from the correct folder (I have since swapped back to doing a single script at a time so I can keep progress better, so not needed).
		  'If the file exist then it copies to Temp and runs, else it skips over it
		  
		  'Trying below to see if that is enough - No seems to need to be put into the script so that the calling script shifts to the right path as it opens a new bash, easy fixed :)
		  'Change to App/Games Install To path to run scripts from (NoInstall sets to InstallFrom)
		  'MsgBox "Path: "+InstallToPath
		  'If ChDirSet(InstallToPath) = True Then ' Was successful
		  'End If
		  
		  If Not TargetWindows Then
		    If Exist(InstallToPath+"LLScript_Sudo.sh") Then
		      if SudoShellLoop.IsRunning = True Then ' Check still running
		        SudoEnabled = True
		      Else
		        SudoEnabled = False
		      End If
		      If SudoEnabled = True Then ' Only bother if the script is running, else ignore it
		        
		        ScriptFile = ExpScript (InstallToPath + "LLScript_Sudo.sh", True)
		        
		        Sh.Execute("mv -f /tmp/Expanded_Script.sh /tmp/LLScript_Sudo.sh") 'Do it the solid way, not with Xojo
		        
		        While Exist ("/tmp/LLScript_Sudo.sh") 'This script gets removed after it completes, do not continue the processing until this happens
		          App.DoEvents(7)
		        Wend
		      End If
		    End If
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RunWait(EXEName As String, PathIn As String = "", ArgsIn As String = "")
		  If Debugging Then Debug("---------- RunWait: "+ PathIn+">"+EXEName+" | "+ArgsIn+" ----------")
		  
		  Dim theShell As New Shell
		  theShell.Mode = 1 'Run and continue code
		  theShell.TimeOut = -1 'Give it All the time it needs
		  
		  If PathIn<>"" Then
		    If ChDirSet(PathIn) = True Then ' Was successful
		    End If
		  End If
		  
		  Running = True
		  theShell.Execute (EXEName)
		  
		  While theShell.IsRunning
		    App.DoEvents(3)
		  Wend
		  If Debugging Then Debug(theShell.Result) ' Debug Print all of the Run Results
		  
		  If Debugging Then Debug("---------- End of RunWait ----------") ' Debug Print all of the Run Results
		  
		  Running = False
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveDataToFile(Data As String, FileIn As String)
		  If TargetWindows Then
		    FileIn = FileIn.ReplaceAll("/","\")
		  Else
		    FileIn = FileIn.ReplaceAll("\","/")
		  End If
		  
		  If Debugging Then Debug("Save Data To File: "+ FileIn)
		  
		  Dim F As FolderItem
		  Dim T As TextOutputStream
		  
		  #Pragma BreakOnExceptions Off
		  
		  Try
		    F = GetFolderItem(FileIn, FolderItem.PathTypeShell)
		    
		    If F <> Nil Then
		      If F.IsWriteable Then
		        If F.Exists Then F.Remove
		        T = TextOutputStream.Create(F)
		        T.Write(Data)
		        T.Close
		      End If
		    End If
		  Catch
		    If Debugging Then Debug("* Error - Saving Data To File: "+ FileIn)
		  End Try
		  
		  #Pragma BreakOnExceptions On
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SaveDialog(FileTyp As FileType, Title As String, InitialPath As String, DefaultName As String) As String
		  Dim F, Init As FolderItem
		  Dim dlg As SaveAsDialog
		  
		  Init = GetFolderItem(InitialPath, FolderItem.PathTypeShell)
		  
		  dlg = New SaveAsDialog
		  dlg.InitialDirectory=Init
		  dlg.Title = Title
		  dlg.SuggestedFileName = DefaultName
		  dlg.Filter = FileTyp
		  F = dlg.ShowModal()
		  
		  If F = Nil Then
		    Return ""
		  Else
		    If Lowercase(Right(F.ShellPath,3)) = Lowercase(FileTyp.Extensions) Then Return F.NativePath
		    Return F.NativePath + "." + Lowercase(FileTyp.Extensions)
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SaveLLFile(SaveToPath As String) As Boolean
		  If Debugging Then Debug("--- Save LLFile ---")
		  If Debugging Then Debug("Save To: "+ SaveToPath)
		  
		  If ItemLLItem.TitleName = "" Or ItemLLItem.BuildType = "" Then
		    MsgBox "Title or BuildType not set, Failed!"
		    Return False
		  End If
		  
		  If Not Exist(SaveToPath) Then
		    MsgBox "Path to Save to Not Found: " + SaveToPath
		  End If
		  
		  Dim I As Integer
		  Dim DataOut As String
		  Dim FlagsOut As String
		  Dim LLFileOut, OutFile As String
		  Dim BType As String
		  
		  Select Case ItemLLItem.BuildType
		  Case "ppGame"
		    DataOut = "[SetupS]" + Chr(10)
		    BType = "SS"
		    OutFile = ItemLLItem.BuildType+".ppg"
		  Case "ssApp"
		    DataOut = "[SetupS]" + Chr(10)
		    BType = "SS"
		    OutFile = ItemLLItem.BuildType+".app"
		  Case  "ppApp"
		    DataOut = "[SetupS]" + Chr(10)
		    BType = "SS"
		    OutFile = ItemLLItem.BuildType+".app"
		  Case "LLApp"
		    DataOut = "[LLFile]" + Chr(10)
		    BType = "LL"
		    OutFile = ItemLLItem.BuildType+".lla"
		  Case "LLGame"
		    DataOut = "[LLFile]" + Chr(10)
		    BType = "LL"
		    OutFile = ItemLLItem.BuildType+".llg"
		  End Select
		  
		  'Prepare LLFile output
		  LLFileOut = FixPath(Slash(SaveToPath)+OutFile)
		  
		  'All Files General
		  DataOut = DataOut + "Title="+ ItemLLItem.TitleName+Chr(10)
		  If ItemLLItem.Version <> "" Then DataOut = DataOut + "Version="+ ItemLLItem.Version+Chr(10)
		  If ItemLLItem.Descriptions <> "" Then DataOut = DataOut + "Description=" + ItemLLItem.Descriptions.ReplaceAll(Chr(13),Chr(30))+Chr(10)
		  If ItemLLItem.URL <> "" Then DataOut = DataOut + "URL=" + ItemLLItem.URL.ReplaceAll(Chr(13),"|")+Chr(10)
		  If ItemLLItem.Categories <> "" Then DataOut = DataOut + "Category=" + ItemLLItem.Categories+Chr(10)
		  DataOut = DataOut + "BuildType=" + ItemLLItem.BuildType+Chr(10)
		  If ItemLLItem.PathApp <> "" Then DataOut = DataOut + "AppPath=" + CompPath(ItemLLItem.PathApp, True)+Chr(10)
		  If ItemLLItem.StartMenuSourcePath <> "" Then DataOut = DataOut + "StartMenuSourcePath=" + ItemLLItem.StartMenuSourcePath+Chr(10)
		  If ItemLLItem.Catalog <> "" Then DataOut = DataOut + "Catalog="+ ItemLLItem.Catalog+Chr(10)
		  If ItemLLItem.StartMenuLegacyPrimary <> "" Then DataOut = DataOut + "StartMenuLegacyPrimary=" + ItemLLItem.StartMenuLegacyPrimary+Chr(10)
		  If ItemLLItem.ShortCutNamesKeep <> "" Then DataOut = DataOut + "ShortCutNamesKeep=" + ItemLLItem.ShortCutNamesKeep+Chr(10)
		  If ItemLLItem.Priority.ToString <> "" Then
		    DataOut = DataOut + "Priority=" + ItemLLItem.Priority.ToString+Chr(10)
		  Else
		    DataOut = DataOut + "Priority=5"+Chr(10)
		  End If
		  If ItemLLItem.DECompatible <> "" Then
		    DataOut = DataOut + "DECompatible=" + ItemLLItem.DECompatible+Chr(10)
		  Else
		    DataOut = DataOut + "DECompatible=All"+Chr(10)
		  End If
		  If ItemLLItem.PMCompatible <> "" Then
		    DataOut = DataOut + "PMCompatible=" + ItemLLItem.PMCompatible+Chr(10)
		  Else
		    DataOut = DataOut + "PMCompatible=All"+Chr(10)
		  End If
		  If ItemLLItem.Assembly <> "" Then DataOut = DataOut + "Assembly=" + ItemLLItem.Assembly.ReplaceAll(Chr(13),Chr(30))+Chr(10)
		  If ItemLLItem.Flags <> "" Then DataOut = DataOut + "Flags=" + ItemLLItem.Flags+Chr(10)
		  If ItemLLItem.Arch <> "" Then DataOut = DataOut + "Architecture=" + ItemLLItem.Arch+Chr(10) 'This will need to convert x86, x64, arm to numbered, 1 = x86, 2 = x64, will need to check the rest to make it match
		  
		  'Meta Here
		  DataOut = DataOut + "[Meta]" + Chr(10)
		  If ItemLLItem.InstallSize.ToString <> "" Then DataOut = DataOut + "InstalledSize=" + ItemLLItem.InstallSize.ToString+Chr(10)
		  If ItemLLItem.Tags <> "" Then DataOut = DataOut + "Tags=" + ItemLLItem.Tags+Chr(10)
		  If ItemLLItem.Publisher <> "" Then DataOut = DataOut + "Publisher=" + ItemLLItem.Publisher+Chr(10)
		  If ItemLLItem.Builder <> "" Then DataOut = DataOut + "Releaser=" + ItemLLItem.Builder+Chr(10)
		  If ItemLLItem.ReleaseDate <> "" Then DataOut = DataOut + "ReleaseDate=" + ItemLLItem.ReleaseDate+Chr(10)
		  If ItemLLItem.License.ToString <> "" Then DataOut = DataOut + "License=" + ItemLLItem.License.ToString+Chr(10)
		  If ItemLLItem.ReleaseVersion <> "" Then DataOut = DataOut + "ReleaseVersion=" + ItemLLItem.ReleaseVersion+Chr(10)
		  
		  'Shortcuts Here
		  If BType = "SS" Then
		    If LnkCount >= 1 Then
		      For I = 1 To LnkCount
		        If ItemLnk(I).Title = "" Then Continue 'Dud item, continue looping to next item
		        DataOut = DataOut + "["+ItemLnk(I).Title+".lnk]"+Chr(10)
		        If ItemLnk(I).Exec <> "" Then DataOut = DataOut + "Target="+ItemLnk(I).Exec+Chr(10)
		        If ItemLnk(I).Associations <> "" Then DataOut = DataOut + "Extensions="+ItemLnk(I).Associations+Chr(10)
		        If ItemLnk(I).Flags <> "" Then DataOut = DataOut + "Flags="+ItemLnk(I).Flags+Chr(10)
		        If ItemLnk(I).Comment <> "" Then DataOut = DataOut + "Comment="+ItemLnk(I).Comment+Chr(10)
		        If ItemLnk(I).Description <> "" Then DataOut = DataOut + "Description="+ItemLnk(I).Description+Chr(10)
		      Next
		    End If
		    
		  Else ' Linux Shortcut
		    If LnkCount >= 1 Then
		      For I = 1 To LnkCount
		        If ItemLnk(I).Title = "" Then Continue 'Dud item, continue looping to next item
		        DataOut = DataOut + "["+ItemLnk(I).Title+".desktop]"+Chr(10)
		        If ItemLnk(I).Exec <> "" Then DataOut = DataOut + "Exec="+ItemLnk(I).Exec+Chr(10)
		        If ItemLnk(I).Comment <> "" Then DataOut = DataOut + "Comment="+ItemLnk(I).Comment+Chr(10)
		        If ItemLnk(I).RunPath <> "" Then DataOut = DataOut + "Path="+ItemLnk(I).RunPath+Chr(10)
		        If ItemLnk(I).Icon <> "" Then DataOut = DataOut + "Icon="+ItemLnk(I).Icon+Chr(10)
		        If ItemLnk(I).Categories <> "" Then DataOut = DataOut + "Categories="+ItemLnk(I).Categories+Chr(10)
		        If ItemLnk(I).Associations <> "" Then DataOut = DataOut + "Extensions="+ItemLnk(I).Associations+Chr(10)
		        If ItemLnk(I).Flags <> "" Then DataOut = DataOut + "Flags="+ItemLnk(I).Flags+Chr(10)
		        If ItemLnk(I).Description <> "" Then DataOut = DataOut + "Description="+ItemLnk(I).Description+Chr(10)
		        DataOut = DataOut + "Terminal="+ItemLnk(I).Terminal.ToString+Chr(10)
		        
		        'Do ShowOn
		        FlagsOut = ""
		        If ItemLnk(I).Desktop = True Then  FlagsOut = FlagsOut + "desktop "
		        If ItemLnk(I).Panel = True Then  FlagsOut = FlagsOut + "panel "
		        If ItemLnk(I).Favorite = True Then  FlagsOut = FlagsOut + "favorite "
		        FlagsOut = FlagsOut.Trim
		        If FlagsOut <> "" Then DataOut = DataOut + "ShowOn="+FlagsOut+Chr(10)
		        
		      Next
		    End If
		  End If
		  
		  
		  If DataOut <> "" Then
		    'Msgbox "Save To: "+LLFileOut
		    'Msgbox DataOut
		    SaveDataToFile(DataOut, LLFileOut) 'This should work, I may need to check here or somewhere (Editor) if I need to update a pre compressed item using the temp paths
		    Return True ' Success
		  Else
		    Return False 'Failed
		  End If
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Slash(Inn As String) As String
		  Inn = Inn.Trim
		  If Right(Inn,1) = "\" Then Inn = Left(Inn,Len(Inn)-1) 'Remove Slash and put back below, so Windows ones work
		  If Right(Inn,1)<>"/" Then Inn = Inn + "/"
		  
		  Inn = Inn.ReplaceAll("\","/")
		  Inn = Inn.ReplaceAll("//","/")'Remove Doubles
		  
		  Return Inn
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function UniversalName(InFile As String) As String
		  Return InFile.Lowercase.ReplaceAll(" ","")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WritableLocation(F As FolderItem) As Boolean
		  #Pragma BreakOnExceptions Off
		  Try
		    Dim F2 As FolderItem
		    Dim TOut As TextOutputStream
		    F2 = GetFolderItem (F.ShellPath +".Test", FolderItem.PathTypeShell)
		    TOut = TextOutputStream.Create(F2)
		    TOut.Close
		    F2.Delete
		    #Pragma BreakOnExceptions On
		    Return True ' Yep Writable
		  Catch
		  End Try
		  #Pragma BreakOnExceptions On
		  
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub XCopy(InPath As String, OutPath As String)
		  If Debugging Then Debug("XCopy: "+ InPath +" To " + OutPath)
		  RunCommand("xcopy.exe /E /C /I /H /Q /R /J /O /Y " +Chr(34) + InPath +Chr(34) +" "+Chr(34)+ OutPath +Chr(34)) ' Don't use linix paths here, xcopy may be fussy
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub XCopyFile(InPath As String, OutPath As String)
		  If Debugging Then Debug("XCopy: "+ InPath +" To " + OutPath)
		  
		  RunCommand("xcopy.exe /C /I /H /Q /R /J /O /Y " +Chr(34) + InPath +Chr(34) +" "+Chr(34)+OutPath+Chr(34))
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		AdminEnabled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		AppPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		AssignedColors(6) As Color
	#tag EndProperty

	#tag Property, Flags = &h0
		AutoBuild As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		AvailableWidth As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		BoldDescription As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		BoldList As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		BoldTitle As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		ColBG As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColCategory As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColDescription As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColDual As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColFG As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColHiLite As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColList As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColLLApp As Color = &C80B0FF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColLLGame As Color = &Cff55ff
	#tag EndProperty

	#tag Property, Flags = &h0
		ColLoading As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColMeta As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColppApp As Color = &CFFFF50
	#tag EndProperty

	#tag Property, Flags = &h0
		ColppGame As Color = &CAAFF40
	#tag EndProperty

	#tag Property, Flags = &h0
		ColSelect As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColssApp As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColStats As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		ColTitle As Color = &CFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h0
		CommandLineFile As String
	#tag EndProperty

	#tag Property, Flags = &h0
		CurrentFader As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		CurrentItemDBID As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		CurrentItemID As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h0
		CurrentPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		DebugFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		DebugFileOk As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		Debugging As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		DebugOutput As TextOutputStream
	#tag EndProperty

	#tag Property, Flags = &h0
		DefaultFader As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		DefaultLoadingWallpaper As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		DefaultMainWallpaper As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		DefaultStartButton As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		DefaultStartButtonHover As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		EditorOnly As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		FavCount As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		Favorites(2048) As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FirstItem As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h0
		FirstRun As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		FlatpakAsUser As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		FontDescription As String = "Ubuntu"
	#tag EndProperty

	#tag Property, Flags = &h0
		FontList As String = "Ubuntu"
	#tag EndProperty

	#tag Property, Flags = &h0
		FontLoading As String = "Ubuntu"
	#tag EndProperty

	#tag Property, Flags = &h0
		FontMeta As String = "Ubuntu"
	#tag EndProperty

	#tag Property, Flags = &h0
		FontStats As String = "Ubuntu"
	#tag EndProperty

	#tag Property, Flags = &h0
		FontTitle As String = "Ubuntu"
	#tag EndProperty

	#tag Property, Flags = &h0
		ForceQuit As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		ForceRefreshDBs As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		HasLinuxSudo As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		HideInstallerGameCats As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		HomePath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		InputStream As TextInputStream
	#tag EndProperty

	#tag Property, Flags = &h0
		InstallArg As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		InstallFromIni As String
	#tag EndProperty

	#tag Property, Flags = &h0
		InstallFromPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Installing As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		InstallOnly As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		InstallToPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ItemCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ItemTempPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Linux7z As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LinuxWget As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LLStoreDrive As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LnkCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		LnkEditing As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		LoadedMain As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		LoadedPosition As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		LoadPresetFile As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		ManualLocationsFile As String
	#tag EndProperty

	#tag Property, Flags = &h0
		MenuWindows(1024,2) As String
	#tag EndProperty

	#tag Property, Flags = &h0
		MenuWindowsCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		MiniInstallerShowing As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		MovieFile As String
	#tag EndProperty

	#tag Property, Flags = &h0
		MovieVolume As Integer = 20
	#tag EndProperty

	#tag Property, Flags = &h0
		OutputStream As TextOutputStream
	#tag EndProperty

	#tag Property, Flags = &h0
		ppApps As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ppAppsDrive As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ppAppsFolder As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ppGames As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ppGamesDrive As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ppGamesFolder As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PreviousPresetPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		QuitInstaller As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Quitting As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Randomiser As Random
	#tag EndProperty

	#tag Property, Flags = &h0
		RedirectAppCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		RedirectGameCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		RedirectsApp(1024,2) As String
	#tag EndProperty

	#tag Property, Flags = &h0
		RedirectsGame(1024,2) As String
	#tag EndProperty

	#tag Property, Flags = &h0
		RegKeyHKLMccsWin As String = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Windows"
	#tag EndProperty

	#tag Property, Flags = &h0
		RepositoryPathLocal As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Running As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		RunningGame As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		RunningInIDE As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		ScaledScreenShot As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		ScaledWallpaper As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		ScannedRootFolders(1024) As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ScannedRootFoldersCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ScreenRes As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ScreenShotCurrent As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		SettingsFile As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SettingsLoaded As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		ShellFast As Shell
	#tag EndProperty

	#tag Property, Flags = &h0
		StartPathAll As String
	#tag EndProperty

	#tag Property, Flags = &h0
		StartPathUser As String
	#tag EndProperty

	#tag Property, Flags = &h0
		StoreMode As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		SudoEnabled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		SudoShellLoop As Shell
	#tag EndProperty

	#tag Property, Flags = &h0
		SysAvailableArchitectures() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SysAvailableDesktops() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SysAvailablePackageManagers() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SysDesktopEnvironment As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SysDrive As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SysPackageManager As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SysProgramFiles As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SysRoot As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SysTerminal As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TempInstall As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ThemePath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TmpItemCount As Integer = 30000
	#tag EndProperty

	#tag Property, Flags = &h0
		TmpPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TmpPathItems As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ToolPath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		WasContext As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		Win7z As String
	#tag EndProperty

	#tag Property, Flags = &h0
		WinWget As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="StoreMode"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AppPath"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="CurrentPath"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ForceQuit"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Running"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DefaultMainWallpaper"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AvailableWidth"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LoadedMain"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScaledScreenShot"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScaledWallpaper"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScreenShotCurrent"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DefaultFader"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DefaultStartButton"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DefaultStartButtonHover"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="RepositoryPathLocal"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HomePath"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ItemCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LnkCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LnkEditing"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ppApps"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ppGames"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TmpPath"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ThemePath"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="CurrentItemID"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Linux7z"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LinuxWget"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Win7z"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="WinWget"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="CurrentItemDBID"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TmpItemCount"
			Visible=false
			Group="Behavior"
			InitialValue="30000"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TmpPathItems"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScannedRootFoldersCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BoldDescription"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BoldList"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BoldTitle"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColBG"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColCategory"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColDescription"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColFG"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColList"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColLLApp"
			Visible=false
			Group="Behavior"
			InitialValue="&C80B0FF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColLLGame"
			Visible=false
			Group="Behavior"
			InitialValue="&Cff55ff"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColLoading"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColMeta"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColppApp"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFF50"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColppGame"
			Visible=false
			Group="Behavior"
			InitialValue="&CAAFF40"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColSelect"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColssApp"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColStats"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColTitle"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DefaultLoadingWallpaper"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FontDescription"
			Visible=false
			Group="Behavior"
			InitialValue="Ubuntu"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FontList"
			Visible=false
			Group="Behavior"
			InitialValue="Ubuntu"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FontLoading"
			Visible=false
			Group="Behavior"
			InitialValue="Ubuntu"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FontMeta"
			Visible=false
			Group="Behavior"
			InitialValue="Ubuntu"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FontStats"
			Visible=false
			Group="Behavior"
			InitialValue="Ubuntu"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FontTitle"
			Visible=false
			Group="Behavior"
			InitialValue="Ubuntu"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColDual"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ColHiLite"
			Visible=false
			Group="Behavior"
			InitialValue="&CFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CurrentFader"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FirstItem"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ForceRefreshDBs"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HideInstallerGameCats"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SettingsFile"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="WasContext"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FirstRun"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ToolPath"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScreenRes"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="QuitInstaller"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="InstallFromIni"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Installing"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TempInstall"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LLStoreDrive"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SysDrive"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SysProgramFiles"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SysRoot"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SudoEnabled"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Quitting"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ppAppsDrive"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ppAppsFolder"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ppGamesDrive"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ppGamesFolder"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RegKeyHKLMccsWin"
			Visible=false
			Group="Behavior"
			InitialValue="HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Windows"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ItemTempPath"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasLinuxSudo"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SysDesktopEnvironment"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SysPackageManager"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SysTerminal"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InstallFromPath"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InstallToPath"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MenuWindowsCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="RedirectAppCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="RedirectGameCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AdminEnabled"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="StartPathAll"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StartPathUser"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Debugging"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="EditorOnly"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CommandLineFile"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunningInIDE"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SettingsLoaded"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="InstallOnly"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AutoBuild"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ManualLocationsFile"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="InstallArg"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LoadPresetFile"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PreviousPresetPath"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FavCount"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LoadedPosition"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DebugFileOk"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MovieFile"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MovieVolume"
			Visible=false
			Group="Behavior"
			InitialValue="20"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunningGame"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FlatpakAsUser"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule