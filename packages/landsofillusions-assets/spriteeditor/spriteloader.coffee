FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.SpriteLoader extends FM.Loader
  constructor: ->
    super arguments...

    @_subscription = LOI.Assets.Asset.forId.subscribe LOI.Assets.Sprite.className, @fileId

    @spriteData = new ComputedField =>
      LOI.Assets.Sprite.documents.findOne @fileId
    ,
      true

    # Create the alias for universal operators.
    @asset = @spriteData

    @displayName = new ComputedField =>
      return unless spriteData = @spriteData()
      spriteData.name or spriteData._id
    ,
      true
    
    # Subscribe to the referenced palettes as well.
    @paletteIds = new ComputedField =>
      @spriteData()?.getAllPaletteIds()
    ,
      true
    
    @_palettesSubscription = Tracker.autorun (computation) =>
      return unless paletteIds = @paletteIds()
      LOI.Assets.Palette.forIds.subscribe paletteIds

  destroy: ->
    @_subscription.stop()
    @spriteData.stop()
    @paletteIds.stop()
    @_palettesSubscription.stop()
