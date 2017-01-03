LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action

class LOI.Construct.Items.OperatorLink extends LOI.Adventure.Item
  @id: -> 'LandsOfIllusions.Construct.Items.OperatorLink'

  @fullName: -> "operator neural link"

  @shortName: -> "operator"

  @description: ->
    "
      This is a neural link with the operator who controls your immersion. It allows you to talk to them.
    "

  @initialize()

  constructor: ->
    super

    @operator = new HQ.Actors.Operator
      adventure: @options.adventure

    @addAbility new Action
      verb: Vocabulary.Keys.Verbs.Talk
      action: =>
        # Don't react if the real operator is on location.
        location = @options.adventure.currentLocation()
        return if location.things HQ.Actors.Operator

        # Don't react in locations that don't have the operator script.
        return unless operatorDialog = location.scripts['LandsOfIllusions.Construct.Scripts.Operator']

        operatorDialog.setActors
          operator: @operator

        operatorDialog.setCallbacks
          Exit: (complete) =>
            @options.adventure.goToLocation HQ.Locations.LandsOfIllusions.Room
            complete()

          Construct: (complete) =>
            @options.adventure.goToLocation LOI.Construct.Locations.Loading
            complete()

        location.director().startScript operatorDialog

  destroy: ->
    super

    @operator.destroy()

  @initialState: ->
    # Don't show operator in the inventory.
    doNotDisplay: true
