AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Finder extends PAA.Pixeltosh.Program
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Finder'
  @register @id()

  @version: -> '0.1.0'

  @fullName: -> "Finder"
  @description: ->
    "
      The file system manager of Pixeltosh.
    "
    
  @programSlug: -> 'finder'

  @initialize()
  
  load: ->
    @os.addWindow contentComponentId: @constructor.Desktop.id()
    
  menuItems: -> [
    caption: ''
    items: []
  ,
    caption: 'File'
    items: []
  ,
    caption: 'Edit'
    items: []
  ,
    caption: 'View'
    items: []
  ,
    caption: 'Special'
    items: []
  ]
  
  programs: ->
    # Show all programs except the finder.
    _.without @os.currentPrograms(), @

  events: ->
    super(arguments...).concat
      'click .program-button': @onClickProgramButton
  
  onClickProgram: (event) ->
    program = @currentData()
    @os.loadProgram program
