AEc = Artificial.Echo

class AEc.Node.Output extends AEc.Node
  @type: -> 'Artificial.Echo.Node.Output'
  @displayName: -> 'Output'

  @initialize()

  @inputs: -> [
    name: 'in'
    type: AEc.ConnectionTypes.Channels
  ]

  getDestinationConnection: (input) ->
    if input is 'in'
      destination: @audio.context.destination
