AE = Artificial.Everywhere
LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Item extends LOI.Adventure.Thing
  @_constructors: ->
    photo: @Photos
    video: @Video
    text: @Article
    link: @Link
    answer: @Answer
    audio: @Audio
    chat: @Chat
    quote: @Quote

  @createItem: (@options) ->
    constructor = @_constructors()[@options.post.type] or @Photos

    new constructor @options

  constructor: (@options) ->
    super @options

    @post = @options.post

    # We need to provide our own ID since multiple instances of this item will appear.
    @_id = Random.id()

    @started = new ReactiveField false

  _createInteractionScript: ->
    # We start with the intro.
    intro = @_createIntroScript()

    # If the post has text, we continue to its execution.
    if @post.text
      introEnd = intro
      introEnd = introEnd.next while introEnd.next
      introEnd.next = @_createTextScript()

    intro

  _createIntroScript: ->
    throw new AE.NotImplementedException "You must provide a method to create the intro script for this item type."

  id: ->
    @_id

  isVisible: ->
    @options.visible ? true

  start: ->
    @started true
    LOI.adventure.director.startNode @_createInteractionScript()

  # Listener

  onScriptsLoaded: ->
    super

    # We need to manually set the default script since we changed the ID and the default handler won't find it.
    @script = @scripts[@options.parent.constructor.id()]

  onCommand: (commandResponse) ->
    item = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, item.avatar]
      priority: 1
      action: => item.start()
