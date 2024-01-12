AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.AssetLoader extends FM.Loader
  constructor: ->
    super arguments...
    
    @drawing = @interface.ancestorComponentOfType PAA.PixelPad.Apps.Drawing
    @portfolio = @drawing.portfolio()
    @editor = @drawing.editor()
  
    @asset = new ComputedField =>
      asset = @editor.manualSpriteData() or @portfolio.displayedAsset()?.asset.document?()
  
      # We can only deal with assets that can return pixels.
      if asset instanceof LOI.Assets.Sprite or asset instanceof LOI.Assets.Bitmap then asset else null
    ,
      true
  
    # Subscribe to the referenced palette as well.
    @paletteIds = new ComputedField =>
      @asset()?.getAllPaletteIds()
    ,
      true
  
    @_palettesSubscription = Tracker.autorun (computation) =>
      return unless paletteIds = @paletteIds()
      LOI.Assets.Palette.forIds.subscribeContent paletteIds

    # We extract the custom palette separately to minimize reactivity.
    @customPalette = new ComputedField =>
      @asset()?.customPalette
    ,
      EJSON.equals
  
    @palettes = new ComputedField =>
      if paletteIds = @paletteIds()
        LOI.Assets.Palette.documents.fetch _id: $in: paletteIds
    
      else
        # See if we have an embedded custom palette.
        if customPalette = @customPalette()
          [customPalette]
          
        else
          []
    ,
      true
    
    @palette = new ComputedField =>
      @palettes()[0]
    ,
      true
      
  destroy: ->
    @asset.stop()
    @paletteIds.stop()
    @_palettesSubscription.stop()
    @palettes.stop()
    @palette.stop()
