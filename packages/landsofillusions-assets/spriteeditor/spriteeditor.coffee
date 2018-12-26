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

    @spriteId = new ComputedField =>
      AB.Router.getParameter 'spriteId'

    @spriteData = new ComputedField =>
      return unless spriteId = @spriteId()

      LOI.Assets.Asset.forId.subscribe LOI.Assets.Sprite.className, spriteId
      LOI.Assets.Sprite.documents.findOne spriteId

    @paletteId = new ComputedField =>
      # Minimize reactivity to only palette changes.
      LOI.Assets.Sprite.documents.findOne(@spriteId(),
        fields:
          palette: 1
      )?.palette?._id

    @documentClass = LOI.Assets.Sprite
    @assetClassName = 'Sprite'
    @assetData = @spriteData
    @assetId = @spriteId
    @setAssetId = (spriteId) =>
      AB.Router.setParameters {spriteId}
      
    @setPalletteId = (paletteId) =>
      LOI.Assets.Asset.update LOI.Assets.Sprite.className, @spriteId(), $set: palette: _id: paletteId

  onCreated: ->
    super arguments...

    # Initialize components.
    @sprite new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      visualizeNormals: @paintNormals

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

    @interface.displayDialog
      contentComponentId: LOI.Assets.Editor.AssetOpenDialog.id()
