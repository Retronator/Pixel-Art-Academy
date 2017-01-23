AM = Artificial.Mummification
PADB = PixelArtDatabase

class PADB.Artwork extends AM.Document
  @id: -> 'PixelArtDatabase.Artwork'
  # type: type of this artwork
  # title: the (working) title of the artwork
  # completionDate: completion date of this artwork
  # startDate: start date of this artwork
  # wip: boolean whether this is an unfinished snapshot
  # authors: array of artists that created this artwork
  #   _id
  #   displayName
  # image: main, cached image that we display for this artwork
  #   url: link to the image in the CDN
  #   pixelScale: pixel size for display of pixel art images
  # representations: array of online resources representing this artwork
  #   url: address of this resource
  #   type: type of the resource
  @Meta
    name: @id()
    fields: =>
      authors: [@ReferenceField PADB.Artist, ['displayName'], true, 'artworks', ['title']]

  @Types:
    # Static image
    Image: 'Image'
    # Short animated work, usually in form of a GIF
    AnimatedImage: 'AnimatedImage'
    # Longer animated work, such as a music video
    Video: 'Video'

  @RepresentationTypes:
    # Resource of MIME type image
    Image: 'Image'
    # Resource of MIME type video
    Video: 'Video'
    # Location of a timelapse video of the artwork
    Timelapse: 'Timelapse'
    # Online article or blog post about this artwork
    Post: 'Post'

  # Methods

  @insert: @method 'insert'

  # Subscriptions

  @all: @subscription 'all'
