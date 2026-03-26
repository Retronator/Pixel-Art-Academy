AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.Desktop.Palette.ColorHelp extends AM.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Palette.ColorHelp'
  @register @id()
  
  constructor: (@palette) ->
    super arguments...
    
    @visible = new ReactiveField false
  
  visibleClass: ->
    'visible' if @visible()
    
  events: ->
    super(arguments...).concat
      'click .close-button': @onClickCloseButton
      
  onClickCloseButton: (event) ->
    @visible false
    
  class @DataInputComponent extends AM.DataInputComponent
    onCreated: ->
      super arguments...
      
      @colorHelp = @ancestorComponentOfType PAA.PixelPad.Apps.Drawing.Editor.Desktop.Palette.ColorHelp

  class @OneTimeHelp extends @DataInputComponent
    @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Palette.ColorHelp.OneTimeHelp'
    @register @id()
    
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Checkbox
   
    load: ->
      return unless tutorialBitmap = @colorHelp.palette.interface.getEditorForActiveFile().desktop.activeAsset()
      return unless tutorialBitmap.initialized()
      tutorialBitmap.hintsEngineComponents.overlaid.displayAllColorErrors()
    
    save: (value) ->
      tutorialBitmap = @colorHelp.palette.interface.getEditorForActiveFile().desktop.activeAsset()
      tutorialBitmap.hintsEngineComponents.overlaid.displayAllColorErrors value
      return unless value

      tutorialBitmap.hintsEngineComponents.overlaid.displayColorHelpUpToPixelCoordinates {x: 0, y: 0}
      @colorHelp.visible false
      
      Meteor.setTimeout =>
        # Animate the display of hints in 1 second.
        bitmapData = tutorialBitmap.bitmap()
        pixelsCount = bitmapData.bounds.width * bitmapData.bounds.height
        
        if pixelsCount > 100
          hintDisplayDelay = 1000 / bitmapData.bounds.height
          
        else
          hintDisplayDelay = 1000 / pixelsCount
        
        displayHintsUpTo = (x, y) =>
          x = bitmapData.bounds.right if pixelsCount > 100
          tutorialBitmap.hintsEngineComponents.overlaid.displayColorHelpUpToPixelCoordinates {x, y}
    
          # Move to next pixel.
          x++
    
          if x > bitmapData.bounds.right
            x = bitmapData.bounds.left
            y++
            
            return if y > bitmapData.bounds.bottom
    
          Meteor.setTimeout =>
            displayHintsUpTo x, y
          ,
            hintDisplayDelay
        
        displayHintsUpTo bitmapData.bounds.left, bitmapData.bounds.top
      ,
        500

  class @ErrorStyle extends @DataInputComponent
    @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Palette.ColorHelp.ErrorStyle'
    @register @id()
    
    @Names =
      PixelOutline: 'Pixel outline'
      HintOutline: 'Hint outline'
      HintGlow: 'Hint glow'
    
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Radio
      @name = 'error-style'
    
    options: ->
      options = [
        value: null
        name: 'None'
      ]
      
      for errorStyle of PAA.PixelPad.Apps.Drawing.Editor.ColorHelp.ErrorStyle
        options.push
          value: errorStyle
          name: @constructor.Names[errorStyle]
          
      options
      
    load: ->
      PAA.PixelPad.Apps.Drawing.Editor.ColorHelp.errorStyle()
    
    save: (value) ->
      PAA.PixelPad.Apps.Drawing.Editor.ColorHelp.state 'errorStyle', value

  class @HintStyle extends @DataInputComponent
    @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Editor.Desktop.Palette.ColorHelp.HintStyle'
    @register @id()
    
    @Names =
      Dots: 'Dots'
      Symbols: 'Symbols'
    
    constructor: ->
      super arguments...
      
      @type = AM.DataInputComponent.Types.Radio
      @name = 'hint-style'
      
    options: ->
      for hintStyle of PAA.PixelPad.Apps.Drawing.Editor.ColorHelp.HintStyle
        value: hintStyle
        name: @constructor.Names[hintStyle]
      
    load: ->
      PAA.PixelPad.Apps.Drawing.Editor.ColorHelp.hintStyle()
    
    save: (value) ->
      PAA.PixelPad.Apps.Drawing.Editor.ColorHelp.state 'hintStyle', value
