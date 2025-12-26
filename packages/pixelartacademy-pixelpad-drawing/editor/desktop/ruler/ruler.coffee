AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Ruler extends FM.View
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Ruler'
  @register @id()
  
  onCreated: ->
    super arguments...
    
    @desktop = @interface.ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop
    
    activateAudio = (filled) =>
      return unless @desktop.drawingActive()
      
      if filled
        @desktop.audio.rulerActivateFilled()
      
      else
        @desktop.audio.rulerActivate()
  
    Tracker.triggerOnDefinedChange =>
      @interface.getOperator(LOI.Assets.SpriteEditor.Tools.Rectangle).data.get 'filled'
    ,
      activateAudio
    
    Tracker.triggerOnDefinedChange =>
      @interface.getOperator(LOI.Assets.SpriteEditor.Tools.Ellipse).data.get 'filled'
    ,
      activateAudio

    @paletteData = new ComputedField =>
      @interface.getLoaderForActiveFile()?.asset()?.getRestrictedPalette()
    
    @paintHelper = @interface.getHelper LOI.Assets.SpriteEditor.Helpers.Paint
    
    @currentColor = new ComputedField =>
      return unless paletteColor = @paintHelper.paletteColor()
      return unless colorData = @paletteData()?.ramps[paletteColor.ramp]?.shades[paletteColor.shade]
      color = THREE.Color.fromObject colorData
      color.multiplyScalar 255
      color
      
  onRendered: ->
    super arguments...
    
    @lineIndicatorImage = new @constructor.IndicatorImage @, '/pixelartacademy/pixelpad/apps/drawing/editor/desktop/ruler-line.png', '.line.indicator', @currentColor
    @rectangleIndicatorImage = new @constructor.IndicatorImage @, '/pixelartacademy/pixelpad/apps/drawing/editor/desktop/ruler-rectangle.png', '.rectangle .outlined.indicator', @currentColor
    @filledRectangleIndicatorImage = new @constructor.IndicatorImage @, '/pixelartacademy/pixelpad/apps/drawing/editor/desktop/ruler-rectangle-filled.png', '.rectangle .filled.indicator', @currentColor
    @ellipseIndicatorImage = new @constructor.IndicatorImage @, '/pixelartacademy/pixelpad/apps/drawing/editor/desktop/ruler-ellipse.png', '.ellipse .outlined.indicator', @currentColor
    @filledEllipseIndicatorImage = new @constructor.IndicatorImage @, '/pixelartacademy/pixelpad/apps/drawing/editor/desktop/ruler-ellipse-filled.png', '.ellipse .filled.indicator', @currentColor
  
  onDestroyed: ->
    super arguments...
    
    @lineIndicatorImage?.destroy()
    @rectangleIndicatorImage?.destroy()
    @filledRectangleIndicatorImage?.destroy()
    @ellipseIndicatorImage?.destroy()
    @filledEllipseIndicatorImage?.destroy()
    
  rectangleFilledClass: ->
    rectangle = @interface.getOperator LOI.Assets.SpriteEditor.Tools.Rectangle
    'filled' if rectangle.data.get 'filled'
    
  ellipseFilledClass: ->
    ellipse = @interface.getOperator LOI.Assets.SpriteEditor.Tools.Ellipse
    'filled' if ellipse.data.get 'filled'

  class @IndicatorImage
    @templateImageData = {}
    
    constructor: (@ruler, @url, @parentSelector, @currentColor) ->
      unless @constructor.templateImageData[@url]
        # Start the loading of the template.
        @constructor.templateImageData[@url] ?= new ReactiveField null
        
        templateImage = new Image
        templateImage.addEventListener 'load', =>
          @constructor.templateImageData[@url] new AM.ReadableCanvas(templateImage).getFullImageData()
        
        # Initiate the loading.
        templateImage.src = Meteor.absoluteUrl @url
        
      @canvas = new ReactiveField null
      @canvasImageData = new ReactiveField null
      
      # Create the canvas with template's alpha channel.
      @_createCanvasAutorun = Tracker.autorun (computation) =>
        return unless templateImageData = @constructor.templateImageData[@url]()
        computation.stop()

        canvas = new AM.ReadableCanvas templateImageData.width, templateImageData.height
        $(canvas).css
          width: "#{templateImageData.width}rem"
          height: "#{templateImageData.height}rem"
        @ruler.$(@parentSelector).prepend canvas
        
        canvasImageData = canvas.getFullImageData()
        
        for x in [0...canvasImageData.width]
          for y in [0...canvasImageData.height]
            index = (y * canvasImageData.width + x) * 4
            continue unless templateImageData.data[index + 3]
            
            canvasImageData.data[index + 3] = 255
        
        canvas.putFullImageData canvasImageData
        
        @canvas canvas
        @canvasImageData canvasImageData

      # Apply the color channel.
      @_changeColorAutorun = Tracker.autorun (computation) =>
        return unless templateImageData = @constructor.templateImageData[@url]()
        return unless canvasImageData = @canvasImageData()
        
        color = @currentColor()
        
        for x in [0...canvasImageData.width]
          for y in [0...canvasImageData.height]
            index = (y * canvasImageData.width + x) * 4
            canvasImageData.data[index] = color?.r ? templateImageData.data[index]
            canvasImageData.data[index + 1] = color?.g ? templateImageData.data[index + 1]
            canvasImageData.data[index + 2] = color?.b ? templateImageData.data[index + 2]
        
        @canvas().putFullImageData canvasImageData
        
    destroy: ->
      @_createCanvasAutorun.stop()
      @_changeColorAutorun.stop()
