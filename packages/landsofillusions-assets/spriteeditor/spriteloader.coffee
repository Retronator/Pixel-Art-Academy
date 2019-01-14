FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.SpriteLoader
  constructor: (@spriteId) ->
    @_subscription = LOI.Assets.Asset.forId.subscribe LOI.Assets.Sprite.className, @spriteId

    @sprite = new ComputedField =>
      LOI.Assets.Sprite.documents.findOne @spriteId

    # Create the alias for universal operators.
    @asset = @sprite

    @paletteId = new ComputedField =>
      @sprite()?.palette?._id

    # Subscribe to a referenced palette.
    @_paletteSubscription = Tracker.autorun (computation) =>
      return unless paletteId = @paletteId()
      LOI.Assets.Palette.forId.subscribe paletteId

    @palette = new ComputedField =>
      if paletteId = @paletteId()
        LOI.Assets.Palette.documents.findOne paletteId

      else
        # See if we have an embedded custom palette.
        @sprite()?.customPalette

  destroy: ->
    @_subscription.stop()
    @sprite.stop()
    @paletteId.stop()
    @_paletteSubscription.stop()
    @palette.stop()
