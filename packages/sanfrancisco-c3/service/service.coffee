LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Service extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.C3.Service'
  @url: -> 'c3/customer-service'
  @region: -> SanFrancisco.Soma

  @version: -> '0.0.1'

  @fullName: -> "Cyborg Construction Center Customer Service"
  @shortName: -> "Customer service"
  @description: ->
    "
      A bright room with many computers lined up against the walls lets customers
      place and manage their orders. The only way out is back west to the lobby.
    "

  @defaultScriptUrl: -> 'retronator_sanfrancisco-c3/service/service.script'

  @initialize()

  constructor: ->
    super

  destroy: ->
    super

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": C3.Lobby

  things: -> [
    C3.Service.Terminal
  ]

  # Script

  initializeScript: ->
    listener = @options.listener

    @setThings listener.avatars

  # Listener

  @avatars: ->
    operator: Retronator.HQ.Actors.Operator

  onCommand: (commandResponse) ->
    if terminal = LOI.adventure.getCurrentThing C3.Service.Terminal
      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.LookAt], terminal.avatar]
        priority: 1
        action: =>
          LOI.adventure.goToItem terminal
