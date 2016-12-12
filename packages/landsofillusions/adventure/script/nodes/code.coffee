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
    'this', 'throw', 'try'
    'typeof', 'var', 'void'
    'while', 'with', 'yield'
    'null', 'true', 'false'
  ]

  @coffeeScriptReplacements =
    ' is ': ' == '
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
    @expression = @expression.replace /[a-zA-Z_@](?:[\w.]|\[.*?\])*(?=(?:[^"']*["'][^"']*["'])*[^"']*$)/g, (identifier) =>
      # Ignore reserved keywords.
      return identifier if identifier in @constructor.reservedKeywords

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
    _ephemeralState = @script.ephemeralState()
    _locationState = @script.options.location.state()
    _globalState = @script.options.adventure.gameState()

    # Attach the user object to global state.
    if user = Retronator.user()
      _globalState.user = user
      _globalState.user.name = _globalState.user.profile?.name

      _globalState.user.itemKeys = {}
      for item in _globalState.user.items
        _globalState.user.itemKeys[item.catalogKey] = item

    console.log "Evaluating code node", @, "with states:", _globalState, _locationState, _scriptState, _ephemeralState if LOI.debug

    try
      result = eval @expression

    catch e
      console.error "Error while evaluating expression", @expression
      throw e

    console.log "Evaluated to", result if LOI.debug

    # User is read-only and should not be saved.
    _globalState.user = null

    # Trigger reactive state change.
    if options.triggerChange
      @script.options.adventure.gameState.updated()
      @script.ephemeralState _ephemeralState

    result
