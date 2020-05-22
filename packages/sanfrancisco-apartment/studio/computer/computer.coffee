LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

Vocabulary = LOI.Parser.Vocabulary

class Studio.Computer extends LOI.Components.Computer
  @id: -> 'SanFrancisco.Apartment.Studio.Computer'
  @url: -> 'sf/apartment/studio/computer'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "computer"
  @descriptiveName: -> "PixelFriend ![computer](use computer)."
  @description: ->
    "
      It's _char's_ trusty old computer, perfect for finding useful things on the internet.
    "

  @initialize()

  onCreated: ->
    super arguments...

    @screens =
      desktop: new @constructor.Desktop @
      browser: new @constructor.Browser @
      email: new @constructor.Email @
      princeOfPersia: new @constructor.Game @, 'prince', 'Prince', 'msdos_Prince_of_Persia_1990'
      lotusTheUltimateChallenge: new @constructor.Game @, 'lotus', 'Lotus', 'msdos_Lotus_-_The_Ultimate_Challenge_1993'

    @switchToScreen @screens.desktop

  # Listener

  onCommand: (commandResponse) ->
    computer = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.LookAt], computer.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem computer
