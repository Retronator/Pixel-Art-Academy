LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Callback extends Script.Node
  constructor: (options) ->
    super
    
    @name = options.name

    # We set the callback, if it was provided directly through options. Note that this is rare.
    # Callback usually gets set later through the setCallbacks method on the script.
    @callback = options.callback

  toString: -> "#{Callback}{#{@name}}"
