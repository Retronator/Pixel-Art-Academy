LOI = LandsOfIllusions

# Note: We can't create a shorthand LOI.Adventure.Script since
# it would clash with the class declaration that also uses Script.
class LOI.Adventure.Script.Nodes.Script extends LOI.Adventure.Script.Node
  constructor: (options) ->
    super arguments...
    
    @id = options.id
    @labels = options.labels
    @callbacks = options.callbacks
