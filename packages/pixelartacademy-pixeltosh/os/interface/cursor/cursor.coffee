FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS.Interface.Cursor extends FM.View
  @id: -> 'PixelArtAcademy.Pixeltosh.OS.Interface.Cursor'
  @register @id()
  
  constructor: ->
    super arguments...
    
    # The pixel coordinate is the display coordinate rounded to a whole integer.
    @coordinates = new ReactiveField null, EJSON.equals

  onCreated: ->
    super arguments...
    
    @display = @callAncestorWith 'display'
    
  onRendered: ->
    super arguments...
    
    @$origin = @$('.pixelartacademy-pixeltosh-os-interface-cursor')
    
  updateCoordinates: (event) ->
    originPosition = @$origin.offset()
    displayScale = @display.scale()
    
    @_updateCoordinatesThrottled ?= _.throttle (coordinates) =>
      @coordinates coordinates
    ,
      33
    
    @_updateCoordinatesThrottled
      x: Math.floor (event.pageX - originPosition.left) / displayScale
      y: Math.floor (event.pageY - originPosition.top) / displayScale
    
  resetCoordinates: ->
    @_updateCoordinatesThrottled.flush()
    @coordinates null
  
  cursorStyle: ->
    unless coordinates = @coordinates()
      return display: 'none'
      
    left: "#{coordinates.x}rem"
    top: "#{coordinates.y}rem"
