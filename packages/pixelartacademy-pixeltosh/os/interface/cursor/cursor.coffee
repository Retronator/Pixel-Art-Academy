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
    
    @desiredClasses = new ReactiveField [
      className: null
      requester: @
    ]
    
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
    
    @class = new ComputedField => _.last(@desiredClasses()).className
    
  onRendered: ->
    super arguments...
    
    @$origin = @$('.pixelartacademy-pixeltosh-os-interface-cursor')
    
  setClass: (className) ->
    desiredClasses = Tracker.nonreactive => @desiredClasses()
    desiredClasses[0].className = className
    @desiredClasses desiredClasses
    
  requestClass: (className, requester) ->
    desiredClasses = Tracker.nonreactive => @desiredClasses()

    # Remove any existing requests for this class/requester and put the new one to the top.
    _.remove desiredClasses, (desiredClass) => desiredClass.className is className and desiredClass.requester is requester
    desiredClasses.push {className, requester}

    @desiredClasses desiredClasses
    
  endClassRequest: (className, requester) ->
    desiredClasses = Tracker.nonreactive => @desiredClasses()
    _.remove desiredClasses, (desiredClass) => desiredClass.className is className and desiredClass.requester is requester
    @desiredClasses desiredClasses
  
  endClassRequests: (requester) ->
    desiredClasses = Tracker.nonreactive => @desiredClasses()
    _.remove desiredClasses, (desiredClass) => desiredClass.requester is requester
    @desiredClasses desiredClasses
  
  wait: (requester) -> @requestClass 'wait', requester
  endWait: (requester) -> @endClassRequest 'wait', requester
  
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
