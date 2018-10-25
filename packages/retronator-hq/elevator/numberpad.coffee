LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Elevator.NumberPad extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Elevator.NumberPad'
  @fullName: -> "number pad"
  @shortName: -> "pad"
  @descriptiveName: -> "Number ![pad](use pad)."
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: -> "It's the pad that controls the elevator."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.yellow
    shade: LOI.Assets.Palette.Atari2600.characterShades.lightest

  @initialize()

  @defaultScriptUrl: -> 'retronator_retronator-hq/elevator/numberpad.script'

  constructor: (@options) ->
    super arguments...

  onCommand: (commandResponse) ->
    numberPad = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.Press], numberPad.avatar]
      action: =>
        @startScript()
