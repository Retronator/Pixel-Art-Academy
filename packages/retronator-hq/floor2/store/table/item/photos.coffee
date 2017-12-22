LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary
Nodes = LOI.Adventure.Script.Nodes

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

  _createIntroScript: ->
    # Create the photos html.
    $photos = $('<div class="retronator-hq-store-table-item-photos">')

    for photo in @post.photos
      $photo = $("<img class='photo' src='#{photo.original_size.url}'>")
      $photos.append($photo)

    # We inject the html with the photos.
    photosNode = new Nodes.NarrativeLine
      line: "%%html#{$photos[0].outerHTML}html%%"
      scrollStyle: LOI.Interface.Components.Narrative.ScrollStyle.Top

    # User looks at a set of photos in this post.
    if @post.photos.length is 1
      introduction = "You look at the photo:"

    else
      introduction = "You look at the photos:"
    
    new Nodes.NarrativeLine
      line: introduction
      next: photosNode
