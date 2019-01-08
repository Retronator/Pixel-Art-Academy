AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor extends LOI.Assets.Editor
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor'
  
  constructor: ->
    super arguments...

    @sprite = new ReactiveField null
    @pixelCanvas = new ReactiveField null

    @lightDirection = new ReactiveField new THREE.Vector3(0, 0, -1).normalize()
    @paintNormals = new ReactiveField false
    @symmetryXOrigin = new ReactiveField null

    @documentClass = LOI.Assets.Sprite
    @assetClassName = @documentClass.className

  onCreated: ->
    super arguments...

    # Initialize components.
    @pixelCanvas new LOI.Assets.Components.PixelCanvas
      initialCameraScale: 8
      activeTool: @activeTool
      lightDirection: @lightDirection
      drawComponents: => [
        @sprite()
        @landmarks()
      ]
      symmetryXOrigin: @symmetryXOrigin

  onRendered: ->
    super arguments...

    editorView = @interface.allChildComponentsOfType(FM.EditorView)[0]
    editorView.addFile id for id in ['CX9JyXqW2mZduyajR', 'KqL3XmQ7MikndhWxN']
