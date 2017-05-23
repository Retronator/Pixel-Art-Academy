AE = Artificial.Everywhere
LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Item extends LOI.Adventure.Thing
  @_constructors: ->
    photo: @Photos
    text: @Article

  @createItem: (@options) ->
    constructor = @_constructors()[@options.post.type] or @Photos

    new constructor @options

  constructor: (@options) ->
    super @options

    @post = @options.post

    # We need to provide our own ID since multiple instances of this item will appear.
    @_id = Random.id()

    if @options.interactions
      # Construct the interaction script and collect all interactions that
      # need to be present at the location so they can be rendered by the interface.
      @interactions = []
      @interactionStartNode = @_createInteractionScript()

    @started = new ReactiveField false

  _createInteractionScript: ->
    # We start with the main interaction.
    mainInteraction = @_createMainInteraction()
    @interactions.push mainInteraction

    textNode = @_createTextScript() if @post.text

    mainInteractionNode = new LOI.Adventure.Script.Nodes.Callback
      callback: (complete) =>
        @options.table.startInteraction mainInteraction
        complete()

    mainInteractionNode

  _createMainInteraction: ->
    throw new AE.NotImplementedException "You must provide a method to create the main interaction with this item type."

  id: ->
    @_id

  isVisible: ->
    @options.visible ? true

  start: ->
    @started true
    LOI.adventure.director.startNode @interactionStartNode

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
      action: =>
        # Go to table if needed.
        atTable =  LOI.adventure.currentLocation() instanceof HQ.Store.Table
        LOI.adventure.goToLocation HQ.Store.Table unless atTable

        HQ.Store.Table.showPost item.post

        # If we were at the table, reset the interface manually since there will be no location change.
        LOI.adventure.interface.resetInterface?() if atTable
