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
    
    @class = new ReactiveField null
    @_desiredClass = null

  onCreated: ->
    super arguments...
    
    @display = @callAncestorWith 'display'
    
    # Create a throttled coordinates update function to emulate a slow CPU.
    @autorun (computation) =>
      delay = if LOI.settings.graphics.slowCPUEmulation.value() then 33 else 0
      
      @_updateCoordinatesThrottled = _.throttle (coordinates) =>
        @coordinates coordinates
      ,
        delay
    
  onRendered: ->
    super arguments...
    
    @$origin = @$('.pixelartacademy-pixeltosh-os-interface-cursor')
    
  setClass: (cursorClass) ->
    @_desiredClass = cursorClass
    
    return if @class() is 'grabbing'
    
    @class cursorClass
    
  startGrabbing: ->
    @class 'grabbing'
    
  endGrabbing: ->
    @class @_desiredClass
    
  updateCoordinates: (event) ->
    originPosition = @$origin.offset()
    displayScale = @display.scale()
    
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
