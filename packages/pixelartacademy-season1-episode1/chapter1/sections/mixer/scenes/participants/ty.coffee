LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.Ty extends C1.Mixer.Participant
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.Ty'

  @location: ->
    PAA.Actors.Ty.Actions

  @initialize()

  constructor: ->
    super arguments...

    # Generate ice-breaker answers for Ty.
    @createAnswers
      "#{C1.Mixer.IceBreakers.Questions.HobbyProfession}": C1.Mixer.IceBreakers.AnswerSides.Left
      "#{C1.Mixer.IceBreakers.Questions.PixelArtOtherStyles}": C1.Mixer.IceBreakers.AnswerSides.Right
      "#{C1.Mixer.IceBreakers.Questions.ExtrovertIntrovert}": C1.Mixer.IceBreakers.AnswerSides.Middle
      "#{C1.Mixer.IceBreakers.Questions.IndividualTeam}": C1.Mixer.IceBreakers.AnswerSides.Middle
