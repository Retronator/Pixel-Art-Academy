LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Immigration.Terminal extends LOI.Adventure.Thing
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Immigration.Terminal'
  @fullName: -> "immigration terminal"
  @description: -> "It's an automated immigration system that you can use to enter Retropolis."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.yellow
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @initialize()

  @listeners: -> [
    @DialogListener
  ]

  class @DialogListener extends LOI.Adventure.Listener
    @scriptUrls: -> [
      'retronator_retropolis-spaceport/airportterminal/arrivals/immigration/terminal.script'
    ]

    class @Scripts.Dialog extends LOI.Adventure.Script
      @id: -> 'Retropolis.Spaceport.AirportTerminal.Immigration.Terminal'
      @initialize()

      initialize: ->
        officer = @options.parent

        @setThings
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
      # Auto-start conversation.
      LOI.adventure.director.startScript @scripts[@constructor.Scripts.Dialog.id()]

    onCommand: (commandResponse) ->
      officer = @options.parent

      commandResponse.onPhrase
        form: [[Vocabulary.Keys.Verbs.Talk, Vocabulary.Keys.Verbs.Use], officer.avatar]
        action: =>
          LOI.adventure.director.startScript @scripts[@constructor.Scripts.Dialog.id()]
