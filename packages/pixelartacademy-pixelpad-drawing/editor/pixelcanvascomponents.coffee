AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
FM = FataMorgana

class PAA.PixelPad.Apps.Drawing.Editor.PixelCanvasComponents extends FM.Helper
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.PixelCanvasComponents'
  @initialize()
  
  constructor: ->
    super arguments...
    
    @drawing = @interface.ancestorComponentOfType PAA.PixelPad.Apps.Drawing
  
    @components = new ComputedField =>
      return unless editor = @drawing.editor()
      return unless editor.isCreated()
      editorActive = editor.active()

      # Add components from the displayed asset and editor.
      displayedAsset = editor.displayedAsset()
      providers = [displayedAsset, editor]
      
      components = []
    
      for provider in providers
        # Add any custom components that are visible all the time.
        if assetComponents = provider?.drawComponents?()
          components.push assetComponents...
      
        # Add components visible only in the editor.
        if editorActive
          if assetComponents = provider?.editorDrawComponents?()
            components.push assetComponents...
      
      # Set extra info to components
      backgroundColor = displayedAsset?.backgroundColor?()
      backgroundColor ?= LOI.Assets.Palette.defaultPalette()?.color LOI.Assets.Palette.Atari2600.hues.gray, 7
    
      for componentInfo in components
        component = componentInfo.component or componentInfo

        component.options.backgroundColor = backgroundColor
    
      components
    ,
      true
    
  destroy: ->
    @components.stop()
