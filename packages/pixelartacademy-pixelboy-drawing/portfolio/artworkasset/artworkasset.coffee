AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelBoy.Apps.Drawing.Portfolio.ArtworkAsset extends PAA.PixelBoy.Apps.Drawing.Portfolio.Asset
  constructor: (@artworkId) ->
    super arguments...
    
    @artwork = new ComputedField =>
      PADB.Artwork.documents.findOne @artworkId
  
    @document = new ComputedField =>
      return unless artwork = @artwork()
      return unless documentRepresentation = _.find artwork.representations, (representation) => representation.type is PADB.Artwork.RepresentationTypes.Document

      # Extract the type and ID.
      url = new URL Meteor.absoluteUrl documentRepresentation.url
      id = url.searchParams.get 'id'
  
      LOI.Assets.Sprite.documents.findOne id if _.startsWith documentRepresentation.url, LOI.Assets.Sprite.documentUrl
  
    @portfolioComponent = new @constructor.PortfolioComponent @
    @clipboardComponent = new @constructor.ClipboardComponent @

  displayName: -> @artwork()?.title or 'Untitled'
  
  description: ->
    return unless document = @document()
    
    parts = []
    
    if bounds = document.bounds
      parts.push "Size: #{bounds.width}x#{bounds.height}"
      
    if palette = document.palette
      parts.push "Palette: #{palette.name}"
      
    parts.join ', '
  
  width: -> @document()?.bounds?.width or 1
  height: -> @document()?.bounds?.height or 1
  
  urlParameter: -> @artworkId
  
  freeform: ->
    return unless document = @document()
    not document.bounds?.fixed
    
  spriteId: ->
    return unless document = @document()
    return unless document instanceof LOI.Assets.Sprite
    document._id
