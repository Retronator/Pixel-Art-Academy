LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Code extends Script.Node
  # The list of keywords that should not be treated as identifiers.
  @reservedKeywords = [
    'break', 'case', 'catch'
    'class', 'const', 'continue'
    'debugger', 'default', 'delete'
    'do', 'else', 'export'
    'extends', 'finally', 'for'
    'function', 'if', 'import'
    'in', 'instanceof', 'new'
    'return', 'super', 'switch'
    'throw', 'try'
    'typeof', 'var', 'void'
    'while', 'with', 'yield'
    'null', 'true', 'false'
  ]

  @coffeeScriptReplacements =
    ' is ': ' == '
    ' isnt ': ' != '
    ' and ': ' && '
    ' or ': ' || '
    'not ': '!'

  constructor: (options) ->
    super

    @expression = options.expression

    # Change CoffeeScript syntax to JavaScript.
    for word, replacement of @constructor.coffeeScriptReplacements
      @expression = @expression.replace new RegExp(word, 'g'), replacement

    # Make variable names in the expression to reference the different states.
    @expression = @expression.replace /(?:[a-zA-Z_@]|\.[a-zA-Z_@])[\w.]*(?=(?:[^"']*["'][^"']*["'])*[^"']*$)/g, (identifier) =>
      # Ignore reserved keywords.
      return identifier if identifier in @constructor.reservedKeywords

      # Ignore identifiers that start with a dot, since these are fields on objects.
      return identifier if _.startsWith identifier, '.'

      # Rename _ (underscore library) to lodash, since lodash is loaded in the window namespace.
      return identifier.replace '_.', 'lodash.' if _.startsWith identifier, '_.'

      if _.startsWith identifier, '@'
        "_globalState.#{identifier.substring 1}"

      else if _.startsWith identifier, '_'
        "_ephemeralState.#{identifier.substring 1}"

      else if _.startsWith identifier, 'location.'
        "_locationState.#{identifier.substring 9}"

      else
        "_scriptState.#{identifier}"

  end: ->
    @evaluate()

    # Finish transition.
    super

  evaluate: (options = {}) ->
    options.triggerChange ?= true

    # Get the states into context.
    _scriptState = @script.state()

    unless _scriptState
      _scriptState = {}
      _scriptStateWasNull = true
    
    _ephemeralState = @script.ephemeralState()

    location = LOI.adventure.currentLocation()
    _locationState = location.state()
    
    unless _locationState
      _locationState = {}
      _locationStateWasNull = true
      
    _locationState.id = location.id()

    _globalState = LOI.adventure.gameState()

    transferredThings = []
    transferThingToState = (thing, state, stateFieldName) =>
      thingState = thing.state()
      thingStateWasEmpty = thingState?

      state[stateFieldName] = thingState or {}
      state["#{stateFieldName}Instance"] = thing

      transferredThings.push {thing, state, stateFieldName, thingStateWasEmpty}

    # Attach the user object to global state.
    if user = Retronator.user()
      _globalState.user = user
      _globalState.user.name = _globalState.user.profile?.name
      _globalState.user.characters ?= []

      _globalState.user.itemKeys = {}
      for item in _globalState.user.items
        _globalState.user.itemKeys[item.catalogKey] = item

    else
      # Create a dummy user.
      _globalState.user =
        itemKeys: {}
        characters: []

    # Attach player object to global state.
    _globalState.player =
      inventory: {}

    # Create a map of inventory items
    currentInventoryThings = LOI.adventure.currentInventoryThings()

    for thing in currentInventoryThings
      transferThingToState thing, _globalState.player.inventory, thing.id()

    # Add script parent as this.
    transferThingToState @script.options.parent, _scriptState, 'this'

    # Add storytelling states to script state.
    if @script.options.parent instanceof LOI.Adventure.Scene
      scene = @script.options.parent
      section = scene.section
      chapter = section?.chapter
      episode = chapter?.episode

      transferThingToState scene, _scriptState, 'scene'
      transferThingToState section, _scriptState, 'section' if section
      transferThingToState chapter, _scriptState, 'chapter' if chapter
      transferThingToState episode, _scriptState, 'episode' if episode

    # Add provided things as shorthands to script state.
    if @script.things
      for shorthand, thing of @script.things
        transferThingToState thing, _scriptState, shorthand

    console.log "Evaluating code node", @, "with states:", _globalState, _locationState, _scriptState, _ephemeralState if LOI.debug

    try
      result = eval @expression

    catch error
      console.error "Error while evaluating expression", @expression
      throw error

    console.log "Evaluated to", result if LOI.debug

    # Transfer thing states to game state (reverse effects of transferThingToState).
    for transferredThing in transferredThings
      newThingState = transferredThing.state[transferredThing.stateFieldName]

      console.log "Writing back state", transferredThing.thing.stateAddress.string(), newThingState if LOI.debug

      # We don't want to write an empty state back into the state if it didn't have any data to begin with.
      transferState = false

      if transferredThing.thingStateWasEmpty
        # See if location state was modified and set it if needed.
        transferState = true if _.keys(newThingState).length

        console.log "Starting state was empty … do we still transfer it?", transferState if LOI.debug

      else
        transferState = true

      if transferState
        # Because we might have nested empty states (if scene and section were both null they were created as separate
        # objects, which are not nested as they would need to be), we can only overwrite the new state over the old one.
        existingState = _.nestedProperty _globalState, transferredThing.thing.stateAddress.string()

        # Overwrite new state over existing state.
        newThingState = _.merge {}, existingState, newThingState

        _.nestedProperty _globalState, transferredThing.thing.stateAddress.string(), newThingState

      delete transferredThing.state[transferredThing.stateFieldName]
      delete transferredThing.state["#{transferredThing.stateFieldName}Instance"]

    # Delete read-only fields that should not be saved.
    delete _globalState.user
    delete _globalState.player

    if _scriptStateWasNull
      # See if location state was modified and set it if needed.
      _.nestedProperty _globalState, @script.stateAddress.string(), _scriptState if _.keys(_scriptState).length

    if _locationStateWasNull
      # See if location state was modified and set it if needed.
      _.nestedProperty _globalState, location.stateAddress.string(), _locationState if _.keys(_locationState).length

    # Trigger reactive state change.
    if options.triggerChange
      LOI.adventure.gameState.updated()
      @script.ephemeralState.set _ephemeralState

    result
