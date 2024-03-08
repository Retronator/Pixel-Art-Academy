AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder.Desktop extends PAA.Pixeltosh.Program.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder.Desktop'
  @register @id()
  
  @program: -> PAA.Pixeltosh.Programs.Finder

  @activateBringsWindowToTop: -> false
  
  programs: ->
    # Show all programs except the finder.
    _.without @os.currentPrograms(), @program

  events: ->
    super(arguments...).concat
      'click .program-button': @onClickProgramButton
  
  onClickProgramButton: (event) ->
    program = @currentData()
    @os.loadProgram program
