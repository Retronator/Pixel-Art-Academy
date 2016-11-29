LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Entrance.Sign extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Locations.Entrance.Sign'

  @register @id()

  @fullName: -> "instructions sign"

  @shortName: -> "sign"

  @description: ->
    "
      The sign informs you of basic navigation. It says:
      To enter a building or a room, type ENTER or IN.
      You can also type GO IN or in this case GO TO LOBBY.
      It's quickest to navigate by compass points. Because the lobby is to the west you can input WEST, or W for short,
      to go there.
    "

  @initialize()

  constructor: ->
    super

    @addAbility new Action
      verbs: [Vocabulary.Keys.Verbs.Look, Vocabulary.Keys.Verbs.Read]
      action: =>
        @options.adventure.showDescription @
