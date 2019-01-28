FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.SpriteLoader extends FM.Loader
  constructor: ->
    super arguments...

    @_subscription = LOI.Assets.Asset.forIdFull.subscribe LOI.Assets.Sprite.className, @fileId

    @spriteData = new ComputedField =>
      LOI.Assets.Sprite.documents.findOne @fileId

    # Create the alias for universal operators.
    @asset = @spriteData

    @paintNormalsData = @interface.getComponentData(LOI.Assets.SpriteEditor.Tools.Pencil).child 'paintNormals'

    # Create the engine sprite.
    @sprite = new LOI.Assets.Engine.Sprite
      spriteData: @spriteData
      visualizeNormals: @paintNormalsData.value

    # Subscribe to the referenced palette as well.
    @paletteId = new ComputedField =>
      @spriteData()?.palette?._id

    @_paletteSubscription = Tracker.autorun (computation) =>
      return unless paletteId = @paletteId()
      LOI.Assets.Palette.forId.subscribe paletteId

    @palette = new ComputedField =>
      if paletteId = @paletteId()
        LOI.Assets.Palette.documents.findOne paletteId

      else
        # See if we have an embedded custom palette.
        @spriteData()?.customPalette

  destroy: ->
    @_subscription.stop()
    @spriteData.stop()
    @paletteId.stop()
    @_paletteSubscription.stop()
    @palette.stop()
