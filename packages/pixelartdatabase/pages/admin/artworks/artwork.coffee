AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.Pages.Admin.Artworks.Artwork extends Artificial.Mummification.Admin.Components.Document
  @register 'PixelArtDatabase.Pages.Admin.Artworks.Artwork'

  constructor: ->
    super

    @previewImage = new ReactiveField null

  onCreated: ->
    super

    # Load the preview image to have measurements.
    @autorun =>
      artwork = @currentData()

      unless artwork?.image?.url
        @previewImage null
        return

      image = new Image()
      image.onload = =>
        console.log "Image loaded", image

        @previewImage image

      image.src = artwork.image.url

  onRendered: ->
    super

  style: ->
    image = @previewImage()
    artwork = @currentData()
    return unless image and artwork

    scale = artwork.image?.pixelScale or 1

    width: "#{image.width * scale}px"
    height: "#{image.height * scale}px"

  class @Title extends AM.DataInputComponent
    @register 'PixelArtDatabase.Artworks.Components.Admin.Artwork.Title'

    load: -> @currentData()?.title

    save: (value) -> Meteor.call "artworkUpdate", @currentData()._id,
      $set:
        title: value

  class @PixelScale extends AM.DataInputComponent
    @register 'PixelArtDatabase.Artworks.Components.Admin.Artwork.PixelScale'

    constructor: ->
      super
      @type = 'number'

    load: -> @currentData()?.image?.pixelScale

    save: (value) -> Meteor.call "artworkUpdate", @currentData()._id,
      $set:
        'image.pixelScale': parseInt(value)
