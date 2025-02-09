#tag DesktopWindow
Begin DesktopWindow Loading
   Backdrop        =   0
   BackgroundColor =   &c00000000
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   True
   HasCloseButton  =   True
   HasFullScreenButton=   False
   HasMaximizeButton=   False
   HasMinimizeButton=   False
   Height          =   200
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   0
   MenuBarVisible  =   False
   MinimumHeight   =   200
   MinimumWidth    =   440
   Resizeable      =   False
   Title           =   "LLStore Loading..."
   Type            =   0
   Visible         =   False
   Width           =   440
   Begin Timer FirstRunTime
      Enabled         =   True
      Index           =   -2147483648
      LockedInPosition=   False
      Period          =   50
      RunMode         =   0
      Scope           =   0
      TabPanelIndex   =   0
   End
   Begin DesktopLabel Status
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   56
      Index           =   -2147483648
      Italic          =   False
      Left            =   7
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Multiline       =   True
      Scope           =   0
      Selectable      =   False
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   False
      Text            =   "Loading..."
      TextAlignment   =   2
      TextColor       =   &cFFFFFF00
      Tooltip         =   ""
      Top             =   140
      Transparent     =   True
      Underline       =   False
      Visible         =   True
      Width           =   427
   End
   Begin Timer DownloadTimer
      Enabled         =   True
      Index           =   -2147483648
      LockedInPosition=   False
      Period          =   100
      RunMode         =   0
      Scope           =   0
      TabPanelIndex   =   0
   End
   Begin Timer VeryFirstRunTimer
      Enabled         =   True
      Index           =   -2147483648
      LockedInPosition=   False
      Period          =   1
      RunMode         =   0
      Scope           =   0
      TabPanelIndex   =   0
   End
   Begin Timer QuitCheckTimer
      Enabled         =   True
      Index           =   -2147483648
      LockedInPosition=   False
      Period          =   1000
      RunMode         =   2
      Scope           =   0
      TabPanelIndex   =   0
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Function CancelClosing(appQuitting As Boolean) As Boolean
		  If ForceQuit = False Then
		    Loading.Hide
		    QuitApp
		    Return False
		  Else
		    Return False
		  End If
		End Function
	#tag EndEvent

	#tag Event
		Sub Closing()
		  Debug("-- Loading Closed")
		End Sub
	#tag EndEvent

	#tag Event
		Sub Opening()
		  Debug("-- Loading Opening")
		  
		  If ForceQuit = True Then Return 'Don't bother even opening if set to quit
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub CheckCompatible()
		  If Debugging Then Debug("- Starting Check Compatible -")
		  App.DoEvents(1) 'This makes the Load Screen Update the Status Text, Needs to be in each Function and Sub call
		  
		  Dim I As Integer
		  Dim DeTest As String
		  
		  'Check if App Path exists
		  For I = 0 To Data.Items.RowCount - 1
		    Data.Items.CellTextAt(I, Data.GetDBHeader("OSCompatible")) = "T" 'Default to Enabled on current OS, incase any are missing below then it will still set to false and skip the rest
		    
		    If TargetWindows Then 'If Windows session, hide linux things that may be in wrong paths
		      DeTest = Data.Items.CellTextAt(I, Data.GetDBHeader("BuildType")) 
		      If DeTest = "LLApp" Or DeTest = "LLGame" Then
		        Data.Items.CellTextAt(I, Data.GetDBHeader("OSCompatible")) = "F"
		        Data.Items.CellTextAt(I, Data.GetDBHeader("Hidden")) = "T" 'Make sure they are NOT shown ever
		      End If
		    End If
		    
		    'Do Arch first as that will always be needed
		    DeTest = Data.Items.CellTextAt(I, Data.GetDBHeader("ArchCompatible")) 
		    If DeTest <> "" Then 'Only do Items with Values set
		      If  DeTest.IndexOf(SysArchitecture) >=0 Or DeTest = "All" Then
		        Data.Items.CellTextAt(I, Data.GetDBHeader("OSCompatible")) = "T"
		      Else 'Not Compatible
		        Data.Items.CellTextAt(I, Data.GetDBHeader("OSCompatible")) = "F"
		      End If
		    End If
		    
		    If Data.Items.CellTextAt(I, Data.GetDBHeader("OSCompatible")) = "T" Then 'Will only continue if Arch Passed and wont check it if empty
		      DeTest = Data.Items.CellTextAt(I, Data.GetDBHeader("DECompatible")) 
		      If DeTest <> "" Then 'Only do Items with Values set
		        If DeTest = "All-Linux" And TargetLinux Then DeTest = "All" 'If it's Linux compatible and we are in Linux then just set it to All in Temp Variable
		        If  DeTest.IndexOf(SysDesktopEnvironment) >=0 Or DeTest = "All" Then
		          Data.Items.CellTextAt(I, Data.GetDBHeader("OSCompatible")) = "T"
		        Else 'Not Compatible
		          Data.Items.CellTextAt(I, Data.GetDBHeader("OSCompatible")) = "F"
		        End If
		      End If
		    End If
		    
		    If Data.Items.CellTextAt(I, Data.GetDBHeader("OSCompatible")) = "T" Then 'Will only continue if Arch Passed, DE Passed or abscent and wont check it if empty
		      DeTest = Data.Items.CellTextAt(I, Data.GetDBHeader("PMCompatible")) 
		      If DeTest <> "" Then 'Only do Items with Values set
		        If  DeTest.IndexOf(SysPackageManager) >=0 Or DeTest = "All" Then
		          'If DeTest = "All-Linux" And TargetLinux Then DeTest = "All" 'If it's Linux compatible and we are in Linux then just set it to All in Temp Variable 'Not used yet (may not need)
		          Data.Items.CellTextAt(I, Data.GetDBHeader("OSCompatible")) = "T"
		        Else 'Not Compatible
		          Data.Items.CellTextAt(I, Data.GetDBHeader("OSCompatible")) = "F"
		        End If
		      End If
		    End If
		    
		  Next
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CheckForLLStoreUpdates()
		  If Debugging Then Debug("- Starting Check For LLStore Updates -")
		  ForceQuit = False ' Need to do this if using downloader as that aborts if it's set
		  
		  Dim CurrentVersion As Double
		  Dim CurrentVersionS As String
		  Dim OnlineVersion As Double
		  Dim OnlineVersionS As String
		  Dim F As FolderItem
		  
		  'Cleanup Updated Store
		  If Exist(Slash(AppPath)+"llstoreold") Then Deltree Slash(AppPath)+"llstoreold"
		  If Exist(Slash(AppPath)+"llstoreold.exe") Then Deltree Slash(AppPath)+"llstoreold.exe"
		  
		  'Check Version
		  If App.MajorVersion = 1 Then
		    GetOnlineFile ("https://github.com/LiveFreeDead/LLStore/raw/refs/heads/main/version.ini",Slash(TmpPath)+"version.ini")
		  Else
		    GetOnlineFile ("https://github.com/LiveFreeDead/LLStore_v2/raw/refs/heads/main/version.ini",Slash(TmpPath)+"version.ini")
		  End If
		  
		  TimeOut = System.Microseconds + (5 *1000000) 'Set Timeout after 5 seconds
		  While Downloading = True
		    App.DoEvents(3)
		    If System.Microseconds >= TimeOut Then Exit 'Timeout after 5 seconds
		  Wend
		  
		  OnlineVersionS = LoadDataFromFile(Slash(TmpPath)+"version.ini").Trim
		  
		  'Delete the downloaded version file
		  Deltree(Slash(TmpPath)+"version.ini")
		  
		  OnlineVersion = OnlineVersionS.ToDouble
		  
		  CurrentVersionS = Str(App.MajorVersion)+"."+Str(App.MinorVersion)
		  CurrentVersion = CurrentVersionS.ToDouble
		  
		  If Debugging Then Debug("--- Update Store Check ---")
		  If Debugging Then Debug("Running Version: " + CurrentVersionS +" Online Version Found: " + OnlineVersionS)
		  
		  Dim MajorRemote, MajorLocal As Double
		  MajorLocal = App.MajorVersion
		  MajorRemote = Val(Left(OnlineVersionS,OnlineVersionS.IndexOf(".")))
		  'MajorRemote = MajorRemote + 1
		  
		  If MajorRemote > MajorLocal Then
		    Dim Success As Boolean
		    'MsgBox "Full Update - Local: "+MajorLocal.ToString+" Remote: "+MajorRemote.ToString
		    
		    'Updating
		    Loading.Status.Text = "Updating Full Store" +CurrentVersionS+ " to " + OnlineVersionS
		    Loading.Refresh
		    App.DoEvents(1)
		    
		    GetOnlineFile ("https://github.com/LiveFreeDead/LastOSLinux_Repository/raw/refs/heads/main/llstore_latest.zip",Slash(TmpPath)+"llstore_latest.zip")
		    
		    While Downloading 'Wait for download to finish
		      App.DoEvents(1)
		    Wend
		    
		    If TargetWindows Then
		      'Do Windows .exe
		      If Exist(Slash(TmpPath)+"llstore_latest.zip") Then
		        ShellFast.Execute ("ren "+Chr(34)+Slash(AppPath).ReplaceAll("/","\")+"llstore.exe"+Chr(34) + " "+"llstoreold.exe") 'Rename
		        ''ShellFast.Execute ("move /y "+Chr(34)+Slash(TmpPath).ReplaceAll("/","\")+"llstore.exe"+Chr(34) + " "+Chr(34)+Slash(AppPath).ReplaceAll("/","\")+Chr(34)) 'Move 
		        'Extract full package here now I've renamed the main executable that is in use (Libraries may still crash things, we'll see)
		        Success = Extract(Slash(TmpPath)+"llstore_latest.zip",AppPath, "")
		      End If
		      
		    Else 'Linux
		      If Exist(Slash(TmpPath)+"llstore_latest.zip") Then
		        '''Rename Existing as it's running
		        ShellFast.Execute ("mv -f "+Chr(34)+Slash(AppPath)+"llstore"+Chr(34) + " "+Chr(34)+Slash(AppPath)+"llstoreold"+Chr(34)) 'Move
		        ''''Replace Original and Make Executable
		        '''ShellFast.Execute ("mv -f "+Chr(34)+Slash(TmpPath)+"llstore"+Chr(34) + " "+Chr(34)+Slash(AppPath)+"llstore"+Chr(34)) 'Move 
		        
		        'Extract full package here now I've renamed the main executable that is in use (Libraries may still crash things, we'll see)
		        Success = Extract(Slash(TmpPath)+"llstore_latest.zip",AppPath, "")
		        
		        ShellFast.Execute ("chmod 775 "+Chr(34)+Slash(AppPath)+"llstore"+Chr(34)) 'Change Read/Write/Execute to defaults
		      End If
		    End If
		    'ReRun the newer Store version
		    If TargetWindows Then
		      F = GetFolderItem(Slash(AppPath)+"llstore.exe", FolderItem.PathTypeShell)
		      F.Launch
		    Else
		      F = GetFolderItem(Slash(AppPath)+"llstore", FolderItem.PathTypeShell)
		      F.Launch
		    End If
		    
		    'These Flags allow it to Quit after the update without rescanning when another timer triggers
		    'ForceQuit = True ' Not required as using QuitApp now
		    Quitting = True
		    'Main.Close
		    QuitApp
		    Return
		    
		  Else
		    'MsgBox "EXE Updates - Local: "+MajorLocal.ToString+" Remote: "+MajorRemote.ToString
		    If OnlineVersion > CurrentVersion Then 'Is Newer, download and apply executables only
		      
		      'Updating Executables
		      Loading.Status.Text = "Updating Executables" +CurrentVersionS+ " to " + OnlineVersionS
		      Loading.Refresh
		      App.DoEvents(1)
		      If App.MajorVersion = 1 Then
		        GetOnlineFile ("https://github.com/LiveFreeDead/LLStore/raw/refs/heads/main/llstore",Slash(TmpPath)+"llstore")
		        GetOnlineFile ("https://github.com/LiveFreeDead/LLStore/raw/refs/heads/main/llstore.exe",Slash(TmpPath)+"llstore.exe")
		      Else
		        GetOnlineFile ("https://github.com/LiveFreeDead/LLStore_v2/raw/refs/heads/main/llstore",Slash(TmpPath)+"llstore")
		        GetOnlineFile ("https://github.com/LiveFreeDead/LLStore_v2/raw/refs/heads/main/llstore.exe",Slash(TmpPath)+"llstore.exe")
		      End If
		      
		      While Downloading 'Wait for download to finish
		        App.DoEvents(1)
		      Wend
		      
		      If TargetWindows Then
		        'Do Windows .exe
		        If Exist(Slash(TmpPath)+"llstore.exe") Then
		          ShellFast.Execute ("ren "+Chr(34)+Slash(AppPath).ReplaceAll("/","\")+"llstore.exe"+Chr(34) + " "+"llstoreold.exe") 'Rename
		          ShellFast.Execute ("move /y "+Chr(34)+Slash(TmpPath).ReplaceAll("/","\")+"llstore.exe"+Chr(34) + " "+Chr(34)+Slash(AppPath).ReplaceAll("/","\")+Chr(34)) 'Move 
		        End If
		        
		        If Exist(Slash(TmpPath)+"llstore") Then
		          Deltree (Slash(AppPath)+"llstore")
		          ShellFast.Execute ("move /y "+Chr(34)+Slash(TmpPath).ReplaceAll("/","\")+"llstore"+Chr(34) + " "+Chr(34)+Slash(AppPath).ReplaceAll("/","\")+Chr(34)) 'Move 
		        End If
		        
		      Else 'Linux
		        If Exist(Slash(TmpPath)+"llstore") Then
		          'Rename Existing as it's running
		          ShellFast.Execute ("mv -f "+Chr(34)+Slash(AppPath)+"llstore"+Chr(34) + " "+Chr(34)+Slash(AppPath)+"llstoreold"+Chr(34)) 'Move
		          'Replace Original and Make Executable
		          ShellFast.Execute ("mv -f "+Chr(34)+Slash(TmpPath)+"llstore"+Chr(34) + " "+Chr(34)+Slash(AppPath)+"llstore"+Chr(34)) 'Move 
		          ShellFast.Execute ("chmod 775 "+Chr(34)+Slash(AppPath)+"llstore"+Chr(34)) 'Change Read/Write/Execute to defaults
		        End If
		        
		        'Now do Windows .exe
		        If Exist(Slash(TmpPath)+"llstore.exe") Then
		          Deltree (Slash(AppPath)+"llstore.exe")
		          ShellFast.Execute ("mv -f "+Chr(34)+Slash(TmpPath)+"llstore.exe"+Chr(34) + " "+Chr(34)+Slash(AppPath)+"llstore.exe"+Chr(34)) 'Move 
		        End If
		      End If
		      'ReRun the newer Store version
		      If TargetWindows Then
		        F = GetFolderItem(Slash(AppPath)+"llstore.exe", FolderItem.PathTypeShell)
		        F.Launch
		      Else
		        F = GetFolderItem(Slash(AppPath)+"llstore", FolderItem.PathTypeShell)
		        F.Launch
		      End If
		      
		      'These Flags allow it to Quit after the update without rescanning when another timer triggers
		      'ForceQuit = True ' Not required as using QuitApp now
		      Quitting = True
		      'Main.Close
		      QuitApp
		      Return
		    Else
		      'Continue without quitting
		    End If 
		    
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CheckInstalled()
		  If Debugging Then Debug("- Starting Check Installed Items -")
		  App.DoEvents(1) 'This makes the Load Screen Update the Status Text, Needs to be in each Function and Sub call
		  
		  Dim I As Integer
		  Dim F As FolderItem
		  
		  'Check if App Path exists
		  If Data.Items.RowCount - 1 >= 0 Then
		    For I = 0 To Data.Items.RowCount - 1
		      F = GetFolderItem(ExpPath(Data.Items.CellTextAt(I, Data.GetDBHeader("PathApp"))), FolderItem.PathTypeNative)
		      If F.Exists = True Then Data.Items.CellTextAt(I, Data.GetDBHeader("Installed")) = "T" Else Data.Items.CellTextAt(I, Data.GetDBHeader("Installed")) = "F"
		    Next
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CheckPath(DirToCheck As String)
		  Dim F As FolderItem
		  
		  Try
		    If TargetWindows Then
		      F = GetFolderItem(DirToCheck.ReplaceAll("/","\"), FolderItem.PathTypeShell)
		    Else
		      F = GetFolderItem(DirToCheck, FolderItem.PathTypeShell)
		    End If
		    'If Debugging Then Debug("Checking Item Path: "+ FixPath(F.NativePath)) 'Don't need to show all these, the parent folder will do.
		    If F.IsFolder And F.IsReadable Then
		      Data.ScanPaths.AddRow(FixPath(F.NativePath))
		      If Debugging Then Debug("Adding Item Path: "+ FixPath(F.NativePath))
		    End If
		  Catch
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ExtractAll()
		  If Debugging Then Debug("--- Starting Extract All ---")
		  
		  App.DoEvents(1) 'This makes the Load Screen Update the Status Text, Needs to be in each Function and Sub call where it goes slow?, this also slows down loading a little
		  
		  Dim F As FolderItem
		  Dim I As Integer
		  Dim Exten, ItemInn As String
		  Dim TmpPathItems As String = Slash(TmpPath)+"items/"
		  Dim TmpItem As String
		  Dim ExcludesIncludes As String
		  Dim T As TextOutputStream
		  Dim EOL As String
		  
		  Dim Sh As New Shell
		  Sh.TimeOut = -1 'Give it All the time it needs
		  
		  Dim ScriptOut As String 
		  Dim ScriptOutMkDir As String
		  
		  Dim ScriptOutFile As String = Slash(TmpPath)+"ExtractAll.sh"
		  
		  Dim ScriptOutMkDirFile As String = Slash(TmpPath)+"MakeDirAll.sh"
		  
		  If TargetWindows Then ScriptOutFile = Slash(TmpPath)+"ExtractAll.cmd" '.cmd is executable in Windows
		  
		  If TargetWindows Then ScriptOutMkDirFile = Slash(TmpPath)+"MakeDirAll.cmd" '.cmd is executable in Windows
		  
		  Dim S As string
		  if TargetMacOS then
		    S = "mkdir -p "
		  elseif TargetWindows then
		    S = "mkdir "
		  elseif TargetLinux then
		    S = "mkdir -p "
		  end if
		  
		  Dim Zip As String
		  Zip = Linux7z
		  if TargetWindows Then Zip = Win7z
		  
		  Dim TmpNumber As Integer = 10000 'Randomiser.InRange(10000, 20000)
		  TmpItem = Slash(TmpPathItems+"tmp" + TmpNumber.ToString)
		  While Exist(TmpItem)
		    TmpNumber = TmpNumber + 1000 'Count up by 1000 Items until none found, incase old temp items exist
		    TmpItem = Slash(TmpPathItems+"tmp" + TmpNumber.ToString)
		  Wend
		  
		  If Data.ScanItems.RowCount >=1 Then
		    For I = 0 To Data.ScanItems.RowCount - 1
		      Loading.Status.Text = "Processing Item: "+ Str(I)+"/"+Str(Data.ScanItems.RowCount - 1)
		      ItemInn = Data.ScanItems.CellTextAt(I,0)
		      
		      ItemInn = ItemInn.ReplaceAll("\","/") 'Linux Paths
		      
		      TmpNumber = TmpNumber + 1 'Can't use Random folders as it may duplicate
		      TmpItem = Slash(TmpPathItems+"tmp" + TmpNumber.ToString)
		      
		      'Store the Tmp Path to the item
		      Data.ScanItems.CellTextAt(I,1) = TmpItem 'Pre extracted Items are stored in the path to access from  LoadLLFile, if one isn't supplied it'll revert back to extractiung one at a time :D
		      
		      If TargetWindows Then
		        EOL = Chr(10) '+Chr(13) 'Don't need Chr(13) in windows command lines I don't think
		      Else
		        EOL = Chr(10)
		      End If
		      F = GetFolderItem(ItemInn,FolderItem.PathTypeShell)
		      If F.Exists Then
		        Exten = Right(ItemInn,4)
		        Exten = Exten.Lowercase
		        Select Case Exten
		        Case ".tar"
		          ScriptOutMkDir = ScriptOutMkDir + S + Chr(34)+TmpItem+Chr(34) + EOL 'Make Dir in the script before extraction command
		          ScriptOutMkDir = ScriptOutMkDir + EOL'Blank Line between items so they don't duplicate wrong
		          ExcludesIncludes = " LLApp.lla LLGame.llg LLScript.sh LLScript_Sudo.sh LLFile.sh LLApp.jpg LLApp.png LLApp.ico LLApp.svg LLGame.jpg LLGame.png LLGame.ico LLGame.svg LLApp1.jpg LLGame1.jpg LLApp2.jpg LLGame2.jpg LLApp3.jpg LLGame3.jpg LLApp4.jpg LLGame4.jpg LLApp5.jpg LLGame5.jpg LLApp6.jpg LLGame6.jpg"
		          ScriptOut = ScriptOut + Zip + " -mtc -aoa x "+Chr(34)+ItemInn+Chr(34)+ " -o"+Chr(34) + TmpItem+Chr(34)+ExcludesIncludes + EOL
		          Data.ScanItems.CellTextAt(I,2) = Left(ItemInn,InStrRev(ItemInn,"/")) 'Gets Parent Path
		        Case ".apz", ".pgz"
		          ScriptOutMkDir = ScriptOutMkDir + S + Chr(34)+TmpItem+Chr(34) + EOL 'Make Dir in the script before extraction command
		          ScriptOutMkDir = ScriptOutMkDir + EOL'Blank Line between items so they don't duplicate wrong
		          ExcludesIncludes = " ssApp.app ppApp.app ppGame.ppg ssApp.jpg ppApp.jpg ssApp.png ppApp.png ssApp.ico ppApp.ico ppGame.jpg ppGame.png ppGame.ico ppGame1.jpg ppGame2.jpg ppGame3.jpg ppGame4.jpg ppGame5.jpg ppGame6.jpg ppApp1.jpg ppApp2.jpg ppApp3.jpg ppApp4.jpg ppApp5.jpg ppApp6.jpg ssApp1.jpg ssApp2.jpg ssApp3.jpg ssApp4.jpg ssApp5.jpg ssApp6.jpg"
		          ScriptOut = ScriptOut + Zip + " -mtc -aoa x "+Chr(34)+ItemInn+Chr(34)+ " -o"+Chr(34) + TmpItem+Chr(34)+ExcludesIncludes + EOL
		          Data.ScanItems.CellTextAt(I,2) = Left(ItemInn,InStrRev(ItemInn,"/")) 'Gets Parent Path
		        Case Else'Not a compressed Item' just nab the path
		          Data.ScanItems.CellTextAt(I,2) = Left(ItemInn,InStrRev(ItemInn,"/")-1) 'Gets Parent Path
		          Data.ScanItems.CellTextAt(I,2) = Left(Data.ScanItems.CellTextAt(I,2),InStrRev(Data.ScanItems.CellTextAt(I,2),"/")) 'Gets Parent Path
		        End Select
		      End If
		    Next
		    
		    F = GetFolderItem(ScriptOutFile, FolderItem.PathTypeNative)
		    If F <> Nil Then
		      If F.IsWriteable Then 'And WritableLocation(F) = True
		        If F.Exists Then F.Delete
		        T = TextOutputStream.Create(F)
		        T.Write(ScriptOut)
		        T.Close
		        Sh.Execute ("chmod 775 "+Chr(34)+ScriptOutFile+Chr(34)) 'Change Read/Write/Execute to Output script
		      End If
		    End If
		    
		    F = GetFolderItem(ScriptOutMkDirFile, FolderItem.PathTypeNative)
		    If F <> Nil Then
		      If F.IsWriteable Then 'And WritableLocation(F) = True
		        If F.Exists Then F.Delete
		        T = TextOutputStream.Create(F)
		        T.Write(ScriptOutMkDir)
		        T.Close
		        Sh.Execute ("chmod 775 "+Chr(34)+ScriptOutMkDirFile+Chr(34)) 'Change Read/Write/Execute to Output script
		      End If
		    End If
		    
		    Loading.Status.Text = "Making Folders..."
		    App.DoEvents(1)
		    RunWait(ScriptOutMkDirFile)'Allows form to refresh
		    Loading.Status.Text = "Extracting Compressed Items..."
		    App.DoEvents(1)
		    RunWait(ScriptOutFile)'Allows form to refresh
		    Loading.Status.Text = "Done Extracting Compressed Items..."
		    App.DoEvents(1)
		    
		    'Try to Clean up Temp Folder
		    Deltree(ScriptOutFile)
		    Deltree(ScriptOutMkDirFile)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GenerateDataCategories()
		  App.DoEvents(1) 'This makes the Load Screen Update the Status Text, Needs to be in each Function and Sub call
		  
		  Dim I, J, K, CatCol, BuildTypeCol As Integer
		  Dim CatCheck As String
		  Dim Sp() As String
		  Dim HideCat As Boolean = False
		  Dim BuildType As String
		  
		  If ItemCount <=0 Then Return
		  
		  CatCol = Data.GetDBHeader("Categories")
		  BuildTypeCol = Data.GetDBHeader("BuildType")
		  If CatCol = -1 Then Return 'Can't find the Column, it's broken, so return
		  For I = 0 To ItemCount
		    CatCheck = Data.Items.CellTextAt(I, CatCol)
		    BuildType = Data.Items.CellTextAt(I, BuildTypeCol)
		    
		    'Hide Linux items and Categories if in Windows
		    If TargetWindows Then
		      If BuildType = "LLApp" or BuildType = "LLGame" Then
		        Continue 'Don't even check it if in Windows and is a Linux Item
		      End If
		    End If
		    
		    Sp = CatCheck.Split(";")
		    For K = 0 To Sp.Count - 1
		      Sp(K) = Sp(K).Trim
		      If Right(Sp(K),4) = "Game" Then
		        Sp(K) = Left(Sp(K), Len(Sp(K))-4) 'Remove Game from Linux Categories
		      End If
		      If Sp(K) = "" Then Exit 'It's Empty, don't check or add
		      HideCat = False
		      For J = 0 To Data.Categories.RowCount  - 1 '0 Based
		        If Sp(K) = Data.Categories.CellTextAt(J, 0) Then
		          HideCat = True
		          Exit 'Quit loop if hidden
		        End If
		        If Data.Categories.CellTextAt(J, 0) = "Game "+ Sp(K) Then 'Hide duplicated Game Cats too (added below)
		          HideCat = True
		          Exit 'Quit loop if hidden
		        End If
		      Next J
		      If HideCat = False Then
		        If StoreMode = 0 Then 'Add it back to the Start if in Install Mode, so they are grouped 
		          If BuildType = "LLGame" or BuildType = "ppGame" Then
		            If Settings.SetHideGameCats.Value = False Then
		              Sp(K) = "Game " + Sp(K) 'This should group all game categories in the listbox
		            Else
		              Sp(K) = "Games" ' Groups all Games
		              Exit 'Loop if Hidden
		            End If
		          End If
		        End If
		        Data.Categories.AddRow(Sp(K))
		      End If
		    Next K
		  Next
		  
		  'Sort the list Alphabettic
		  Data.Categories.SortingColumn = 0
		  Data.Categories.ColumnSortDirectionAt(0) = DesktopListBox.SortDirections.Ascending
		  Data.Categories.Sort ()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetAdminMode()
		  'Check If Admin Mode
		  If RunningInIDE = False Then
		    If FirstRun = False Then 'Only check it the first run, else you already quit or decided to run without admin
		      Quitting = False
		      If TargetWindows Then
		        If StoreMode = 0 Or StoreMode = 2 Then 'If Install Mode or Installer then check has Admin
		          If Debugging Then Debug("--- Checking Admin Mode in Windows")
		          If IsAdmin = False Then
		            Dim LLStoreAppExe As FolderItem
		            LLStoreAppExe = App.ExecutableFile
		            If InStr(LLStoreAppExe.NativePath, "Debugllstore.exe") <= 0 Then 'Don't request Admin if debugging code
		              
		              Dim RetVal as Boolean
		              RetVal = ShellExecuteEx(SEE_MASK_NOCLOSEPROCESS, _
		              0, _ //Window handle
		              StringToMB("runas"), _ //Operation to perform
		              StringToMB(LLStoreAppExe.NativePath), _ //Application path and name
		              StringToMB(System.CommandLine), _ //Additional parameters
		              StringToMB(LLStoreAppExe.Parent.NativePath), _ //Working Directory
		              SW_SHOWNORMAL, _
		              0, _
		              Nil, _
		              Nil, _
		              0, _
		              0, _
		              0, _
		              0)
		              
		              Loading.Show
		              App.DoEvents(1)
		              
		              If RetVal = False Then 'If denied UAC it will be false
		                Dim Ret As Integer
		                If StoreMode = 0 Then
		                  If Debugging Then Debug("Run Without Admin?")
		                  Ret = MsgBox ("Run LLStore Without Administrator Access", 52)
		                End If
		                If Ret = 7 Then
		                  ForceQuit = True
		                  Quitting = True
		                  QuitApp
		                  'Return
		                End If
		              Else
		                ForceQuit = True
		                Quitting = True
		                QuitApp
		                'Return
		              End If
		            End If
		            
		          End If
		        End If
		      End If
		      
		      If TargetWindows Then 'Make sure this only happens in Windows or makes random file called %WinDir%...
		        If IsAdmin = True Then AdminEnabled = True
		      End If
		    End If
		  End If 'End of Check Admin
		  
		  If Quitting = True Then
		    ForceQuit = True
		    QuitApp
		    Return ' If gets here then just return
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetExistingppFolder(GetType As String) As String
		  Declare Function SetErrorMode Lib "Kernel32" (mode As Integer) As Integer
		  Const SEM_FAILCRITICALERRORS = &h1
		  Dim oldMode As Integer = SetErrorMode( SEM_FAILCRITICALERRORS )
		  Dim reg As registryItem
		  Dim Ret As String
		  Dim I, A As Integer
		  Dim F As FolderItem
		  
		  #Pragma BreakOnExceptions Off
		  Try
		    reg = new registryItem(RegKeyHKLMccsWin) 'RegKeyHKLMccsWin = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Windows"
		    reg.Value("ErrorMode") = 2
		  Catch
		  End Try
		  
		  Ret = ""
		  A = Asc("Z")
		  
		  Select Case Lowercase(GetType)
		  Case "ppapps"
		    Try
		      For I = 0 To 23
		        If FileExists (Chr(A-I)+":/ppApps") Then
		          F = GetFolderItem(Chr(A-I)+":/ppAppsWritable.ini", FolderItem.PathTypeShell)
		          If F.IsWriteable And WritableLocation(F) Then
		            Ret = Chr(A-I)+":"
		            Exit For I
		          End If
		        End If
		      Next I
		    Catch
		    End Try
		  Case "ppGames"
		    Try
		      For I = 0 To 23
		        If FileExists (Chr(A-I)+":/ppGames") Then
		          F = GetFolderItem(Chr(A-I)+":/ppGamesWritable.ini", FolderItem.PathTypeShell)
		          If F.IsWriteable And WritableLocation(F) Then
		            Ret = Chr(A-I)+":"
		            Exit For I
		          End If
		        End If
		      Next I
		    Catch
		    End Try
		  End Select
		  
		  Call SetErrorMode( oldMode )
		  #Pragma BreakOnExceptions Off
		  Try
		    reg = new registryItem(RegKeyHKLMccsWin) 'RegKeyHKLMccsWin = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Windows"
		    reg.Value("ErrorMode") = 0
		  Catch
		  End Try
		  #Pragma BreakOnExceptions Default
		  Return Ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetItem(ItemInn As String, InnTmp As String = "") As Integer
		  If ItemInn = "" Then Return  -1 'Nothing given
		  
		  If Debugging Then Debug("Get Item: "+ ItemInn)
		  
		  Dim I, J As Integer
		  Dim F As FolderItem
		  Dim Exten As String
		  Dim Success As Boolean = False
		  
		  F = GetFolderItem(ItemInn,FolderItem.PathTypeShell)
		  If F.Exists Then
		    
		    Exten = Right(ItemInn,4)
		    Exten = Exten.Lowercase
		    Select Case Exten
		    Case ".lla"
		      Success = LoadLLFile (ItemInn)
		    Case ".llg"
		      Success = LoadLLFile (ItemInn)
		    Case ".app"
		      Success = LoadLLFile (ItemInn)
		    Case ".ppg"
		      Success = LoadLLFile (ItemInn)
		    Case ".tar"
		      Success = LoadLLFile (ItemInn, InnTmp) 'InnTmp is the PreExtracted items stored in the Data DB
		    Case".apz"
		      Success = LoadLLFile (ItemInn, InnTmp)
		    Case ".pgz"
		      Success = LoadLLFile (ItemInn, InnTmp)
		    End Select
		  End If
		  
		  'Checks
		  If ItemLLItem.TitleName = "" Then Return -1 'No Title given, don't add
		  If ItemLLItem.Hidden = True Then Return -1 'Set as Hidden, hide it entirly.
		  
		  If Success = True Then ' Loaded Item fine, Add to Data
		    If Debugging Then Debug("Success Loading: "+ ItemInn)
		    ItemCount =  Data.Items.RowCount
		    Data.Items.AddRow(Data.Items.RowCount.ToString("000000")) 'This adds the Leading 0's or prefixes it to 6 digits as it sort Alphabettical, fixed 1,10,100,2 to 001,002,010,100 for example
		    
		    'Reference Only Keep
		    'LocalDBHeader = " BuildType Compressed HiddenAlways ShowAlways ShowSetupOnly Arch OS TitleName Version Categories Description URL Priority PathApp PathINI FileINI FileCompressed FileIcon FileScreenshot FileFader FileMovie Flags Tags Publisher Language Rating Additional Players License ReleaseVersion ReleaseDate RequiredRuntimes Builder InstalledSize LnkTitle LnkComment LnkDescription LnkCategories LnkRunPath LnkExec LnkArguments LnkFlags LnkAssociations LnkTerminal LnkMultiple LnkIcon LnkOSCompatible LnkDECompatible LnkPMCompatible ArchCompatible  NoInstall OSCompatible DECompatible PMCompatible ArchCompatible UniqueName Dependencies ""
		    
		    For I = 1 To Data.Items.ColumnCount
		      Select Case  Data.Items.HeaderAt(I)
		      Case "TitleName"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.TitleName
		      Case "Version"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.Version
		      Case "Description"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.Descriptions
		      Case "PathApp"
		        Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLLItem.PathApp)
		      Case "URL"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.URL
		      Case "Categories"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.Categories
		      Case "Catalog"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.Catalog
		      Case "BuildType"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.BuildType
		      Case "Priority"
		        Data.Items.CellTextAt(ItemCount,I) = Str(ItemLLItem.Priority)
		      Case "PathINI"
		        Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLLItem.PathINI)
		      Case "FileIcon"
		        Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLLItem.FileIcon)
		      Case "FileFader"
		        Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLLItem.FileFader)
		      Case "FileMovie"
		        Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLLItem.FileMovie)
		      Case "FileINI"
		        Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLLItem.FileINI)
		      Case "FileScreenshot"
		        Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLLItem.FileScreenshot)
		      Case "Tags"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.Tags
		      Case "Publisher"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.Publisher
		      Case "Language"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.Language
		      Case "License"
		        Data.Items.CellTextAt(ItemCount,I) = Str(ItemLLItem.License)
		      Case "Arch"
		        Data.Items.CellTextAt(ItemCount,I) = Str(ItemLLItem.Arch)
		      Case "OS"
		        Data.Items.CellTextAt(ItemCount,I) = Str(ItemLLItem.OS)
		      Case "Rating"
		        Data.Items.CellTextAt(ItemCount,I) = Str(ItemLLItem.Rating)
		      Case "ReleaseVersion"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.ReleaseVersion
		      Case "ReleaseDate"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.ReleaseDate
		      Case "Builder"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.Builder
		      Case "InstallSize","InstalledSize"
		        Data.Items.CellTextAt(ItemCount,I) = Str(ItemLLItem.InstallSize)
		      Case "Flags"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.Flags
		      Case "HiddenAlways"
		        Data.Items.CellTextAt(ItemCount,I) = Str(ItemLLItem.HiddenAlways)
		      Case "ShowAlways"
		        Data.Items.CellTextAt(ItemCount,I) = Str(ItemLLItem.ShowAlways)
		      Case "ShowSetupOnly"
		        Data.Items.CellTextAt(ItemCount,I) = Str(ItemLLItem.ShowSetupOnly)
		      Case "NoInstall"
		        Data.Items.CellTextAt(ItemCount,I) =  Str(ItemLLItem.NoInstall)
		      Case "UniqueName"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.TitleName.Lowercase + ItemLLItem.BuildType.Lowercase
		        Data.Items.CellTextAt(ItemCount,I) = Data.Items.CellTextAt(ItemCount,I).ReplaceAll(" ","")
		      Case "Selected"
		        Data.Items.CellTextAt(ItemCount,I) = "F"
		      Case "Compressed"
		        Data.Items.CellTextAt(ItemCount,I) = Left(Str(ItemLLItem.Compressed),1)
		        
		      Case "OSCompatible"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.OSCompatible
		      Case "DECompatible"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.DECompatible
		      Case "PMCompatible"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.PMCompatible
		      Case "ArchCompatible"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLLItem.ArchCompatible
		        
		      Case "LnkMultiple" 'Links
		        If LnkCount >1 Then
		          Data.Items.CellTextAt(ItemCount,I) = "T"
		        Else 
		          Data.Items.CellTextAt(ItemCount,I) = "F" 'LnkMultiple
		        End If
		      Case "LnkTitle"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLnk(1).Title
		      Case "LnkComment"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLnk(1).Comment
		      Case "LnkDescription"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLnk(1).Description
		      Case "LnkCategories"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLnk(1).Categories
		      Case "LnkRunPath"
		        Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLnk(1).RunPath)
		        If Data.Items.CellTextAt(ItemCount,I) = "" Then Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLLItem.PathApp) 'Make sure it has some kind of path, so it has somewhere to be
		      Case "LnkExec"
		        Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLnk(1).Exec)
		      Case "LnkArguments"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLnk(1).Arguments
		      Case "LnkFlags"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLnk(1).Flags
		      Case "LnkAssociations"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLnk(1).Associations
		      Case "LnkTerminal"
		        Data.Items.CellTextAt(ItemCount,I) = Left(Str(ItemLnk(1).Terminal),1)
		      Case "LnkIcon"
		        Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLnk(1).Icon)
		        
		      Case "LnkOSCompatible"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLnk(1).LnkOSCompatible
		      Case "LnkDECompatible"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLnk(1).LnkDECompatible
		      Case "LnkPMCompatible"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLnk(1).LnkPMCompatible
		      Case "LnkArchCompatible"
		        Data.Items.CellTextAt(ItemCount,I) = ItemLnk(1).LnkArchCompatible
		        
		      End Select
		    Next
		    
		  End If
		  
		  'Reference Only Keep
		  '"RefID Selected BuildType Compressed Hidden ShowAlways ShowSetupOnly Installed Arch OS TitleName Version Categories Description URL Priority PathApp PathINI FileINI FileCompressed FileIcon IconRef FileScreenshot FileFader FileMovie Flags Tags Publisher Language Rating Additional Players License ReleaseVersion ReleaseDate RequiredRuntimes Builder InstalledSize
		  'LnkTitle LnkComment LnkDescription LnkCategories LnkRunPath LnkExec LnkArguments LnkFlags LnkAssociations LnkTerminal LnkMultiple LnkParentRef LnkIcon LnkOSCompatible LnkDECompatible LnkPMCompatible LnkArchCompatible NoInstall OSCompatible DECompatible PMCompatible ArchCompatible UniqueName Dependencies "
		  
		  Dim MainItem As Integer = ItemCount
		  
		  'Add Icon to Cache and associate Icon with item (Do vefore the Links so can use same icon if none provided
		  If ItemIcon <> Nil Then
		    IconCount = Data.Icons.RowCount
		    Data.Icons.AddRow
		    Data.Icons.RowImageAt(IconCount) = ItemIcon
		    Data.Items.CellTextAt(ItemCount,Data.GetDBHeader("IconRef")) = Str(IconCount)
		  Else 'Icon not found - Use Defaults
		    Data.Items.CellTextAt(ItemCount,Data.GetDBHeader("IconRef")) = Str(0)
		  End If
		  
		  'If Launcher then duplicate Items to Shortcut Link Counts and point to Lnk's
		  If StoreMode = 1 Then 'Get all the links and clone
		    If LnkCount >1 Then 'Clone Items
		      For J = 1 To LnkCount
		        ItemCount =  Data.Items.RowCount
		        Data.Items.AddRow(Str(Data.Items.RowCount))
		        Data.Items.CellTextAt(ItemCount,I) = ItemLnk(1).Icon
		        For I = 1 To Data.Items.ColumnCount
		          Data.Items.CellTextAt(ItemCount,I) = Data.Items.CellTextAt(MainItem,I)
		          Select Case  Data.Items.HeaderAt(I)
		          Case "LnkMultiple" 'Links
		            'If LnkCount >1 Then
		            'Data.Items.CellTextAt(ItemCount,I) = "T"
		            'Else 
		            Data.Items.CellTextAt(ItemCount,I) = "F" 'LnkMultiple, make them all not true, so can hide all the ones that are in Launcher
		            'End If
		          Case "LnkTitle"
		            Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).Title
		          Case "TitleName"
		            Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).Title
		          Case "LnkComment"
		            Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).Comment
		          Case "LnkDescription"
		            If ItemLnk(J).Description <> "" Then
		              Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).Description
		            Else
		              If ItemLnk(J).Comment <> "" Then Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).Comment
		            End If
		          Case "Description"
		            If ItemLnk(J).Description <> "" Then
		              Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).Description
		            Else
		              If ItemLnk(J).Comment <> "" Then Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).Comment
		            End If
		          Case "LnkCategories"
		            Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).Categories
		          Case "Categories"
		            Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).Categories
		          Case "LnkRunPath"
		            Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLnk(J).RunPath)
		            If Data.Items.CellTextAt(ItemCount,I) = "" Then Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLLItem.PathApp) 'Make sure it has some kind of path, so it has somewhere to be
		          Case "LnkExec"
		            Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLnk(J).Exec)
		          Case "LnkArguments"
		            Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).Arguments
		          Case "LnkFlags"
		            Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).Flags
		          Case "LnkAssociations"
		            Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).Associations
		          Case "LnkTerminal"
		            Data.Items.CellTextAt(ItemCount,I) = Left(Str(ItemLnk(J).Terminal),1)
		          Case "LnkIcon"
		            Data.Items.CellTextAt(ItemCount,I) = ExpPath(ItemLnk(J).Icon)
		            
		          Case "LnkOSCompatible"
		            Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).LnkOSCompatible
		          Case "LnkDECompatible"
		            Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).LnkDECompatible
		          Case "LnkPMCompatible"
		            Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).LnkPMCompatible
		          Case "LnkArchCompatible"
		            Data.Items.CellTextAt(ItemCount,I) = ItemLnk(J).LnkArchCompatible
		            
		          End Select
		        Next
		      Next
		    End If
		    
		  End If
		  
		  Return MainItem
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetItems(Inn As String)
		  Dim F, G As FolderItem
		  Dim D As Integer
		  Dim DirToCheck As String
		  Dim Exten As String
		  Dim ItemPath As String
		  
		  'Add folders with an item in it and add files that match
		  DirToCheck = Slash(Inn)
		  If TargetWindows Then
		    F = GetFolderItem(DirToCheck.ReplaceAll("/","\"), FolderItem.PathTypeShell) 'When Getting items, best use correct OS paths
		  Else
		    F = GetFolderItem(DirToCheck, FolderItem.PathTypeShell)
		  End If
		  If F.IsFolder And F.IsReadable Then
		    If F.Count > 0 Then
		      For D = 1 To F.Count
		        ItemPath = Slash(FixPath(F.Item(D).NativePath))
		        If StoreMode = 0 Then
		          If F.Item(D).Directory Then 'Look for folders only
		            G = GetFolderItem(ItemPath + "LLApp.lla", FolderItem.PathTypeShell)
		            If G.Exists Then
		              Data.ScanItems.AddRow(FixPath(G.NativePath))
		            End If
		            G = GetFolderItem(ItemPath + "LLGame.llg", FolderItem.PathTypeShell)
		            If G.Exists Then
		              Data.ScanItems.AddRow(FixPath(G.NativePath))
		            End If
		            G = GetFolderItem(ItemPath+ "ssApp.app", FolderItem.PathTypeShell)
		            If G.Exists Then
		              Data.ScanItems.AddRow(FixPath(G.NativePath))
		            End If
		            G = GetFolderItem(ItemPath + "ppApp.app", FolderItem.PathTypeShell)
		            If G.Exists Then
		              Data.ScanItems.AddRow(FixPath(G.NativePath))
		            End If
		            G = GetFolderItem(ItemPath + "ppGame.ppg", FolderItem.PathTypeShell)
		            If G.Exists Then
		              Data.ScanItems.AddRow(FixPath(G.NativePath))
		            End If
		          Else 'Check if it's a Compressed Item
		            Exten = Right(FixPath(F.Item(D).NativePath),4)
		            If Len(Exten) >=4 Then
		              Exten = Exten.Lowercase
		              Select Case Exten
		              Case ".tar"
		                Data.ScanItems.AddRow(FixPath(F.Item(D).NativePath))
		              Case".apz"
		                Data.ScanItems.AddRow(FixPath(F.Item(D).NativePath))
		              Case".pgz"
		                Data.ScanItems.AddRow(FixPath(F.Item(D).NativePath))
		              End Select
		            End If
		          End If
		        ElseIf StoreMode = 1 Then 'Launcher
		          If F.Item(D).Directory Then 'Look for folders only
		            If TargetWindows Then
		              G = GetFolderItem(Slash(F.Item(D).NativePath.ReplaceAll("/","\")) + "LLGame.llg", FolderItem.PathTypeShell)
		            Else
		              G = GetFolderItem(Slash(F.Item(D).NativePath) + "LLGame.llg", FolderItem.PathTypeShell)
		            End If
		            If G.Exists Then
		              Data.ScanItems.AddRow(FixPath(G.NativePath), ItemPath, DirToCheck) 'Instead of TmpPath use ScanedInPath for Games
		            End If
		            If TargetWindows Then
		              G = GetFolderItem(Slash(FixPath(F.Item(D).NativePath.ReplaceAll("/","\"))) + "ppGame.ppg", FolderItem.PathTypeShell)
		            Else
		              G = GetFolderItem(Slash(FixPath(F.Item(D).NativePath)) + "ppGame.ppg", FolderItem.PathTypeShell)
		            End If
		            If G.Exists Then
		              Data.ScanItems.AddRow(FixPath(G.NativePath), ItemPath, DirToCheck) 'Instead of TmpPath use ScanedInPath for Games
		            End If
		          End If
		        End If
		      Next
		    End If
		  End If
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetItemsPaths(Inn As String, ScanRoot As Boolean = False)
		  'If Debugging Then Debug("- Starting Get Item Path -")
		  Dim F As FolderItem
		  Dim DirToCheck As String
		  Dim I As Integer
		  If Inn = "" Then Return
		  Inn = Slash(FixPath(Inn))
		  
		  If ScannedRootFoldersCount >=1 Then 'Make sure this actuall allows root item to show
		    '- Only add Paths not already added, but I only send through the root, need to check if scanned before
		    For I = 1 To ScannedRootFoldersCount 'See if already added and skip it
		      If Inn = ScannedRootFolders(I) Then Return 'Skip existing items
		    Next I
		  End If
		  
		  ScannedRootFoldersCount = ScannedRootFoldersCount + 1
		  ScannedRootFolders(ScannedRootFoldersCount) = Inn
		  
		  If Debugging Then Debug("Scanning For Items In: "+ Inn)
		  
		  #Pragma BreakOnExceptions False
		  Try
		    If ScanRoot = True Then
		      CheckPath(Slash(Inn))
		    End If
		    
		    'Look in paths for correct folders
		    CheckPath(Slash(Inn + "LLAppsInstalls"))
		    CheckPath(Slash(Inn + "LLGamesInstalls"))
		    CheckPath(Slash(Inn +"ssAppsInstalls"))
		    CheckPath(Slash(Inn + "ppAppsInstalls"))
		    CheckPath(Slash(Inn + "ppAppsLive"))
		    CheckPath(Slash(Inn + "ppGamesInstalls"))
		    
		  Catch
		  End Try
		  #Pragma BreakOnExceptions True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetOnlineDBs()
		  ForceQuit = False 'To allow quitting while loading, this is set, it breaks the downloader though as it aborts if your quitting, to make it cleaner.
		  Dim I As Integer
		  Dim Sp() As String
		  Dim UniqueName As String
		  
		  If OnlineDBs.Trim = "" Then OnlineDBs = Settings.SetOnlineRepos.Text.ReplaceAll(Chr(10), Chr(13)) ' Convert to standard format so it works in Windows and Linux
		  
		  Sp() = OnlineDBs.Split(Chr(13)) 'Text Areas use Chr (13) In Windows
		  
		  'Clean Up
		  Deltree(Slash(RepositoryPathLocal)+"FailedDownload")
		  
		  If Sp.Count >= 1 Then
		    For I = 0 To Sp.Count-1
		      UniqueName = Sp(I).ReplaceAll("lldb.ini","")
		      UniqueName = UniqueName.ReplaceAll(".lldb","")
		      UniqueName = UniqueName.ReplaceAll("https://","")
		      UniqueName = UniqueName.ReplaceAll("http://","")
		      UniqueName = UniqueName.ReplaceAll("/","")
		      UniqueName = UniqueName.ReplaceAll(".","")
		      UniqueName = "00-"+UniqueName+".lldbini"
		      
		      If Exist(Slash(RepositoryPathLocal)+UniqueName) Then Deltree(Slash(RepositoryPathLocal)+UniqueName) 'Remove Cached download (Might add a check/setting for doing this, ignore if exists? seem pointless as if your not online, it's gonna skip it anyway
		      CurrentDBURL = Sp(I).ReplaceAll(".lldb/lldb.ini", "") 'Only want the parent, not the sub path and file
		      If Left (Sp(I).Trim,1) = "#" Then Continue 'Skip remarked Repo's
		      GetOnlineFile (Sp(I), Slash(RepositoryPathLocal)+UniqueName)
		      While Downloading
		        App.DoEvents(1)
		        
		        If Exist(Slash(RepositoryPathLocal)+"FailedDownload") Then
		          Deltree(Slash(RepositoryPathLocal)+"FailedDownload")
		          Exit
		        End If
		      Wend
		      
		      'Try to load the downloaded DB
		      LoadDB(Slash(RepositoryPathLocal)+UniqueName, True) 'The true allows full DB path to be given, so can use Unique DB names
		    Next
		  End If
		  
		  ''Get Remote WebLinks to use 'Disabled for now due to Google stopping API use with wget
		  'GetOnlineFile ("https://github.com/LiveFreeDead/LLStore/raw/refs/heads/main/WebLinks.db",Slash(RepositoryPathLocal)+"RemoteWebLinks.db")
		  'TimeOut = System.Microseconds + (5 *1000000) 'Set Timeout after 5 seconds
		  'While Downloading = True
		  'App.DoEvents(3)
		  'If System.Microseconds >= TimeOut Then Exit 'Timeout after 5 seconds
		  'Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetScanPaths()
		  App.DoEvents(1) 'This makes the Load Screen Update the Status Text, Needs to be in each Function and Sub call
		  
		  If Debugging Then Debug("--- Starting Scan Paths for Items ---")
		  
		  Dim IniFile As String
		  Dim ManIn As String
		  Dim Sp() As String
		  
		  'For Win
		  Dim Let As Integer
		  Dim I As Integer
		  Dim Item As FolderItem
		  Dim CheckDir As String
		  
		  Dim F, G As FolderItem
		  Dim DirToCheck As String
		  Dim D, E As Integer
		  Dim TestLocations As String
		  
		  ScannedRootFoldersCount = 0
		  
		  Data.ScanPaths.RemoveAllRows
		  
		  'Check the locations for items and Add them to the Data Form
		  If StoreMode = 0 Then 'Get Installable items
		    DirToCheck = NoSlash(AppPath)
		    
		    DirToCheck = Left(DirToCheck, InStrRev(DirToCheck, "/",-1)) ' Checks up one level from the LastOSLinux Store    
		    
		    If TargetWindows Then
		      F = GetFolderItem(DirToCheck.ReplaceAll("/","\"), FolderItem.PathTypeShell)
		    Else
		      F = GetFolderItem(DirToCheck, FolderItem.PathTypeShell)
		    End If
		    If F.IsFolder And F.IsReadable Then
		      GetItemsPaths(DirToCheck)
		      GetItemsPaths(Slash(DirToCheck) +"ssTek")
		      GetItemsPaths(Slash(DirToCheck) +"LLTek")
		    End If
		    
		    If TargetLinux Then
		      DirToCheck = "/media/"
		      F = GetFolderItem(DirToCheck, FolderItem.PathTypeShell)
		      If F.IsFolder And F.IsReadable Then
		        If F.Count > 0 Then
		          For D = 1 To F.Count
		            If F.Item(D).Directory Then 'Look for folders only
		              G = F.Item(D)
		              If G.IsReadable Then
		                If G.Count > 0 Then
		                  For E = 1 To G.Count
		                    If G.Item(E).Directory Then 'Look for sub folders only
		                      GetItemsPaths(FixPath(G.Item(E).NativePath))
		                      GetItemsPaths(Slash(FixPath(G.Item(E).NativePath) +"ssTek"))
		                      GetItemsPaths(Slash(FixPath(G.Item(E).NativePath) +"LLTek"))
		                    End If
		                  Next
		                End If
		              End If
		            End If
		          Next
		        End If
		      End If
		      
		      
		      DirToCheck = "/run/media/"
		      F = GetFolderItem(DirToCheck, FolderItem.PathTypeShell)
		      If F.IsFolder And F.IsReadable Then
		        If F.Count > 0 Then
		          For D = 1 To F.Count
		            If F.Item(D).Directory Then 'Look for folders only
		              G = F.Item(D)
		              If G.IsReadable Then
		                If G.Count > 0 Then
		                  For E = 1 To G.Count
		                    If G.Item(E).Directory Then 'Look for sub folders only
		                      GetItemsPaths(FixPath(G.Item(E).NativePath))
		                      GetItemsPaths(Slash(FixPath(G.Item(E).NativePath) +"ssTek"))
		                      GetItemsPaths(Slash(FixPath(G.Item(E).NativePath) +"LLTek"))
		                    End If
		                  Next
		                End If
		              End If
		            End If
		          Next
		        End If
		      End If
		      
		      
		      DirToCheck = "/mnt/"
		      F = GetFolderItem(DirToCheck, FolderItem.PathTypeShell)
		      If F.IsFolder And F.IsReadable Then
		        If F.Count > 0 Then
		          For D = 1 To F.Count
		            If F.Item(D).Directory Then 'Look for folders only
		              GetItemsPaths(FixPath(F.Item(D).NativePath))
		              GetItemsPaths(Slash(FixPath(F.Item(D).NativePath) +"ssTek"))
		              GetItemsPaths(Slash(FixPath(F.Item(D).NativePath) +"LLTek"))
		            End If
		          Next
		        End If
		      End If
		      
		    ElseIf TargetWindows Then 'Get Items in Windows, check C to Z drives
		      Let = Asc("C")
		      For I = 0 To 23
		        Let = Asc("C") + I
		        DirToCheck = Chr(Let)+":/" 'Linux Path
		        F = GetFolderItem(DirToCheck.ReplaceAll("/","\"), FolderItem.PathTypeShell) 'This fixes the issue, yes whenever windows does folder stuff, convert it back until it returns, or it will add a backslash after the forward slash
		        
		        If F.IsFolder And F.IsReadable Then
		          If F.Count > 0 Then
		            For D = 1 To F.Count
		              item = F.trueItem(D) 'This is the issue, it returns "D:/\Path/" instead when using "D:/" in path
		              
		              If Right(FixPath(Item.NativePath),4) <> ".lnk" Then 'Do NOT use .lnk to folders, if missing it will throw an error, plus why would you?
		                
		                If F.Item(D).Directory Then 'Look for folders only
		                  CheckDir = FixPath(NoSlash(F.Item(D).NativePath))
		                  CheckDir = Right(CheckDir,Len(CheckDir)-InStrRev(CheckDir,"/")) ' Always Backslash in Windows but you can use Forward slash too
		                  
		                  'Ignores all other folders (to speed up loading and keep to proper paths) ' May need to make a new one for Manual Added Paths to check the root folders
		                  If CheckDir = "LLAppsInstalls" Or CheckDir = "ssAppsInstalls" Or CheckDir = "ppAppsInstalls" Or CheckDir = "LLGamesInstalls" Or CheckDir = "ppGamesInstalls" Or CheckDir = "ppAppsLive" Or CheckDir = "ssTek" Or CheckDir = "LLTek" Then
		                    GetItemsPaths(FixPath(F.Item(D).NativePath), True) 'True to Do Root folder as it'll only have proper items in at this stage
		                  End If
		                End If
		              End If
		            Next
		          End If
		        End If
		      Next
		    End If
		    
		    
		    'Check the Repo Cache if Enabled to do so
		    If Settings.SetIgnoreCache.Value = True Or Exist(Slash(AppPath)+"RepoBuilderNoCache") Then 'So if you have it set to ignore the cache or the file exists it does nothing (wont scan for it)
		    Else
		      DirToCheck = RepositoryPathLocal
		      If TargetWindows Then
		        F = GetFolderItem(DirToCheck.ReplaceAll("/","\"), FolderItem.PathTypeShell)
		      Else
		        F = GetFolderItem(DirToCheck, FolderItem.PathTypeShell)
		      End If
		      If F.IsFolder And F.IsReadable Then
		        GetItemsPaths(DirToCheck, True)
		      End If
		    End If
		    
		    
		    'Get Manual Locations
		    If Settings.SetUseManualLocations.Value = True Then 'Only use them if set to use them
		      If Debugging Then Debug("--- Get Manual Locations: ---")
		      TestLocations = Settings.SetManualLocations.Text
		      TestLocations = TestLocations.ReplaceAll(Chr(10), Chr(13))
		      Sp() = TestLocations.Split(Chr(13))
		      'If Debugging Then Debug("ManualLocs")
		      If Sp.Count >= 1 Then
		        For I = 0 To Sp.Count - 1
		          DirToCheck = Sp(I).Trim
		          If TargetWindows Then DirToCheck = DirToCheck.ReplaceAll("%USBDrive%", Left(AppPath,2)) 'Convert Current USB drive to variable so when you load it back in it points to right location
		          GetItemsPaths(DirToCheck, True)
		        Next
		      End If
		    End If
		    
		    
		  ElseIf StoreMode = 1 Then 'Launcher Mode
		    If TargetLinux Then
		      GetItemsPaths(Slash(HomePath)+"LLGames/", True)
		      GetItemsPaths(Slash(HomePath)+".wine/drive_c/ppGames/", True)
		      
		      'Make it check the root folder to LLStore, so can carry on USB stick with installed items to play - This may cause issues, needs Testing Glenn
		      Dim GamePath As String
		      GamePath = AppPath
		      GamePath = Slash(Left(GamePath, Len(GamePath)-InStrRev(GamePath,"/")))
		      If GamePath <> "/LastOS/" And GamePath <> "/" Then
		        GetItemsPaths(Slash(GamePath)+"LLGames/", True)
		      End If
		      GamePath = Slash(Left(GamePath, Len(GamePath)-InStrRev(GamePath,"/"))) ' I check up to folders
		      If GamePath <> "/LastOS/" And GamePath <> "/" Then
		        GetItemsPaths(Slash(GamePath)+"LLGames/", True)
		      End If
		      
		    ElseIf TargetWindows Then 'Only get Windows Games on Windows, can't run Linux games
		      Let = Asc("C")
		      For I = 0 To 23
		        Let = Asc("C") + I
		        GetItemsPaths(Chr(Let)+":/ppGames/", True)
		      Next I
		    End If
		    
		    
		    'Get Manual Locations for Windows
		    If Settings.SetUseManualLocations.Value = True Then 'Only use them if set to use them
		      If TargetWindows Then
		        IniFile = Slash(AppPath)+"LLL_Launcher_Win_Manual_Locations.ini"
		      Else
		        IniFile = Slash(AppPath)+"LLL_Launcher_Linux_Manual_Locations.ini"
		      End If
		      If Exist(IniFile) Then
		        ManIn = LoadDataFromFile(IniFile)
		        Sp() = ManIn.Split(Chr(10))
		        If Sp.Count >=1 Then
		          For I = 0 To Sp.Count -1
		            DirToCheck = Sp(I).Trim
		            GetItemsPaths(DirToCheck, True)
		          Next
		        End If
		      End If
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetTheme()
		  Dim F As FolderItem
		  Dim RL As String
		  
		  #Pragma BreakOnExceptions Off
		  Try
		    If StoreMode = 0 Then
		      ThemePath = AppPath+"Themes/Theme.ini"
		      F = GetFolderItem(ThemePath,FolderItem.PathTypeNative)
		      InputStream = TextInputStream.Open(F)
		      RL = InputStream.ReadLine.Trim
		      inputStream.Close
		      ThemePath = AppPath+"Themes/"+RL+"/"
		      LoadTheme (RL)
		    ElseIf StoreMode = 1 Then
		      ThemePath = AppPath+"Themes/ThemeLauncher.ini"
		      F = GetFolderItem(ThemePath,FolderItem.PathTypeNative)
		      InputStream = TextInputStream.Open(F)
		      RL = InputStream.ReadLine.Trim
		      inputStream.Close
		      ThemePath = AppPath+"Themes/"+RL+"/"
		      LoadTheme (RL)
		    End If
		  Catch
		    'No Theme files found
		    If Debugging Then Debug("* Error: Theme Not Found: "+ThemePath)
		  End Try
		  #Pragma BreakOnExceptions On
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetWebLinks()
		  Dim I As Integer
		  Dim RL As String
		  Dim Sp() As String
		  Dim TemStrSp() As String
		  Dim FileIn As String
		  
		  FileIn = Slash(RepositoryPathLocal)+"RemoteWebLinks.db"
		  If TargetWindows Then
		    FileIn = FileIn.ReplaceAll("/","\")
		  Else
		    FileIn = FileIn.ReplaceAll("\","/")
		  End If
		  
		  RL = LoadDataFromFile(FileIn)
		  RL = RL.ReplaceAll(Chr(13),Chr(10))
		  
		  Sp = RL.Split(Chr(10))
		  If Sp.Count >= 1 Then
		    WebLinksCount = 0
		    For I = 0 To Sp.Count - 1
		      TemStrSp = Sp(I).Split("|")
		      If TemStrSp.Count = 2 Then
		        WebLinksName(WebLinksCount) = TemStrSp(0).Trim
		        WebLinksLink(WebLinksCount) = TemStrSp(1).Trim            
		        'MsgBox WebLinksName(WebLinksCount) + " = " + WebLinksLink(WebLinksCount)
		        WebLinksCount = WebLinksCount + 1
		      End If
		    Next
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HideOldVersions()
		  If Debugging Then Debug("- Starting Hide Old Versions -")
		  App.DoEvents(1) 'This makes the Load Screen Update the Status Text, Needs to be in each Function and Sub call
		  
		  DIm I, J As Integer
		  Dim ItemToAdd(16000) As String
		  Dim BuildType(16000) As String
		  Dim ItemHidden(16000) As Boolean
		  Dim V(16000) As String
		  Dim VI(16000) As Integer
		  Dim ColsHidden, ColsBuildType, ColsTitleName, ColsVersion As Integer
		  
		  ColsHidden = Data.GetDBHeader("Hidden")
		  ColsBuildType = Data.GetDBHeader("BuildType")
		  ColsTitleName = Data.GetDBHeader("TitleName")
		  ColsVersion = Data.GetDBHeader("Version")
		  
		  'Pre Add all the data to quickly compare, hiding the Easy ones
		  For I = 0 To Data.Items.RowCount - 1
		    If Data.Items.CellTextAt(I, ColsHidden) = "T" Then ItemHidden(I) = True
		    BuildType(I) = Data.Items.CellTextAt(I, ColsBuildType)
		    ''We'll hide Games as we don't version check these, Will try for now, doesn't slow down too much
		    'If BuildType(I) = "ppGame" Or BuildType(I) = "LLGame" Then 
		    'ItemHidden(I) = True
		    '''Data.Items.CellTextAt(I, ColsHidden) = "T"
		    'End If
		    ItemToAdd(I) = Data.Items.CellTextAt(I, ColsTitleName)
		    V(I) = Data.Items.CellTextAt(I, ColsVersion)
		    
		    'Clean Versions so they can be compared, they all need it and the short or no version ones will be quick
		    If V(I) <>"" Then ' Don't treat Empty ones, a little speed increase
		      If Left(V(I),1).Lowercase = "v" Then V(I) = Right (V(I), V(I).Length-1)
		      V(I) = V(I).Replace (".","") 'Remove all Decimals and only keep the one created below
		      V(I) = V(I).Replace ("R",".") 'Convert R to Decimal to make it comparable
		      V(I) = V(I).Replace (" ","") 'Remove all Spaces
		      V(I) = V(I).Replace ("-","") 'Remove all Minus
		      V(I) = V(I).Replace ("_","") 'Remove all Underscore
		      V(I) = V(I).Replace ("beta","") 'Remove all Spaces
		      VI(I) = V(I).ToDouble
		    End If
		  Next
		  For I = 0 To Data.Items.RowCount - 1
		    If ItemHidden(I) = True Then Continue 'Don't add any that are set to Hidden (Old versions and Duplicates get Hidden)
		    
		    For J = 0 To Data.Items.RowCount - 1 'Check if Duplicated item (no version checks)
		      If ItemHidden(J) = True Then Continue 'Don't add any that are set to Hidden (Old versions and Duplicates get Hidden)
		      If I = J Then Continue 'Don't compare to Self and it shouldn't hide everything
		      If ItemToAdd(I) = ItemToAdd(J) And BuildType(I) = BuildType(J) Then 'If same Name and Build Type then process
		        'Do Version Test Here
		        If V(I) = "" And V(J) = "" Or V(I) = V(J) Then 'If No Version to comapre, Just hide one, or if version same text (Quickest check)
		          ItemHidden(J) = True
		          Data.Items.CellTextAt(J, ColsHidden) = "T"
		          Continue
		        End If
		        'No Need to test if either Version contains anything but still need to test if one is Empty
		        If V(I) = "" Then Continue 'Skip checking non versioned items
		        If V(J) = "" Then Continue 'Skip checking non versioned items
		        
		        'Main version work here
		        If VI(I) > VI(J) Then 'Check which version Number is highest
		          ItemHidden(J) = True
		          Data.Items.CellTextAt(J, ColsHidden) = "T"
		          Continue
		        End If
		        
		      End If
		    Next
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadDB(DBRootIn As String, FullPathGiven As Boolean = False)
		  Dim F As FolderItem
		  If FullPathGiven = True Then
		    F = GetFolderItem(DBRootIn, FolderItem.PathTypeNative)
		    DBRootIn = Left(DBRootIn,DBRootIn.IndexOf("00-")) 'Drop back to the Folder
		  Else
		    F = GetFolderItem(DBRootIn+".lldb/lldb.ini",FolderItem.PathTypeNative)
		  End If
		  
		  If Not F.Exists Then
		    If Debugging Then Debug("Atempted to load Database From: "+ F.NativePath)
		    Return 'Dud file, get out of here
		  End If
		  
		  If Debugging Then Debug("Loading Database From: "+ F.NativePath)
		  
		  'Load in whole file at once (Fastest Method)
		  inputStream = TextInputStream.Open(F)
		  
		  Dim I, J, K As Integer
		  Dim RL As String
		  Dim Sp() As String
		  Dim HeadSp() As String
		  Dim ItemSp() As String
		  Dim DataHeadID As Integer
		  
		  Dim FadeFile As String
		  
		  While Not inputStream.EndOfFile 'If Empty file this skips it
		    RL = inputStream.ReadAll '.ConvertEncoding(Encodings.ASCII) 'Don't need to do this as DB's shouldn't have invalid chars
		  Wend
		  inputStream.Close
		  
		  If FullPathGiven = True Then 'Only Online DB's use this
		    RL = RL .ReplaceAll("%URLPath%", NoSlash(CurrentDBURL)) 'This is to point to the Online DB rather than the local cache, I'll have to convert them to RepositoryLocalDB 'Do All at once, must be faster than doing one at a time
		    RL = RL .ReplaceAll("%DBPath%", NoSlash(DBRootIn)) 'Do All at once, must be faster than doing one at a time
		  Else
		    RL = RL .ReplaceAll("%URLPath%", NoSlash(DBRootIn))
		    RL = RL .ReplaceAll("%DBPath%", NoSlash(DBRootIn)) 'Do All at once, must be faster than doing one at a time
		  End If
		  Sp()=RL.Split(Chr(10))
		  
		  If Sp.Count >= 1 Then
		    HeadSp= Sp(0).Split("|")
		    
		    If HeadSp.Count >= 1 Then
		      For I = 1 To Sp.Count - 1 'Items in DB
		        ItemSP = Sp(I).Split(",|,")
		        If ItemSp.Count >= 1 Then
		          For J = 0 To HeadSp.Count - 1
		            
		            DataHeadID = -1
		            For K = 0 To Data.Items.ColumnCount - 1
		              If Data.Items.HeaderAt(K) = HeadSp(J) Then
		                DataHeadID = K
		                Exit 'Found it
		              End If
		            Next
		            
		            Select Case HeadSp(J)
		            Case "RefID"
		              ItemCount =  Data.Items.RowCount
		              Data.Items.AddRow(Data.Items.RowCount.ToString("000000")) 'This adds the Leading 0's or prefixes it to 6 digits as it sort Alphabettical, fixed 1,10,100,2 to 001,002,010,100 for example
		            Case "IconRef" 'As the icon file is listed before this we can add it here
		              If Data.Items.CellTextAt(ItemCount,Data.GetDBHeader("FileIcon")) <> "" Then 'If it has a file listed then it should exist
		                IconCount = Data.Icons.RowCount
		                Data.Icons.AddRow
		                FadeFile = Data.Items.CellTextAt(ItemCount,Data.GetDBHeader("FileIcon"))
		                F = GetFolderItem(FadeFile, FolderItem.PathTypeNative)
		                If F.Exists Then
		                  ItemIcon = Picture.Open(F)
		                  Data.Icons.RowImageAt(IconCount) = ItemIcon
		                  Data.Items.CellTextAt(ItemCount,Data.GetDBHeader("IconRef")) = Str(IconCount)
		                Else
		                  Data.Items.CellTextAt(ItemCount,Data.GetDBHeader("IconRef")) = Str(0) 'Can't find file
		                End If
		              Else 'Icon not found - Use Defaults
		                Data.Items.CellTextAt(ItemCount,Data.GetDBHeader("IconRef")) = Str(0)
		              End If
		            Case Else
		              If DataHeadID >= 1 Then
		                Data.Items.CellTextAt(ItemCount,DataHeadID) = ItemSP(J)
		              End If
		            End Select
		          Next
		        End If
		      Next
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadFavorites()
		  Dim I As Integer
		  'Load in Favorites if exists
		  FavCount = 0
		  Dim InFavs As String
		  Dim InFavSp() As String
		  If StoreMode = 1 Then
		    If Exist(Slash(AppPath)+"Favorites.ini") Then
		      InFavs = LoadDataFromFile(Slash(AppPath)+"Favorites.ini")
		      InFavs = InFavs.ReplaceAll (Chr(13), Chr(10))
		      InFavSp() = InFavs.Split(Chr(10))
		      If InFavSp.Count >= 1 Then
		        For I = 0 To InFavSp.Count - 1
		          If InFavSp(I).Trim <> "" Then
		            Favorites(FavCount) = InFavSp(I).Trim
		            FavCount = FavCount + 1
		          End If
		        Next
		      End If
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadPosition()
		  Dim FileIn As String
		  Dim DataIn As String
		  Dim DataSp() As String
		  Dim I As Integer
		  
		  FileIn = ""
		  If StoreMode = 0 Then 
		    FileIn = Slash(SpecialFolder.ApplicationData.NativePath)+".LLStore.ini"
		  ElseIf StoreMode = 1 Then
		    FileIn = Slash(SpecialFolder.ApplicationData.NativePath)+".LLLauncher.ini"
		  End If
		  
		  If FileIn <> "" Then
		    If Exist(FileIn) Then
		      If Debugging Then Debug ("- Load Windows Position From File: " + FileIn)
		      
		      DataIn = LoadDataFromFile(FileIn)
		      If DataIn.Trim <> "" Then
		        DataSp = DataIn.Split(Chr(10))
		        For I = 0 To DataSp.Count - 1
		          If DataSp(I).IndexOf("MainLeft=") >=0 Then
		            LoadedPosition = True
		            Main.Left = DataSp(I).ReplaceAll("MainLeft=", "").Trim.ToInteger
		          End If
		          If DataSp(I).IndexOf("MainTop=") >=0 Then
		            Main.Top = DataSp(I).ReplaceAll("MainTop=", "").Trim.ToInteger
		          End If
		          If DataSp(I).IndexOf("MainWidth=") >=0 Then
		            Main.Width = DataSp(I).ReplaceAll("MainWidth=", "").Trim.ToInteger
		          End If
		          If DataSp(I).IndexOf("MainHeight=") >=0 Then
		            Main.Height = DataSp(I).ReplaceAll("MainHeight=", "").Trim.ToInteger
		          End If
		          
		          If DataSp(I).IndexOf("CatFont=") >=0 Then
		            Main.Categories.FontSize = DataSp(I).ReplaceAll("CatFont=", "").Trim.ToInteger
		          End If
		          If DataSp(I).IndexOf("ItemFont=") >=0 Then
		            Main.Items.FontSize = DataSp(I).ReplaceAll("ItemFont=", "").Trim.ToInteger
		          End If
		          If DataSp(I).IndexOf("DescriptionFont=") >=0 Then
		            Main.Description.FontSize = DataSp(I).ReplaceAll("DescriptionFont=", "").Trim.ToInteger
		          End If
		          If DataSp(I).IndexOf("MetaFont=") >=0 Then
		            Main.MetaData.FontSize = DataSp(I).ReplaceAll("MetaFont=", "").Trim.ToInteger
		          End If
		        Next
		      End If
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadSettings()
		  If Debugging Then Debug("--- Starting Load Settings ---")
		  Dim RL As String
		  Dim F As FolderItem
		  Dim EnableDebugging As Boolean
		  
		  SettingsLoaded = True
		  
		  SettingsFile = AppPath+"LLL_Settings.ini"
		  F = GetFolderItem(SettingsFile,FolderItem.PathTypeNative)
		  If Not F.Exists Then Return 'No Settings file found
		  
		  InputStream = TextInputStream.Open(F)
		  While Not inputStream.EndOfFile 'If Empty file this skips it
		    RL = inputStream.ReadAll.ConvertEncoding(Encodings.ASCII)
		  Wend
		  inputStream.Close
		  
		  Dim I As Integer
		  Dim Sp() As String
		  Dim Lin, LineID, LineData As String
		  Dim EqPos As Integer
		  Dim IniFile As String
		  
		  RL = RL.ReplaceAll(Chr(13), Chr(10))
		  SP()=RL.Split(Chr(10))
		  If Sp.Count <= 0 Then Return ' Empty File
		  For I = 0 To Sp().Count -1
		    Lin = Sp(I).Trim
		    EqPos = Lin.IndexOf(1,"=")
		    LineID = ""
		    LineData = ""
		    If  EqPos >= 1 Then
		      LineID = Left(Lin,EqPos)
		      LineData = Right(Lin,Len(Lin)-Len(LineID)-1)
		      LineID=LineID.Trim.Lowercase
		      LineData=LineData.Trim
		    End If
		    Select Case LineID
		    Case "LastUsedCategory"
		      LastUsedCategory = LineData
		    Case"SudoAsNeeded"
		      If LineData <> "" Then Settings.SetSudoAsNeeded.Value = IsTrue(LineData)
		      SudoAsNeeded = Settings.SetSudoAsNeeded.Value
		    Case"hideinstallergamecats"
		      If LineData <> "" Then Settings.SetHideGameCats.Value = IsTrue(LineData) 'HideInstallerGameCats = IsTrue(LineData)
		    Case"fontsizedescription"
		      If LineData <> "" Then Main.Description.FontSize = Val(LineData)
		    Case"fontsizecategories"
		      If LineData <> "" Then Main.Categories.FontSize = Val(LineData)
		    Case"fontsizeitems"
		      If LineData <> "" Then Main.Items.FontSize = Val(LineData)
		    Case"fontsizemetadata"
		      If LineData <> "" Then Main.MetaData.FontSize = Val(LineData)
		    Case "checkforupdates"
		      If LineData <> "" Then Settings.SetCheckForUpdates.Value = IsTrue(LineData)
		    Case "quitoncomplete"
		      If LineData <> "" Then Settings.SetQuitOnComplete.Value = IsTrue(LineData)
		    Case "videoplayback"
		      If LineData <> "" Then Settings.SetVideoPlayback.Value = IsTrue(LineData)
		    Case "videovolume"
		      If LineData <> "" Then Settings.SetVideoVolume.Text = LineData.Trim
		      If Val(Settings.SetVideoVolume.Text) > 100 Then Settings.SetVideoVolume.Text  = "100"
		      If Val(Settings.SetVideoVolume.Text) < 0 Then Settings.SetVideoVolume.Text  = "0"
		      MovieVolume = Val(Settings.SetVideoVolume.Text)
		    Case "uselocaldbs"
		      If LineData <> "" Then Settings.SetUseLocalDBFiles.Value = IsTrue(LineData)
		    Case "copyitemstobuiltrepo"
		      If LineData <> "" Then Settings.SetCopyToRepoBuild.Value = IsTrue(LineData)
		    Case "ignorecachedrepoitems"
		      If LineData <> "" Then Settings.SetIgnoreCache.Value = IsTrue(LineData)
		    Case "hideinstalledonstartup"
		      If LineData <> "" Then
		        Settings.SetHideInstalled.Value = IsTrue(LineData)
		        Main.HideInstalled = IsTrue(LineData) 'Apply it to current settings
		      End If
		    Case "usemanuallocations"
		      If LineData <> "" Then Settings.SetUseManualLocations.Value = IsTrue(LineData)
		    Case "flatpaklocation"
		      If LineData = "User" Then
		        Settings.SetFlatpakAsUser.Value = True
		        Settings.SetFlatpakAsSystem.Value = False
		        FlatpakAsUser = Settings.SetFlatpakAsUser.Value
		      Else
		        Settings.SetFlatpakAsUser.Value = False
		        Settings.SetFlatpakAsSystem.Value =  True
		        FlatpakAsUser = Settings.SetFlatpakAsUser.Value
		      End If
		    Case "useonlinerepositiories"
		      If LineData <> "" Then Settings.SetUseOnlineRepos.Value = IsTrue(LineData)
		    Case "debugenabled"
		      If LineData <> "" Then Settings.SetDebugEnabled.Value = IsTrue(LineData)
		      If DebugFileOk = True Then
		        EnableDebugging = Settings.SetDebugEnabled.Value
		      Else
		        Debugging = False 'If the file isn't writable then no point in enabling the debugger
		        EnableDebugging = False
		      End If
		    Case "alwaysshowres"
		      If LineData <> "" Then Settings.SetAlwaysShowRes.Value = IsTrue(LineData)
		    Case "recoverscreenres"
		      If LineData <> "" Then Settings.SetRecoverScreenRes.Value = IsTrue(LineData)
		    End Select
		  Next
		  App.DoEvents(1)' Update the Settings Form with the new Check values before we do anything, might fix it, else I'll need to use Variables
		  
		  
		  'Get Manual Locations
		  Settings.SetManualLocations.Text = "" 'Clear it, will load again if one is available for Store Mode
		  If Settings.SetUseManualLocations.Value = True Then 'Only use them if set to use them
		    If StoreMode = 0 Then
		      If TargetWindows Then
		        IniFile = Slash(AppPath)+"LLL_Store_Win_Manual_Locations.ini"
		      Else
		        IniFile = Slash(AppPath)+"LLL_Store_Linux_Manual_Locations.ini"
		      End If
		    Else
		      If TargetWindows Then
		        IniFile = Slash(AppPath)+"LLL_Launcher_Win_Manual_Locations.ini"
		      Else
		        IniFile = Slash(AppPath)+"LLL_Launcher_Linux_Manual_Locations.ini"
		      End If
		    End If
		    ManualLocationsFile = IniFile
		    If Exist(IniFile) Then
		      Settings.SetManualLocations.Text = LoadDataFromFile(IniFile)
		    End If
		  End If
		  
		  If EnableDebugging Then Debugging = True 'Do this after the above settings or it shows them before the first line later on
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadTheme(ThemeName As String)
		  If Debugging Then Debug("--- Starting Load Theme ---")
		  
		  'Load Wallpaper for main theme
		  Dim F As FolderItem
		  Dim ImgPath As String
		  Dim I As Integer
		  
		  Main.Description.FontSize = 12
		  Main.Items.FontSize = 12
		  Main.Categories.FontSize = 12
		  Main.MetaData.FontSize = 12
		  
		  ThemePath = AppPath+"Themes/"+ThemeName+"/"
		  
		  ImgPath = ThemePath+"Loading.png"
		  F=GetFolderItem(ImgPath, FolderItem.PathTypeShell)
		  DefaultLoadingWallpaper = Picture.Open(F)
		  
		  If Loading.Backdrop = Nil Then
		    Loading.Backdrop = New Picture(Loading.Width+1,Loading.Height, 32)
		  End If
		  
		  App.DoEvents(1)
		  Loading.Backdrop.Graphics.DrawPicture(DefaultLoadingWallpaper,0,0,Loading.Width+1, Loading.Height,0,0,DefaultLoadingWallpaper.Width, DefaultLoadingWallpaper.Height)
		  
		  'Below stops the first draw issue in Linux (It's ugly)
		  If FirstRun = False Then Loading.Show 'Show as soon as it's Themed, then it draws right :)
		  
		  ImgPath = ThemePath+"Wallpaper.jpg"
		  F=GetFolderItem(ImgPath, FolderItem.PathTypeShell)
		  If Exist(ImgPath) Then
		    DefaultMainWallpaper = Picture.Open(F)
		  Else
		    DefaultMainWallpaper = New Picture(Screen(0).AvailableWidth,Screen(0).AvailableHeight, 32)
		    DefaultMainWallpaper.Graphics.DrawingColor = &C000000
		    DefaultMainWallpaper.Graphics.FillRectangle(0,0,DefaultMainWallpaper.Width,DefaultMainWallpaper.Height)
		  End If
		  
		  If Exist(ThemePath+"Screenshot.jpg") Then
		    F=GetFolderItem(ThemePath+"Screenshot.jpg", FolderItem.PathTypeShell)
		    ScreenShotCurrent = Picture.Open(F)
		  Else
		    'No Need to make black if always transparent
		    ScreenShotCurrent = New Picture(Screen(0).AvailableWidth,Screen(0).AvailableHeight, 32)
		    ScreenShotCurrent.Graphics.DrawingColor = &C000000
		    ScreenShotCurrent.Graphics.FillRectangle(0,0,ScreenShotCurrent.Width,ScreenShotCurrent.Height)
		  End If
		  
		  Main.Backdrop = DefaultMainWallpaper
		  
		  F=GetFolderItem(ThemePath+"Icon.png", FolderItem.PathTypeShell)
		  DefaultFader = Picture.Open(F)
		  
		  F=GetFolderItem(ThemePath+"StartButton.png", FolderItem.PathTypeShell)
		  DefaultStartButton = Picture.Open(F)
		  
		  F=GetFolderItem(ThemePath+"StartButtonHover.png", FolderItem.PathTypeShell)
		  DefaultStartButtonHover = Picture.Open(F)
		  
		  If Main.StartButton.Backdrop = Nil Then
		    Main.StartButton.Backdrop = New Picture(Main.StartButton.Width,Main.StartButton.Height, 32)
		  End If
		  
		  Main.StartButton.Backdrop.Graphics.DrawPicture(DefaultFader,0,0,Main.StartButton.Width, Main.StartButton.Height,0,0,DefaultStartButton.Width, DefaultStartButton.Height)
		  
		  
		  Data.Icons.AddRow
		  Data.Icons.RowImageAt(0) = DefaultFader
		  Data.Icons.DefaultRowHeight = 256
		  
		  'Load in whole file at once (Fastest Method)
		  F = GetFolderItem(ThemePath+"Style.ini",FolderItem.PathTypeShell)
		  inputStream = TextInputStream.Open(F)
		  
		  Dim RL As String
		  Dim Sp() As String
		  Dim Lin, LineID, LineData As String
		  Dim EqPos As Integer
		  If  F.Exists Then 
		    While Not inputStream.EndOfFile 'If Empty file this skips it
		      RL = inputStream.ReadAll.ConvertEncoding(Encodings.ASCII)
		    Wend
		    inputStream.Close
		  End If
		  RL = RL.ReplaceAll(Chr(13), Chr(10))
		  SP()=RL.Split(Chr(10))
		  If Sp.Count >= 1 Then  'Not Empty Theme File
		    For I = 1 To Sp().Count -1
		      Lin = Sp(I).Trim
		      EqPos = Lin.IndexOf(1,"=")
		      LineID = ""
		      LineData = ""
		      If  EqPos >= 1 Then
		        LineID = Left(Lin,EqPos)
		        LineData = Right(Lin,Len(Lin)-Len(LineID)-1)
		        LineID=LineID.Trim.Lowercase
		        LineData=LineData.Trim
		      Else 'No Equals, Broken?
		        LineID = Lin.Trim
		      End If
		      Select Case LineID
		      Case "coltitle"
		        If LineData <> "" Then ColTitle = Color.FromString(LineData)
		      Case"colcategory"
		        If LineData <> "" Then ColCategory = Color.FromString(LineData)
		      Case"coldescription"
		        If LineData <> "" Then ColDescription = Color.FromString(LineData)
		      Case"collist"
		        If LineData <> "" Then ColList = Color.FromString(LineData)
		      Case"colssapp"
		        If LineData <> "" Then ColssApp = Color.FromString(LineData)
		      Case"colppapp"
		        If LineData <> "" Then ColppApp = Color.FromString(LineData)
		      Case"colppgame"
		        If LineData <> "" Then ColppGame = Color.FromString(LineData)
		      Case"colllapp"
		        If LineData <> "" Then ColLLApp = Color.FromString(LineData)
		      Case"colllgame"
		        If LineData <> "" Then ColLLGame = Color.FromString(LineData)
		      Case"colmeta"
		        If LineData <> "" Then ColMeta = Color.FromString(LineData)
		      Case"colstats"
		        If LineData <> "" Then ColStats = Color.FromString(LineData)
		      Case"colbg"
		        If LineData <> "" Then ColBG = Color.FromString(LineData)
		      Case"colfg"
		        If LineData <> "" Then ColFG = Color.FromString(LineData)
		      Case"colselect"
		        If LineData <> "" Then ColSelect = Color.FromString(LineData)
		      Case "colhilite"
		        If LineData <> "" Then ColHiLite = Color.FromString(LineData)
		      Case"colloading"
		        If LineData <> "" Then ColLoading = Color.FromString(LineData)
		      Case"fontloading"
		        If LineData <> "" Then FontLoading = LineData
		      Case"fonttitle"
		        If LineData <> "" Then FontTitle = LineData
		      Case"fontlist"
		        If LineData <> "" Then FontList = LineData
		      Case"fontdescription"
		        If LineData <> "" Then FontDescription = LineData
		      Case"fontstats"
		        If LineData <> "" Then FontStats = LineData
		      Case"fontmeta"
		        If LineData <> "" Then FontMeta = LineData
		      Case"boldtitles"
		        If LineData <> "" Then BoldTitle = IsTrue(LineData)
		      Case"boldlist"
		        If LineData <> "" Then BoldList = IsTrue(LineData)
		      Case"bolddescription"
		        If LineData <> "" Then BoldDescription = IsTrue(LineData)
		      End Select
		    Next
		  End If
		  
		  'Apply Settings
		  'Labels
		  Main.TitleLabel.TextColor = ColTitle
		  Main.CategoriesLabel.TextColor = ColTitle
		  Main.ItemsLabel.TextColor = ColTitle
		  
		  Main.TitleLabel.FontName = FontTitle
		  Main.CategoriesLabel.FontName = FontTitle
		  Main.ItemsLabel.FontName = FontTitle
		  
		  Main.TitleLabel.Bold = BoldTitle
		  Main.CategoriesLabel.Bold = BoldTitle
		  Main.ItemsLabel.Bold = BoldTitle
		  
		  'Stats
		  Main.Stats.TextColor = ColStats
		  Main.Stats.FontName = FontStats
		  
		  'Meta 'Cols are in the PaintEvents
		  Main.MetaData.FontName = FontMeta
		  
		  'Description, This also gets applied before changing the description in FirstRun Timer event and ChangeItem method
		  Main.Description.TextColor = ColDescription
		  Main.Description.BackgroundColor = ColBG
		  Main.Description.FontName = FontDescription
		  Main.Description.Bold = BoldDescription
		  
		  'Categories
		  'Main.Categories.TextColor = ColCategory 'Done in CellPaint Events
		  Main.Categories.FontName = FontList
		  Main.Categories.Bold = BoldList
		  
		  'Items
		  'Main.Items.TextColor = ColList 'Done in CellPaint Events
		  Main.Items.FontName = FontList
		  Main.Items.Bold = BoldList
		  
		  Loading.Status.TextColor = ColLoading
		  Loading.Status.FontName = FontLoading
		  
		  ColDual = Color.RGB(((ColHiLite.Blue + ColSelect.Blue) /2),((ColHiLite.Green + ColSelect.Green)/2),((ColHiLite.Red + ColSelect.Red) /2)) 'Inversed
		  'ColDual = Color.RGB(((ColHiLite.Red + ColSelect.Red) /2),((ColHiLite.Green + ColSelect.Green)/2),((ColHiLite.Blue + ColSelect.Blue) /2)) 'Average
		  
		  If Debugging Then Debug("- Loaded Theme: "+ThemeName)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RefreshDBs()
		  ForceRefreshDBs = True
		  Loading.Visible = True
		  Main.Visible = False
		  Loading.FirstRunTime.RunMode = Timer.RunModes.Single
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveAllDBs()
		  If Debugging Then Debug("--- Starting Save All DBs ---")
		  App.DoEvents(1) 'This makes the Load Screen Update the Status Text, Needs to be in each Function and Sub call
		  
		  Dim H, G, F As FolderItem
		  Dim I, J, K As Integer
		  Dim DBOutPath As String
		  Dim DBOutText As String
		  Dim DataOut As String
		  Dim PatIni As String
		  Dim UniqueName As String
		  Dim IsCompressed As Boolean
		  
		  'SaveDB's if Writable (Move this to a thread to do in the background?)
		  For I = 0 To Data.ScanPaths.RowCount - 1
		    DBOutPath = Data.ScanPaths.CellTextAt(I, 0) + ".lldb/"
		    
		    If Slash(Data.ScanPaths.CellTextAt(I,0)) = Slash(RepositoryPathLocal) Then Continue 'Do NOT do local repository path databases, it uses the online one for that
		    
		    If Data.ScanPaths.CellTextAt(I,1) = "T" Then Continue 'It loaded from an existing DB so no need to save it
		    
		    Deltree(DBOutPath) 'Kill Previous Database if writable media.
		    MakeFolder(DBOutPath) 'Make sure it exist again
		    
		    DBOutText=""
		    For K = 0 To Data.Items.ColumnCount -2 'Changed this from -1 to -2 to ignore the Sorting Column
		      DBOutText=DBOutText + Data.Items.HeaderAt(K)+"|"
		    Next K
		    DBOutText = DBOutText + Chr(10)'New Line To Seperate the header
		    
		    For J = 0 To Data.ScanItems.RowCount - 1
		      If Data.ScanItems.CellTextAt(J, 2) = Data.ScanPaths.CellTextAt(I, 0) Then
		        If Data.ScanItems.CellTagAt(J,0) >=0 Then 'Only Add Valid Items to the DB
		          
		          'Get if compressed and the correct INI Path for the item
		          IsCompressed = IsTrue(Data.Items.CellTextAt (Data.ScanItems.CellTagAt(J,0),Data.GetDBHeader("Compressed")))
		          If IsCompressed Then
		            PatINI = Data.Items.CellTextAt (Data.ScanItems.CellTagAt(J,0),Data.GetDBHeader("PathINI"))
		            PatINI = Left(PatIni,InStrRev(PatIni,"/")-1)
		          Else
		            PatINI = Data.Items.CellTextAt (Data.ScanItems.CellTagAt(J,0),Data.GetDBHeader("PathINI"))
		            PatINI = Left(PatIni,InStrRev(PatIni,"/") -1)
		            PatINI = Left(PatIni,InStrRev(PatIni,"/")-1)
		          End If
		          
		          UniqueName = Data.Items.CellTextAt (Data.ScanItems.CellTagAt(J,0),Data.GetDBHeader("UniqueName"))
		          
		          For K = 0 To Data.Items.ColumnCount -2 'Changed this from -1 to -2 to ignore the Sorting Column
		            'Add each item (May Be slow) but a DB if enabled is faster once built.
		            Select Case Data.Items.HeaderAt(K)
		            Case "FileINI" 'If doing INIFile, we need to change to %dbpath%
		              DataOut = Data.Items.CellTextAt (Data.ScanItems.CellTagAt(J,0),K)
		              DataOut = DataOut.ReplaceAll(PatINI, "%DBPath%")
		              DataOut = DataOut.ReplaceAll("\", "/") 'Windows can use Linux paths, but Linux can't use Windows paths, so do the switch
		            Case "PathINI" 'If doing INIFile, we need to change to %dbpath%
		              DataOut = Data.Items.CellTextAt (Data.ScanItems.CellTagAt(J,0),K)
		              DataOut = DataOut.ReplaceAll(PatINI, "%URLPath%")
		              DataOut = DataOut.ReplaceAll("\", "/") 'Windows can use Linux paths, but Linux can't use Windows paths, so do the switch
		            Case "FileIcon", "FileFader", "FileScreenshot" 'Change to %DBPath%
		              DataOut = Data.Items.CellTextAt (Data.ScanItems.CellTagAt(J,0),K)
		              DataOut = DataOut.ReplaceAll("\", "/") 'Windows can use Linux paths, but Linux can't use Windows paths, so do the switch
		              If IsCompressed Then
		                If DataOut <>"" Then
		                  H = GetFolderItem(DataOut, FolderItem.PathTypeNative)
		                  G = GetFolderItem(DBOutPath+UniqueName+Right(DataOut,4), FolderItem.PathTypeNative) 'Right is the extension
		                  If G.Exists Then 
		                    Try 
		                      If FixPath(H.NativePath) <> FixPath(G.NativePath) Then G.Delete 'If it's not the same file delete it
		                    Catch
		                    End Try
		                  End If
		                  
		                  If FixPath(H.NativePath) <> FixPath(G.NativePath) Then 'Don't copy if it's itself
		                    If G.IsWriteable Then
		                      If H.Exists Then
		                        #Pragma BreakOnExceptions Off
		                        Try
		                          If G.Exists Then G.Remove ' Delete before copying to it
		                          H.CopyTo(G)
		                          DataOut = "%DBPath%/.lldb/"+UniqueName+Right(DataOut,4)
		                        Catch
		                        End Try
		                        #Pragma BreakOnExceptions On
		                      End If
		                    End If
		                  End If
		                End If
		              Else 'Not compressed, just use current ini path
		                DataOut = DataOut.ReplaceAll(PatINI, "%DBPath%")
		                DataOut = DataOut.ReplaceAll("\", "/") 'Windows can use Linux paths, but Linux can't use Windows paths, so do the switch
		              End If
		            Case Else
		              DataOut = CompPath(Data.Items.CellTextAt (Data.ScanItems.CellTagAt(J,0),K))
		            End Select
		            DBOutText=DBOutText+DataOut+",|,"
		          Next K
		          DBOutText = DBOutText + Chr(10)'New Line per item Added
		        End If
		      End If
		    Next
		    'Save File
		    SaveDataToFile (DBOutText, DBOutPath+"lldb.ini")
		  Next
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveFavorites()
		  If FavCount <= 0 Then Return
		  Dim I As Integer
		  Dim FavOut As String
		  'Save Favorites if some are set
		  For I = 0 To FavCount - 1
		    If Favorites(I) <> "" Then FavOut = FavOut + Favorites(I) + Chr(10)
		  Next I
		  
		  If FavOut <> "" Then
		    SaveDataToFile (FavOut, Slash(AppPath)+"Favorites.ini")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SavePosition()
		  Dim FileOut As String
		  Dim DataOut As String
		  
		  FileOut = ""
		  If StoreMode = 0 Then 
		    FileOut = Slash(SpecialFolder.ApplicationData.NativePath)+".LLStore.ini"
		  ElseIf StoreMode = 1 Then
		    FileOut = Slash(SpecialFolder.ApplicationData.NativePath)+".LLLauncher.ini"
		  End If
		  
		  If TargetWindows Then
		    FileOut = FileOut.ReplaceAll("/","\")
		  Else
		    FileOut = FileOut.ReplaceAll("\","/")
		  End If
		  
		  If Debugging Then Debug ("- Saving Position To File: " + FileOut)
		  
		  If FileOut <> "" Then
		    If Main.Visible = True Then
		      If Main.Left >=0 And Main.Top >=0 Then
		        If Main.Left+Main.Width <= Screen(0).AvailableWidth And Main.Top+Main.Height <= Screen(0).AvailableHeight Then
		          'Only save if visible
		          DataOut = DataOut + "MainLeft=" + Main.Left.ToString+Chr(10)
		          DataOut = DataOut + "MainTop=" + Main.Top.ToString+Chr(10)
		          DataOut = DataOut + "MainWidth=" + Main.Width.ToString+Chr(10)
		          DataOut = DataOut + "MainHeight=" + Main.Height.ToString+Chr(10)
		          
		          DataOut = DataOut + "CatFont=" + Main.Categories.FontSize.ToString+Chr(10)
		          DataOut = DataOut + "ItemFont=" + Main.Items.FontSize.ToString+Chr(10)
		          DataOut = DataOut + "DescriptionFont=" + Main.Description.FontSize.ToString+Chr(10)
		          DataOut = DataOut + "MetaFont=" + Main.MetaData.FontSize.ToString+Chr(10)
		          
		          SaveDataToFile (DataOut, FileOut)
		          
		        End If
		      End If
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveSettings()
		  If Debugging Then Debug("--- Starting Save Settings ---")
		  If SettingsLoaded = False Then Return
		  
		  Dim RL As String
		  
		  SettingsFile = Slash(AppPath)+"LLL_Settings.ini"
		  RL = "[LLStore]" + Chr(10) 'Using a header so I can sort below without having to shufffle the first item, gets ignored
		  
		  RL = RL + "FontSizeCategories=" + Str(Main.Categories.FontSize)+Chr(10)
		  RL = RL + "FontSizeDescription=" + Str(Main.Description.FontSize)+Chr(10)
		  RL = RL + "FontSizeItems=" + Str(Main.Items.FontSize)+Chr(10)
		  RL = RL + "FontSizeMetaData=" + Str(Main.MetaData.FontSize)+Chr(10)
		  RL = RL + "HideInstallerGameCats=" + Str(Settings.SetHideGameCats.Value) + Chr(10)
		  
		  RL = RL + "SudoAsNeeded=" + Str(Settings.SetSudoAsNeeded.Value) + Chr(10)
		  RL = RL + "CheckForUpdates=" + Str(Settings.SetCheckForUpdates.Value) + Chr(10)
		  RL = RL + "QuitOnComplete=" + Str(Settings.SetQuitOnComplete.Value) + Chr(10)
		  RL = RL + "VideoPlayback=" + Str(Settings.SetVideoPlayback.Value) + Chr(10)
		  RL = RL + "VideoVolume=" + Str(Settings.SetVideoVolume.Text) + Chr(10)
		  RL = RL + "UseLocalDBs=" + Str(Settings.SetUseLocalDBFiles.Value) + Chr(10)
		  RL = RL + "CopyItemsToBuiltRepo=" + Str(Settings.SetCopyToRepoBuild.Value) + Chr(10)
		  RL = RL + "IgnoreCachedRepoItems=" + Str(Settings.SetIgnoreCache.Value) + Chr(10)
		  RL = RL + "LastUsedCategory=" + LastUsedCategory + Chr(10)
		  If Settings.SetFlatpakAsUser.Value = True Then
		    RL = RL + "FlatpakLocation=User" + Chr(10)
		  Else
		    RL = RL + "FlatpakLocation=System" + Chr(10)
		  End If
		  
		  RL = RL + "HideInstalledOnStartup=" + Str(Settings.SetHideInstalled.Value) + Chr(10)
		  
		  RL = RL + "UseManualLocations=" + Str(Settings.SetUseManualLocations.Value) + Chr(10)
		  RL = RL + "UseOnlineRepositiories=" + Str(Settings.SetUseOnlineRepos.Value) + Chr(10)
		  
		  RL = RL + "DebugEnabled=" + Str(Settings.SetDebugEnabled.Value) + Chr(10)
		  
		  RL = RL + "AlwaysShowRes=" + Str(Settings.SetAlwaysShowRes.Value) + Chr(10)
		  
		  RL = RL + "RecoverScreenRes=" + Str(Settings.SetRecoverScreenRes.Value) + Chr(10)
		  
		  'Save to actual Settings File
		  SaveDataToFile(RL, SettingsFile)
		  
		  'Save Manual Locations
		  Dim IniFile As String
		  If StoreMode = 0 Then
		    If TargetWindows Then
		      IniFile = Slash(AppPath)+"LLL_Store_Win_Manual_Locations.ini"
		    Else
		      IniFile = Slash(AppPath)+"LLL_Store_Linux_Manual_Locations.ini"
		    End If
		  Else
		    If TargetWindows Then
		      IniFile = Slash(AppPath)+"LLL_Launcher_Win_Manual_Locations.ini"
		    Else
		      IniFile = Slash(AppPath)+"LLL_Launcher_Linux_Manual_Locations.ini"
		    End If
		  End If
		  SaveDataToFile(Settings.SetManualLocations.Text, IniFile)
		  
		  'Save Repo's
		  SaveDataToFile(Settings.SetOnlineRepos.Text.ReplaceAll(Chr(13), Chr(10)),Slash(AppPath)+"LLL_Repos.ini")
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ShowDownloadImages()
		  Dim F As FolderItem
		  Dim WebWall As String
		  Dim UN As String
		  
		  'Get UN Name (Universal Name)
		  UN = UniversalName(Data.Items.CellTextAt(CurrentItemID, Data.GetDBHeader("TitleName"))+Data.Items.CellTextAt(CurrentItemID, Data.GetDBHeader("BuildType")))
		  
		  If  Exist(Slash(RepositoryPathLocal)+".lldb/"+UN+".jpg") Then 'Screenshot
		    WebWall = Slash(RepositoryPathLocal)+".lldb/"+UN+".jpg" 'Data.Items.CellTextAt(CurrentItemIn, Data.GetDBHeader("FileScreenshot"))
		    If WebWall = "" Or Not Exist(WebWall) Then
		      WebWall = Slash(ThemePath) + "Screenshot.jpg" 'Default Theme Wallpaper used if no other given (could do Category Screenshots here if wanted)
		    End If
		    
		    F = GetFolderItem(WebWall, FolderItem.PathTypeShell)
		    ScreenShotCurrent = Picture.Open(F)
		    Main.ScaleScreenShot
		  End If
		  If Exist(Slash(RepositoryPathLocal)+".lldb/"+UN+".png") Then 'Fader
		    WebWall = Slash(RepositoryPathLocal)+".lldb/"+UN+".png" 'Data.Items.CellTextAt(CurrentItemID, Data.GetDBHeader("FileFader"))
		    If WebWall = "" Or Not Exist(WebWall) Then
		      WebWall = Slash(ThemePath) + "Icon.png" 'Default Theme Icon  used if no other given (could do Category Icons here if wanted)
		    End If
		    F = GetFolderItem(WebWall, FolderItem.PathTypeShell)
		    CurrentFader = Picture.Open(F)
		    
		    'Clone From Wallpaper to Icon BG
		    If Main.ItemFaderPic.Backdrop <> Nil And Main.Backdrop <> Nil Then ' Only do if Valid
		      Main.ItemFaderPic.Backdrop.Graphics.DrawPicture(Main.Backdrop,0,0,Main.ItemFaderPic.Width, Main.ItemFaderPic.Height, Main.ItemFaderPic.Left, Main.ItemFaderPic.Top, Main.ItemFaderPic.Width, Main.ItemFaderPic.Height)
		      'Draw Fader Icon on BG
		      Main.ItemFaderPic.Backdrop.Graphics.DrawPicture(CurrentFader,0,0,Main.ItemFaderPic.Width, Main.ItemFaderPic.Height,0,0,CurrentFader.Width, CurrentFader.Height)
		      Main.ItemFaderPic.Refresh
		    End If
		  End If
		  
		End Sub
	#tag EndMethod


#tag EndWindowCode

#tag Events FirstRunTime
	#tag Event
		Sub Action()
		  'This disables errors from breaking/debugging in the IDE, disable to debug
		  '# Pragma BreakOnExceptions False
		  If Debugging Then Debug("--- Starting LLStore FirstRunTimer ---")
		  
		  Dim I As Integer
		  Dim F As FolderItem
		  Dim Success As Boolean
		  Dim Test As String
		  
		  'Center Form
		  self.Left = (screen(0).AvailableWidth - self.Width) / 2
		  self.top = (screen(0).AvailableHeight - self.Height) / 2
		  
		  'Clear Data, always start with fresh fields etc (Do before theme so first icon is loaded
		  Data.ClearData
		  
		  'Clear Temp Paths here?
		  
		  'Make sure paths exist (But only once per execution)
		  TmpPathItems = Slash(TmpPath)+"items/" 'Use Linux Paths for both OS's
		  MakeFolder(TmpPathItems)
		  
		  If StoreMode <=1 Then 'Only load items if not (Mode 3 Editor or Mode 4 Installer) - Mode 2 is For silent mode stuff, not used yet
		    
		    Loading.Visible = True 'Don't show this if Arguments and mode is set Different
		    Loading.Show
		    Loading.Refresh
		    App.DoEvents
		    
		    'Check For Updates
		    'Msgbox RunningInIDE.ToString
		    If Settings.SetCheckForUpdates.Value = True And RunningInIDE = False Then
		      Loading.Status.Text = "Check For Store Updates..."
		      Loading.Refresh
		      App.DoEvents(1)
		      CheckForLLStoreUpdates
		    End IF
		    
		    'Get Scan Paths Here
		    Loading.Status.Text = "Scanning Drives..."
		    Loading.Refresh
		    App.DoEvents(1)
		    GetScanPaths
		    
		    'Get items from in Scan Paths (Don't add yet)
		    Loading.Status.Text = "Scanning for Items..."
		    Loading.Refresh
		    App.DoEvents(1)
		    
		    If Data.ScanPaths.RowCount >=1 Then
		      For I = 0 To Data.ScanPaths.RowCount - 1
		        If Settings.SetUseLocalDBFiles.Value = True Then
		          F = GetFolderItem(Data.ScanPaths.CellTextAt(I,0)+".lldb/lldb.ini",FolderItem.PathTypeNative)
		          If F.Exists And ForceRefreshDBs = False Then
		            LoadDB(Data.ScanPaths.CellTextAt(I,0))
		            Data.ScanPaths.CellTextAt(I,1) = "T"
		          Else 'Scan Items and Save DB Below
		            GetItems(Data.ScanPaths.CellTextAt(I,0))
		            Data.ScanPaths.CellTextAt(I,1) = "F"
		          End If
		        Else 'Not using LocalDB's
		          GetItems(Data.ScanPaths.CellTextAt(I,0))
		          Data.ScanPaths.CellTextAt(I,1) = "F"
		        End If
		      Next
		    End If
		    
		    'Extract Compressed items in one script
		    If StoreMode = 0 Then 'Only need to extract when install mode as games are already installed
		      Loading.Status.Text = "Extract Items Data..."
		      Loading.Refresh
		      App.DoEvents(1)
		      ExtractAll
		    End If
		    
		    '------------------------------------------------------------------------- Optimise the Loading of items --------------------------------------------------------------
		    'Load Item Data, Need to Do DB stuff here also
		    Loading.Status.Text = "Adding Items..."
		    Loading.Refresh
		    App.DoEvents(1)
		    If Data.ScanItems.RowCount >=1 Then
		      For I = 0 To Data.ScanItems.RowCount - 1
		        Loading.Status.Text = "Adding Items: "+ Str(I)+"/"+Str(Data.ScanItems.RowCount - 1)
		        Data.ScanItems.CellTagAt(I,0) = GetItem(Data.ScanItems.CellTextAt(I,0), Data.ScanItems.CellTextAt(I,1)) 'The 2nd Part is the TmpFolder stored in the DB if it has Data
		      Next
		    End If
		    
		    'Save DBFiles
		    If Settings.SetUseLocalDBFiles.Value = True Then
		      Loading.Status.Text = "Writing to DB Files..."
		      Loading.Refresh
		      App.DoEvents(1)
		      SaveAllDBs
		    End If
		    
		    ForceRefreshDBs = False
		    
		    'Get online Databases
		    If StoreMode = 0 Then
		      OnlineDBs = LoadDataFromFile(Slash(AppPath)+"LLL_Repos.ini").ReplaceAll(Chr(10), Chr(13)) ' Convert to standard format so it works in Windows and Linux
		      If OnlineDBs.Trim <> "" Then Settings.SetOnlineRepos.Text = OnlineDBs.Trim
		      
		      If Settings.SetUseOnlineRepos.Value = True Then
		        Loading.Status.Text = "Downloading Online Databases..."
		        Loading.Refresh
		        App.DoEvents(1)
		        GetOnlineDBs 'Only do this when in Installation mode
		      End If
		    End If
		    'Disabled Weblinks for now while I find an alternative as google API is blocked by wget for non logged in users.
		    'If StoreMode = 0 Then
		    ''Get Weblinks to use Google etcx to host large files
		    'Loading.Status.Text = "Get Weblinks for large items..."
		    'Loading.Refresh
		    'App.DoEvents(1)
		    'GetWebLinks()
		    'End If
		    
		    'Hide Old Version (Only need to do this once as you load in Items)
		    Loading.Status.Text = "Hiding Old Versions..."
		    Loading.Refresh
		    App.DoEvents(1)
		    HideOldVersions
		    
		    'Check If Items Are Installed
		    Loading.Status.Text = "Checking For Installed Items..."
		    Loading.Refresh
		    App.DoEvents(1)
		    CheckInstalled
		    
		    'Check If Items Are Installed
		    Loading.Status.Text = "Checking For Compatible Items..."
		    Loading.Refresh
		    App.DoEvents(1)
		    CheckCompatible
		    
		    'Get Shortcut Redirects
		    Loading.Status.Text = "Checking Shortcut Redirects..."
		    Loading.Refresh
		    App.DoEvents(1)
		    GetCatalogRedirects
		    
		    'Make the Category list in Data Sections
		    Loading.Status.Text = "Generating Lists..."
		    Loading.Refresh
		    App.DoEvents(1)
		    GenerateDataCategories()
		    Main.GenerateCategories()
		    
		    'Change Categories to All (This Generates the items too)
		    If LastUsedCategory = "" Then
		      Main.ChangeCat("All")
		    Else
		      Dim DidIt As Boolean = False
		      'Select Last Used Category - If Exist
		      For I = 0 To Data.Categories.RowCount - 1
		        If Main.Categories.CellTextAt(I, 0) = LastUsedCategory Then
		          'MsgBox LastUsedCategory
		          Main.ChangeCat(LastUsedCategory)
		          DidIt = True
		          Exit
		        End If
		      Next
		      'If not set then set to All
		      If DidIt = False Then  Main.ChangeCat("All")
		    End If
		    
		    'Load Favorites
		    LoadFavorites()
		    
		    'Last Status 
		    Loading.Status.Text = "Generating GUI..."
		    Loading.Refresh
		    App.DoEvents(1)
		    
		    'Save Debug Of The Scanned Items:
		    If Debugging Then
		      Debug ("--- ITEMS IN DB ---")
		      If Data.Items.RowCount >=1 Then
		        For I = 0 To Data.Items.RowCount - 1
		          Debug("Item "+Str(I)+": "+ Data.Items.CellTextAt(I, Data.GetDBHeader("TitleName"))+" "+Data.Items.CellTextAt(I, Data.GetDBHeader("BuildType")))
		        Next
		        Debug("") 'Adds Blank Line
		      Else
		        Debug("No Items Added To Known Items")
		      End If
		    End If
		    
		    'Load position of main windows or Centre if not set
		    If StoreMode = 0 Or StoreMode = 1 Then Loading.LoadPosition 'Only Load if Store or Launcher
		    
		    If LoadedPosition = False Then 'Only resize to default position if none loaded
		      Main.width=screen(0).AvailableWidth-(screen(0).AvailableWidth/6)
		      Main.height=screen(0).AvailableHeight-(screen(0).AvailableHeight/12)
		      
		      Main.Left = (screen(0).AvailableWidth - Main.Width) / 2
		      Main.top = (screen(0).AvailableHeight - Main.Height) / 2
		    End If
		    
		    'Enable Resize Now, uses timer on main form to draw it properly
		    Main.ResizeMainForm
		    App.DoEvents(1)
		    LoadedMain = True
		    
		    'Do Default Description
		    '-------------
		    #Pragma BreakOnExceptions False
		    AssignedColors = Array( &C80B0FF, &Cff55ff, &CFFFFFF, &CFFFF50, &CAAFF40)
		    
		    Main.Description.Bold = BoldDescription
		    Main.Description.FontName = FontDescription
		    Main.Description.TextColor = ColDescription
		    Main.Description.StyledText.TextColor(0, Len(Main.Description.Text)) = ColDescription 'Make sure it's the right colour in Linux
		    
		    If StoreMode = 1 Then
		      Main.Description.Text = "Select a Game and press Start to Play it, if no games are shown the Launcher only shows items installed with LLStore." +chr(13) +chr(13) _
		      +"If you hold in Shift you can set the Screen Resolution of the game." + chr(13) _
		      + "You can also double click or press Enter to start the selected Game." _
		      + chr(13) +chr(13) + "Press Ctrl + Shift + F4 or Ctrl + Break during game play to exit from most games instantly in LastOSLinux"
		      
		      'Add extras so it shows Scrllbar always
		      If TargetLinux Then Main.Description.Text = Main.Description.Text + Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)
		    Else
		      
		      Dim TriggerWords() As String
		      Dim EndCount As Integer
		      
		      TriggerWords = Array("LLApps","LLGames","ssApps", "ppApps", "ppGames")
		      
		      Main.Description.Text = "Select the Items you wish to install by marking your selection with spacebar, double clicking or using the context menu Selection options." +chr(13) +chr(13) _
		      + "Each Item you click will show its details in this description box." + chr(13)_
		      + "LLApps, LLGames, are Linux items determined by their Location and/or .lla/.llg file, and they are color-coded in the Items list." + chr(13)_
		      + "ssApps, ppApps, and ppGames are Windows/WINE items determined by their Location and/or .app/.ppg file, and they are color-coded in the Items list." _
		      + chr(13) + chr(13) + "Right-click the Items list for a menu that allows you to change Item selection and/or load/save a Preset." _
		      + "  Other options are available." + chr(13) + chr(13) _ 
		      + "LLStore cannot always detect previously installed applications and therefore may not hide these applications from the Items list. Especially when they are tweaks, themes and do not use an installation path" + chr(13) + chr(13) _ 
		      + "LLStore requires an internet connection to show online repositories, only local items will be shown otherwise."
		      
		      'Add extras so it shows Scrllbar always
		      If TargetLinux Then Main.Description.Text = Main.Description.Text + Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)
		      
		      EndCount = UBound(TriggerWords)
		      
		      Main.Description.Bold = BoldDescription
		      Main.Description.FontName = FontDescription
		      Main.Description.TextColor = ColDescription
		      Main.Description.StyledText.TextColor(0, Len(Main.Description.Text)) = ColDescription 'Make sure it's the right colour in Linux
		      
		      Try
		        For I = 0 To EndCount 'Looks complicated, but I got tired of counting characters by hand every time the text was edited :)
		          Main.Description.StyledText.TextColor (Instr (Main.Description.Text, TriggerWords(I)) - 1, Len(TriggerWords(I))) = AssignedColors(I)
		        Next
		      Catch
		      End Try
		      
		    End If
		    #Pragma BreakOnExceptions True
		    '--------------
		    
		    'Load The Preset specified
		    If LoadPresetFile = True Then
		      If CommandLineFile <> "" Then
		        If Not Exist(CommandLineFile) Then
		          Test = Slash(Slash(AppPath)+"Presets")+CommandLineFile
		          If Exist(Test) Then CommandLineFile = Test 'Look in the Presets folder for it
		        End If
		        Success = Main.LoadFromPreset(CommandLineFile)
		        If Success Then
		          If InstallArg = True Then
		            'Hide Loading now it's done
		            Loading.Visible = False
		            App.DoEvents(1)'Make it hide before showing the main form (Less redraw)
		            
		            FirstRun = True 'Set this once everything is done and it's ready to go, used by ChangeItem so the intro isn't erased
		            
		            'Start Installer
		            MiniInstallerShowing = True
		            MiniInstaller.StartInstaller()
		            
		            'Clean up Main so it's ready
		            Main.ResizeMainForm 'Just check again as sometimes it's wrong
		            App.DoEvents(1)'Make sure it draws before doing other stuff that would make it draw ugly
		            
		            Return 'Quit Routine
		          End If
		        End If
		      End If
		    End If
		    
		    'Hide Loading now it's done
		    Loading.Visible = False
		    App.DoEvents(1)'Make it hide before showing the main form (Less redraw)
		    
		    'Show main form
		    Main.Visible = True
		    App.DoEvents(1)'Make sure it draws before doing other stuff that would make it draw ugly
		    Main.ResizeMainForm 'Just check again as sometimes it's wrong
		    App.DoEvents(1)'Make sure it draws before doing other stuff that would make it draw ugly
		    
		    FirstRun = True 'Set this once everything is done and it's ready to go, used by ChangeItem so the intro isn't erased
		    
		  Else
		    ForceQuit = True
		    Main.Close  'Just quit for now, will do editor and installer stuff here
		    
		  End If
		  
		  ForceQuit = False 'Makes everything not close and just hide again, but if you close the loading screen it's forced to quit now
		  
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events DownloadTimer
	#tag Event
		Sub Action()
		  If Debugging Then Debug("- Starting Download Timer -")
		  
		  Dim Test As String
		  Dim I As Integer
		  Dim LocalName As String
		  Dim GetURL As String
		  Dim Prog As String
		  Dim ShowProg As Boolean
		  Dim ProgPerc As String
		  Dim Commands As String
		  
		  Dim theResults As String
		  
		  Dim DownloadShell As New Shell
		  DownloadShell.TimeOut = -1
		  DownloadShell.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  
		  Dim Sh As New Shell
		  Sh.TimeOut = -1
		  Sh.ExecuteMode = Shell.ExecuteModes.Asynchronous
		  
		  'Cleanup
		  If Exist(Slash(RepositoryPathLocal) + "DownloadDone") Then Deltree(Slash(RepositoryPathLocal) + "DownloadDone")
		  If Exist(Slash(RepositoryPathLocal)+"FailedDownload") Then Deltree(Slash(RepositoryPathLocal)+"FailedDownload")
		  
		  QueueUpTo = 0
		  '
		  'DownloadingDone is the gate keeper, it'll make sure only one at a time downloads
		  While QueueUpTo < QueueCount
		    
		    If Exist(QueueLocal(QueueUpTo) + ".partial") Then Deltree(QueueLocal(QueueUpTo) + ".partial")'Removal partial download if exist
		    
		    'Get Weblinks and substitute URL's if found
		    GetURL = QueueURL(QueueUpTo)
		    
		    'Add Weblinks back in to get from there instead of the repo's Glenn 2029
		    If WebLinksCount >= 1 Then
		      For I = 0 To WebLinksCount - 1
		        LocalName = Replace(QueueLocal(QueueUpTo), Slash(RepositoryPathLocal), "") 'Remove Path, just use File Name
		        If WebLinksName(I) = LocalName Then GetURL = WebLinksLink(I) 'Use WebLinks if file name is found in that list
		      Next
		    End If
		    
		    'Check Remote file exist, else it'll fail
		    Test = RunCommandResults("curl --head --silent " + Chr(34) + GetURL + Chr(34))
		    
		    If Debugging Then Debug(">>> Download <<<")
		    If Debugging Then Debug("URL: "+GetURL)
		    If Debugging Then Debug("To: " + QueueLocal(QueueUpTo))
		    If Debugging Then Debug("Results: "+Left(Test,12)) ' Test) '
		    
		    If Trim(Test) = "" Then 'No Internet or very dodgy item, just abort all internet and try the next item that gets sent here
		      SaveDataToFile ("Failed Header Getting : "+GetURL, Slash(RepositoryPathLocal) + "FailedDownload")
		      If Debugging Then Debug ("* Download Error *")
		      If Debugging Then Debug ("Failed Getting Header of: "+GetURL)
		    Else ' Try to get item
		      Test = Left(Test,18) 'Only need the start of the header, the time stamps sometimes have 404 in them
		      If Test.IndexOf("404") >= 0  Then '404 not found in Header result 'And Test.IndexOf("404") <= 18 <- Not needed as I reduce the header to 18 characters
		        If Debugging Then Debug ("* Download Error *")
		        If Debugging Then Debug ("Download Not Found: "+GetURL)
		        Test = ""
		        If Right(GetURL, 4) = ".jpg" Or Right(GetURL, 4) = ".png" Or Right(GetURL, 4) = ".ini" Then
		        Else 'Only show missing for actual Items, not just their screenshots and faders
		          If Not TargetWindows Then RunCommand ("notify-send " + Chr(34) + "Skipping Missing Item: " + GetURL + Chr(34))
		        End If
		        SaveDataToFile ("Failed Finding Remote: "+GetURL, Slash(RepositoryPathLocal) + "FailedDownload")
		      Else ' It exist, download it
		        If Debugging Then Debug ("Start Downloading From: "+GetURL)
		        FailedDownload = False
		        If TargetWindows Then
		          Commands = WinWget + " --tries=6 --timeout=9 -q -O " + Chr(34) + QueueLocal(QueueUpTo) + ".partial" + Chr(34) + " --show-progress " + Chr(34) + GetURL + Chr(34) + " && echo 'done' > " + Slash(RepositoryPathLocal) + "DownloadDone"        
		          If Debugging Then Debug("Command: "+Chr(10)+Commands)
		          DownloadShell.Execute (Commands)
		        Else
		          Commands = LinuxWget + " --tries=6 --timeout=9 -q -O " + Chr(34) + QueueLocal(QueueUpTo) + ".partial" + Chr(34) + " --show-progress " + Chr(34) + GetURL + Chr(34) + " ; echo 'done' > " + Slash(RepositoryPathLocal) + "DownloadDone"        
		          If Debugging Then Debug("Command: "+Chr(10)+Commands)
		          DownloadShell.Execute (Commands)
		        End If
		        
		        DownloadPercentage = "" 'Clear Percentage
		        
		        While Not Exist(Slash(RepositoryPathLocal) + "DownloadDone")
		          App.DoEvents(1)
		          If ForceQuit Then Exit 'Exit loop if quitting 'As the Loading screen allows force quitting, this is a problem, so I disable quitting while it's in use. Needs to be allowed so it quits when switching to Admin mode in Windows.
		          
		          If Exist(Slash(RepositoryPathLocal) + "DownloadDone") Then Exit 'If Shell says done, then exit loop
		          If DownloadShell.IsRunning = False Then Exit 'Disabled for testing purposes
		          
		          'Update Progress
		          If MiniInstallerShowing Then
		            theResults = DownloadShell.ReadAll
		            
		            ProgPerc = Right(theResults, 80)
		            ProgPerc = Left(ProgPerc, ProgPerc.IndexOf("%")+1)
		            ProgPerc = Right(ProgPerc, 6)
		            ProgPerc = ProgPerc.ReplaceAll(".","").Trim
		            
		            If ProgPerc <> "" Then
		              DownloadPercentage = ProgPerc
		            End If
		            MiniInstaller.Stats.Text = "Downloading "+ DownloadPercentage
		          End If
		        Wend
		        
		        'This was due to ForceQuit being enabled in Loading, make sure to remember this bug causing issue next time
		        
		        'For I = 0 To 10 '10 is about 1 second of looking for it
		        'If Exist(QueueLocal(QueueUpTo) + ".partial") Then Exit 'If it is found, stop looking for it
		        'App.DoEvents(100) 'Give it time to make the file exist after it completes, else it detects as not found.
		        'Next
		        
		        If Exist(QueueLocal(QueueUpTo) + ".partial") Then 'If you don't have access to the file then it's better to try to delete it and then not move/overwrite as it asks if you want to try, this stops automation.
		          If Exist(QueueLocal(QueueUpTo)) Then Deltree QueueLocal(QueueUpTo) 'Remove Existing item, only if Partial one is ready to rename
		          
		          If TargetWindows Then
		            Commands = Chr(34) + QueueLocal(QueueUpTo) + ".partial" + Chr(34) + " " + Chr(34) + QueueLocal(QueueUpTo) + Chr(34)
		            Commands = Commands.ReplaceAll("/", "\")'Windows move commands requires backslash's
		            Commands = "move /y " + Commands
		            Sh = New Shell ' Clear previous results
		            Sh.Execute (Commands)
		            While Sh.IsRunning
		              App.DoEvents(1)
		            Wend
		            If Debugging Then Debug ("Move Results: "+ Sh.Result)
		          Else
		            Sh = New Shell ' Clear previous results
		            Sh.Execute ("mv -f " + Chr(34) + QueueLocal(QueueUpTo) + ".partial" + Chr(34) + " " + Chr(34) + QueueLocal(QueueUpTo) + Chr(34))
		            While Sh.IsRunning
		              App.DoEvents(1)
		            Wend
		            If Debugging Then Debug ("Move Results: "+ Sh.Result)
		          End If
		          
		          Deltree(Slash(RepositoryPathLocal) + "DownloadDone")
		          If Debugging Then Debug("Download Detected as Successful")
		        Else 'Failed, Clean Up
		          If Not TargetWindows Then RunCommand ("notify-send " + Chr(34) + "Failed Downloading Item: " + QueueLocal(QueueUpTo) + Chr(34))
		          SaveDataToFile ("Failed Finding Local: "+QueueLocal(QueueUpTo) + ".partial", Slash(RepositoryPathLocal) + "FailedDownload")
		          FailedDownload = True
		          If Debugging Then Debug ("* Download Error *")
		          If Debugging Then Debug("Download Fail Results: " + Chr(10)+theResults)
		        End If
		      End If
		    End If    
		    QueueUpTo = QueueUpTo + 1
		  Wend
		  QueueUpTo = 0
		  QueueCount = 0
		  Downloading = False  
		  'Make sure it's gone
		  If Exist(Slash(RepositoryPathLocal) + "DownloadDone") Then Deltree(Slash(RepositoryPathLocal) + "DownloadDone")
		  
		  If ForceQuit = True Then
		    CleanTemp
		    DebugOutput.Flush 'Write cached data to file
		    DebugOutput.Close 'Close File when quiting
		    Quit 'This is just a precaution for if the wget loop keeps the app from quiting if a problem or forced quit occurs
		  End If
		  
		  'Reload item once queue completes, if not installing items currently
		  If Main.Visible = True Then ' Do only if showing form
		    If Installing = False And Test <> "" Then 
		      ShowDownloadImages
		    End If
		  End If
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events VeryFirstRunTimer
	#tag Event
		Sub Action()
		  App.AllowAutoQuit = True 'Makes it close if no windows are open
		  
		  If ForceQuit = True Then Return 'Don't bother even opening if set to quit
		  
		  VeryFirstRunTimer.RunMode = Timer.RunModes.Off ' Disable this timer again
		  
		  'Get Consts
		  If TargetLinux Then
		    SysDesktopEnvironment = System.EnvironmentVariable("XDG_SESSION_DESKTOP").Lowercase
		    SysPackageManager = ""
		    SysTerminal = ""
		    ManualLocationsFile = "Linux"
		  Else
		    SysDesktopEnvironment = "explorer" 'Windows only uses Explorer
		    SysPackageManager = ""
		    SysTerminal = "cmd "
		    ManualLocationsFile = "Win"
		  End If
		  
		  SysAvailableDesktops = Array("All","All-Linux","Cinnamon","Explorer","Gnome","KDE","LXDE","Mate","Unity","XFCE","cosmic", "ubuntu","LXQt","budgie")
		  SysAvailablePackageManagers = Array("All","apt","apk","dnf","emerge","eopkg","pacman","winget","zypper")
		  SysAvailableArchitectures = Array("All","x86 + x64","x86","x64","ARM")
		  
		  Dim F, G As FolderItem
		  Dim TI As TextInputStream
		  Dim S, Path As String
		  Dim Success As Boolean
		  Dim Build As Boolean = False
		  Dim Compress As Boolean = False
		  
		  Randomiser = New Random 'This Randomizes the timer, to make it truely random
		  
		  'Some of my Shell calls use this for speed and less code, it waits for the command to complete before code continues though, so will tie up the main thread.
		  ShellFast = New Shell ' Just do this once to see if it speeds up loading using the one shell for 7z each time
		  ShellFast.TimeOut = -1 'Give it All the time it needs
		  
		  'Sudo Shell Loop waits forever to run Sudo Tasks without needing to type password constantly
		  SudoShellLoop = New Shell 'Keep the admin shell running /looping until you quit LLStore
		  SudoShellLoop.TimeOut = -1 'Give it All the time it needs
		  SudoShellLoop.ExecuteMode = Shell.ExecuteModes.Asynchronous ' Runs in background
		  
		  'Get App Paths
		  If TargetLinux Then
		    HomePath = Slash(FixPath(SpecialFolder.UserHome.NativePath))
		  Else
		    HomePath = Slash(FixPath(SpecialFolder.UserHome.NativePath))
		  End If
		  
		  CurrentPath =  FixPath(SpecialFolder.CurrentWorkingDirectory.NativePath)
		  F = App.ExecutableFile.Parent
		  Do
		    If Exist(Slash(F.ShellPath) + "Tools") Then
		      AppPath  = F.NativePath
		      Exit Do
		    End If
		    F = F.Parent
		    If F = Nil Then
		      If TargetWindows Then
		        G = GetFolderItem("C:\Windows\LLStore\LLStore.exe",FolderItem.PathTypeShell) 'Pretend path for now, might move it to be system wide tool in System32
		      Else
		        G = GetFolderItem("/bin/llfile",FolderItem.PathTypeShell) 'Hardcoded path, will exist on LastOS's
		      End If
		      If G.Exists Then 'Use LLFile path
		        AppPath = Slash(G.Parent.NativePath)
		        Exit Do 'Exit Loop
		      End If
		    End If
		  Loop
		  
		  If Exist (AppPath+"Tools") Then
		  Else
		    If TargetLinux Then
		      If Exist("/LastOS/LLStore/Tools") Then
		        AppPath = "/LastOS/LLStore/" 'Fall back to this version/path if I can't get the real path (due to using /bin/llfile etc)
		      Else
		        MsgBox "Can't find Tools path, Exiting"
		        Quit
		        Exit
		      End If
		    Else 'Windows
		      If Exist("C:\Program Files\LLStore\Tools") Then
		        AppPath = "C:\Program Files\LLStore\" 'Fall back to this version/path if I can't get the real path
		      Else
		        MsgBox "Can't find Tools path, Exiting"
		        Quit
		        Exit
		      End If
		    End If
		  End If
		  
		  'If TargetLinux Then
		  'ShellFast.Execute("echo "+Chr(34)+AppPath+Chr(34) + " > "+Slash(HomePath)+"Desktop/Debugger2.txt")
		  'End If
		  
		  If TargetWindows Then 'Need to add Windows ppGames and Apps drives here
		    HomePath = Slash(FixPath(SpecialFolder.UserHome.NativePath))
		    RepositoryPathLocal = Slash(HomePath) + "zLastOSRepository/"
		    TmpPath =  Slash(HomePath) + "LLTemp/"
		    
		    'C: for Defaults, only changes if one found to replace with
		    ppGames = "C:/ppGames/"
		    ppApps = "C:/ppApps/"
		    
		    'Get Default Paths
		    LLStoreDrive = Left (AppPath, 2)
		    SysProgramFiles = ReplaceAll(GetLongPath(System.EnvironmentVariable("PROGRAMFILES")), " (x86)", "")
		    SysDrive = Lowercase(System.EnvironmentVariable("SYSTEMDRIVE"))
		    SysRoot = GetLongPath(System.EnvironmentVariable("SYSTEMROOT"))
		    ToolPath = Slash(Slash(AppPath) +"Tools")
		  Else
		    HasLinuxSudo = True 'Default to true so it can call it
		    
		    HomePath = Slash(FixPath(SpecialFolder.UserHome.NativePath))
		    RepositoryPathLocal = Slash(HomePath) + "zLastOSRepository/"
		    TmpPath =  Slash(HomePath) + ".lltemp/"
		    ppGames = Slash(HomePath)+".wine/drive_c/ppGames/"
		    ppApps = Slash(HomePath)+".wine/drive_c/ppApps/"
		    
		    'Get Default Paths
		    LLStoreDrive = "" 'Drive not used by linux
		    SysProgramFiles = "C:/Program Files/"
		    SysDrive = "C:"
		    SysRoot = "C:/Windows/"
		    ToolPath = Slash(Slash(AppPath) +"Tools")
		    ShellFast.Execute(Slash(AppPath)+"Tools/DefaultTerminal.sh")
		    SysTerminal = ShellFast.Result
		    SysTerminal = SysTerminal.ReplaceAll(Chr(10),"")
		    SysTerminal = SysTerminal.ReplaceAll(Chr(13),"")
		    SysTerminal = SysTerminal.ReplaceAll(EndOfLine,"")
		  End If
		  
		  If TargetWindows Then
		    StartPathAll = Slash(FixPath(SpecialFolder.SharedApplicationData.NativePath)) + "Microsoft/Windows/Start Menu/Programs/" 'All Users
		    StartPathUser = Slash(FixPath(SpecialFolder.ApplicationData.NativePath)) + "Microsoft/Windows/Start Menu/Programs/" 'Current User
		  End If
		  
		  'Get ppDrives
		  If TargetWindows Then ' Get the real drives with ppApps/Games etc
		    'Get ppApps and ppGames Default Install locations
		    Try
		      F = GetFolderItem(SysRoot + "/ppAppDrive.ini", FolderItem.PathTypeShell)
		      If F <> Nil And F.Exists Then
		        TI = TextInputStream.Open(F)
		        S = Trim(Left(TI.ReadLine, 2))
		        ppAppsDrive = S
		        TI.Close
		      Else
		        'If LivePE Then ppAppsDrive = SysDrive 'Setting to thie within the LivePE will make all items shown (Ignores if Installed)
		      End If
		    Catch
		    End Try
		    
		    Try
		      F = GetFolderItem(SysRoot + "/ppGameDrive.ini", FolderItem.PathTypeShell)
		      If F <> Nil And F.Exists Then
		        TI = TextInputStream.Open(F)
		        S = Trim(Left(TI.ReadLine, 2))
		        ppGamesDrive = S
		        TI.Close
		      Else
		        'If LivePE Then ppGamesDrive = SysDrive 'Setting to thie within the LivePE will make all items shown (Ignores if Installed)
		      End If
		    Catch
		    End Try
		    
		    If ppAppsDrive = "" Then 'If not set in Above file then scan for existing ones if not in LivePE
		      ppAppsDrive = SysDrive 'Just in case none exist
		      ppAppsDrive = GetExistingppFolder("ppApps")
		    End If
		    If ppGamesDrive = "" Then 'If not set in Above file then scan for existing ones if not in LivePE
		      ppGamesDrive = SysDrive 'Just in case none exist
		      ppGamesDrive = GetExistingppFolder("ppGames")
		    End If
		    
		    ppAppsFolder = ppAppsDrive + "/ppApps/"
		    ppGamesFolder = ppGamesDrive + "/ppGames/"
		  Else 'Linux defaults
		    ppAppsDrive = Slash(HomePath)+".wine/drive_c/"
		    ppGamesDrive = Slash(HomePath)+".wine/drive_c/"
		    ppAppsFolder = Slash(HomePath)+".wine/drive_c/ppApps/"
		    ppGamesFolder = Slash(HomePath)+".wine/drive_c/ppGames/"
		  End If
		  
		  'Make All paths Linux, because they work in Linux and Windows (Except for Move, Copy and Deltree etc)
		  AppPath = AppPath.ReplaceAll("\","/")
		  ToolPath = ToolPath.ReplaceAll("\","/")
		  HomePath = HomePath.ReplaceAll("\","/")
		  RepositoryPathLocal = Slash(RepositoryPathLocal.ReplaceAll("\","/"))
		  TmpPath = TmpPath.ReplaceAll("\","/")
		  ppGames = ppGames.ReplaceAll("\","/")
		  ppApps = ppApps.ReplaceAll("\","/")
		  SysProgramFiles = SysProgramFiles.ReplaceAll("\","/")
		  
		  ppAppsDrive = ppAppsDrive.ReplaceAll("\","/")
		  ppGamesDrive = ppGamesDrive.ReplaceAll("\","/")
		  
		  ppAppsFolder = ppAppsFolder.ReplaceAll("\","/")
		  ppGamesFolder = ppGamesFolder.ReplaceAll("\","/")
		  
		  'Set the folders
		  ppApps = ppAppsFolder
		  ppGames = ppGamesFolder
		  
		  Linux7z = ToolPath + "7zzs"
		  LinuxWget = ToolPath + "wget"
		  Win7z = Chr(34)+ToolPath + "7z.exe"+Chr(34) 'Added " to make it work in paths with spaces?
		  WinWget = Chr(34)+ToolPath + "wget.exe"+Chr(34) 'Added " to make it work in paths with spaces?
		  
		  'Clean Temp folders
		  CleanTemp 'Clearing LLTemp folder entirly
		  If Exist(Slash(RepositoryPathLocal) + "DownloadDone") Then Deltree (Slash(RepositoryPathLocal) + "DownloadDone")
		  
		  'Make Temp Folders (Can NOT use the one to make the temp path it uses to run as a script instead of using a shell. so manual here and below ones (they happen first and should fix the issue using it elsewhere)
		  if TargetWindows then
		    Path = Path.ReplaceAll("/","\")
		    S = "mkdir " + chr(34) + TmpPath + chr(34)
		    ShellFast.Execute (S)
		  Else
		    MakeFolder (TmpPath)
		  End If
		  
		  'Make sure paths exist (But only once per execution)
		  TmpPathItems = Slash(TmpPath)+"items/" 'Use Linux Paths for both OS's
		  if TargetWindows then
		    Path = Path.ReplaceAll("/","\")
		    S = "mkdir " + chr(34) + TmpPathItems + chr(34)
		    ShellFast.Execute (S)
		  Else
		    MakeFolder(TmpPathItems)
		  End If
		  
		  'Make Local paths and Debug File
		  #Pragma BreakOnExceptions Off
		  F = GetFolderItem(Slash(RepositoryPathLocal)+".lldb", FolderItem.PathTypeShell)
		  If Not F.Exists Then
		    Try 
		      MakeFolder(F.NativePath)
		    Catch
		    End Try
		  End If
		  
		  'Enable Debugger
		  Try
		    DebugFileName = Slash(TmpPath)+"DebugLog"+Randomiser.InRange(10000, 20000).ToString+".txt"
		    DebugFile = GetFolderItem(DebugFileName, FolderItem.PathTypeShell)
		    If Exist(DebugFileName) Then
		      Deltree(DebugFileName)
		      DebugOutput = TextOutputStream.open(DebugFile)
		    Else
		      DebugOutput = TextOutputStream.Create(DebugFile)
		    end if
		    DebugFileOk = True
		  Catch
		    Debugging = False
		    DebugFileOk = False
		  End Try
		  
		  #Pragma BreakOnExceptions On
		  
		  'Set Default Settings, these get replaced by the loading of Settings, but we need defaults when there isn't one
		  Settings.SetFlatpakAsUser.Value = True
		  
		  'Centre Form
		  self.Left = (screen(0).AvailableWidth - self.Width) / 2
		  self.top = (screen(0).AvailableHeight - self.Height) / 2
		  
		  'Check the Arguments here and don't show if installer mode or editor etc
		  Dim Args As String
		  Args = System.CommandLine
		  
		  'Pick mode depending on calling name
		  If Args.IndexOf("lllauncher") >= 0 Then
		    StoreMode = 1
		  End If
		  
		  If Args.IndexOf("llfile") >= 0 Then
		    StoreMode = 2
		    InstallArg = True
		  End If
		  
		  If Args.IndexOf("llapp") >= 0 Then
		    StoreMode = 2
		    InstallArg = True
		  End If
		  
		  If Args.IndexOf("llgame") >= 0 Then
		    StoreMode = 2
		    InstallArg = True
		  End If
		  
		  If Args.IndexOf("llinstall") >= 0 Then
		    StoreMode = 2
		    InstallArg = True
		  End If
		  
		  If Args.IndexOf("lledit") >= 0 Then
		    StoreMode = 3
		  End If
		  
		  If Args.IndexOf("llfile") >=0 Then Args = Right(Args,Len(Args)-InStrRev(Args,"llfile",-1)-6) 'Will be 0 if it can't find it, meaning it'll keep tthe whole Argments and File name
		  If Args.IndexOf("llapp") >=0 Then Args = Right(Args,Len(Args)-InStrRev(Args,"llapp",-1)-5)
		  If Args.IndexOf("llgame") >=0 Then Args = Right(Args,Len(Args)-InStrRev(Args,"llgame",-1)-6)
		  If Args.IndexOf("lledit") >=0 Then Args = Right(Args,Len(Args)-InStrRev(Args,"lledit",-1)-6)
		  If Args.IndexOf("llinstall") >=0 Then Args = Right(Args,Len(Args)-InStrRev(Args,"llinstall",-1)-9)
		  If Args.IndexOf("lllauncher") >=0 Then Args = Right(Args,Len(Args)-InStrRev(Args,"lllauncher",-1)-10)
		  If Args.IndexOf("llstore.exe") >=0 Then Args = Right(Args,Len(Args)-InStrRev(Args,"llstore.exe")-11)
		  If Args.IndexOf("llstore") >=0 Then Args = Right(Args,Len(Args)-InStrRev(Args,"llstore",-1)-7)
		  
		  'Cleaning above isn't really required, maybe kill it off once testing is done
		  
		  Dim I As Integer
		  Dim ArgsSP(-1) As String
		  ArgsSP=System.CommandLine.ToArray(" ")
		  CommandLineFile = ""
		  For I = 1 To ArgsSP().Count -1 'Start At 1 as 0 is the Command line calling LLStore, Nope drop back to 0 as it doesn't work from IDE without it
		    
		    Select Case ArgsSP(I).Lowercase.Trim
		      
		    Case "-launcher" , "-l"
		      StoreMode = 1
		    Case "-install", "-i"
		      StoreMode = 2
		      InstallArg = True
		    Case "-edit", "-e"
		      EditorOnly = True
		      StoreMode = 3
		    Case "-build", "-b"
		      StoreMode = 3
		      Build = True
		      EditorOnly = True
		    Case "-compress", "-c"
		      StoreMode = 3
		      Build = True
		      Compress = True
		      EditorOnly = True
		    Case "-preset", "-p"
		      StoreMode = 0
		      LoadPresetFile = True
		    Case "-setup", "-s"
		      StoreMode = 4
		      InstallStore = True
		    Case "-keepsudo", "-ks"
		      KeepSudo = True
		    Case "-quit" , "-q"
		      ForcePostQuit = True
		    Case Else
		      CommandLineFile = CommandLineFile + ArgsSP(I) + " "
		    End Select
		  Next
		  
		  CommandLineFile = CommandLineFile.Trim '(Remove end space)
		  'Remove Flags from name (I also make sure to have a space after each removal as it causes a issue when removes -Build from a folder with the word LastOS-Builder in it for example.
		  CommandLineFile = CommandLineFile.ReplaceAll("-preset ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-p ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-build ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-b ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-compress ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-c ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-install ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-i ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-edit ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-e ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-setup ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-s ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-quit ","")
		  CommandLineFile = CommandLineFile.ReplaceAll("-q ","")
		  
		  CommandLineFile = CommandLineFile.ReplaceAll(Chr(34)+"C:\Program Files\LLStore\llstore.exe"+Chr(34),"") 'Remove dodgy path
		  CommandLineFile = CommandLineFile.ReplaceAll("C:\Program Files\LLStore\llstore.exe","")
		  CommandLineFile = CommandLineFile.ReplaceAll("Files\LLStore\llstore.exe"+Chr(34),"")
		  CommandLineFile = CommandLineFile.ReplaceAll("Files\LLStore\llstore.exe","")
		  CommandLineFile = CommandLineFile.ReplaceAll(" "+Chr(34),Chr(34)) 'If the Loading file has a space after it, it'll have the quote around it, removed.
		  CommandLineFile = CommandLineFile.Trim '(Remove end space)
		  
		  If TargetWindows Then
		    CommandLineFile = CommandLineFile.ReplaceAll("/","\")
		  Else
		    CommandLineFile = CommandLineFile.ReplaceAll("\","/")
		  End If
		  
		  If LoadPresetFile = True Then
		    StoreMode = 0
		  End If
		  
		  'Not Needed move out of GetTheme to here
		  ''Check if CommandLineFile is an actual file and switch to install mode by default, Need to do this here to reduce the occurance of Loading form being shown before it's time
		  'Select Case Right(CommandLineFile, 4)
		  'Case ".apz", ".pgz", ".app",".ppg",".tar",".lla",".llg"
		  'StoreMode = 2 ' This forces it to install ANY viable file regardless of how it's called' I was sick of Nemo etc removing the -i from the command.
		  'End Select
		  
		  Dim RL As String
		  
		  'Get theme
		  GetTheme
		  
		  'Nofications can not be called before here - The theme needs to be loaded in to show Graphics, else it'll just show text
		  'Notify ("This is a long test to see how it goes when you type a really really long status.")
		  
		  'Load Settings - (This is Where the Debugger is activated, else it's not writing until after here)
		  LoadSettings
		  
		  'Get Actual CommandLineFile File if only a Folder is given
		  If CommandLineFile <> "" Then
		    'Remove Quotes that get put on my Nemo etc
		    If Left(CommandLineFile,1) = Chr(34) Then CommandLineFile = CommandLineFile.ReplaceAll(Chr(34),"") 'Remove Quotes from given path entirly
		    
		    'Do I Need to convert ./ to $PWD etc - Glenn 2025 - Yes
		    If TargetLinux Then
		      'If Not Exist (CommandLineFile) Then CommandLineFile = Slash(CurrentPath)+CommandLineFile
		      If Left (CommandLineFile,1) <> "/" Then CommandLineFile = Slash(CurrentPath)+CommandLineFile 'Make sure path is given
		    End If
		    
		    If IsFolder(CommandLineFile) Then
		      CommandLineFile = FixPath(Slash(CommandLineFile))
		      'Check for app files here, if only given the path to an item
		      If Exist (CommandLineFile+"LLApp.lla") Then CommandLineFile = CommandLineFile + "LLApp.lla"
		      If Exist (CommandLineFile+"LLGame.llg") Then CommandLineFile = CommandLineFile + "LLGame.llg"
		      If Exist (CommandLineFile+"ssApp.app") Then CommandLineFile = CommandLineFile + "ssApp.app"
		      If Exist (CommandLineFile+"ppApp.app") Then CommandLineFile = CommandLineFile + "ppApp.app"
		      If Exist (CommandLineFile+"ppGame.ppg") Then CommandLineFile = CommandLineFile + "ppGame.ppg"
		    End If
		  End If
		  
		  'Check if CommandLineFile is an actual file and switch to install mode by default
		  If Build = True Or Compress = True Or EditorOnly = True Then 'This fixes the issue of not compressing etc, installed them instead.
		  Else
		    
		    Select Case Right(CommandLineFile, 4)
		    Case ".apz", ".pgz", ".app",".ppg",".tar",".lla",".llg"
		      StoreMode = 2 ' This forces it to install ANY viable file regardless of how it's called' I was sick of Nemo etc removing the -i from the command.
		    End Select
		  End If
		  
		  'If EditorOnly = True Then StoreMode = 3 ' Editor mode, even though the file above is a file, I never want the store or launcher to start
		  
		  'Show Loading Screen here if the Store Mode is 0
		  If StoreMode = 0 Then Loading.Visible = True 'Show the loading form here
		  
		  'Get Package Manager
		  For I = 0 To SysAvailablePackageManagers.Count -1
		    ShellFast.Execute("which "+SysAvailablePackageManagers(I))
		    If ShellFast.Result <> "" Then
		      SysPackageManager = SysAvailablePackageManagers(I)
		      Exit ' Found It
		    End If
		  Next
		  
		  'Get Systems Arch
		  SysArchitecture = "x64" 'Default
		  If TargetWindows Then
		    '%PROCESSOR_ARCHITEW6432% <- If I have issues change to this and if it's empty it's x86, not sure how it works on ARM yet though.
		    ShellFast.Execute("echo %PROCESSOR_ARCHITECTURE%")
		    If ShellFast.Result = "x86" Then SysArchitecture = "x86"
		    If ShellFast.Result.IndexOf("64") >= 0 Then SysArchitecture = "x64"
		    If Left(ShellFast.Result,3) = "arm" Then SysArchitecture = "ARM"
		  Else
		    ShellFast.Execute("uname -m")
		    If ShellFast.Result = "x86_64" Then SysArchitecture = "x64"
		    If Right(ShellFast.Result,2) = "86" Then SysArchitecture = "x86"
		    If Left(ShellFast.Result,3) = "arm" Then SysArchitecture = "ARM"
		  End If
		  
		  'Check if Online
		  IsOnline = True
		  ShellFast.Execute("curl -fsS http://google.com > /dev/null")
		  If  ShellFast.Result.Trim <> "" Then IsOnline = False
		  
		  If Debugging Then Debug("--- Debugging Starts Here ---")
		  If Debugging Then Debug("Store Mode: "+StoreMode.ToString)
		  If Debugging Then Debug("Online Status: "+IsOnline.ToString)
		  If Debugging Then Debug("AppPath: "+AppPath)
		  If Debugging Then Debug("ToolPath: "+ToolPath)
		  If Debugging Then Debug("TmpPath: "+TmpPath)
		  If Debugging Then Debug("CurrentPath: "+CurrentPath)
		  If Debugging Then Debug("RepositoryPathLocal: "+RepositoryPathLocal)
		  If Debugging Then Debug("WinWget: "+WinWget)
		  If Debugging Then Debug("LinuxWget: "+LinuxWget)
		  If Debugging Then Debug("ppApps: "+ppApps)
		  If Debugging Then Debug("ppGames: "+ppGames+ Chr(10))
		  
		  If Debugging Then Debug("Architecture: "+SysArchitecture)
		  If Debugging Then Debug("Desktop Environment: "+SysDesktopEnvironment)
		  If Debugging Then Debug("Package Manager: "+SysPackageManager)
		  If Debugging Then Debug("Terminal: "+SysTerminal+ Chr(10))
		  
		  If Debugging Then Debug("Args: "+System.CommandLine)
		  If Debugging Then Debug("CommandLineFile: " + CommandLineFile)
		  If Debugging Then Debug("EditorOnly: " + EditorOnly.ToString +" Build: " + Build.ToString +" Compress: " + Compress.ToString)
		  
		  'Move from FirstRunTimer to here
		  GetAdminMode
		  
		  If Debugging Then Debug("Admin Enabled: " + AdminEnabled.ToString)
		  
		  'Install Store Mode
		  If StoreMode = 4 Or InstallStore = True Then
		    InstallLLStore
		    PreQuitApp ' Save Debug etc
		    QuitApp 'Done installing, exit app, no need to continue
		    Return ' Just get out of here once set to show editor
		  End If
		  
		  'Install Item Mode
		  If StoreMode = 2 Then
		    SudoAsNeeded = True 'As your only installing one item, there is no benefit to asking for SUDO if it isn't needed, so don't
		    InstallOnly = True
		    If Debugging Then Debug("--- Install From Commandline ---")
		    #Pragma BreakOnExceptions Off
		    If CommandLineFile <> "" Then
		      If Exist (CommandLineFile) Then 'Install it
		        'MsgBox "Installing: "+ CommandLineFile
		        'Switched to using System Notify as it fails to show before it's extracted the archive, hopefully it works in Windows
		        'Notify ASAP so users knows something is happening
		        'Notify ("LLStore Installing", "Installing:-"+Chr(10)+CommandLineFile, "", -1) 'Mini Installer can't call this and wouldn't want to.
		        'App.DoEvents(7) 'Putting this here to hopefully redraw the Notification window, it only partly draws otherwise
		        
		        
		        Success = InstallLLFile (CommandLineFile)
		        If Success Then 'Worked
		          If Debugging Then Debug("Installed: "+ CommandLineFile)
		        Else 'Failed
		          If Debugging Then Debug("* Error Installing: "+ CommandLineFile)
		        End If
		      End If
		    End If
		    
		    If Not TargetWindows Then 'Only make Sudo in Linux
		      If SudoEnabled = True Then
		        SudoEnabled = False
		        If KeepSudo = False Then ShellFast.Execute ("echo "+Chr(34)+"Unlock"+Chr(34)+" > /tmp/LLSudoDone") 'Quits Terminal after All items have been installed.
		      End If
		    End If
		    PreQuitApp ' Save Debug etc
		    QuitApp 'Done installing, exit app, no need to continue
		    Return ' Just get out of here once set to show editor
		  End If
		  
		  'Editor Mode
		  If StoreMode = 3 Then
		    'MsgBox "Loading: " + CommandLineFile
		    #Pragma BreakOnExceptions Off
		    If CommandLineFile = "" Then
		      Editor.Left = (Screen(0).AvailableWidth/2) - (Editor.Width /2) 'Centered
		      Editor.Top = (Screen(0).AvailableHeight/2) - (Editor.Height /2)
		      Editor.PopulateData
		      Editor.Show
		    Else
		      Success = LoadLLFile(CommandLineFile) ', "", True) 'The true means it extracts all the file contents, we'll just update existing ones if open then saving instead of Extracting the big ones
		      If Success Then 
		        If Build = False Then
		          Editor.Left = (Screen(0).AvailableWidth/2) - (Editor.Width /2) 'Centered
		          Editor.Top = (Screen(0).AvailableHeight/2) - (Editor.Height /2)
		          Editor.PopulateData
		          Editor.Show
		        Else ' Just Build It
		          AutoBuild = True 'Set it to Auto Build and not show a message when complete
		          Editor.PopulateData
		          If Compress = True Then Editor.CheckCompress.Value = True 'Set to Compress if it's in the Arguments
		          Editor.ButtonBuild.Press() 'Press the Build Button with No Compress, if it's not already compressed
		          
		          'Moved Below to Build Button push as I always want to quit the editor after a build
		          'PreQuitApp ' Save Debug etc
		          'QuitApp 'Done installing, exit app, no need to continue
		          
		        End If
		      Else 'Failed to load item, Show Editor
		        Editor.Left = (Screen(0).AvailableWidth/2) - (Editor.Width /2) 'Centered
		        Editor.Top = (Screen(0).AvailableHeight/2) - (Editor.Height /2)
		        Editor.PopulateData
		        Editor.Show
		      End If
		    End If
		    #Pragma BreakOnExceptions On
		    Return ' Just get out of here once set to show editor
		  End If
		  
		  'Using a timer at the end of Form open allows it to display, many events hold off other processes until the complete
		  If StoreMode <=1 Then FirstRunTime.RunMode = Timer.RunModes.Single ' Only show the store in Installer or Launcher modes, else just quit?
		  
		  
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events QuitCheckTimer
	#tag Event
		Sub Action()
		  If ForceQuit = True Then
		    If EditorOnly Then 
		      PreQuitApp
		      QuitApp
		    End If
		  End If
		End Sub
	#tag EndEvent
#tag EndEvents
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
		Name="Interfaces"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
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
		Name="Width"
		Visible=true
		Group="Size"
		InitialValue="600"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Height"
		Visible=true
		Group="Size"
		InitialValue="400"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumWidth"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumHeight"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumWidth"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumHeight"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Type"
		Visible=true
		Group="Frame"
		InitialValue="0"
		Type="Types"
		EditorType="Enum"
		#tag EnumValues
			"0 - Document"
			"1 - Movable Modal"
			"2 - Modal Dialog"
			"3 - Floating Window"
			"4 - Plain Box"
			"5 - Shadowed Box"
			"6 - Rounded Window"
			"7 - Global Floating Window"
			"8 - Sheet Window"
			"9 - Modeless Dialog"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Visible=true
		Group="Frame"
		InitialValue="Untitled"
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasCloseButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMaximizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMinimizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasFullScreenButton"
		Visible=true
		Group="Frame"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Resizeable"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Composite"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MacProcID"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="0"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreen"
		Visible=true
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="DefaultLocation"
		Visible=true
		Group="Behavior"
		InitialValue="2"
		Type="Locations"
		EditorType="Enum"
		#tag EnumValues
			"0 - Default"
			"1 - Parent Window"
			"2 - Main Screen"
			"3 - Parent Window Screen"
			"4 - Stagger"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Visible"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="ImplicitInstance"
		Visible=true
		Group="Window Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasBackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="BackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="&cFFFFFF"
		Type="ColorGroup"
		EditorType="ColorGroup"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Backdrop"
		Visible=true
		Group="Background"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBar"
		Visible=true
		Group="Menus"
		InitialValue=""
		Type="DesktopMenuBar"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBarVisible"
		Visible=true
		Group="Deprecated"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
#tag EndViewBehavior
