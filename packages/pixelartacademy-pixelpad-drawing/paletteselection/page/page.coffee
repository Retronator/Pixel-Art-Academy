AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.PaletteSelection.Page extends LOI.Component
  @pageTemplateImageData = new ReactiveField null
  
  constructor: ->
    super arguments...
    
    @width = 224
    @height = 53

  onCreated: ->
    super arguments...
    
    unless @constructor._pageTemplateImageDataLoading
      # Start the loading of the template.
      @constructor._pageTemplateImageDataLoading = true
      
      pageTemplateImage = new Image
      pageTemplateImage.addEventListener 'load', =>
        @constructor.pageTemplateImageData new AM.ReadableCanvas(pageTemplateImage).getFullImageData()
      
      # Initiate the loading.
      pageTemplateImage.src = Meteor.absoluteUrl '/pixelartacademy/pixelpad/apps/drawing/paletteselection/page-template.png'
    
    # Create the canvases
    @bottomCanvas = new AM.ReadableCanvas @width, @height
    @topCanvas = new AM.ReadableCanvas @width, @height
    
    @bottomCanvas.className = 'bottom-canvas'
    @topCanvas.className = 'top-canvas'
    
    @bottomCanvasImageData = @bottomCanvas.getFullImageData()
    @topCanvasImageData = @topCanvas.getFullImageData()
    
    # Apply the alpha channel.
    @autorun (computation) =>
      return unless pageTemplateImageData = @constructor.pageTemplateImageData()
      computation.stop()
      
      for x in [0...@width]
        for y in [0...@height]
          index = (y * @width + x) * 4
          continue unless pageTemplateImageData.data[index + 3]
          
          @bottomCanvasImageData.data[index + 3] = 255
          @topCanvasImageData.data[index + 3] = 255
          
      @bottomCanvas.putFullImageData @bottomCanvasImageData
      @topCanvas.putFullImageData @topCanvasImageData
      
  onRendered: ->
    super arguments...
    
    @$('.page').prepend(@topCanvas).prepend(@bottomCanvas)
  
  applyCanvases: ->
    # Shade bottom canvas.
    for x in [0...@width]
      for y in [0...@height]
        index = (y * @width + x) * 4
        
        for offset in [0..2]
          @bottomCanvasImageData.data[index + offset] = @topCanvasImageData.data[index + offset] * 0.5
    
    # Put data into canvases.
    @bottomCanvas.putFullImageData @bottomCanvasImageData
    @topCanvas.putFullImageData @topCanvasImageData
