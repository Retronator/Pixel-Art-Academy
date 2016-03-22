PAA = PixelArtAcademy

class PAA.Artworks.Artwork extends Document
  # title: the (working) title of the artwork
  # wip: boolean whether this is an unfinished snapshot
  # artist: the author of the artwork
  #   _id
  #   displayName
  # image:
  #   url: link to the image in the CDN
  #   pixelScale: pixel size for display of pixel art images
  #
  @Meta
    name: 'Artwork'
    fields: =>
      artist: @ReferenceField PAA.Artworks.Artist, ['displayName'], false

  @defaultData: ->
    title: null
    wip: false
