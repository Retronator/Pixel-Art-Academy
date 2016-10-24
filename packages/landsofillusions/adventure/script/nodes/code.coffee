LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Code extends Script.Node
  # The list of JavaScript keywords that should not be treated as identifiers.
  @javaScriptKeywords = [
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

  constructor: (options) ->
    super

    @expression = options.expression

    # Detect if this is a return statement.
    if @expression.match /^return/
      @return = true

      # Remove return part.
      @expression = @expression.replace /^(return)/, ''

    # Make variable names in the expression to reference the state.
    @expression = @expression.replace /[a-zA-Z_]\w*(?=(?:[^"']*["'][^"']*["'])*[^"']*$)/g, (identifier) =>
      # Ignore reserved keywords.
      return identifier if identifier in @constructor.javaScriptKeywords

      "_locationState.#{identifier}"

  end: (state) ->
    result = @evaluate state

    if @return
      # TODO: Do something with the result.
      result

    # Finish transition.
    super

  evaluate: (_locationState) ->
    # Evaluate the conditional expression. _locationState is set in the context to provide state variables.
    result = eval @expression

    result
