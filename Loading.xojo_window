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
      TabStop         =   True
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
      Index           =   -2147483648
      LockedInPosition=   False
      Period          =   100
      RunMode         =   0
      Scope           =   0
      TabPanelIndex   =   0
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Function CancelClosing(appQuitting As Boolean) As Boolean
		  If ForceQuit = False Then
		    Me.Hide
		    Return True
		  Else
		    Quit 'Just dump everything ,Loading is the last form we shut and does this step
		    Return False
		  End If
		End Function
	#tag EndEvent

	#tag Event
		Sub Opening()
		  ForceQuit = True 'Enable this when I can so you can close the loading screen to quit the app, else it opens without the loading form
		  
		  
		  'Get Consts
		  If TargetLinux Then
		    SysDesktopEnvironment = System.EnvironmentVariable("XDG_SESSION_DESKTOP").Lowercase
		    SysPackageManager = ""
		    SysTerminal = ""
		  Else
		    SysDesktopEnvironment = "explorer" 'Windows only uses Explorer
		    SysPackageManager = ""
		    SysTerminal = "cmd "
		  End If
		  
		  SysAvailableDesktops = Array("All","Cinnamon","Gnome","KDE","LXDE","Mate","Unity","XFCE")
		  SysAvailablePackageManagers = Array("apt","apk","dnf","emerge","pacman","zypper")
		  SysAvailableArchitectures = Array("x86","x64","arm")
		  
		  'MsgBox  SysDesktopEnvironment
		  
		  Dim F As FolderItem
		  Dim TI As TextInputStream
		  Dim S As String
		  
		  Randomiser = New Random 'This Randomizes the timer, to make it truely random
		  
		  'Some of my Shell calls use this for speed and less code, it waits for the command to complete before code continues though, so will tie up the main thread.
		  ShellFast = New Shell ' Just do this once to see if it speeds up loading using the one shell for 7z each time
		  ShellFast.TimeOut = -1 'Give it All the time it needs
		  
		  'Sudo Shell Loop waits forever to run Sudo Tasks without needing to type password constantly
		  SudoShellLoop = New Shell 'Keep the admin shell running /looping until you quit LLStore
		  SudoShellLoop.TimeOut = -1 'Give it All the time it needs
		  SudoShellLoop.ExecuteMode = Shell.ExecuteModes.Asynchronous ' Runs in background
		  
		  'Get App Paths
		  CurrentPath =  FixPath(SpecialFolder.CurrentWorkingDirectory.NativePath)
		  AppPath = FixPath(App.ExecutableFile.Parent.NativePath)
		  AppPath = Replace(AppPath,"Debugllstore/","") 'Use correct path when running from IDE
		  AppPath = Replace(AppPath,"Debugllstore\","") 'Use correct path when running from IDE in Windows
		  
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
		  Win7z = ToolPath + "7z.exe"
		  WinWget = ToolPath + "wget.exe"
		  
		  #Pragma BreakOnExceptions Off
		  F = GetFolderItem(Slash(RepositoryPathLocal)+".lldb", FolderItem.PathTypeNative)
		  If Not F.Exists Then
		    Try 
		      MakeFolder(F.NativePath)
		    Catch
		    End Try
		  End If
		  #Pragma BreakOnExceptions On
		  
		  'Set Default Settings, these get replaced by the loading of Settings, but we need defaults when there isn't one
		  Settings.SetFlatpakAsUser.Value = True
		  
		  'Clean Temp folders
		  CleanTemp 'Clearing LLTemp folder entirly
		  If Exist(Slash(RepositoryPathLocal) + "DownloadDone") Then Deltree (Slash(RepositoryPathLocal) + "DownloadDone")
		  
		  MakeFolder (TmpPath)
		  
		  'Centre Form
		  self.Left = (screen(0).AvailableWidth - self.Width) / 2
		  self.top = (screen(0).AvailableHeight - self.Height) / 2
		  
		  'Check the Arguments here and don't show if installer mode or editor etc
		  Dim Args As String
		  Args = System.CommandLine
		  Args = Right(Args,Len(Args)-InStrRev(Args,"llstore")-7)
		  Args = Right(Args,Len(Args)-InStrRev(Args,"llstore.exe")-11)
		  
		  'MsgBox Args
		  Dim I As Integer
		  Dim ArgsSP(-1) As String
		  ArgsSP=System.CommandLine.ToArray(" ")
		  For I = 1 To ArgsSP().Count -1 'Start At 1 as 0 is the Command line calling LLStore
		    If ArgsSP(I).Lowercase = "-launcher" Then StoreMode = 1
		  Next
		  
		  'Example of Try event captured
		  'MsgBox Str(Args().Count)
		  Try
		    'MsgBox Args(0)
		    'MsgBox Args(1)
		    'MsgBox Args(2)
		    'MsgBox Args(3)
		    'MsgBox System.CommandLine
		  Catch
		  End Try
		  
		  Dim RL As String
		  
		  'Get theme
		  If StoreMode = 0 Then
		    ThemePath = AppPath+"Themes/Theme.ini"
		    F = GetFolderItem(ThemePath,FolderItem.PathTypeNative)
		    InputStream = TextInputStream.Open(F)
		    RL = InputStream.ReadLine.Trim
		    inputStream.Close
		    ThemePath = AppPath+"Themes/"+RL+"/"
		    LoadTheme (RL)
		    Loading.Visible = True 'Show the loading form here
		  ElseIf StoreMode = 1 Then
		    ThemePath = AppPath+"Themes/ThemeLauncher.ini"
		    F = GetFolderItem(ThemePath,FolderItem.PathTypeNative)
		    InputStream = TextInputStream.Open(F)
		    RL = InputStream.ReadLine.Trim
		    inputStream.Close
		    ThemePath = AppPath+"Themes/"+RL+"/"
		    LoadTheme (RL)
		  End If
		  
		  'Load Settings
		  LoadSettings
		  
		  'Using a timer at the end of Form open allows it to display, many events hold off other processes until the complete
		  FirstRunTime.RunMode = Timer.RunModes.Single
		  
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub CheckInstalled()
		  App.DoEvents(1) 'This makes the Load Screen Update the Status Text, Needs to be in each Function and Sub call
		  
		  DIm I As Integer
		  Dim F As FolderItem
		  
		  'Check if App Path exists
		  For I = 0 To Data.Items.RowCount - 1
		    F = GetFolderItem(ExpPath(Data.Items.CellTextAt(I, Data.GetDBHeader("PathApp"))), FolderItem.PathTypeNative)
		    If F.Exists = True Then Data.Items.CellTextAt(I, Data.GetDBHeader("Installed")) = "T" Else Data.Items.CellTextAt(I, Data.GetDBHeader("Installed")) = "F"
		  Next
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CheckPath(DirToCheck As String)
		  Dim F As FolderItem
		  
		  If TargetWindows Then
		    F = GetFolderItem(DirToCheck.ReplaceAll("/","\"), FolderItem.PathTypeShell)
		  Else
		    F = GetFolderItem(DirToCheck, FolderItem.PathTypeShell)
		  End If
		  If F.IsFolder And F.IsReadable Then
		    Data.ScanPaths.AddRow(FixPath(F.NativePath))
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ExtractAll()
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
		    ItemCount =  Data.Items.RowCount
		    Data.Items.AddRow(Data.Items.RowCount.ToString("000000")) 'This adds the Leading 0's or prefixes it to 6 digits as it sort Alphabettical, fixed 1,10,100,2 to 001,002,010,100 for example
		    
		    'Reference Only
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
		      End Select
		    Next
		    
		  End If
		  
		  'Reference Only
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
		  Dim F As FolderItem
		  Dim DirToCheck As String
		  Dim I As Integer
		  If Inn = "" Then Return
		  Inn = Slash(FixPath(Inn))
		  
		  If ScannedRootFoldersCount >=1 Then 'See if already added and skip it, FIX IT Glenn 2027
		    '- Only add Paths not already added, but I only send through the root, need to check if scanned before, this is broken
		    For I = 1 To ScannedRootFoldersCount
		      If Inn = ScannedRootFolders(I) Then Return 'Skip existing items
		    Next I
		  End If
		  
		  ScannedRootFoldersCount = ScannedRootFoldersCount + 1
		  ScannedRootFolders(ScannedRootFoldersCount) = Inn
		  
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
		  Dim OnlineDBs As String
		  Dim Sp() As String
		  Dim UniqueName As String
		  
		  OnlineDBs = Settings.SetOnlineRepos.Text.ReplaceAll(Chr(10), Chr(13)) ' Convert to standard format so it works in Windows and Linux
		  
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
		  
		  ForceQuit = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetScanPaths()
		  App.DoEvents(1) 'This makes the Load Screen Update the Status Text, Needs to be in each Function and Sub call
		  
		  'For Win
		  Dim Let As Integer
		  Dim I As Integer
		  Dim Item As FolderItem
		  Dim CheckDir As String
		  
		  Dim F, G As FolderItem
		  Dim DirToCheck As String
		  Dim D, E As Integer
		  
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
		        F = GetFolderItem(DirToCheck.ReplaceAll("/","\"), FolderItem.PathTypeShell) 'This fixes the issue 2029, yes whenever windows does folder stuff, convert it back until it returns, or it will add a backslash after the forward slash
		        
		        If F.IsFolder And F.IsReadable Then
		          If F.Count > 0 Then
		            For D = 1 To F.Count
		              item = F.trueItem(D) 'This is the issue Glenn 2029, it returns "D:/\Path/" instead when using "D:/" in path
		              
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
		    If Settings.SetIgnoreCache.Value = False Then
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
		    
		    Dim ManIn As String
		    Dim Sp() As String
		    
		    'Get Manual Locations
		    If Settings.SetUseManualLocations.Value = True Then 'Only use them if set to use them
		      If Exist(Slash(AppPath)+"LLStore_Manual_Locations.ini") Then
		        ManIn = LoadDataFromFile(Slash(AppPath)+"LLStore_Manual_Locations.ini")
		        Sp() = ManIn.Split(Chr(10))
		        If Sp.Count >=1 Then
		          For I = 0 To Sp.Count -1
		            DirToCheck = Sp(I).Trim
		            GetItemsPaths(DirToCheck, True)
		          Next
		        End If
		      End If
		    End If
		    
		    
		  ElseIf StoreMode = 1 Then 'Launcher Mode - Glenn 2027 - Make it check the root folder to LLStore, so can carry on USB stick with installed items to play
		    If TargetLinux Then
		      GetItemsPaths(Slash(HomePath)+"LLGames/", True)
		      GetItemsPaths(Slash(HomePath)+".wine/drive_c/ppGames/", True)
		    ElseIf TargetWindows Then 'Only get Windows Games on Windows, can't run Linux games
		      Let = Asc("C")
		      For I = 0 To 23
		        Let = Asc("C") + I
		        GetItemsPaths(Chr(Let)+":/ppGames/", True)
		      Next I
		      
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HideOldVersions()
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
		    'MsgBox DBRootIn 'Debug Glenn 2027
		  Else
		    F = GetFolderItem(DBRootIn+".lldb/lldb.ini",FolderItem.PathTypeNative)
		  End If
		  
		  If Not F.Exists Then Return 'Dud file, get out of here
		  
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
		Sub LoadSettings()
		  Dim RL As String
		  Dim F As FolderItem
		  
		  SettingsFile = AppPath+"LLStore_Settings.ini"
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
		    Case "uselocaldbs"
		      If LineData <> "" Then Settings.SetUseLocalDBFiles.Value = IsTrue(LineData)
		    Case "copyitemstobuiltrepo"
		      If LineData <> "" Then Settings.SetCopyToRepoBuild.Value = IsTrue(LineData)
		      'Case "ignorecachedrepoitems"
		      'If LineData <> "" Then Settings.SetIgnoreCache.Value = IsTrue(LineData)
		    Case "hideinstalledonstartup"
		      If LineData <> "" Then Settings.SetHideInstalled.Value = IsTrue(LineData)
		    Case "usemanuallocations"
		      If LineData <> "" Then Settings.SetUseManualLocations.Value = IsTrue(LineData)
		    Case "flatpaklocation"
		      If LineData = "User" Then
		        Settings.SetFlatpakAsUser.Value = True
		        Settings.SetFlatpakAsSystem.Value = False
		      Else
		        Settings.SetFlatpakAsUser.Value = False
		        Settings.SetFlatpakAsSystem.Value =  True
		      End If
		    Case "useonlinerepositiories"
		      If LineData <> "" Then Settings.SetUseOnlineRepos.Value = IsTrue(LineData)
		    End Select
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadTheme(ThemeName As String)
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
		  DefaultMainWallpaper = Picture.Open(F)
		  
		  F=GetFolderItem(ThemePath+"Screenshot.jpg", FolderItem.PathTypeShell)
		  ScreenShotCurrent = Picture.Open(F)
		  
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
		    Deltree (DBOutPath+"lldb.ini")
		    'F = GetFolderItem(DBOutPath+"lldb.ini", FolderItem.PathTypeNative)
		    'If F.Exists Then F.Delete 'Remove Existing DB (Will need to test if ReadOnly)
		    OutputStream = TextOutputStream.Open(F)
		    OutputStream.Write (DBOutText)
		    OutputStream.Close
		  Next
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveSettings()
		  Dim RL As String
		  
		  SettingsFile = AppPath+"LLStore_Settings.ini"
		  RL = "[LLStore]" + Chr(10) 'Using a header so I can sort below without having to shufffle the first item, gets ignored
		  
		  RL = RL + "FontSizeCategories=" + Str(Main.Categories.FontSize)+Chr(10)
		  RL = RL + "FontSizeDescription=" + Str(Main.Description.FontSize)+Chr(10)
		  RL = RL + "FontSizeItems=" + Str(Main.Items.FontSize)+Chr(10)
		  RL = RL + "FontSizeMetaData=" + Str(Main.MetaData.FontSize)+Chr(10)
		  RL = RL + "HideInstallerGameCats=" + Str(Settings.SetHideGameCats.Value) + Chr(10)
		  
		  RL = RL + "CheckForUpdates=" + Str(Settings.SetCheckForUpdates.Value) + Chr(10)
		  RL = RL + "QuitOnComplete=" + Str(Settings.SetQuitOnComplete.Value) + Chr(10)
		  RL = RL + "VideoPlayback=" + Str(Settings.SetVideoPlayback.Value) + Chr(10)
		  RL = RL + "VideoVolume=" + Str(Settings.SetVideoVolume.Text) + Chr(10)
		  RL = RL + "UseLocalDBs=" + Str(Settings.SetUseLocalDBFiles.Value) + Chr(10)
		  RL = RL + "CopyItemsToBuiltRepo=" + Str(Settings.SetCopyToRepoBuild.Value) + Chr(10)
		  'RL = RL + "IgnoreCachedRepoItems=" + Str(Settings.SetIgnoreCache.Value) + Chr(10)
		  If Settings.SetFlatpakAsUser.Value = True Then
		    RL = RL + "FlatpakLocation=User"
		  Else
		    RL = RL + "FlatpakLocation=System"
		  End If
		  RL = RL + "HideInstalledOnStartup=" + Str(Settings.SetHideInstalled.Value) + Chr(10)
		  RL = RL + "UseManualLocations=" + Str(Settings.SetUseManualLocations.Value) + Chr(10)
		  RL = RL + "UseOnlineRepositories=" + Str(Settings.SetUseOnlineRepos.Value) + Chr(10)
		  
		  
		  'Save to actual Settings File
		  SaveDataToFile(RL, SettingsFile)
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
		  ForceQuit = True
		  
		  'This disables errors from breaking/debugging in the IDE, disable to debug
		  '# Pragma BreakOnExceptions False
		  
		  'Check If Admin Mode
		  If FirstRun = False Then 'Only check it the first run, else you already quit or decided to run without admin
		    Quitting = False
		    If TargetWindows Then
		      If StoreMode = 0 Then 'If Install Mode then check has Admin
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
		              If StoreMode = 0 Then Ret = MsgBox ("Run LLStore Without Administrator Access", 52)
		              If Ret = 7 Then
		                ForceQuit = True
		                Quitting = True
		                Main.Close
		              End If
		            Else
		              ForceQuit = True
		              Quitting = True
		              Main.Close
		            End If
		          End If
		          
		        End If
		      End If
		    End If
		    
		    If Quitting = True Then Quit ' Make sure nothing happens
		  End If
		  
		  If TargetWindows Then 'Make sure this only happens in Windows or makes random file called %WinDir%...
		    If IsAdmin = True Then AdminEnabled = True
		  End If
		  
		  Dim I As Integer
		  Dim F As FolderItem
		  
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
		    
		    ''Test Downloader
		    'Loading.Status.Text = "Downloading..."
		    'Loading.Refresh
		    'App.DoEvents(1)
		    '
		    ''GetOnlineFile ("https://www.lastos.org/linuxrepo/Unreal.Tournament_v1.0_LLGame.tar","/home/glenn/Desktop/Unreal.Tournament_v1.0_LLGame.tar")
		    'GetOnlineFile ("https://www.lastos.org/linuxrepo/Limbo_LLGame.tar",SpecialFolder.Desktop.NativePath+"/Limbo_LLGame.tar")
		    '
		    'While Downloading 'Wait for Downloading to end
		    'App.DoEvents(5)
		    'Wend
		    '
		    'Loading.Status.Text = "Downloading Done..."
		    'Loading.Refresh
		    'App.DoEvents(1)
		    '
		    'MsgBox ("Done")
		    'Quit
		    
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
		        F = GetFolderItem(Data.ScanPaths.CellTextAt(I,0)+".lldb/lldb.ini",FolderItem.PathTypeNative)
		        If F.Exists And ForceRefreshDBs = False Then
		          LoadDB(Data.ScanPaths.CellTextAt(I,0))
		          Data.ScanPaths.CellTextAt(I,1) = "T"
		        Else 'Scan Items and Save DB Below
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
		    
		    'Save DBFiles (Need to add check it's enabled Glenn 2027)
		    Loading.Status.Text = "Writing to DB Files..."
		    Loading.Refresh
		    App.DoEvents(1)
		    SaveAllDBs
		    
		    ForceRefreshDBs = False
		    
		    'Get online Databases
		    Loading.Status.Text = "Downloading Online Databases..."
		    Loading.Refresh
		    App.DoEvents(1)
		    GetOnlineDBs
		    
		    'Hide Old Version (Only need to do this once as you load in Items)
		    Loading.Status.Text = "Hiding Old Versions..."
		    Loading.Refresh
		    App.DoEvents(1)
		    HideOldVersions
		    
		    'Check If Items Are Installed
		    Loading.Status.Text = "Checking For Installed Iems..."
		    Loading.Refresh
		    App.DoEvents(1)
		    CheckInstalled
		    
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
		    Main.ChangeCat("All")
		    'Main.GenerateItems()
		    
		    'Last Status 
		    Loading.Status.Text = "Generating GUI..."
		    Loading.Refresh
		    App.DoEvents(1)
		    
		    'Centre Main Form (For now, will load in position once stored)
		    Main.width=screen(0).AvailableWidth-(screen(0).AvailableWidth/6)
		    Main.height=screen(0).AvailableHeight-(screen(0).AvailableHeight/12)
		    
		    Main.Left = (screen(0).AvailableWidth - Main.Width) / 2
		    Main.top = (screen(0).AvailableHeight - Main.Height) / 2
		    
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
		      Main.Description.Text = "Select a Game and press Start to Play it" +chr(13) +chr(13) _
		      + "You can also double click or press Enter to start the selected Game" _
		      + chr(13) +chr(13) + "Press Ctrl + Shift + F4 or Ctrl + Break during game play to exit from most games instantly"
		      
		      'Add extras so it shows Scrllbar always
		      If TargetLinux Then Main.Description.Text = Main.Description.Text + Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)+ Chr(13)
		    Else
		      
		      Dim TriggerWords() As String
		      Dim EndCount As Integer
		      
		      TriggerWords = Array("LLApps","LLGames","ssApps", "ppApps", "ppGames")
		      
		      Main.Description.Text = "Select the Items you wish to install by marking your selection." +chr(13) +chr(13) _
		      + "Each Item you click will show its details in this description box." + chr(13)_
		      + "LLApps, LLGames, are Linux items determined by their Location and/or .lla/.llg file, and they are color-coded in the Items list." + chr(13)_
		      + "ssApps, ppApps, and ppGames are Windows/WINE items determined by their Location and/or .app/.ppg file, and they are color-coded in the Items list." _
		      + chr(13) + chr(13) + "Right-click the Items list for a menu that allows you to change Item selection and/or load/save a Preset." _
		      + "  Other options are available." + chr(13) + chr(13) _ 
		      + "LLStore cannot always detect previously installed applications and therefore may not hide these applications from the Items list. Especially when they are tweaks, themes and do not use an installation path"
		      
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
		    'If WebLinksCount >= 1 Then
		    'For I = 0 To WebLinksCount - 1
		    'LocalName = Replace(QueueLocal(QueueUpTo), Slash(RepositoryPathLocal), "") 'Remove Path, just use File Name
		    'If WebLinksName(I) = LocalName Then GetURL = WebLinksLink(I) 'Use WebLinks if file name is found in that list
		    'Next
		    'End If
		    
		    'Check Remote file exist, else it'll fail
		    Test = RunCommandResults("curl --head --silent " + Chr(34) + GetURL + Chr(34))
		    
		    If Trim(Test) = "" Then 'No Internet or very dodgy item, just abort all internet and try the next item that gets sent here
		      SaveDataToFile ("Failed Finding/Getting : "+GetURL, Slash(RepositoryPathLocal) + "FailedDownload")
		    Else ' Try to get item
		      If Test.IndexOf("404") >= 0 Then '404 not found
		        'SaveDataToFile(GetURL+Chr(10)+Test, Slash(SpecialFolder.Desktop.NativePath)+"Debug.txt")
		        Test = ""
		        If Right(GetURL, 4) = ".jpg" Or Right(GetURL, 4) = ".png" Or Right(GetURL, 4) = ".ini" Then
		        Else 'Only show missing for actual Items, not just their screenshots and faders
		          If Not TargetWindows Then RunCommand ("notify-send " + Chr(34) + "Skipping Missing Item: " + GetURL + Chr(34))
		        End If
		        SaveDataToFile ("Failed Finding/Getting : "+GetURL, Slash(RepositoryPathLocal) + "FailedDownload")
		      Else ' It exist, download it
		        'SaveDataToFile(GetURL+Chr(10)+Test, Slash(SpecialFolder.Desktop.NativePath)+"Debug_Worked.txt")
		        
		        FailedDownload = False
		        
		        If TargetWindows Then
		          Commands = LinuxWget + " --tries=6 --timeout=9 -q -O " + Chr(34) + QueueLocal(QueueUpTo) + ".partial" + Chr(34) + " --show-progress " + Chr(34) + GetURL + Chr(34) + " && echo 'done' > " + Slash(RepositoryPathLocal) + "DownloadDone"        
		          'SaveDataToFile (Commands, SpecialFolder.Desktop.NativePath+"Here.cmd")
		          DownloadShell.Execute (Commands)
		        Else
		          Commands = LinuxWget + " --tries=6 --timeout=9 -q -O " + Chr(34) + QueueLocal(QueueUpTo) + ".partial" + Chr(34) + " --show-progress " + Chr(34) + GetURL + Chr(34) + " ; echo 'done' > " + Slash(RepositoryPathLocal) + "DownloadDone"        
		          DownloadShell.Execute (Commands)
		        End If
		        
		        DownloadPercentage = "" 'Clear Percentage
		        
		        While Not Exist(Slash(RepositoryPathLocal) + "DownloadDone")
		          App.DoEvents(1)
		          If ForceQuit Then Exit 'Exit loop if quitting 'As the Loading screen allows force quitting, this is a problem, so I disable quitting while it's in use. Needs to be allowed so it quits when switching to Admin mode in Windows.
		          
		          If Exist(Slash(RepositoryPathLocal) + "DownloadDone") Then Exit 'If Shell says done, then exit loop
		          If DownloadShell.IsRunning = False Then Exit 'Disabled for testing purposes
		          
		          'Update Progress
		          If MiniInstaller.Visible Then
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
		        
		        If Exist(QueueLocal(QueueUpTo) + ".partial") Then 'If you don't have access to the file then it's better to try to delete it and then not move/overwrite as it asks if you want to try, this stops automation.
		          If Exist(QueueLocal(QueueUpTo)) Then Deltree QueueLocal(QueueUpTo) 'Remove Existing item, only if Partial one is ready to rename
		          
		          If TargetWindows Then
		            Commands = Chr(34) + QueueLocal(QueueUpTo) + ".partial" + Chr(34) + " " + Chr(34) + QueueLocal(QueueUpTo) + Chr(34)
		            Commands = Commands.ReplaceAll("/", "\")'Windows move commands requires backslash's
		            Commands = "move /y " + Commands
		            'SaveDataToFile (Commands, SpecialFolder.Desktop.NativePath+"Here.cmd")
		            Sh.Execute (Commands)
		            While Sh.IsRunning
		              App.DoEvents(1)
		            Wend
		          Else
		            RunCommand ("mv -f " + Chr(34) + QueueLocal(QueueUpTo) + ".partial" + Chr(34) + " " + Chr(34) + QueueLocal(QueueUpTo) + Chr(34))
		          End If
		          
		          Deltree(Slash(RepositoryPathLocal) + "DownloadDone")
		        Else 'Failed, Clean Up
		          If Not TargetWindows Then RunCommand ("notify-send " + Chr(34) + "Failed Downloading Item: " + QueueLocal(QueueUpTo) + Chr(34))
		          SaveDataToFile ("Failed Finding/Getting : "+GetURL, Slash(RepositoryPathLocal) + "FailedDownload")
		          FailedDownload = True
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
