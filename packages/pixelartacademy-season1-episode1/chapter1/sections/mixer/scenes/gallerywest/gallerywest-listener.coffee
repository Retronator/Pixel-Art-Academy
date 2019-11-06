LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.GalleryWest extends C1.Mixer.GalleryWest
  @avatars: ->
    answer: C1.Mixer.Answer
    sticker: C1.Mixer.Sticker

  onEnter: (enterResponse) ->
    scene = @options.parent

    enterResponse.overrideIntroduction =>
      # Change the intro text when in the mixer context.
      return unless LOI.adventure.currentContext() instanceof C1.Mixer.Context
      scene.translations()?.intro

  onCommand: (commandResponse) ->
    scene = @options.parent

    return unless alexandra = LOI.adventure.getCurrentThing HQ.Actors.Alexandra
    return unless retro = LOI.adventure.getCurrentThing HQ.Actors.Retro
    return unless shelley = LOI.adventure.getCurrentThing HQ.Actors.Shelley
    return unless reuben = LOI.adventure.getCurrentThing HQ.Actors.Reuben

    return unless marker = LOI.adventure.getCurrentThing C1.Mixer.Marker
    return unless stickers = LOI.adventure.getCurrentThing C1.Mixer.Stickers

    eventPhase = scene.eventPhase()

    if eventPhase is C1.Mixer.GalleryWest.EventPhases.BeforeStart
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, alexandra]
        action: => @startScript label: 'TalkToAlexandra'
  
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, retro]
        action: => @startScript label: 'TalkToRetro'
  
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, shelley]
        priority: 1
        action: => @startScript label: 'TalkToShelley'
  
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, reuben]
        action: => @startScript label: 'TalkToReuben'
  
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Get, marker]
        action: =>
          marker.state 'inInventory', true
          true
  
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Get, [@avatars.sticker, stickers]]
        action: =>
          stickers.state 'inInventory', true
          true

    if eventPhase is C1.Mixer.GalleryWest.EventPhases.Answering
      writeAnswerAction = =>
        firstAnswerIndex = @script.state('answers')[0]
        answers = ['Hobby', 'Hobby/Professional', 'Professional']

        @script.ephemeralState 'firstAnswer', answers[firstAnswerIndex]

        @startScript label: 'HobbyProfessionWrite'

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Use, marker]
        priority: 1
        action: writeAnswerAction

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Use, [@avatars.sticker, stickers]]
        priority: 1
        action: writeAnswerAction

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.UseWith, marker, [@avatars.sticker, stickers]]
        priority: 1
        action: writeAnswerAction

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Write, @avatars.answer]
        action: writeAnswerAction

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.WriteOn, @avatars.answer, [@avatars.sticker, stickers]]
        action: writeAnswerAction

    if eventPhase is C1.Mixer.GalleryWest.EventPhases.TalkToClassmates
      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, retro]
        action: =>
          @script.ephemeralState 'talkToClassmatesMinutesLeft', Math.round(scene.talkToClassmatesMinutesLeft())
          @startScript label: 'TalkToRetroDuringBreak'

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, alexandra]
        action: => @startScript label: 'TalkToAlexandraDuringBreak'

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, shelley]
        priority: 1
        action: => @startScript label: 'TalkToShelleyDuringBreak'

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.TalkTo, reuben]
        action: => @startScript label: 'TalkToReubenDuringBreak'
