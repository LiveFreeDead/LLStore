#tag Module
Protected Module MdlShellExecuteInfoEx
	#tag Method, Flags = &h0
		Function IsUnicode() As Boolean
		  //This performs a test to determine if the computer is unicode (W) or (ANSI)
		  #If TargetWindows
		    Soft Declare function GetDefaultPrinterW Lib "Winspool.drv" (pszBuffer as Ptr, ByRef pcchBuffer as UInt32) as Integer
		    If System.IsFunctionAvailable("GetDefaultPrinterW", "Winspool.drv") Then
		      Return True //Yes, it is Unicode
		    Else
		      Return False //No, it is not unicode
		    End If
		  #EndIf
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ShellExecuteEx(fMask as UInt32, hWnd as Integer, lpVerb as Ptr, lpFile as Ptr, lpParameters as Ptr, lpDirectory as Ptr, nShow as Int32, hInstApp as Integer, lpIDList as Ptr, lpClass as Ptr, hKeyClass as Integer, dwHotKey as UInt32, hIcon as Integer, hProcess as Integer) As Boolean
		  #If TargetWindows then
		    If IsUnicode Then
		      #If Target32Bit 
		        Dim TmpShExInfoW as SHELLEXECUTEINFOW32
		        TmpShExInfoW.cbSize = TmpShExInfoW.Size
		        TmpShExInfoW.fMask = fMask
		        TmpShExInfoW.hWnd = hWnd //Window handle
		        TmpShExInfoW.lpVerb = lpVerb //Operation to perform
		        TmpShExInfoW.lpFile = lpFile //Application name 
		        TmpShExInfoW.lpParameters = lpParameters //Additional Parameters
		        TmpShExInfoW.lpDirectory = lpDirectory //Working Directory
		        TmpShExInfoW.nShow = nShow
		        TmpShExInfoW.hInstApp = hInstApp
		        TmpShExInfoW.lpIDList = lpIDList
		        TmpShExInfoW.lpClass = lpClass
		        TmpShExInfoW.hKeyClass = hKeyClass
		        TmpShExInfoW.dwHotKey = dwHotKey
		        TmpShExInfoW.hIcon = hIcon
		        TmpShExInfoW.hProcess = hProcess
		        Return ShellExecuteExW32(TmpShExInfoW)
		      #Else
		        Dim TmpShExInfoW as SHELLEXECUTEINFOW64
		        TmpShExInfoW.cbSize = TmpShExInfoW.Size
		        TmpShExInfoW.fMask = fMask
		        TmpShExInfoW.hWnd = hWnd //Window handle
		        TmpShExInfoW.lpVerb = lpVerb //Operation to perform
		        TmpShExInfoW.lpFile = lpFile //Application name 
		        TmpShExInfoW.lpParameters = lpParameters //Additional Parameters
		        TmpShExInfoW.lpDirectory = lpDirectory //Working Directory
		        TmpShExInfoW.nShow = nShow
		        TmpShExInfoW.hInstApp = hInstApp
		        TmpShExInfoW.lpIDList = lpIDList
		        TmpShExInfoW.lpClass = lpClass
		        TmpShExInfoW.hKeyClass = hKeyClass
		        TmpShExInfoW.dwHotKey = dwHotKey
		        TmpShExInfoW.hIcon = hIcon
		        TmpShExInfoW.hProcess = hProcess
		        Return ShellExecuteExW64(TmpShExInfoW)
		      #Endif
		    Else
		      #If Target32Bit //ANSI 32-bit
		        Dim TmpShExInfoA as SHELLEXECUTEINFOA32
		        TmpShExInfoA.cbSize = TmpShExInfoA.Size
		        TmpShExInfoA.fMask = fMask
		        TmpShExInfoA.hWnd = hWnd //Window handle
		        TmpShExInfoA.lpVerb = lpVerb //Operation to perform
		        TmpShExInfoA.lpFile = lpFile //Application name 
		        TmpShExInfoA.lpParameters = lpParameters //Additional Parameters
		        TmpShExInfoA.lpDirectory = lpDirectory //Working Directory
		        TmpShExInfoA.nShow = nShow
		        TmpShExInfoA.hInstApp = hInstApp
		        TmpShExInfoA.lpIDList = lpIDList
		        TmpShExInfoA.lpClass = lpClass
		        TmpShExInfoA.hKeyClass = hKeyClass
		        TmpShExInfoA.dwHotKey = dwHotKey
		        TmpShExInfoA.hIcon = hIcon
		        TmpShExInfoA.hProcess = hProcess
		        Return ShellExecuteExA32(TmpShExInfoA)
		      #Else
		        Dim TmpShExInfoA as SHELLEXECUTEINFOA64
		        TmpShExInfoA.cbSize = TmpShExInfoA.Size
		        TmpShExInfoA.fMask = fMask
		        TmpShExInfoA.hWnd = hWnd //Window handle
		        TmpShExInfoA.lpVerb = lpVerb //Operation to perform
		        TmpShExInfoA.lpFile = lpFile //Application name 
		        TmpShExInfoA.lpParameters = lpParameters //Additional Parameters
		        TmpShExInfoA.lpDirectory = lpDirectory //Working Directory
		        TmpShExInfoA.nShow = nShow
		        TmpShExInfoA.hInstApp = hInstApp
		        TmpShExInfoA.lpIDList = lpIDList
		        TmpShExInfoA.lpClass = lpClass
		        TmpShExInfoA.hKeyClass = hKeyClass
		        TmpShExInfoA.dwHotKey = dwHotKey
		        TmpShExInfoA.hIcon = hIcon
		        TmpShExInfoA.hProcess = hProcess
		        Return ShellExecuteExA64(TmpShExInfoA)
		      #Endif
		    End If
		  #Else
		    //System.DebugLog "This is not a Windows OS"
		    Return False
		  #Endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ShellExecuteExA32(ByRef pExecInfo as SHELLEXECUTEINFOA32) As Boolean
		  #If TargetWindows
		    Declare Function ShellExecuteExA Lib "Shell32.dll" (ByRef pExecInfo as SHELLEXECUTEINFOA32) as Boolean
		    If System.IsFunctionAvailable("ShellExecuteExA","Shell32.dll") Then
		      Return ShellExecuteExA(pExecInfo)
		    Else
		      System.DebugLog "Error calling ShellExecuteExA32"
		      Return False
		    End If
		  #Else
		    //System.DebugLog "This is not a Windows OS"
		    Return False
		  #Endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ShellExecuteExA64(ByRef pExecInfo as SHELLEXECUTEINFOA64) As Boolean
		  #If TargetWindows
		    Declare Function ShellExecuteExA Lib "Shell32.dll" (ByRef pExecInfo as SHELLEXECUTEINFOA64) as Boolean
		    If System.IsFunctionAvailable("ShellExecuteExA","Shell32.dll") Then
		      Return ShellExecuteExA(pExecInfo)
		    Else
		      System.DebugLog "Error calling ShellExecuteExA64"
		      Return False
		    End If
		  #Else
		    //System.DebugLog "This is not a Windows OS"
		    Return False
		  #Endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ShellExecuteExW32(ByRef pExecInfo as SHELLEXECUTEINFOW32) As Boolean
		  #If TargetWindows
		    Declare Function ShellExecuteExW Lib "Shell32.dll" (ByRef pExecInfo as SHELLEXECUTEINFOW32) as Boolean
		    If System.IsFunctionAvailable("ShellExecuteExW","Shell32.dll") Then
		      Return ShellExecuteExW(pExecInfo)
		    Else
		      System.DebugLog "Error calling ShellExecuteExW32"
		      Return False
		    End If
		  #Else
		    //System.DebugLog "This is not a Windows OS"
		    Return False
		  #Endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ShellExecuteExW64(ByRef pExecInfo as SHELLEXECUTEINFOW64) As Boolean
		  #If TargetWindows
		    Declare Function ShellExecuteExW Lib "Shell32.dll" (ByRef pExecInfo as SHELLEXECUTEINFOW64) as Boolean
		    If System.IsFunctionAvailable("ShellExecuteExW","Shell32.dll") Then
		      Return ShellExecuteExW(pExecInfo)
		    Else
		      System.DebugLog "Error calling ShellExecuteExW64"
		      Return False
		    End If
		  #Else
		    //System.DebugLog "This is not a Windows OS"
		    Return False
		  #Endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringToMB(MyString as String) As MemoryBlock
		  Dim mb32 as New MemoryBlock(256)
		  Dim mb64 as New MemoryBlock(512)
		  
		  #If TargetWindows
		    #If Target64Bit //64 bit
		      If IsUnicode then
		        mb64.WString(0) = MyString
		        Return mb64
		      Else
		        mb64.CString(0) = MyString
		        Return mb64
		      End If
		    #Else //32 bit
		      If IsUnicode then
		        mb32.WString(0) = MyString
		        Return mb32
		      Else
		        mb32.CString(0) = MyString
		        Return mb32
		      End If
		    #Endif
		  #Else
		    //System.DebugLog "This is not a Windows OS"
		    Return nil
		  #Endif
		End Function
	#tag EndMethod


	#tag Constant, Name = SEE_MASK_ASYNCOK, Type = Double, Dynamic = False, Default = \"&H00100000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_CLASSKEY, Type = Double, Dynamic = False, Default = \"&H00000003", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_CLASSNAME, Type = Double, Dynamic = False, Default = \"&H00000001", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_CONNECTNETDRV, Type = Double, Dynamic = False, Default = \"&H00000080", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_DEFAULT, Type = Double, Dynamic = False, Default = \"&H00000000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_DOENVSUBST, Type = Double, Dynamic = False, Default = \"&H00000200", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_FLAG_DDEWAIT, Type = Double, Dynamic = False, Default = \"&H00000100", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_FLAG_HINST_IS_SITE, Type = Double, Dynamic = False, Default = \"&H08000000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_FLAG_LOG_USAGE, Type = Double, Dynamic = False, Default = \"&H04000000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_FLAG_NO_UI, Type = Double, Dynamic = False, Default = \"&H00000400", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_HMONITOR, Type = Double, Dynamic = False, Default = \"&H00200000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_HOTKEY, Type = Double, Dynamic = False, Default = \"&H00000020", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_ICON, Type = Double, Dynamic = False, Default = \"&H00000010", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_IDLIST, Type = Double, Dynamic = False, Default = \"&H00000004", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_INVOKEIDLIST, Type = Double, Dynamic = False, Default = \"&H0000000C", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_NOASYNC, Type = Double, Dynamic = False, Default = \"&H00000100", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_NOCLOSEPROCESS, Type = Double, Dynamic = False, Default = \"&H00000040", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_NOQUERYCLASSSTORE, Type = Double, Dynamic = False, Default = \"&H01000000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_NOZONECHECKS, Type = Double, Dynamic = False, Default = \"&H00800000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_NO_CONSOLE, Type = Double, Dynamic = False, Default = \"&H00008000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_UNICODE, Type = Double, Dynamic = False, Default = \"&H00004000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SEE_MASK_WAITFORINPUTIDLE, Type = Double, Dynamic = False, Default = \"&H02000000", Scope = Public
	#tag EndConstant

	#tag Constant, Name = SW_SHOWNORMAL, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant


	#tag Structure, Name = SHELLEXECUTEINFOA32, Flags = &h0
		cbSize as UInt32
		  fMask as UInt32
		  hWnd as Integer
		  lpVerb as Ptr
		  lpFile as Ptr
		  lpParameters as Ptr
		  lpDirectory as Ptr
		  nShow as Int32
		  hInstApp as Integer
		  lpIDList as Ptr
		  lpClass as Ptr
		  hKeyClass as Integer
		  dwHotKey as UInt32
		  hIcon as Integer
		hProcess as Integer
	#tag EndStructure

	#tag Structure, Name = SHELLEXECUTEINFOA64, Flags = &h0
		cbSize as UInt32
		  fMask as UInt32
		  hWnd as Integer
		  lpVerb as Ptr
		  lpFile as Ptr
		  lpParameters as Ptr
		  lpDirectory as Ptr
		  nShow as Int32
		  _Padding1 as UInt32
		  hInstApp as Integer
		  lpIDList as Ptr
		  lpClass as Ptr
		  hKeyClass as Integer
		  dwHotKey as UInt32
		  _Padding2 as UInt32
		  hIcon as Integer
		hProcess as Integer
	#tag EndStructure

	#tag Structure, Name = SHELLEXECUTEINFOW32, Flags = &h0
		cbSize as UInt32
		  fMask as UInt32
		  hWnd as Integer
		  lpVerb as Ptr
		  lpFile as Ptr
		  lpParameters as Ptr
		  lpDirectory as Ptr
		  nShow as Int32
		  hInstApp as Integer
		  lpIDList as Ptr
		  lpClass as Ptr
		  hKeyClass as Integer
		  dwHotKey as UInt32
		  hIcon as Integer
		hProcess as Integer
	#tag EndStructure

	#tag Structure, Name = SHELLEXECUTEINFOW64, Flags = &h0
		cbSize as UInt32
		  fMask as UInt32
		  hWnd as Integer
		  lpVerb as Ptr
		  lpFile as Ptr
		  lpParameters as Ptr
		  lpDirectory as Ptr
		  nShow as Int32
		  _Padding1 as UInt32
		  hInstApp as Integer
		  lpIDList as Ptr
		  lpClass as Ptr
		  hKeyClass as Integer
		  dwHotKey as UInt32
		  _Padding2 as UInt32
		  hIcon as Integer
		hProcess as Integer
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
	#tag EndViewBehavior
End Module
#tag EndModule
