LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Item.Photos extends HQ.Store.Table.Item
  @id: -> 'Retronator.HQ.Store.Table.Item.Photos'

  # We use both terms for matching in the parser.
  @fullName: -> "set of photos"
  @shortName: -> "photo"

  @initialize()

  # Circumvent the non-dynamic avatar translations.
  fullName: ->
    if @post.photos.length is 1
      "photo"

    else
      "set of photos"

  shortName: -> @fullName()

  descriptiveName: ->
    if @post.photos.length is 1
      "A ![photo](look at photo)."

    else
      "A set of ![photos](look at photos)."

  description: ->
    if @post.photos.length is 1
      "It's a photo."

    else
      "It's a set of photos."

  _createMainInteraction: ->
    # The main interaction is to look at a set of photos in this post.
    new HQ.Store.Table.Interaction.Photos @post.photos
