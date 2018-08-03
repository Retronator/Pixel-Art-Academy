LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Conditional extends Script.Nodes.Code

  end: (state) ->
    result = @evaluate state

    # Transition to the true branch (node) or continue (next).
    @transition if result then @node else @next
