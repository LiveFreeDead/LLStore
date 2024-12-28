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
		    
		    CreateShortcut("LLInstall", Target, TargetPath, OutPath, "-i")
		    CreateShortcut("LLEdit", Target, TargetPath, OutPath, "-e")
		    CreateShortcut("LLEdit (AutoBuild Archive)", Target, TargetPath, OutPath, "-c")
		    CreateShortcut("LLEdit (AutoBuild Folder)", Target, TargetPath, OutPath, "-b")
		    
		    'Make .apz, .pgz, .app and .ppg associations.
		    MakeFileType("LLStore", "apz pgz app ppg", "LLStore File", Target, TargetPath, Target, "-i ") '2nd Target is the icon, The -i allows it to install default
		    
		    
		  Else
		    MainPath = MainPath.ReplaceAll("\","/")
		    InstallPath = "/LastOS/LLStore/"
		    EnableSudoScript
		    RunSudo("mkdir -p "+Chr(34)+InstallPath+Chr(34))
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
