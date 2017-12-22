LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

class HQ.Store.Table.Item.Link extends HQ.Store.Table.Item
  @id: -> 'Retronator.HQ.Store.Table.Item.Link'

  @fullName: -> "webpage address"
  @shortName: -> "link"

  @initialize()

  descriptiveName: ->
    "A ![webpage address](look at webpage address)."

  description: ->
    "It's a link to a webpage."

  introduction: ->
    ""

  _createIntroScript: ->
    # Create the link html.
    $link = $('<div class="retronator-hq-store-table-item-link">')
    $link.append("<div class='url'><a href='#{@post.link.url}' target='_blank'>#{@post.link.url}</a></div>")
    $link.append("<div class='title'><a href='#{@post.link.url}' target='_blank'>#{@post.link.title}</a></div>")
    $link.append("<div class='excerpt'><a href='#{@post.link.url}' target='_blank'>#{@post.link.excerpt}</a></div>")

    for photo in @post.photos
      $photo = $("<a href='#{@post.link.url}' target='_blank'><img class='photo' src='#{photo.original_size.url}'></a>")
      $link.append($photo)

    # We inject the html with the link.
    photosNode = new Nodes.NarrativeLine
      line: "%%html#{$link[0].outerHTML}html%%"
      scrollStyle: LOI.Interface.Components.Narrative.ScrollStyle.Top

    # User looks at the link in this post.
    new Nodes.NarrativeLine
      line: "You see a webpage link scribbled down on a piece of paper:"
      next: photosNode
