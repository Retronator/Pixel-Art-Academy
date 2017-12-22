LOI = LandsOfIllusions
PAA = PixelArtAcademy
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary
Verbs = Vocabulary.Keys.Verbs

class RS.AirportTerminal.Immigration.Terminal extends LOI.Adventure.Thing
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Immigration.Terminal'
  @fullName: -> "immigration terminal"
  @shortName: -> "terminal"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: -> "It's an automated immigration system that you can use to enter Retropolis."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.yellow
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @dialogueDeliveryType: -> LOI.Avatar.DialogueDeliveryType.Displaying
  @dialogTextTransform: -> LOI.Avatar.DialogTextTransform.Uppercase

  @defaultScriptUrl: -> 'retronator_retropolis-spaceport/airportterminal/arrivals/immigration/terminal.script'

  @initialize()

  initializeScript: ->
    terminal = @options.parent

    @setThings {terminal}

    @setCallbacks
      EndImmigration: (complete) ->
        # Move on to baggage claim.
        LOI.adventure.goToLocation RS.AirportTerminal.BaggageClaim

        complete()

  @avatars: ->
    passport: PAA.Season1.Episode0.Chapter1.Items.Passport
    letter: PAA.Season1.Episode0.Chapter1.Items.AcceptanceLetter

  onCommand: (commandResponse) ->
    terminal = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Use, terminal.avatar]
      action: =>
        @startScript()

    showPassport = => @startScript label: 'ShowPassport'
    showLetter = => @startScript label: 'ShowLetter'

    commandResponse.onPhrase
      form: [[Verbs.UseWith, Verbs.ShowTo, Verbs.GiveTo], @avatars.passport, terminal.avatar]
      action: => showPassport()

    commandResponse.onPhrase
      form: [[Verbs.UseWith, Verbs.ShowTo, Verbs.GiveTo], @avatars.letter, terminal.avatar]
      action: => showLetter()

    commandResponse.onPhrase
      form: [[Verbs.Show, Verbs.Use], @avatars.passport]
      action: => showPassport()

    commandResponse.onPhrase
      form: [[Verbs.Show, Verbs.Use], @avatars.letter]
      action: => showLetter()
