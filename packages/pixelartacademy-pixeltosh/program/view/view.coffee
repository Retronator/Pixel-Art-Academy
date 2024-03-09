AE = Artificial.Everywhere
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Program.View extends LOI.View
  # programId: ID of the program this view belongs to
  # activateBringsWindowToTop: boolean whether activating this view brings its window to top, true by default
  # contentArea: the component that is rendered in this view
  @id: -> 'PixelArtAcademy.Pixeltosh.Program.View'
  @register @id()

  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    
  program: ->
    return unless viewData = @data()
    @os.getProgram viewData.get 'programId'
    
  events: ->
    super(arguments...).concat
      'pointerdown': @onPointerDown
  
  onPointerDown: (event) ->
    @os.activateView @
