#tag Module
Protected Module LLMod_Items
	#tag Property, Flags = &h0
		BlankItem As LLItem
	#tag EndProperty

	#tag Property, Flags = &h0
		BlankItemLnk As LLLnk
	#tag EndProperty

	#tag Property, Flags = &h0
		IconCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ItemFader As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		ItemIcon As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		ItemLLItem As LLItem
	#tag EndProperty

	#tag Property, Flags = &h0
		ItemLnk(128) As LLLnk
	#tag EndProperty

	#tag Property, Flags = &h0
		ItemScreenshot As Picture
	#tag EndProperty


	#tag Structure, Name = LLItem, Flags = &h0
		Additional As String * 1024
		  Arch As String * 32
		  Assembly As String * 2048
		  Builder As String * 64
		  BuildType As String * 16
		  Catalog As String * 2048
		  Categories As String * 128
		  Compressed As Boolean
		  Dependencies As String * 1024
		  Descriptions As String * 8192
		  FileCompressed As Boolean
		  FileFader As String * 1024
		  FileIcon As String * 1024
		  FileINI As String * 2048
		  FileMovie As String * 2048
		  FileScreenshot As String * 2048
		  Flags As String * 2048
		  Hidden As Boolean
		  HiddenAlways As Boolean
		  HideInLauncher As Boolean
		  IconRef As Integer
		  Installed As Boolean
		  InstallSize As Integer
		  KeepAll As Boolean
		  KeepInFolder As Boolean
		  Language As String * 1024
		  License As Integer
		  LnkCount As Integer
		  LnkRef As Integer
		  NoInstall As Boolean
		  OS As String * 2048
		  PathApp As String * 2048
		  PathINI As String * 2048
		  Players As Integer
		  Priority As Integer
		  Publisher As String * 512
		  Rating As Double
		  RefID As Integer
		  ReleaseDate As String * 128
		  ReleaseVersion As String * 64
		  RequiredRuntimes As String * 512
		  Selected As Boolean
		  SendTo As Boolean
		  ShortCutNamesKeep As String * 1024
		  ShowAlways As Boolean
		  ShowSetupOnly As Boolean
		  StartMenuLegacyPrimary As String * 1024
		  StartMenuSourcePath As String * 1024
		  Tags As String * 2048
		  TitleName As String * 1024
		  UniqueName As String * 1024
		  URL As String * 4096
		  Version As String * 256
		  OSCompatible As String * 1024
		  DECompatible As String * 1024
		  PMCompatible As String * 1024
		  ArchCompatible As String * 32
		InternetRequired As Boolean
	#tag EndStructure

	#tag Structure, Name = LLLnk, Flags = &h0
		Active As Boolean
		  Title As String * 1024
		  Comment As String * 512
		  Description As String * 8192
		  Categories As String * 1024
		  RunPath As String * 2048
		  Exec As String * 2048
		  Arguments As String * 1024
		  Flags As String * 1024
		  Associations As String * 512
		  Terminal As Boolean
		  Multiple As Boolean
		  ParentRef As Integer
		  Icon As String * 2048
		  Desktop As Boolean
		  Panel As Boolean
		  Favorite As Boolean
		  LnkOSCompatible As String * 1024
		  LnkDECompatible As String * 1024
		  LnkPMCompatible As String * 1024
		  LnkArchCompatible As String * 32
		LnkSendTo As Boolean
	#tag EndStructure


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
			Name="ItemScreenshot"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ItemIcon"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ItemFader"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
