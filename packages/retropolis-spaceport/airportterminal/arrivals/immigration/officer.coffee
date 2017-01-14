LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Immigration.Officer extends LOI.Adventure.Thing
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Immigration.Officer'
  @fullName: -> "immigration officer"
  @shortName: -> "officer"
  @description: -> "It's one of the immigration officers that can allow you into Retropolis."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.yellow
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @initialize()

  @listenerClasses: -> [
    @DialogListener
  ]

  class @DialogListener extends LOI.Adventure.Listener
    @scriptUrls: -> [
      'retronator_retropolis-spaceport/airportterminal/arrivals/immigration/officer.script'
    ]

    class @Scripts.Dialog extends LOI.Adventure.Script
      @id: -> 'Retropolis.Spaceport.AirportTerminal.Immigration.Officer'
      @initialize()

      initialize: ->
        officer = @options.parent

        @setActors
          officer: officer
          
        @setCallbacks
          OpenFacebook: (complete) =>
            window.open 'https://www.facebook.com/retronator/', '_blank'
            complete()

          OpenRetronator: (complete) =>
            window.open 'https://twitter.com/retronator', '_blank'
            complete()

          OpenPixelArtAcademy: (complete) =>
            window.open 'https://twitter.com/PixelArtAcademy', '_blank'
            complete()

    @initialize()

    onScriptsLoaded: ->
      officer = @options.parent

      # Auto-start conversation.
      LOI.adventure.director.startScript @scripts[@constructor.Scripts.Dialog.id()]

    onCommand: (commandResponse) ->
      officer = @options.parent
      commandResponse.requireAvatar officer.avatar

      commandResponse.onPhrase
        phraseKey: Vocabulary.Keys.Verbs.Talk
        aliases: [Vocabulary.Keys.Verbs.Use]
        idealForm: (translatedPhrase) =>
          "#{translatedPhrase} #{officer.avatar.shortName()}"
        action: =>
          LOI.adventure.director.startScript @scripts[@constructor.Scripts.Dialog.id()]
