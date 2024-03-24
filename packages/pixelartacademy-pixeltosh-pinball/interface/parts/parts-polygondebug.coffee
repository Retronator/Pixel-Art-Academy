AC = Artificial.Control
AM = Artificial.Mirage
AP = Artificial.Pyramid
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Interface.Parts extends Pinball.Interface.Parts
  @register @id()
  
  @polygonDebug = false
  
  onCreated: ->
    super arguments...
    
    return unless @constructor.polygonDebug

    @polygonDebugCanvas = new AM.Canvas
    @polygonDebugTrianglesDrawCount = new ReactiveField -1
    
    $(document).on 'keydown.pixelartacademy-pixeltosh-programs-pinball-interface-parts', (event) =>
      switch event.which
        when AC.Keys.period then delta = 1
        when AC.Keys.comma then delta = -1
      
      return unless delta
      
      @polygonDebugTrianglesDrawCount @polygonDebugTrianglesDrawCount() + delta
  
  onRendered: ->
    super arguments...
    
    return unless @constructor.polygonDebug
    
    $polygonDebug = @$('.polygon-debug')
    $polygonDebug.append @polygonDebugCanvas
    
    context = @polygonDebugCanvas.context
    
    @autorun =>
      @pinball.os.display.scale()
      
      @polygonDebugCanvas.width = $polygonDebug.width() * devicePixelRatio
      @polygonDebugCanvas.height = $polygonDebug.height() * devicePixelRatio
      
      parts = @pinball.sceneManager().parts()
      return unless playfield = _.find parts, (part) => part instanceof Pinball.Parts.Playfield
      
      context.setTransform 1, 0, 0, 1, 0, 0
      context.clearRect 0, 0, @polygonDebugCanvas.width, @polygonDebugCanvas.height
    
      scale = @polygonDebugCanvas.width / 0.53
      context.scale scale, scale
      context.translate 0.015, 0.015

      drawPolygon = (style, lineWidth, polygon) =>
        context.strokeStyle = style
        context.lineWidth = lineWidth / scale
        
        context.beginPath()
        
        lastVertex = _.last polygon.vertices
        context.moveTo lastVertex.x, lastVertex.y
        
        for vertex in polygon.vertices
          context.lineTo vertex.x, vertex.y
          
        context.stroke()
      
      holeBoundaries = []
      
      for part in parts
        holeBoundaries.push partHoleBoundaries... if partHoleBoundaries = part.playfieldHoleBoundaries()

      for holeBoundary in holeBoundaries
        drawPolygon 'yellow', 8, holeBoundary
      
      return unless playfield.avatar.shape()
      return unless playfieldBoundary = playfield.avatar.playfieldBoundingRectangle()?.getBoundary()
      
      playfieldPolygon = new AP.PolygonWithHoles playfieldBoundary, holeBoundaries
      playfieldPolygon = playfieldPolygon.getPolygonWithoutHoles()
      
      insetPolygon = playfieldPolygon.getInsetPolygon 0.002
      
      drawPolygon 'blue', 2, insetPolygon
      
      indexBufferArray = playfieldPolygon.triangulate()
      
      trianglesDrawCount = @polygonDebugTrianglesDrawCount()
      
      for indexOfIndex in [0...indexBufferArray.length] by 3
        return unless trianglesDrawCount
        trianglesDrawCount--

        drawPolygon 'green', 1, vertices: [
          insetPolygon.vertices[indexBufferArray[indexOfIndex]]
          insetPolygon.vertices[indexBufferArray[indexOfIndex + 1]]
          insetPolygon.vertices[indexBufferArray[indexOfIndex + 2]]
        ]
  
  onDestroyed: ->
    super arguments...
    
    return unless @constructor.polygonDebug

    $(document).off '.pixelartacademy-pixeltosh-programs-pinball-interface-parts'
