LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

Vocabulary = LOI.Parser.Vocabulary

class Studio.Computer extends LOI.Components.Computer
  @id: -> 'SanFrancisco.Apartment.Studio.Computer'
  @url: -> 'sf/apartment/studio/computer'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "computer"

  @description: ->
    "
      It's _char's_ trusty old computer, perfect for finding useful things on the internet.
    "

  @initialize()

  onCreated: ->
    super

    @screens =
      desktop: new @constructor.Desktop @
      browser: new @constructor.Browser @
      princeOfPersia: new @constructor.Game @, 'msdos_Prince_of_Persia_1990'
      lotusTheUltimateChallenge: new @constructor.Game @, 'msdos_Lotus_-_The_Ultimate_Challenge_1993'

    @switchToScreen @screens.browser

  # Listener

  onCommand: (commandResponse) ->
    computer = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.LookAt], computer.avatar]
      action: =>
        LOI.adventure.goToItem computer
