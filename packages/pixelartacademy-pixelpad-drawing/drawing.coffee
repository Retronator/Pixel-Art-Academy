AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class PAA.PixelPad.Apps.Drawing extends PAA.PixelPad.App
  # editorId: which editor component to use for editing sprites in the app
  # externalSoftware: which external software the player is using to edit sprites
  # artworks: array of manually created artworks
  #   artworkId: the ID of the artwork document
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing'
  @url: -> 'drawing'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Drawing"
  @description: ->
    "
      It's the app for drawing pixel art.
    "
    
  @initialize()
  
  @canEdit: ->
    # Editor needs to be selected.
    return unless @state('editorId')

    # Player must have completed the reference copy challenge with a built-in editor.
    PAA.Practice.Project.Asset.Bitmap.state 'canEdit'

  @canUpload: ->
    # External software needs to be selected.
    return unless @state('externalSoftware')
  
    # Player must have completed the reference copy challenge by uploading the result.
    PAA.Practice.Project.Asset.Bitmap.state 'canUpload'
    
  @canCreateArtworks: ->
    PAA.Practice.Project.Asset.Bitmap.state('unlockedPixelArtEvaluationCriteria')?.length

  constructor: ->
    super arguments...

    @portfolio = new ReactiveField null
    @clipboard = new ReactiveField null
    @paletteSelection = new ReactiveField null
    @editor = new ReactiveField null

  onCreated: ->
    super arguments...

    # Initialize components.
    @portfolio new @constructor.Portfolio @
    @clipboard new @constructor.Clipboard @
    
    # Pre-load palette selection audio since we're creating the palette selection component ad-hoc.
    PAA.PixelPad.Apps.Drawing.PaletteSelection.Audio.load LOI.adventure.audioManager
    
    @autorun (computation) =>
      return unless editorId = @state('editorId')
      
      editorClass = LOI.Adventure.Thing.getClassForId editorId
      @editor new editorClass @
    
    @displayedAssetCustomComponent = new ComputedField =>
      portfolio = @portfolio()
      return unless portfolio.isCreated()
      
      portfolio.displayedAsset()?.asset.customComponent

    @autorun (computation) =>
      portfolio = @portfolio()
      editor = @editor()
      displayedAssetCustomComponent = @displayedAssetCustomComponent()

      if portfolio.isCreated() and portfolio.activeAsset()
        if editor.active() or @paletteSelection()?.activatable.activating() or @paletteSelection()?.activatable.activated()
          @setMaximumPixelPadSize fullscreen: true

        else if displayedAssetCustomComponent
          displayedAssetCustomComponent.setPixelPadSize @
          
        else
          @setFixedPixelPadSize 200, 260

      else
        @setFixedPixelPadSize 332, 241

  onDestroyed: ->
    super arguments...
    
    PAA.PixelPad.Apps.Drawing.PaletteSelection.Audio.unload()
    
    @editor().destroy()

  onBackButton: ->
    # Relay to palette selection.
    result = @paletteSelection()?.onBackButton()
    return result if result?

    # Relay to editor.
    result = @editor().onBackButton()
    return result if result?

    # Relay to clipboard.
    result = @clipboard().onBackButton()
    return result if result?
    
    # Relay to displayed asset custom component.
    result = @displayedAssetCustomComponent()?.onBackButton?()
    return result if result?
    
    portfolio = @portfolio()

    # We only need to handle closing groups when not on an asset.
    return unless portfolio.activeGroup() and not portfolio.activeAsset()

    # Close the group.
    portfolio.activeGroup null

    # Inform that we've handled the back button.
    true
  
  showPaletteSelection: (paletteName) ->
    paletteSelection = new @constructor.PaletteSelection paletteName
    @paletteSelection paletteSelection
    
    new Promise (resolve, reject) =>
      # Wait until palette selection has been activating and deactivating again.
      componentWasActivating = false

      # Wait for the component to be rendered.
      Tracker.afterFlush =>
        paletteSelection.activatable.activate()
        
        Tracker.autorun (computation) =>
          if paletteSelection.activatable.activating()
            componentWasActivating = true
          
          else if paletteSelection.activatable.deactivating() and componentWasActivating
            resolve paletteSelection.selectedPalette
            
          else if paletteSelection.activatable.deactivated() and componentWasActivating
            computation.stop()
            @paletteSelection null
  
  inGameMusicMode: ->
    # Play music in location when in the editor or if the asset requests it.
    if activeAsset = @portfolio()?.activeAsset()
      return activeAsset.inGameMusicMode() if activeAsset.inGameMusicMode
    
    if @editor()?.active() then LM.Interface.InGameMusicMode.InLocation else LM.Interface.InGameMusicMode.Direct

  activeAsset: ->
    portfolio = @portfolio()
    return unless portfolio.isCreated()
    
    portfolio.activeAsset()

  activeAssetClass: ->
    'active-asset' if @activeAsset()
  
  editorVisibleClass: ->
    'editor-visible' if @editor().visible()

  editorActiveClass: ->
    'editor-active' if @editor().active()

  editorFocusedModeClass: ->
    'editor-focused-mode' if @editor().focusedMode?()

  editorClass: ->
    @editor()?.constructor.styleClass()
