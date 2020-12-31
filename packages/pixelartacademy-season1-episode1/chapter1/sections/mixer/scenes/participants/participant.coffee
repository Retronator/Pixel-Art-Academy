LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.Participant extends LOI.Adventure.Scene
  createAnswers: (answerData) ->
    @answerActionDocuments = for question, answer of answerData
      _id: Random.id()
      type: C1.Mixer.IceBreakers.AnswerAction.type
      content:
        question: question
        answer: answer

  things: -> @answerActionDocuments
