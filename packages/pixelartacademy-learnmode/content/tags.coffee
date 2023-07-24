AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Content.Tags
  @Free = 'Free'
  @BaseGame = 'BaseGame'
  @DLC = 'DLC'
  @WIP = 'WIP'
  @Future = 'Future'
  
  @id: -> 'PixelArtAcademy.LearnMode.Content.Tags'
  
  @getDisplayNameForKey: (key) -> @_getTranslationForKey key, 'displayName'
  @getDescriptionForKey: (key) -> @_getTranslationForKey key, 'description'
  
  @_getTranslationForKey: (key, property) -> AB.translate(@_translationSubscription, "#{key}.#{property}").text

  @initialize: (translations) ->
    translationNamespace = @id()

    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        # Create translations.
        for tag, tagTranslations of translations
          for property, value of tagTranslations
            AB.createTranslation translationNamespace, "#{tag}.#{property}", value

    # On the client, subscribe to the translations.
    if Meteor.isClient
      @_translationSubscription = AB.subscribeNamespace translationNamespace

LM.Content.Tags.initialize
  Free:
    displayName: "Free"
    description: "This course is available for free as the game's demo."
  BaseGame:
    displayName: "Base game"
    description: "This course is included in the base version of the game."
  DLC:
    displayName: "DLC"
    description: "This course can be purchased as downloadable content."
  DLCAppStore:
    displayName: "DLC"
    description: "This course can be purchased as an in-app purchase."
  WIP:
    displayName: "WIP"
    description: "This content is currently work in progress. Players with alpha access can play it in its unfinished state."
  Future:
    displayName: "Future"
    description: "This content is planned for development in the future and is not yet available."
