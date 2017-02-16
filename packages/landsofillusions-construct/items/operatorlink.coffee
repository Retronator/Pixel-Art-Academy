LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary



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

    @addAbility new Action
      verb: Vocabulary.Keys.Verbs.Talk
      action: =>
        # Don't react if the real operator is on location.
        location = LOI.adventure.currentLocation()
        return if location.things HQ.Actors.Operator

        # Don't react in locations that don't have the operator script.
        return unless operatorDialog = location.scripts['LandsOfIllusions.Construct.Scripts.Operator']

        operatorDialog.setThings
          operator: @operator

        operatorDialog.setCallbacks
          Exit: (complete) =>
            LOI.adventure.goToLocation HQ.Locations.LandsOfIllusions.Room
            complete()

          Construct: (complete) =>
            LOI.adventure.goToLocation LOI.Construct.Locations.Loading
            complete()

        LOI.adventure.director.startScript operatorDialog

  destroy: ->
    super

    @operator.destroy()

  @state: ->
    # Don't show operator in the inventory.
    doNotDisplay: true
