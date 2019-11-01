LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.ElevatorButton extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Items.ElevatorButton'
  @fullName: -> "elevator button"
  @shortName: -> "button"
  @descriptiveName: -> "Elevator ![button](press button)."
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: -> "It's the button that calls the elevator."

  @initialize()

  @defaultScriptUrl: -> 'retronator_retronator-hq/items/elevatorbutton/elevatorbutton.script'

  constructor: (@options) ->
    super arguments...

  onScriptsLoaded: ->
    button = @options.parent

    # Tell the script which floor it's on.
    @script.ephemeralState 'buttonFloor', button.options.floor

  onCommand: (commandResponse) ->
    button = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Press, Vocabulary.Keys.Verbs.Use], button.avatar]
      action: =>
        @startScript()
