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
    
    @_pinballDemoMachines ?= new PAA.Pixeltosh.OS.FileSystem.File
      id: "#{PAA.Pixeltosh.Programs.Pinball.id()}.DemoMachines"
      path: 'Pinball Creation Kit/Demo Machines'
      type: PAA.Pixeltosh.OS.FileSystem.FileTypes.Folder
      disk: @_pinballDisk
    
    pinballEnabled = LM.PixelArtFundamentals.pinballEnabled()
    
    [
      @_pinballDisk if pinballEnabled
      @_pinballProgram if pinballEnabled
      @_pinballDemoMachines if pinballEnabled
    ]
