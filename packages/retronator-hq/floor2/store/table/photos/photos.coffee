LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Item.Photos extends HQ.Store.Table.Item
  @id: -> 'Retronator.HQ.Store.Table.Item.Photos'

  @register @id()
  template: -> @constructor.id()

  # We use both terms for matching in the parser.
  @fullName: -> "set of photos"
  @shortName: -> "photo"

  @defaultScriptUrl: -> 'retronator_retronator-hq/floor2/store/table/photos/photos.script'

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

  # Script

  initializeScript: ->
    photos = @options.parent

    @setCallbacks
      LookAtPhotos: (complete) =>
        photos.interact => complete()

  # Listener
  onCommand: (commandResponse) ->
    photos = @options.parent
    post = photos.post

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, photos.avatar]
      priority: 1
      action: =>
        @startScript label: if post.photos.length is 1 then 'LookAtPhoto' else 'LookAtPhotos'
