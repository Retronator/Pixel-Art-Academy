LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary



class HQ.Actors.ElevatorButton extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Actors.ElevatorButton'
  @fullName: -> "elevator button"
  @shortName: -> "button"
  @description: -> "It's the button that calls the elevator."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.yellow
    shade: LOI.Assets.Palette.Atari2600.characterShades.lightest

  @initialize()

  @setupButton: (options) ->
    Tracker.autorun (computation) =>
      return unless button = options.location.things HQ.Actors.ElevatorButton.id()
      computation.stop()

      button.addAbility new Action
        verbs: [Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.Press]
        action: =>
          LOI.adventure.director.startScript buttonInteraction

      buttonInteraction = options.location.scripts['Retronator.HQ.Actors.ElevatorButton']

      # Tell the script which floor it's on.
      state = buttonInteraction.ephemeralState()
      state.buttonFloor = options.floor
      buttonInteraction.ephemeralState state
