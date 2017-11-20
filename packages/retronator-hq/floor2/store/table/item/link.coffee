LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Item.Link extends HQ.Store.Table.Item
  @id: -> 'Retronator.HQ.Store.Table.Item.Link'

  @fullName: -> "link"

  @initialize()

  descriptiveName: ->
    "A ![webpage address](look at webpage address)."

  description: ->
    "It's a link to a webpage."

  introduction: ->
    "You see a webpage link scribbled down on a piece of paper."

  _createMainInteraction: ->
    # The main interaction is to look at a set of photos in this post.
    new HQ.Store.Table.Interaction.Photos @post.photos
