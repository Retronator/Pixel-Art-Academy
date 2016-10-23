LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Conditional extends Script.Node
  constructor: (options) ->
    super

    # Make variable names in the expression to reference the state.
    @expression = options.expression.replace /[a-zA-Z_]\w*(?=(?:[^"']*["'][^"']*["'])*[^"']*$)/g, '_locationState.$&'

  end: (_locationState) ->
    # Evaluate the conditional expression.
    result = eval @expression

    # Transition to the true branch (node) or continue (next).
    @transition if result then @node else @next
