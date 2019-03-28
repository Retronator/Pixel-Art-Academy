LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.GalleryWest extends C1.Mixer.GalleryWest
  initializeScript: ->
    scene = @options.parent

    @setCurrentThings
      retro: HQ.Actors.Retro
      alexandra: HQ.Actors.Alexandra
      shelley: HQ.Actors.Shelley
      reuben: HQ.Actors.Reuben

    @setCallbacks
      IceBreakersStart: (complete) =>
        # Animate characters to the middle.
        characters = _.flatten [
          LOI.character()
          LOI.adventure.getCurrentThing actorClass for actorClass in scene.constructor.actorClasses
        ]

        for character in characters
          scene._movePersonToLandmark character, 'MixerMiddle'

        complete()

      HobbyProfessionStart: (complete) =>
        scene._animateActorsOnQuestion C1.Mixer.IceBreakers.Questions.HobbyProfession
        complete()

      HobbyProfessionEnd: (complete) =>
        answers = @state 'answers'
        scene._doAnswerAction C1.Mixer.IceBreakers.Questions.HobbyProfession, answers[0]
        complete()

      PixelArtOtherStylesStart: (complete) =>
        scene._animateActorsOnQuestion C1.Mixer.IceBreakers.Questions.PixelArtOtherStyles
        complete()

      PixelArtOtherStylesEnd: (complete) =>
        answers = @state 'answers'
        scene._doAnswerAction C1.Mixer.IceBreakers.Questions.PixelArtOtherStyles, answers[1]
        complete()

      ExtrovertIntrovertStart: (complete) =>
        scene._animateActorsOnQuestion C1.Mixer.IceBreakers.Questions.ExtrovertIntrovert
        complete()

      ExtrovertIntrovertEnd: (complete) =>
        answers = @state 'answers'

        personalityChanged = scene._changePersonality 1, 1 - answers[2]
        @ephemeralState 'factor1Changed', personalityChanged

        scene._doAnswerAction C1.Mixer.IceBreakers.Questions.ExtrovertIntrovert, answers[2]
        complete()

      IndividualTeamStart: (complete) =>
        scene._animateActorsOnQuestion C1.Mixer.IceBreakers.Questions.IndividualTeam
        complete()

      IndividualTeamEnd: (complete) =>
        answers = @state 'answers'

        personalityChanged = scene._changePersonality 2, answers[3] - 1
        @ephemeralState 'factor2Changed', personalityChanged

        scene._doAnswerAction C1.Mixer.IceBreakers.Questions.IndividualTeam, answers[3]
        complete()

      StartTalkToClassmates: (complete) =>
        scene.state 'talkToClassmatesStart', Date.now()
        complete()
