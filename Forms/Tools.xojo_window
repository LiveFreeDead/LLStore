#tag DesktopWindow
Begin DesktopWindow Tools
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   False
   HasMaximizeButton=   False
   HasMinimizeButton=   True
   Height          =   400
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   ""
   MenuBarVisible  =   False
   MinimumHeight   =   64
   MinimumWidth    =   64
   Resizeable      =   False
   Title           =   "LLStore Tools"
   Type            =   0
   Visible         =   False
   Width           =   600
   Begin DesktopButton InstallLLStore
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "Install LLStore"
      Default         =   True
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   40
      Index           =   -2147483648
      Italic          =   False
      Left            =   470
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   "Install LLStore to the current OS"
      Top             =   349
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   120
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
		    Return False
		  End If
		End Function
	#tag EndEvent

	#tag Event
		Sub Closing()
		  Debug("-- Tools Closed")
		End Sub
	#tag EndEvent


#tag EndWindowCode

#tag Events InstallLLStore
	#tag Event
		Sub Pressed()
		  Dim InstallPath As String
		  Dim MainPath As String = Slash(AppPath)
		  Dim Res As String
		  Dim TargetPath As String
		  Dim Target As String
		  Dim OutPath As String
		  
		  If TargetWindows Then
		    If Debugging Then Debug ("--- Installing LLStore in Windows ---")
		    MainPath = MainPath.ReplaceAll("/","\")
		    InstallPath = Slash(SpecialFolder.Applications.NativePath) + "\LLStore\"
		    InstallPath = InstallPath.ReplaceAll("/","\")
		    MakeFolder(InstallPath+"llstore Libs")
		    XCopy(MainPath+"llstore Libs", InstallPath+"llstore Libs\")
		    MakeFolder(InstallPath+"llstore Resources")
		    XCopy(MainPath+"llstore Resources", InstallPath+"llstore Resources\")
		    MakeFolder(InstallPath+"Presets")
		    XCopy(MainPath+"Presets", InstallPath+"Presets\")
		    MakeFolder(InstallPath+"Themes")
		    XCopy(MainPath+"Themes", InstallPath+"Themes\")
		    MakeFolder(InstallPath+"Tools")
		    XCopy(MainPath+"Tools", InstallPath+"Tools\")
		    XCopyFile(MainPath+"*.dll", InstallPath)
		    XCopyFile(MainPath+"version.ini", InstallPath)
		    XCopyFile(MainPath+"LLL_Settings.ini", InstallPath)
		    XCopyFile(MainPath+"llstore.exe", InstallPath)
		    XCopyFile(MainPath+"llstore", InstallPath)
		    Res = RunCommandResults ("icacls "+Chr(34)+ NoSlash(InstallPath)+Chr(34)+ " /grant "+ "Users:F /t /c /q") 'Using Chr(10) instead of ; as scripts don't allow them, only the prompt does
		    
		    'Make Shortcuts to SendTo and Start Menu
		    TargetPath = "C:\Program Files\LLStore"
		    Target = TargetPath +"\llstore.exe"
		    OutPath = Slash(SpecialFolder.ApplicationData.NativePath).ReplaceAll("/","\") + "Microsoft\Windows\SendTo\"
		    
		    'Send To
		    CreateShortcut("LL Install", Target, TargetPath, OutPath, "-i")
		    CreateShortcut("LL Edit", Target, TargetPath, OutPath, "-e", TargetPath +"\Themes\LLEdit.ico")
		    CreateShortcut("LL Edit (AutoBuild Archive)", Target, TargetPath, OutPath, "-c", TargetPath +"\Themes\LLEdit.ico")
		    CreateShortcut("LL Edit (AutoBuild Folder)", Target, TargetPath, OutPath, "-b", TargetPath +"\Themes\LLEdit.ico")
		    
		    'Start Menu
		    OutPath = Slash(SpecialFolder.ApplicationData.NativePath).ReplaceAll("/","\") + "Microsoft\Windows\Start Menu\Programs\"
		    CreateShortcut("LL Edit", Target, TargetPath, OutPath, "-e", TargetPath +"\Themes\LLEdit.ico")
		    CreateShortcut("LL Store", Target, TargetPath, OutPath, "")
		    CreateShortcut("LL Launcher", Target, TargetPath, OutPath, "-l", TargetPath +"\Themes\LLLauncher.ico") 'Specifying the Icon is required for making the Launcher Blue
		    
		    'Desktop
		    OutPath = Slash(SpecialFolder.Desktop.NativePath).ReplaceAll("/","\")
		    CreateShortcut("LL Store", Target, TargetPath, OutPath, "")
		    CreateShortcut("LL Launcher", Target, TargetPath, OutPath, "-l", TargetPath +"\Themes\LLLauncher.ico") 'Specifying the Icon is required for making the Launcher Blue
		    
		    
		    'Make .apz, .pgz, .app and .ppg associations.
		    MakeFileType("LLStore", "apz pgz app ppg", "LLStore File", Target, TargetPath, Target, "-i ") '2nd Target is the icon, The -i allows it to install default
		    
		    Tools.Hide
		  Else
		    If Debugging Then Debug ("--- Installing LLStore in Linux ---")
		    MainPath = MainPath.ReplaceAll("\","/")
		    InstallPath = "/LastOS/LLStore/"
		    Target = InstallPath+"llstore"
		    'If Not Exist(InstallPath) Then 'Only do this if required
		    EnableSudoScript
		    RunSudo("mkdir -p "+Chr(34)+InstallPath+Chr(34)+ " ; " + "chmod -R 777 "+Chr(34)+InstallPath+Chr(34))
		    'End If
		    
		    ShellFast.Execute("cp -R "+Chr(34)+MainPath+"llstore Libs"+Chr(34)+" "+Chr(34)+InstallPath+Chr(34))
		    ShellFast.Execute("cp -R "+Chr(34)+MainPath+"llstore Resources"+Chr(34)+" "+Chr(34)+InstallPath+Chr(34))
		    ShellFast.Execute("cp -R "+Chr(34)+MainPath+"Presets"+Chr(34)+" "+Chr(34)+InstallPath+Chr(34))
		    ShellFast.Execute("cp -R "+Chr(34)+MainPath+"Themes"+Chr(34)+" "+Chr(34)+InstallPath+Chr(34))
		    ShellFast.Execute("cp -R "+Chr(34)+MainPath+"Tools"+Chr(34)+" "+Chr(34)+InstallPath+Chr(34))
		    ShellFast.Execute("cp "+Chr(34)+MainPath+Chr(34)+"*.dll"+" "+Chr(34)+InstallPath+Chr(34))
		    ShellFast.Execute("cp "+Chr(34)+MainPath+"version.ini"+Chr(34)+" "+Chr(34)+InstallPath+Chr(34))
		    ShellFast.Execute("cp "+Chr(34)+MainPath+"LLL_Settings.ini"+Chr(34)+" "+Chr(34)+InstallPath+Chr(34))
		    ShellFast.Execute("cp "+Chr(34)+MainPath+"llstore.exe"+Chr(34)+" "+Chr(34)+InstallPath+Chr(34))
		    ShellFast.Execute("cp "+Chr(34)+MainPath+"llstore"+Chr(34)+" "+Chr(34)+InstallPath+Chr(34))
		    
		    RunSudo("chmod -R 777 "+Chr(34)+InstallPath+Chr(34)) 'Make all executable
		    
		    Dim Bin As String = " /usr/bin/" 'Make sure to include the space at the start of this as it's used.
		    
		    'Make SymLinks to Store
		    RunSudo("ln -sf "+Target+Bin+"llapp ; ln -sf "+Target+Bin+"lledit ; ln -sf "+Target+Bin+"llfile ; ln -sf "+Target+Bin+"llinstall ; ln -sf "+Target+Bin+"lllauncher ; ln -sf "+Target+Bin+"llstore" ) 'Sym Links do not need to be set to Exec
		    
		    'Make Associations
		    MakeFileType("LLFile", "apz pgz tar app ppg lla llg", "Install LLFiles", Target, InstallPath, InstallPath+"llstore Resources/appicon_48.png")
		    
		    'Make Shortcuts
		    Dim DesktopContent As String
		    Dim DesktopFile As String
		    Dim DesktopOutPath As String
		    
		    'Store
		    DesktopContent = "[Desktop Entry]" + Chr(10)
		    DesktopContent = DesktopContent + "Type=Application" + Chr(10)
		    DesktopContent = DesktopContent + "Version=1.0" + Chr(10)
		    DesktopContent = DesktopContent + "Name=LL Store" + Chr(10)
		    DesktopContent = DesktopContent + "Exec=llstore" + Chr(10)
		    DesktopContent = DesktopContent + "Comment=Install LLFiles" + Chr(10)
		    DesktopContent = DesktopContent + "Icon=" + InstallPath+"llstore Resources/appicon_48.png" + Chr(10)
		    DesktopContent = DesktopContent + "Categories=Application;System;Settings;XFCE;X-XFCE-SettingsDialog;X-XFCE-SystemSettings;" + Chr(10)
		    DesktopContent = DesktopContent + "Terminal=No" + Chr(10)
		    
		    DesktopFile = "llstore.desktop"
		    DesktopOutPath = Slash(HomePath)+".local/share/applications/"
		    SaveDataToFile(DesktopContent, DesktopOutPath+DesktopFile)
		    ShellFast.Execute ("chmod 775 "+Chr(34)+DesktopOutPath+DesktopFile+Chr(34)) 'Change Read/Write/Execute to defaults
		    
		    DesktopOutPath = Slash(HomePath)+"Desktop/"
		    SaveDataToFile(DesktopContent, DesktopOutPath+DesktopFile)
		    ShellFast.Execute ("chmod 775 "+Chr(34)+DesktopOutPath+DesktopFile+Chr(34)) 'Change Read/Write/Execute to defaults
		    
		    'Editor
		    DesktopContent = "[Desktop Entry]" + Chr(10)
		    DesktopContent = DesktopContent + "Type=Application" + Chr(10)
		    DesktopContent = DesktopContent + "Version=1.0" + Chr(10)
		    DesktopContent = DesktopContent + "Name=LL Editor" + Chr(10)
		    DesktopContent = DesktopContent + "Exec=llstore -e" + Chr(10)
		    DesktopContent = DesktopContent + "Comment=Edit LLFiles" + Chr(10)
		    DesktopContent = DesktopContent + "Icon=" + InstallPath+"Themes/LLEditor.png" + Chr(10)
		    DesktopContent = DesktopContent + "Categories=Application;System;Settings;XFCE;X-XFCE-SettingsDialog;X-XFCE-SystemSettings;" + Chr(10)
		    DesktopContent = DesktopContent + "Terminal=No" + Chr(10)
		    
		    DesktopFile = "lledit.desktop"
		    DesktopOutPath = Slash(HomePath)+".local/share/applications/"
		    SaveDataToFile(DesktopContent, DesktopOutPath+DesktopFile)
		    ShellFast.Execute ("chmod 775 "+Chr(34)+DesktopOutPath+DesktopFile+Chr(34)) 'Change Read/Write/Execute to defaults
		    
		    
		    'Launcher
		    DesktopContent = "[Desktop Entry]" + Chr(10)
		    DesktopContent = DesktopContent + "Type=Application" + Chr(10)
		    DesktopContent = DesktopContent + "Version=1.0" + Chr(10)
		    DesktopContent = DesktopContent + "Name=LL Launcher" + Chr(10)
		    DesktopContent = DesktopContent + "Exec=llstore -l" + Chr(10)
		    DesktopContent = DesktopContent + "Comment=Launch LLStore games" + Chr(10)
		    DesktopContent = DesktopContent + "Icon=" + InstallPath+"Themes/LLLauncher.png" + Chr(10)
		    DesktopContent = DesktopContent + "Categories=Game;" + Chr(10)
		    DesktopContent = DesktopContent + "Terminal=No" + Chr(10)
		    
		    DesktopFile = "lllauncher.desktop"
		    DesktopOutPath = Slash(HomePath)+".local/share/applications/"
		    SaveDataToFile(DesktopContent, DesktopOutPath+DesktopFile)
		    ShellFast.Execute ("chmod 775 "+Chr(34)+DesktopOutPath+DesktopFile+Chr(34)) 'Change Read/Write/Execute to defaults
		    
		    DesktopOutPath = Slash(HomePath)+"Desktop/"
		    SaveDataToFile(DesktopContent, DesktopOutPath+DesktopFile)
		    ShellFast.Execute ("chmod 775 "+Chr(34)+DesktopOutPath+DesktopFile+Chr(34)) 'Change Read/Write/Execute to defaults
		    
		    
		    'Close Sudo Terminal
		    'Make sure Sudo is closed (not added ability to echo to /tmp/LLSudo to close it yet, so disabled) Glenn 2029
		    If Not TargetWindows Then 'Only make Sudo in Linux
		      If SudoEnabled = True Then
		        SudoEnabled = False
		        ShellFast.Execute ("echo "+Chr(34)+"Unlock"+Chr(34)+" > /tmp/LLSudoDone") 'Quits Terminal after All items have been installed.
		      End If
		    End If
		    Tools.Hide
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
