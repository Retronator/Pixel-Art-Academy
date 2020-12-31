AM = Artificial.Mummification
LOI = LandsOfIllusions

# An arbitrary image.
class LOI.Assets.Image extends AM.Document
  @id: -> 'LandsOfIllusions.Assets.Image'
  # url: link to the image in the CDN
  # uploader: character that added this image to the CDN
  #   _id
  @Meta
    name: @id()
    fields: =>
      uploader: Document.ReferenceField LOI.Character, [], false

  # Methods

  @insert: @method 'insert'
