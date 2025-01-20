#tag Module
Protected Module LLDownloader
	#tag Method, Flags = &h0
		Sub Download(InURL As String, OutFile As String)
		  'Dim http As New HTTPSocket
		  'Dim f as FolderItem = GetFolderItem(OutFile, FolderItem.PathTypeShell)
		  'http.Get(InURL, f)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetOnlineFile(URL As String, OutPutFile As String)
		  Dim I As Integer
		  If QueueCount >= 1 Then 'Testing if this causes issues
		    For I = 0 To QueueCount - 1
		      If QueueURL(I) = URL Then Return 'Skip existing URL download already queued up
		    Next
		  End If
		  QueueURL(QueueCount) = URL
		  QueueLocal(QueueCount) = OutPutFile
		  QueueCount = QueueCount + 1
		  If Downloading = False Then
		    Downloading = True 'Do this ASAP, so the check is in place as soon as it's sent (as most wont have a wait at the end of the shell calls)  
		    Loading.DownloadTimer.RunMode = Timer.RunModes.Single  'Only call it if it's finnished, else it'll pick up the changes at runtime
		  End If
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		CurrentDBURL As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Downloading As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		DownloadPercentage As String
	#tag EndProperty

	#tag Property, Flags = &h0
		FailedDownload As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		QueueCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		QueueLocal(1024) As String
	#tag EndProperty

	#tag Property, Flags = &h0
		QueueUpTo As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		QueueURL(1024) As String
	#tag EndProperty

	#tag Property, Flags = &h0
		WebLinksCount As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		WebLinksLink(2048) As String
	#tag EndProperty

	#tag Property, Flags = &h0
		WebLinksName(2048) As String
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
			Name="FailedDownload"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Downloading"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="DownloadPercentage"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="QueueCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="QueueUpTo"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CurrentDBURL"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="WebLinksCount"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
