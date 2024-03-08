AE = Artificial.Everywhere
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Program.View extends LOI.View
  @program: -> throw new AE.NotImplementedException "A program view must specify which program this view belongs to."
  
  @activateBringsWindowToTop: -> true # Override if interacting with this view does not bring its window to top.
  
  onCreated: ->
    super arguments...
    
    @os = @interface.parent
    @program = @os.getProgram @constructor.program()
    
  events: ->
    super(arguments...).concat
      'click': @onClick
      
  onClick: (event) ->
    @os.activateView @
