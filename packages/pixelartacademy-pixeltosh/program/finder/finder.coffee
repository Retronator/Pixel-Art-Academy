AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder extends PAA.Pixeltosh.Program
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Finder"
  @description: ->
    "
      The file system manager of Pixeltosh.
    "

  @initialize()
  
  template: -> @id()
  
  apps: ->
    # Show all programs except the finder.
    _.without @os.currentPrograms(), @

  events: ->
    super(arguments...).concat
      'click .program-button': @onClickProgramButton
  
  onClickProgram: (event) ->
    program = @currentData()
    @os.loadProgram program
