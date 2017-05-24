LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Item.Article extends HQ.Store.Table.Item
  @id: -> 'Retronator.HQ.Store.Table.Item.Article'

  # We use both terms for matching in the parser.
  @fullName: -> "article"

  @initialize()

  fullName: ->
    # Use the post title as the full name.
    @post.title

  shortName: ->
    # Retain the original short name.
    @constructor.fullName()

  descriptiveName: ->
    "An ![article](read article) titled #{@post.title}."

  description: ->
    "It's an article."

  introduction: ->
    "You read the article."

  _createMainInteraction: ->
    # The main interaction is to look at an article.
    null

  onCommand: (commandResponse) ->
    super

    article = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Read, article.avatar]
      action: => HQ.Store.Table.showPost item.post
