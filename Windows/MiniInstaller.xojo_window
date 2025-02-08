#tag DesktopWindow
Begin DesktopWindow MiniInstaller
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
   Height          =   440
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   600
   MenuBar         =   0
   MenuBarVisible  =   False
   MinimumHeight   =   440
   MinimumWidth    =   360
   Resizeable      =   True
   Title           =   "LLStore Mini Installer"
   Type            =   0
   Visible         =   False
   Width           =   360
   Begin DesktopListBox Items
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   False
      AllowExpandableRows=   False
      AllowFocusRing  =   True
      AllowResizableColumns=   True
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   2
      ColumnWidths    =   ""
      DefaultRowHeight=   -1
      DropIndicatorVisible=   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      GridLineStyle   =   0
      HasBorder       =   False
      HasHeader       =   False
      HasHorizontalScrollbar=   False
      HasVerticalScrollbar=   True
      HeadingIndex    =   -1
      Height          =   392
      Index           =   -2147483648
      InitialValue    =   "Install Name	Skip"
      Italic          =   False
      Left            =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   0
      Transparent     =   True
      Underline       =   False
      Visible         =   True
      Width           =   360
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin DesktopLabel Stats
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   28
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   138
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Multiline       =   False
      Scope           =   0
      Selectable      =   False
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   False
      Text            =   "Installing 0/0"
      TextAlignment   =   2
      TextColor       =   &c000000
      Tooltip         =   ""
      Top             =   404
      Transparent     =   True
      Underline       =   False
      Visible         =   True
      Width           =   151
   End
   Begin DesktopButton Pause
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "Pause"
      Default         =   True
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   26
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   74
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   "Pause Installing Next Items"
      Top             =   404
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   52
   End
   Begin DesktopButton Skip
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "Skip"
      Default         =   True
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   26
      Index           =   -2147483648
      Italic          =   False
      Left            =   292
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   "Skip Highlighted Item"
      Top             =   404
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   56
   End
   Begin Thread InstallItems
      Index           =   -2147483648
      LockedInPosition=   False
      Priority        =   5
      Scope           =   0
      StackSize       =   0
      TabPanelIndex   =   0
      Type            =   0
   End
   Begin Timer UpdateUI
      Index           =   -2147483648
      LockedInPosition=   False
      Period          =   100
      RunMode         =   0
      Scope           =   0
      TabPanelIndex   =   0
   End
   Begin DesktopCheckBox SudoRunning
      AllowAutoDeactivate=   True
      Bold            =   False
      Caption         =   "Sudo"
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   28
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   False
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   "Click this to pre enabled a sudo terminal, try to only have one terminal or it will conflict and run commands called twice"
      Top             =   404
      Transparent     =   False
      Underline       =   False
      Value           =   False
      Visible         =   True
      VisualState     =   0
      Width           =   71
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
		  Debug("-- MiniInstaller Closed")
		End Sub
	#tag EndEvent

	#tag Event
		Sub Opening()
		  If Debugging Then Debug("--- Starting MiniInstaller Opening ---")
		  If ForceQuit = True Then Return 'Don't bother even opening if set to quit
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddInstallingItems()
		  Dim I As Integer
		  Dim SortCol, ItemToAdd As String
		  Dim BT As Integer
		  
		  QuitInstaller = False
		  
		  'Hide main form as it messes up the drawing of the list anyway
		  Main.Hide
		  
		  'Sort the Installation Order
		  HasLinuxSudo = False
		  For I = 0 To Data.Items.RowCount - 1
		    Select Case Data.Items.CellTextAt(I, Data.GetDBHeader("BuildType"))
		    Case "LLApp"
		      BT=1
		    Case "ssApp"
		      BT=2
		    Case "ppApp"
		      BT=3
		    Case "LLGame"
		      BT=4
		    Case "ppGame"
		      BT=5
		    End Select
		    
		    SortCol =  Data.Items.CellTextAt(I, Data.GetDBHeader("Priority")).Val.ToString("000")+BT.ToString("00")
		    Data.Items.CellTextAt(I, Data.GetDBHeader("Sorting")) = SortCol 'Add Sorting Data so it will be in the right order (Games last etc)
		  Next
		  
		  'Sort by Sorting column
		  Data.Items.ColumnSortDirectionAt(Data.GetDBHeader("Sorting")) = DesktopListBox.SortDirections.Ascending 'Sort by Sorting method
		  Data.Items.SortingColumn = Data.GetDBHeader("Sorting")
		  Data.Items.Sort ()
		  
		  'Set Column Widths and Make right Colum Aligned Right
		  Items.ColumnWidths = "*,80"
		  
		  'Build Install List to MiniInstaller
		  MiniInstaller.Items.RemoveAllRows 'Clear List of Items to install
		  ItemsToInstall = 0
		  For I = 0 To Data.Items.RowCount - 1 'Get Items to Install
		    If Data.Items.CellTextAt(I, Data.GetDBHeader("Selected")) = "T" Then
		      ItemToAdd = Data.Items.CellTextAt(I, Data.GetDBHeader("TitleName")) 
		      If Data.Items.CellTextAt(I, Data.GetDBHeader("Version")) <> "" Then ItemToAdd = ItemToAdd + " " + Data.Items.CellTextAt(I, Data.GetDBHeader("Version"))
		      
		      If Left(Data.Items.CellTextAt(I, Data.GetDBHeader("BuildType")),1) = "L" Then HasLinuxSudo = True ' Only show Sudo prompt if an item needs it.
		      
		      MiniInstaller.Items.AddRow (ItemToAdd)
		      MiniInstaller.Items.CellTagAt(MiniInstaller.Items.RowCount - 1, 0) = I 'Sets the TagID to the main DB so can use items from there with the Tag as Reference
		      'MiniInstaller.Items.CellAlignmentAt(MiniInstaller.Items.RowCount - 1,1) = DesktopListBox.Alignments.Right ' Align Right
		      ItemsToInstall = ItemsToInstall + 1
		    End If
		  Next I
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RunInstallerREMOVED()
		  'This is not used, but leave for reference so can send multiple items from a preset without showing mini installer maybe???
		  
		  '########################################################### Run Installer ##################################################
		  MiniInstaller.Show
		  App.DoEvents 'Redraw Form
		  
		  Dim I As Integer
		  Dim  P As Integer
		  Dim Success As Boolean
		  Installing = True
		  For I = 0 To MiniInstaller.Items.RowCount - 1 'Go Through each installer
		    MiniInstaller.Refresh
		    App.DoEvents 'Redraw Form
		    MiniUpTo = I
		    'If Items.ScrollPosition
		    
		    'Position List if off screen
		    If MiniUpTo + 6 >= Items.ScrollPosition + 12 Then
		      P = MiniUpTo - 6
		      If P <= 0 Then P = 0
		      If P >= Items.RowCount - 7 Then P = Items.RowCount - 7
		      Items.ScrollPosition = P
		    End If
		    
		    Stats.Text = "Installing "+Str(I+1)+"/"+Str(MiniInstaller.Items.RowCount)
		    MiniInstaller.Title = Str(I+1)+"/"+Str(MiniInstaller.Items.RowCount) + " Installing"
		    MiniInstaller.Refresh
		    App.DoEvents 'Redraw Form
		    
		    'MiniInstaller.Title = Data.Items.CellTextAt(MiniInstaller.Items.CellTagAt(I, 0), Data.GetDBHeader("TitleName"))
		    ''MiniInstaller.Items.RowSelectedAt (I) = True 'Don't need to select items anymore, the BGPaint will do the task, allows the user to pick an item to skip without focus lost
		    
		    If Items.CellTextAt(MiniUpTo, 1) = "Skip" Then
		      Items.CellTextAt(MiniUpTo, 1) = "Skipped"
		      MiniInstaller.Refresh
		      App.DoEvents 'Redraw Form
		      Continue 'Skip the item
		    End If
		    
		    'Items.ColumnAlignmentAt
		    
		    Items.CellTextAt(I, 1) = "Installing"
		    MiniInstaller.Refresh
		    Items.Refresh
		    App.DoEvents 'Redraw Form
		    
		    Success = InstallLLFile (Data.Items.CellTextAt(MiniInstaller.Items.CellTagAt(I, 0), Data.GetDBHeader("FileINI")))
		    
		    If QuitInstaller Then Exit ' Break the loop and assume done
		    While Pause.Caption = "Un-Pause" And QuitInstaller = False
		      App.DoEvents(4) ' Wait for Un Pause or closed
		      If MiniInstaller.Visible = False Then QuitInstaller = True
		    Wend
		    If QuitInstaller Then Exit ' Break the loop and assume done
		    
		    If Success = True Then
		      Items.CellTextAt(I, 1) = "Installed"
		    Else
		      Items.CellTextAt(I, 1) = "Failed"
		    End If
		    MiniInstaller.Refresh
		    Items.Refresh
		    App.DoEvents 'Redraw Form
		  Next
		  
		  Installing = False
		  
		  'Default Sorting back to normal
		  Data.Items.ColumnSortDirectionAt(Data.GetDBHeader("RefID")) = DesktopListBox.SortDirections.Ascending 'Sort by RefID
		  Data.Items.SortingColumn = Data.GetDBHeader("RefID")
		  Data.Items.Sort ()
		  
		  'Select None, Also need to recheck installed items etc (may be better to rescan for items instead)
		  Main.SelectsCount = 0
		  For I = 0 To Data.Items.RowCount - 1 ' Unselect everything
		    Data.Items.CellTextAt(I, Data.GetDBHeader("Selected")) = "F" ' Un-Select Items
		  Next I
		  
		  'Make sure Sudo Window is closed
		  If Not TargetWindows Then 'Only make Sudo in Linux
		    If SudoEnabled = True Then
		      SudoEnabled = False
		      ShellFast.Execute ("echo "+Chr(34)+"Unlock"+Chr(34)+" > /tmp/LLSudoDone") 'Quits Terminal after All items have been installed.
		    End If
		  End If
		  
		  'Bring back main form, if enabled to
		  MiniInstaller.Hide ' Hide the installer
		  MiniInstallerShowing = False 'Make it invisible again
		  Main.Show
		  QuitInstaller = False
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StartInstaller()
		  FileToInstallFrom = ""
		  InstallDone = False
		  MiniSelected = -1
		  MiniUpTo = -1 ' It's 0 Based
		  Paused = False
		  QuitInstaller = False
		  SuccessfulInstall = False
		  ThreadFinished = True 'It's sets itself to False when it can't be called to run a 2nd Thread
		  
		  ItemsToInstall = 0
		  
		  'Position MiniInstaller bottom right
		  MiniInstaller.Left = Screen(0).AvailableWidth - MiniInstaller.Width '- 20
		  MiniInstaller.Top = Screen(0).AvailableHeight - MiniInstaller.Height
		  
		  Dim I As Integer
		  For I = 0 To 4095
		    SkipItem(I) = False
		  Next
		  
		  AddInstallingItems
		  
		  MiniInstaller.Show
		  
		  'Call thread and lets hope I got it right
		  InstallItems.Start
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		FileToInstallFrom As String
	#tag EndProperty

	#tag Property, Flags = &h0
		InstallDone As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		ItemsToInstall As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		JobInstalling As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		MiniSelected As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h0
		MiniUpTo As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		Paused As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		QuitInstaller As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		SkipItem(4096) As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		SuccessfulInstall As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		ThreadFinished As Boolean = True
	#tag EndProperty


#tag EndWindowCode

#tag Events Items
	#tag Event
		Sub SelectionChanged()
		  MiniSelected = Items.SelectedRowIndex
		  
		  If MiniSelected >=0 Then
		    'MiniInstaller.Title = Items.CellTextAt(MiniSelected, 0)
		  End If
		  Items.Refresh
		End Sub
	#tag EndEvent
	#tag Event
		Function PaintCellText(g as Graphics, row as Integer, column as Integer, x as Integer, y as Integer) As Boolean
		  '#Pragma BreakOnExceptions False
		  
		  #Pragma BreakOnExceptions Off
		  
		  #PRAGMA unused x
		  #PRAGMA unused y
		  
		  Var icon As Picture
		  
		  Dim Pos As Integer
		  
		  Try
		    Pos = 2+(g.Height / 6)
		  Catch
		  End Try
		  
		  'Get Item
		  Dim CLI, RefIcon As Integer
		  '#Pragma BreakOnExceptions Off
		  Try
		    CLI = Items.CellTagAt(Row, 0)
		  Catch
		    CLI = -1
		  End Try
		  
		  #Pragma BreakOnExceptions Off
		  
		  Try
		    'Draw Text
		    g.DrawingColor = ColList
		    g.FontName = FontList
		    
		    If StoreMode = 0 Then 'Only color when in Installer mode
		      If CLI >=0 Then 
		        Select Case Data.Items.CellTextAt(CLI,Data.GetDBHeader("BuildType"))
		        Case "LLApp"
		          g.DrawingColor = ColLLApp
		        Case "LLGame"
		          g.DrawingColor = ColLLGame
		        Case "ssApp"
		          g.DrawingColor = ColssApp
		        Case "ppApp"
		          g.DrawingColor = ColppApp
		        Case "ppGame"
		          g.DrawingColor = ColppGame
		        End Select
		      End If
		    End If
		    If column = 0 Then 'Only add it to the main Column
		      g.DrawText(Items.CellTextAt(row, column), g.Height+2, g.Height-Pos)
		    Else
		      g.DrawText(Items.CellTextAt(row, column), 2, g.Height-Pos) 'Only pad 2 pixels for 2nd column
		    End If
		    
		    'Draw Icon
		    If column = 0 Then 'Only add it to the main Column
		      #Pragma BreakOnExceptions False
		      Try
		        RefIcon = Val(Data.Items.CellTextAt(CLI, Data.GetDBHeader("IconRef")))
		        icon = Data.Icons.RowImageAt(RefIcon)
		        g.DrawPicture(icon, 1, 1, g.Height-2,g.Height-2, _
		        0, 0, icon.Width, icon.Height)
		      Catch
		      End Try
		      
		      #Pragma BreakOnExceptions On
		    End If
		    
		    Return True
		    
		  Catch
		  End Try
		  
		  #Pragma BreakOnExceptions Off
		End Function
	#tag EndEvent
	#tag Event
		Function PaintCellBackground(g As Graphics, row As Integer, column As Integer) As Boolean
		  'If MiniInstaller.Visible = False Then Return False' Don't redraw if not seen
		  
		  ''Can Do Solid Color
		  Try
		    g.DrawingColor =  ColBG '&C000000 'Match Description BG colour
		    g.FillRectangle(0,0,g.Width, g.Height)
		  Catch
		  End Try
		  
		  'Draw Wallpaper (Transparent) Disabled for now
		  'g.DrawPicture ScaledWallpaper, -Items.Left, (-Items.Top)-(row*me.RowHeight) +(Me.ScrollPosition*me.RowHeight)
		  
		  'Get Item
		  Dim CLI, RefIcon As Integer
		  #Pragma BreakOnExceptions Off
		  Try
		    'Nil error?
		    CLI = Items.CellTagAt(Row, 0)
		  Catch
		    CLI = -1
		  End Try
		  #Pragma BreakOnExceptions On
		  
		  If CLI = -1 Then Return True ' Not an item, just skip it (Drawn BG above)
		  
		  #Pragma BreakOnExceptions Off
		  Try
		    If  Me.SelectedRowIndex = Row Then  'If selected and Hilighted  'IsTrue(Data.Items.CellTextAt(CLI,Data.GetDBHeader("Selected"))) And
		      g.ForeColor = ColDual
		      g.FillRect 0,0,g.Width, g.Height
		      Return True 'Take away drawing default Highlight
		    End If
		    
		    If MiniSelected = Row Then 'Select items you click on
		      g.ForeColor = ColSelect
		      g.FillRect 0,0,g.Width, g.Height
		    End If
		    
		    Dim Test As Integer = MiniUpTo
		    If Test <=0 Then Test = 0
		    
		    If Test = Row Then 'Highlight
		      g.ForeColor = ColHiLite
		      g.FillRect 0,0,g.Width, g.Height
		      Return True 'Take away drawing default Highlight
		    End If
		    
		  Catch
		  End Try
		  
		  #Pragma BreakOnExceptions On
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events Pause
	#tag Event
		Sub Pressed()
		  If Pause.Caption = "Pause" Then
		    Pause.Caption = "Un-Pause"
		    Paused = True
		  Else
		    Pause.Caption = "Pause"
		    Paused = False
		  End If
		  
		  Items.Refresh
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events Skip
	#tag Event
		Sub Pressed()
		  If MiniSelected >=0 Then
		    If Items.CellTextAt(MiniSelected, 1) = "" Then
		      Items.CellTextAt(MiniSelected, 1) = "Skip"
		      SkipItem(MiniSelected) = True
		    ElseIf Items.CellTextAt(MiniSelected, 1) = "Skip" Then
		      Items.CellTextAt(MiniSelected, 1) = "" 'Set to install again
		      SkipItem(MiniSelected) = False
		    End If
		  End If
		  Items.Refresh
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events InstallItems
	#tag Event
		Sub Run()
		  'This routine is recursive and will stop once it counts to the last item, you can access UI data, just not set or update it (I think).
		  ThreadFinished = False 'Won't allow 2 calls to the timer or restart thread before it's done
		  UpdateUI.RunMode = Timer.RunModes.Multiple 'Keep updating until done, so you can pause and Skip etc.
		  
		  If QuitInstaller = False Then 'Bypass everything if you close the form
		    If Not Paused Then 
		      Installing = True
		      If FileToInstallFrom <> "" Then '------------
		        SuccessfulInstall = InstallLLFile (FileToInstallFrom)
		        If SuccessfulInstall = False Then 'Check for errors
		          If Debugging Then Debug("* Error: Failed - Aborting Install")
		        End If
		      End If '--------------------
		      MiniUpTo = MiniUpTo + 1 'Move to the Next Item, current item was empty or completed
		      Installing = False
		    End If
		  End If
		  
		  'App.DoEvents(4000) 'Wait 4 seconds 'Just a for testing thing
		  
		  ThreadFinished = True
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events UpdateUI
	#tag Event
		Sub Action()
		  If MiniInstaller.Visible = False Then QuitInstaller = True
		  
		  If MiniUpTo+1 > MiniInstaller.Items.RowCount Then 'Past the end of the installer
		    InstallDone = True ' Trigger to quit MiniInstaller
		    
		    InstallItems.Stop 'Disable the Thread Loop
		    UpdateUI.RunMode = Timer.RunModes.Off 'Disable Redraw Timer if Quitting
		    MiniUpTo = -1 
		    QuitInstaller = True
		    'Sort Data.Items back to original order
		    Data.Items.ColumnSortDirectionAt(Data.GetDBHeader("RefID")) = DesktopListBox.SortDirections.Ascending 'Sort by RefID
		    Data.Items.SortingColumn = Data.GetDBHeader("RefID")
		    Data.Items.Sort ()
		    
		    'Select None, Also need to recheck installed items etc (may be better to rescan for items instead)
		    Main.SelectsCount = 0
		    Dim I As Integer
		    For I = 0 To Data.Items.RowCount - 1 ' Unselect everything
		      Data.Items.CellTextAt(I, Data.GetDBHeader("Selected")) = "F" ' Un-Select Items
		    Next I
		    
		    'Make sure Sudo is closed (not added ability to echo to /tmp/LLSudo to close it yet, so disabled)
		    If Not TargetWindows Then 'Only make Sudo in Linux
		      If SudoEnabled = True Then
		        SudoEnabled = False
		        ShellFast.Execute ("echo "+Chr(34)+"Unlock"+Chr(34)+" > /tmp/LLSudoDone") 'Quits Terminal after All items have been installed.
		      End If
		    End If
		    
		    'Bring back main form, if enabled to
		    MiniInstaller.Hide ' Hide the installer
		    If Settings.SetQuitOnComplete.Value = True Or ForcePostQuit = True Then
		      QuitApp 'If set to Quit on Complete then do so
		      Exit
		    End If
		    
		    Main.Show
		    QuitInstaller = False
		    Exit'Don't Continue this Sub after Quitting
		    
		  End If
		  
		  If Not QuitInstaller Then 'If Set to Quit, do nothing
		    If TargetWindows Then
		      SudoRunning.Visible = False
		    Else
		      SudoRunning.Visible = True
		      If SudoShellLoop.IsRunning Then
		        SudoRunning.Value = True
		      Else
		        SudoRunning.Value = False
		      End If
		    End If
		    
		    Dim P As Integer
		    'Position List if off screen
		    If MiniUpTo + 6 >= Items.ScrollPosition + 12 Then
		      P = MiniUpTo - 6
		      If P <= 0 Then P = 0
		      If P >= Items.RowCount - 7 Then P = Items.RowCount - 7
		      Items.ScrollPosition = P
		    End If
		    
		    'Update Stats
		    #Pragma BreakOnExceptions Off
		    Try
		      If Downloading = True Then
		        Stats.Text = "Downloading "+ DownloadPercentage
		      Else
		        Stats.Text = "Installing "+Str(MiniUpTo+1)+"/"+Str(MiniInstaller.Items.RowCount)
		        DownloadPercentage = ""
		        App.DoEvents(1)
		      End If
		      MiniInstaller.Title = Str(MiniUpTo+1)+"/"+Str(MiniInstaller.Items.RowCount) + " Installing"
		      
		      If MiniUpTo - 1 >=0 Then
		        If Items.CellTextAt(MiniUpTo-1, 1) = "Installing" Then Items.CellTextAt(MiniUpTo-1, 1) = "Installed" 'Does this work here, will test, Yes works here, except for the last item, but that doesn't matter as the form hides when it's done
		      End If
		      #Pragma BreakOnExceptions Off
		      Try
		        If Items.CellTextAt(MiniUpTo, 1) = "Skip" Then ' If on the Item change to Skipped so can't pick to UnSkip it again (I don't count backwards)
		          Items.CellTextAt(MiniUpTo, 1) = "Skipped"
		          
		          MiniUpTo = MiniUpTo + 1 'This Will proceed to the next Item without trying to install the previously skipped ones, without having to check in the Thread :)
		          
		        Else
		          If Items.CellTextAt(MiniUpTo, 1) = "" Then
		            Items.CellTextAt(MiniUpTo, 1) = "Installing" 'Change it to Installing if it's where we are up to (Called before it start to install so this should always fire
		          End If
		        End If
		      Catch
		      End Try
		      #Pragma BreakOnExceptions On
		      
		      If MiniUpTo - 1 >= 0 Then 
		        If Items.CellTextAt(MiniUpTo-1, 1) = "" Then Items.CellTextAt(MiniUpTo - 1, 1) = "Installed" 'Make the first Item changed to Installed, can add Fail check here too
		      End If
		    Catch
		    End Try
		    #Pragma BreakOnExceptions On
		    
		    'Redraw changed UI
		    MiniInstaller.Refresh
		    MiniInstaller.Items.Refresh
		    
		    'Downloading is also a job so when it is done it re-checks the files exist and will retry, I'll need to add a retry counter and only reset it when it goes over or MiniUpTo increases (successful)
		    If JobInstalling = True And Downloading = False And ThreadFinished = True Then JobInstalling = False 'This resets the flag once done
		    
		    If JobInstalling = True Then Return ' It's busy, don't bother checking
		    
		    'This routine is Also called before the Item installs, so I can use it to set the Item to Install, MiniUpTo will start at 0 after all
		    #Pragma BreakOnExceptions Off
		    Try 'This is so pre listing doesn't crash it
		      JobInstalling = True
		      FileToInstallFrom = Data.Items.CellTextAt(MiniInstaller.Items.CellTagAt(MiniUpTo, 0), Data.GetDBHeader("FileINI"))
		      Dim F As FolderItem
		      Dim DownloadAnyway As Boolean
		      DownloadAnyway = False
		      Try
		        F = GetFolderItem(FileToInstallFrom, FolderItem.PathTypeShell)
		        If F.Length <=10000 Then '10KB is pretty small
		          If Left(Data.Items.CellTextAt(MiniInstaller.Items.CellTagAt(MiniUpTo, 0), Data.GetDBHeader("PathINI")), 4) = "http" Then DownloadAnyway = True 'If the File isn't online one then don't download or will cause issues
		        End If
		      Catch
		        DownloadAnyway = True 'If the file has errors then just set it to re-download
		      End Try
		      
		      If Not Exist(FileToInstallFrom) Or DownloadAnyway = True Then 'Only if it doesn't exist or the existing file is tiny download it
		        'Download if possible
		        If Left(Data.Items.CellTextAt(MiniInstaller.Items.CellTagAt(MiniUpTo, 0), Data.GetDBHeader("PathINI")), 4) = "http" Then
		          GetOnlineFile(Data.Items.CellTextAt(MiniInstaller.Items.CellTagAt(MiniUpTo, 0), Data.GetDBHeader("PathINI")), FileToInstallFrom)
		        Else
		          Items.CellTextAt(MiniUpTo, 1) = "Failed" 'Usually due to unreadable USB or DVD
		          If Debugging Then Debug("* Error Accessing: "+Data.Items.CellTextAt(MiniInstaller.Items.CellTagAt(MiniUpTo, 0), Data.GetDBHeader("PathINI")))
		          MiniUpTo = MiniUpTo + 1 'Skip the item if not able to download from internet
		          Return
		        End If
		        
		        'Do counter here, so will abort if stuck in download loop etc- Glenn
		        
		        Return 'Once you start the download we don't continue the job processing below, just update the stats until it's done or aborted
		      End If
		      
		      If MiniUpTo >= 0 And MiniUpTo < ItemsToInstall Then 
		        If ThreadFinished Then
		          InstallItems.Start 'Loop again Recursive
		          'MsgBox FileToInstallFrom 'Glenn  'Mesage box needs to be below due to recursive and thread based, For Debugging, Keep
		        End If
		      Else
		        Installing = False
		        InstallDone = True
		      End If
		      
		    Catch
		    End Try
		    #Pragma BreakOnExceptions On
		  End If
		  
		  'MsgBox "Done, Trying for next item"
		  'It only gets here after an item completes, could count using this if I wanted
		  
		  
		  
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events SudoRunning
	#tag Event
		Sub MouseUp(x As Integer, y As Integer)
		  If SudoShellLoop.IsRunning Then
		    SudoRunning.Value = True
		  Else
		    EnableSudoScript
		  End If
		End Sub
	#tag EndEvent
	#tag Event
		Function MouseDown(x As Integer, y As Integer) As Boolean
		  Return True
		End Function
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
	#tag ViewProperty
		Name="MiniSelected"
		Visible=false
		Group="Behavior"
		InitialValue="-1"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MiniUpTo"
		Visible=false
		Group="Behavior"
		InitialValue="-1"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="FileToInstallFrom"
		Visible=false
		Group="Behavior"
		InitialValue=""
		Type="String"
		EditorType="MultiLineEditor"
	#tag EndViewProperty
	#tag ViewProperty
		Name="InstallDone"
		Visible=false
		Group="Behavior"
		InitialValue=""
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="ItemsToInstall"
		Visible=false
		Group="Behavior"
		InitialValue=""
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Paused"
		Visible=false
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="QuitInstaller"
		Visible=false
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="SuccessfulInstall"
		Visible=false
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="ThreadFinished"
		Visible=false
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="JobInstalling"
		Visible=false
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
#tag EndViewBehavior
