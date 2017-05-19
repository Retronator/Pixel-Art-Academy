LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.Items.Map extends LOI.Adventure.Item
  @id: -> 'SanFrancisco.Soma.Items.Map'
  @url: -> 'sf/map'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "map of San Francisco"
  @shortName: -> "SF map"

  @description: ->
    "
      It's Retronator's signature isometric pixel art map of San Francisco, centered on the SOMA district.
    "

  @defaultScriptUrl: -> 'retronator_retronator-hq/items/sync/sync.script'

  @initialize()

  # Listener

  onCommand: (commandResponse) ->
    map = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Get, map.avatar]
      action: =>
        map.state 'inInventory', true

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], map.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem map
