AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset extends PAA.PixelPad.Apps.Drawing.Portfolio.Asset
  constructor: (@artworkId) ->
    super arguments...
    
    @artwork = new ComputedField =>
      PADB.Artwork.documents.findOne @artworkId
  
    @document = new ComputedField =>
      return unless artwork = @artwork()
      return unless documentRepresentation = artwork.firstDocumentRepresentation()

      # Extract the type and ID.
      url = new URL Meteor.absoluteUrl documentRepresentation.url
      id = url.searchParams.get 'id'
  
      for documentClassName in ['Sprite', 'Bitmap'] when _.startsWith documentRepresentation.url, LOI.Assets[documentClassName].documentUrl()
        return LOI.Assets[documentClassName].getDocumentForId id
        
      null
      
    @_palettesAutorun = Tracker.autorun (computation) =>
      return unless document = @document()
      return unless paletteIds = document.getAllPaletteIds()
      LOI.Assets.Palette.forIds.subscribeContent paletteIds
  
    @portfolioComponent = new @constructor.PortfolioComponent @
    @clipboardComponent = new @constructor.ClipboardComponent @
    @changeArtworkComponent = new @constructor.ChangeArtwork @
    
  destroy: ->
    @_palettesAutorun.stop()

  displayName: -> @artwork()?.title or 'Untitled'
  
  description: ->
    return unless document = @document()
    
    parts = []
    
    if bounds = document.bounds
      parts.push "Size: #{bounds.width}x#{bounds.height}"
      
    if palette = document.palette
      palette.refresh()
      parts.push "Palette: #{palette.name}"
      
    parts.join ', '
  
  width: -> @document()?.bounds?.width or 1
  height: -> @document()?.bounds?.height or 1
  portfolioBorderWidth: -> if @document()?.properties?.canvasBorder then 6 else 0
  pixelArtScaling: -> @document()?.properties?.pixelArtScaling
  
  urlParameter: -> @artworkId
  
  ready: ->
    # Asset is ready when the artwork document has been loaded.
    @document()
  
  freeform: ->
    return unless document = @document()
    not document.bounds?.fixed
