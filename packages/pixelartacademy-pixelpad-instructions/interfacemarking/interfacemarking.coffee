AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Markup = PAA.Practice.Helpers.Drawing.Markup
Atari2600 = LOI.Assets.Palette.Atari2600

class PAA.PixelPad.Systems.Instructions.InterfaceMarking extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Systems.Instructions.InterfaceMarking'
  @register @id()
  
  @defaultStyle: ->
    palette = LOI.palette()
    markupColor = palette.color Atari2600.hues.red, 3
    
    "##{markupColor.getHexString()}"
  
  @textBase: ->
    size: 5
    lineHeight: 7
    font: 'Small Print Retronator'
    style: @defaultStyle()
    align: Markup.TextAlign.Center
    
  @arrowBase: ->
    arrow:
      end: true
      width: 6
      length: 3
    style: @defaultStyle()
  
  constructor: ->
    super arguments...
  
  onCreated: ->
    super arguments...
    
    @left = new ReactiveField 0
    @top = new ReactiveField 0
    @visible = new ReactiveField false
    
    @display = @callAncestorWith 'display'
    
    @markup = new Markup.EngineComponent
    
  onRendered: ->
    super arguments...
    
    @$canvas = @$('.drawing-canvas')
    @canvas = @$canvas[0]
    @context = @canvas.getContext '2d'
    
    @autorun (computation) =>
      markingData = @data()

      # Depend on viewport changes.
      @display.viewport()
      scale = @display.scale()

      # Hide while waiting for positioning to happen.
      @visible false
      
      Meteor.clearTimeout @_repositionTimeout
      
      @_repositionTimeout = Meteor.setTimeout =>
        $target = $(markingData.selector)
        
        unless $target.length
          console.warn "Marking selector #{markingData.selector} returned no elements."
          return
        
        targetOffset = $target.offset()
  
        $os = $('.pixelartacademy-pixelpad-os')
        osOffset = $os.offset()
  
        @left (targetOffset.left - osOffset.left) / scale
        @top (targetOffset.top - osOffset.top) / scale
        @visible true
      ,
        (markingData.delay or 0) * 1000
    
    # Redraw when data or size changes.
    @autorun (computation) =>
      markingData = @data()
      displayScale = @display.scale()
      scale = displayScale # * devicePixelRatio
      
      @canvas.width = markingData.bounds.width * scale
      @canvas.height = markingData.bounds.height * scale
      
      @context.resetTransform()
      @context.scale scale, scale
      @context.translate -markingData.bounds.x, -markingData.bounds.y
    
      @markup.drawMarkup markingData.markings, @context,
        pixelSize: 1 / scale # * devicePixelRatio
        displayPixelSize: 1 / scale * displayScale
        minimumZoomPercentage: 100
  
  onDestroyed: ->
    super arguments...
    
  visibleClass: ->
    'visible' if @visible()
    
  markingStyle: ->
    markingData = @data()
  
    left: "#{@left() + markingData.bounds.x}rem"
    top: "#{@top() + markingData.bounds.y}rem"
  
  canvasStyle: ->
    markingData = @data()
    
    width: "#{markingData.bounds.width}rem"
    height: "#{markingData.bounds.height}rem"
