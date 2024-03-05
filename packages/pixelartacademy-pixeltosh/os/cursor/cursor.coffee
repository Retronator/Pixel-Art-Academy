LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.Cursor extends LOI.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.OS.Cursor'
  @register @id()
  
  @Types:
    Default: 'Default'
  
  constructor: (@os) ->
    super arguments...
    
    # The pixel coordinate is the display coordinate rounded to a whole integer.
    @coordinates = new ReactiveField null, EJSON.equals
    
    @type = new ReactiveField @constructor.Types.Default
    
  onRendered: ->
    super arguments...
    
    @$os = @$('.pixelartacademy-pixeltosh-os-cursor').closest('.pixelartacademy-pixeltosh-os')
    
  updateCoordinates: (event) ->
    osPosition = @$os.offset()
    displayScale = @os.display.scale()
    
    @coordinates
      x: Math.floor (event.pageX - osPosition.left) / displayScale
      y: Math.floor (event.pageY - osPosition.top) / displayScale
    
  resetCoordinates: ->
    @coordinates null
  
  typeClass: ->
    _.kebabCase @type()
  
  cursorStyle: ->
    unless coordinates = @coordinates()
      return display: 'none'
      
    left: "#{coordinates.x}rem"
    top: "#{coordinates.y}rem"
