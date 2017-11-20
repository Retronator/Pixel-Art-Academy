LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Item.Video extends HQ.Store.Table.Item
  @id: -> 'Retronator.HQ.Store.Table.Item.Video'

  @fullName: -> "video"

  @initialize()

  descriptiveName: ->
    "A ![video](view video)."

  description: ->
    "It's a video playing on a tablet."

  introduction: ->
    "You sit down and play the video."

  _createMainInteraction: ->
    new HQ.Store.Table.Interaction.Video @post.video.player
