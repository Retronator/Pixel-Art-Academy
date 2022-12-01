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
    ,
      true
  
    # Subscribe to the referenced palettes as well.
    @paletteIds = new ComputedField =>
      @asset()?.getAllPaletteIds()
    ,
      true
  
    @_palettesSubscription = Tracker.autorun (computation) =>
      return unless paletteIds = @paletteIds()
      LOI.Assets.Palette.forIds.subscribe paletteIds

  destroy: ->
    @asset.stop()
    @paletteIds.stop()
    @_palettesSubscription.stop()
