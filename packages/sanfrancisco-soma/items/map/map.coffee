LOI = LandsOfIllusions
Soma = SanFrancisco.Soma

Vocabulary = LOI.Parser.Vocabulary

class Soma.Items.Map extends LOI.Adventure.Item
  @id: -> 'SanFrancisco.Soma.Items.Map'
  @url: -> 'sf/map'

  @version: -> '0.0.1'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "map of San Francisco"
  @shortName: -> "SF map"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @description: ->
    "
      It's Retronator's signature isometric pixel art map of San Francisco, centered on the SOMA district.
    "

  @initialize()

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  notesVisibleClass: ->
    'visible' if @state 'c3Highlighted'

  # Listener

  onCommand: (commandResponse) ->
    map = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Get, map.avatar]
      action: =>
        map.state 'inInventory', true

        # Report OK to the user.
        true

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], map.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem map
