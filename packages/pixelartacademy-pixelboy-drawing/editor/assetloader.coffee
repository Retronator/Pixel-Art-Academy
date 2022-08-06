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
      LOI.Assets.Palette.forId.subscribe paletteId
  
    @palette = new ComputedField =>
      if paletteId = @paletteId()
        LOI.Assets.Palette.documents.findOne paletteId
    
      else
        # See if we have an embedded custom palette.
        @asset()?.customPalette
        
  destroy: ->
    @asset.stop()
    @paletteId.stop()
    @_paletteSubscription.stop()
    @palette.stop()
