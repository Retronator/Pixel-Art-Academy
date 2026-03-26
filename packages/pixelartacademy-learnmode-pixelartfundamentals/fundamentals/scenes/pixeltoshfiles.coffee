LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.PixeltoshFiles extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.PixeltoshFiles'

  @location: -> PAA.Pixeltosh.OS.FileSystem

  @initialize()
  
  things: ->
    unless @_pinballDisk
      @_pinballDisk = new PAA.Pixeltosh.OS.FileSystem.File
        id: "#{PAA.Pixeltosh.Programs.Pinball.id()}.Disk"
        path: 'Pinball Creation Kit'
        type: PAA.Pixeltosh.OS.FileSystem.FileTypes.Disk
      
      @_pinballDisk.options.disk = @_pinballDisk
      
    @_pinballProgram ?= new PAA.Pixeltosh.OS.FileSystem.File
      id: PAA.Pixeltosh.Programs.Pinball.id()
      path: 'Pinball Creation Kit/Pinball Creation Kit'
      type: PAA.Pixeltosh.Programs.Pinball
      disk: @_pinballDisk
    
    @_pinballMachine ?= new PAA.Pixeltosh.OS.FileSystem.File
      id: "#{PAA.Pixeltosh.Programs.Pinball.id()}.PinballMachine"
      path: 'Pinball Creation Kit/My Pinball Machine'
      type: PAA.Pixeltosh.Programs.Pinball.Project
      disk: @_pinballDisk
      data: => PAA.Pixeltosh.Programs.Pinball.Project.state 'activeProjectId'
    
    @_moonShot ?= new PAA.Pixeltosh.OS.FileSystem.File
      id: "#{PAA.Pixeltosh.Programs.Pinball.id()}.DemoMachines.MoonShot"
      path: 'Pinball Creation Kit/Demo Machines/Moon Shot'
      type: PAA.Pixeltosh.Programs.Pinball.Project
      disk: @_pinballDisk
      data: => 'ewzE9QPCPPLnxHvpi'
    
    pinballEnabled = LM.PixelArtFundamentals.pinballEnabled()
    
    unless @_drawQuicklyDisk
      @_drawQuicklyDisk = new PAA.Pixeltosh.OS.FileSystem.File
        id: "#{PAA.Pixeltosh.Programs.DrawQuickly.id()}.Disk"
        path: 'Draw Quickly'
        type: PAA.Pixeltosh.OS.FileSystem.FileTypes.Disk
      
      @_drawQuicklyDisk.options.disk = @_drawQuicklyDisk
    
    @_drawQuciklyProgram ?= new PAA.Pixeltosh.OS.FileSystem.File
      id: PAA.Pixeltosh.Programs.DrawQuickly.id()
      path: 'Draw Quickly/Draw Quickly'
      type: PAA.Pixeltosh.Programs.DrawQuickly
      disk: @_drawQuicklyDisk
      
    drawQuciklyEnabled = LM.PixelArtFundamentals.drawQuicklyEnabled()
    
    [
      @_pinballDisk if pinballEnabled
      @_pinballProgram if pinballEnabled
      @_pinballMachine if pinballEnabled
      @_moonShot if pinballEnabled
      @_drawQuicklyDisk if drawQuciklyEnabled
      @_drawQuciklyProgram if drawQuciklyEnabled
    ]
