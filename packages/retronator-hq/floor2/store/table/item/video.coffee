LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class HQ.Store.Table.Item.Video extends HQ.Store.Table.Item
  @id: -> 'Retronator.HQ.Store.Table.Item.Video'

  @fullName: -> "video"

  @initialize()

  descriptiveName: ->
    "A ![video](view video)."

  description: ->
    "It's a video playing on a tablet."

  _createIntroScript: ->
    # Create the iframe embed.
    largePlayer = _.last _.sortBy @post.video.player, (player) -> player.width
    $video = $(largePlayer.embed_code)
    $video.addClass('retronator-hq-store-table-item-video')

    # We inject the html of the player.
    videoNode = new Nodes.NarrativeLine
      line: "%%html#{$video[0].outerHTML}html%%"
      scrollStyle: LOI.Interface.Components.Narrative.ScrollStyle.Top

    # User looks at the video in this post.
    new Nodes.NarrativeLine
      line: "You sit down and play the video:"
      next: videoNode
