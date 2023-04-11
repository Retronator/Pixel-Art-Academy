AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelBoy.Apps.Drawing.Editor.AssetLoader extends FM.Loader
  constructor: ->
    super arguments...
    
    @drawing = @interface.ancestorComponentOfType PAA.PixelBoy.Apps.Drawing
    @portfolio = @drawing.portfolio()
    @editor = @drawing.editor()
  
    @asset = new ComputedField =>
      @editor.manualSpriteData() or @portfolio.displayedAsset()?.asset.document?()
  
    # Subscribe to the referenced palette as well.
    @paletteId = new ComputedField =>
      @asset()?.palette?._id
  
    @_paletteSubscription = Tracker.autorun (computation) =>
      return unless paletteId = @paletteId()
      LOI.Assets.Palette.forId.subscribeContent paletteId

    # We extract the custom palette separately to minimize reactivity.
    @customPalette = new ComputedField =>
      @asset()?.customPalette
    ,
      EJSON.equals
  
    @palette = new ComputedField =>
      if paletteId = @paletteId()
        LOI.Assets.Palette.documents.findOne paletteId
    
      else
        # See if we have an embedded custom palette.
        @customPalette()
        
  destroy: ->
    @asset.stop()
    @paletteId.stop()
    @_paletteSubscription.stop()
    @palette.stop()
