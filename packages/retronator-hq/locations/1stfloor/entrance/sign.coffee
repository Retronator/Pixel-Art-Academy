LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Entrance.Sign extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Locations.Entrance.Sign'

  @fullName: -> "instructions sign"

  @shortName: -> "sign"

  @description: ->
    "
      The sign informs you of basic navigation. It says:
      To enter a building or a room, type _ENTER_ or _IN_.
      You can also type _GO IN_ or in this case _GO TO LOBBY_.
      It's quickest to navigate by compass points. Because the lobby is to the west you can input _WEST_, or _W_ for short,
      to go there.
    "

  @initialize()

  constructor: ->
    super

    @addAbility new Action
      verbs: [Vocabulary.Keys.Verbs.Look, Vocabulary.Keys.Verbs.Read]
      action: =>
        LOI.adventure.showDescription @
