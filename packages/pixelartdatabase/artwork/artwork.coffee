AB = Artificial.Base
AM = Artificial.Mummification
PADB = PixelArtDatabase

class PADB.Artwork extends AM.Document
  @id: -> 'PixelArtDatabase.Artwork'
  # type: type of this artwork
  # title: the (working) title of the artwork
  # completionDate: completion date of this artwork or object when exact date is not known
  #   year: year of completion, if known
  #   month: month of completion, if known (1-based)
  #   day: day of completion, if known
  # startDate: start date of this artwork or object when exact date is not known
  #   year: year of start, if known
  #   month: month of start, if known (1-based)
  #   day: day of start, if known
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
    # Physical 2D artwork
    Physical: 'Physical'

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
  @forUrl: new AB.Subscription
    name: "#{@id()}.forUrl"
    query: (url) =>
      # Match artworks both by image and representation urls.
      @documents.find
        $or: [
          'image.url': url
        ,
          'representations.url': url
        ]

  # Returns the first image representation.
  firstImageRepresentation: ->
    _.find @representations, type: PADB.Artwork.RepresentationTypes.Image
