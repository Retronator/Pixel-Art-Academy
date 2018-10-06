LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.Context extends LOI.Adventure.Context
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.Context'

  @initialize()
  
  # Listener
  
  @avatars: ->
    answer: C1.Mixer.Answer
  
  onCommand: (commandResponse) ->
    # We override the parent implementation (and not call super) 
    # since we don't want the back command to exit the context.
    return unless marker = LOI.adventure.getCurrentThing C1.Mixer.Marker
    return unless stickers = LOI.adventure.getCurrentThing C1.Mixer.Stickers

    writeAnswerAction = =>
      galleryWest = _.find LOI.adventure.currentScenes(), (scene) => scene instanceof C1.Mixer.GalleryWest
      galleryWestListener = galleryWest.listeners[0]
      galleryWestScript = galleryWestListener.script

      firstAnswerIndex = galleryWestScript.state('answers')[0]
      answers = ['Hobby', 'Hobby + Professional', 'Professional']

      galleryWestScript.ephemeralState 'firstAnswer', answers[firstAnswerIndex]

      galleryWestListener.startScript label: 'HobbyProfessionWrite'

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Use, marker]
      priority: 1
      action: writeAnswerAction

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Use, stickers]
      priority: 1
      action: writeAnswerAction

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.UseWith, marker, stickers]
      priority: 1
      action: writeAnswerAction

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Write, @avatars.answer]
      action: writeAnswerAction

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.WriteOn, @avatars.answer, stickers]
      action: writeAnswerAction
