AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

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

  constructor: ->
    super arguments...

    @portfolio = new ReactiveField null
    @clipboard = new ReactiveField null
    @editor = new ReactiveField null

  onCreated: ->
    super arguments...

    # Initialize components.
    @portfolio new @constructor.Portfolio @
    @clipboard new @constructor.Clipboard @
    @editor new @constructor.Editor.Desktop @
    
    @displayedAssetCustomComponent = new ComputedField =>
      portfolio = @portfolio()
      return unless portfolio.isCreated()
      
      portfolio.displayedAsset()?.asset.customComponent

    @autorun (computation) =>
      portfolio = @portfolio()
      editor = @editor()
      displayedAssetCustomComponent = @displayedAssetCustomComponent()

      if portfolio.isCreated() and portfolio.activeAsset()
        if editor.active()
          @setMaximumPixelPadSize fullscreen: true

        else if displayedAssetCustomComponent
          displayedAssetCustomComponent.setPixelPadSize @
          
        else
          @setFixedPixelPadSize 200, 260

      else
        @setFixedPixelPadSize 332, 241

  onDestroyed: ->
    super arguments...
    
    @editor().destroy()

  onBackButton: ->
    # Relay to editor.
    result = @editor().onBackButton?()
    return result if result?

    # Relay to clipboard.
    result = @clipboard().onBackButton?()
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

  activeAssetClass: ->
    portfolio = @portfolio()

    'active-asset' if portfolio.isCreated() and portfolio.activeAsset()

  editorActiveClass: ->
    'editor-active' if @editor().active()

  editorFocusedModeClass: ->
    'editor-focused-mode' if @editor().focusedMode?()

  editorClass: ->
    @editor()?.constructor.styleClass()
