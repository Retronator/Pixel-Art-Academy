AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelBoy.Apps.Drawing.Editor.PixelCanvasComponents extends FM.Helper
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.PixelCanvasComponents'
  @initialize()
  
  constructor: ->
    super arguments...
    
    @drawing = @interface.ancestorComponentOfType PAA.PixelBoy.Apps.Drawing
  
    @components = new ComputedField =>
      editor = @drawing.editor()
      displayedAsset = editor.displayedAsset()
      
      components = []
    
      # Add any custom components that are visible all the time.
      if assetComponents = displayedAsset?.drawComponents?()
        components.push assetComponents...
    
      # Add components visible only in the editor.
      if @drawing.editor().active()
        if assetComponents = displayedAsset?.editorDrawComponents?()
          components.push assetComponents...
    
      # Set extra info to components
      backgroundColor = displayedAsset?.backgroundColor?()
      backgroundColor ?= LOI.Assets.Palette.defaultPalette().color LOI.Assets.Palette.Atari2600.hues.gray, 7
    
      for componentInfo in components
        component = componentInfo.component or componentInfo

        component.options.backgroundColor = backgroundColor
    
      components
      
  destroy: ->
    @components.stop()
