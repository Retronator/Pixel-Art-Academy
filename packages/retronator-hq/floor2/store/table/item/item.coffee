AE = Artificial.Everywhere
LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Item extends LOI.Adventure.Item
  @_constructors: ->
    photo: @Photos

  @createItem: (@options) ->
    constructor = @_constructors()[@options.post.type] or @Photos

    new constructor @options

  constructor: (@options) ->
    super @options

    @post = @options.post

    # We need to provide our own ID since multiple instances of this item will appear.
    @_id = Random.id()

    # Construct the interaction script and collect all interactions that
    # need to be present at the location so they can be rendered by the interface.
    @interactions = []
    @interactionStartNode = @_createInteractionScript()

  _createInteractionScript: ->
    # We start with the main interaction.
    mainInteraction = @_createMainInteraction()
    @interactions.push mainInteraction

    textNode = @_createTextScript() if @post.text

    mainInteractionNode = new LOI.Adventure.Script.Nodes.Callback
      callback: (complete) =>
        mainInteraction.start endNode: textNode
        complete()

    mainInteractionNode

  @_createMainInteraction: ->
    throw new AE.NotImplementedException "You must provide a method to create the main interaction with this item type."

  @_createTextScript: ->
    
  id: ->
    @_id

  isVisible: ->
    @options.visible ? true

  # A variant of item interaction helper that directly activates an item instead of going through adventure.
  interact: (callback) ->
    # Wait until item has been active and deactivated again.
    itemWasActive = false
    @activate()

    Tracker.autorun (computation) =>
      if @activated() and not itemWasActive
        itemWasActive = true

      else if @deactivated() and itemWasActive
        computation.stop()
        callback()

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
        LOI.adventure.director.startNode item.interactionStartNode
