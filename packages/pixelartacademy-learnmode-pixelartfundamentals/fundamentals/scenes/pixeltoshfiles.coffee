LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.PixeltoshFiles extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.PixeltoshFiles'

  @location: -> PAA.Pixeltosh.OS.FileSystem

  @initialize()
  
  things: ->
    pixeltoshFiles = []
    
    if LM.PixelArtFundamentals.pinballEnabled()
      unless @_pinballDisk
        @_pinballDisk = new PAA.Pixeltosh.OS.FileSystem.File
          id: "#{PAA.Pixeltosh.Programs.Pinball.id()}.Disk"
          path: 'Pinball Creation Kit'
          type: PAA.Pixeltosh.OS.FileSystem.FileTypes.Disk
        
        @_pinballDisk.options.disk = @_pinballDisk
      
      pixeltoshFiles.push @_pinballDisk
      
      @_pinballProgram ?= new PAA.Pixeltosh.OS.FileSystem.File
        id: PAA.Pixeltosh.Programs.Pinball.id()
        path: 'Pinball Creation Kit/Pinball Creation Kit'
        type: PAA.Pixeltosh.Programs.Pinball
        disk: @_pinballDisk
      
      pixeltoshFiles.push @_pinballProgram
      
      @_pinballMachines ?= {}
      
      for project in PAA.Pixeltosh.Programs.Pinball.Project.getCurrentProfileProjects()
        @_pinballMachines[project._id] ?= new PAA.Pixeltosh.Programs.Pinball.Project.File project._id, @_pinballDisk
        pixeltoshFiles.push @_pinballMachines[project._id]
  
      @_moonShot ?= new PAA.Pixeltosh.OS.FileSystem.File
        id: "#{PAA.Pixeltosh.Programs.Pinball.id()}.DemoMachines.MoonShot"
        path: 'Pinball Creation Kit/Demo Machines/Moon Shot'
        type: PAA.Pixeltosh.Programs.Pinball.Project
        disk: @_pinballDisk
        data: => projectId: 'ewzE9QPCPPLnxHvpi'
      
      pixeltoshFiles.push @_moonShot
    
    if LM.PixelArtFundamentals.drawQuicklyEnabled()
      unless @_drawQuicklyDisk
        @_drawQuicklyDisk = new PAA.Pixeltosh.OS.FileSystem.File
          id: "#{PAA.Pixeltosh.Programs.DrawQuickly.id()}.Disk"
          path: 'Draw Quickly'
          type: PAA.Pixeltosh.OS.FileSystem.FileTypes.Disk
        
        @_drawQuicklyDisk.options.disk = @_drawQuicklyDisk
        
      pixeltoshFiles.push @_drawQuicklyDisk
      
      @_drawQuciklyProgram ?= new PAA.Pixeltosh.OS.FileSystem.File
        id: PAA.Pixeltosh.Programs.DrawQuickly.id()
        path: 'Draw Quickly/Draw Quickly'
        type: PAA.Pixeltosh.Programs.DrawQuickly
        disk: @_drawQuicklyDisk
        
      pixeltoshFiles.push @_drawQuciklyProgram
      
    if LM.PixelArtFundamentals.chessEnabled()
      unless @_chessDisk
        @_chessDisk = new PAA.Pixeltosh.OS.FileSystem.File
          id: "#{PAA.Pixeltosh.Programs.Chess.id()}.Disk"
          path: 'Chess Academy'
          type: PAA.Pixeltosh.OS.FileSystem.FileTypes.Disk
        
        @_chessDisk.options.disk = @_chessDisk
        
      pixeltoshFiles.push @_chessDisk
      
      @_chessProgram ?= new PAA.Pixeltosh.OS.FileSystem.File
        id: PAA.Pixeltosh.Programs.Chess.id()
        path: 'Chess Academy/Chess Academy'
        type: PAA.Pixeltosh.Programs.Chess
        disk: @_chessDisk
        
      pixeltoshFiles.push @_chessProgram
      
    pixeltoshFiles
