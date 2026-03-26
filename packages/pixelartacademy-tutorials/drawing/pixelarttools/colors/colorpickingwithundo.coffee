AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtTools.Colors.ColorPickingWithUndo extends PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap
  constructor: ->
    super arguments...
  
    @unlockUndo = new ReactiveField false
  
  class @Error extends PAA.Tutorials.Drawing.Instructions.Instruction
    @id: -> "#{Asset.id()}.Error"
    @assetClass: -> Asset
    
    @message: -> """
      You have overwritten the correct colors and can't complete the lesson anymore. Use the undo button to get back on track.
    """
    
    @priority: -> 1
    
    constructor: ->
      super arguments...
      
      @amountOfColors = new AE.LiveComputedField =>
        return unless asset = @getActiveAsset()
        return unless bitmapLayer = asset.bitmap()?.layers[0]
        colors = []
        
        # Find unique colors in the bitmap.
        for x in [bitmapLayer.bounds.x...bitmapLayer.bounds.x + bitmapLayer.bounds.width]
          for y in [bitmapLayer.bounds.y...bitmapLayer.bounds.y + bitmapLayer.bounds.height]
            continue unless pixel = bitmapLayer.getPixel x, y
            
            colorFound = false
            
            for color in colors
              if EJSON.equals color, pixel.paletteColor
                colorFound = true
                break
                
            colors.push pixel.paletteColor unless colorFound
        
        colors.length
        
      @initialAmountOfColors = new ReactiveField 0
      
      @_updateInitialAmountOfColorsAutorun = Tracker.autorun (computation) =>
        amountOfColors = @amountOfColors() or 0
        
        Tracker.nonreactive =>
          @initialAmountOfColors Math.max @initialAmountOfColors(), amountOfColors
          
    destroy: ->
      super arguments...
      
      @amountOfColors.stop()
      @_updateInitialAmountOfColorsAutorun.stop()
      
    activeConditions: ->
      return unless @getActiveAsset()
      
      # Show when you don't have all the initial colors available anymore.
      @amountOfColors() < @initialAmountOfColors()
      
    onDisplayed: ->
      # Unlock the undo.
      asset = @constructor.getActiveAsset()
      asset.unlockUndo true
