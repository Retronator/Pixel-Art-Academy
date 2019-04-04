LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

C1.Mixer.IceBreakers.AnswerAction.latestAnswersForCharacter.publish (characterId) ->
  check characterId, Match.DocumentId

  # Find out which answer actions are the latest for each of question types
  answerActionsForQuestion = {}

  answerActions = LOI.Memory.Action.documents.fetch
    'character._id': characterId
    type: C1.Mixer.IceBreakers.AnswerAction.type
  ,
    order:
      time: -1

  for question of C1.Mixer.IceBreakers.Questions
    answerActionsForQuestion[question] = _.find (answerActions), (answerAction) => answerAction.content.question is question

  answerActionIds = (answerAction._id for question, answerAction of answerActionsForQuestion when answerAction)

  LOI.Memory.Action.documents.find
    _id: $in: answerActionIds
