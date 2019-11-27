AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Learning.Task.Entry.insert.method (characterId, situation, taskId, data) ->
  check characterId, Match.DocumentId
  # Note: Situation will be checked in the Action do call.
  check taskId, String
  check data, Match.OptionalOrNull
    upload: Match.Optional
      picture:
        url: String
    survey: Match.Optional Object

  LOI.Authorize.characterAction characterId

  taskClass = PAA.Learning.Task.getClassForId taskId

  if data
    # Make sure the provided data matches the task type.
    for field in ['upload', 'survey']
      className = _.upperFirst field

      # Check that the task class inherits from the correct task type.
      if data[field] and not taskClass.prototype instanceof PAA.Learning.Task[className]
        throw new AE.ArgumentException "Task is not an #{className}, but #{field} data provided."

    # Do extra checks for surveys.
    if data.survey
      questions = taskClass.questions()

      surveyMatchPattern = {}

      for question in questions
        switch question.type
          when PAA.Learning.Task.Survey.QuestionType.MultipleChoice
            answersCount = _.keys(data.survey[question.key]).length

            if answersCount > 1 and not question.multipleAnswers
              throw new AE.ArgumentException "Survey question #{question.key} does not accept multiple answers."

            if answersCount is 0 and question.required
              throw new AE.ArgumentException "Survey question #{question.key} requires an answer."

            questionMatchPattern = {}

            for choice in question.choices
              if choice.text
                choiceMatchPattern = String

              else
                choiceMatchPattern = Boolean

              questionMatchPattern[choice.key] = Match.Optional choiceMatchPattern

        if question.required
          surveyMatchPattern[question.key] = questionMatchPattern

        else
          surveyMatchPattern[question.key] = Match.Optional questionMatchPattern

      check data.survey, surveyMatchPattern

  # Make sure we don't already have an entry for this task. This should not
  # raise an exception since the client might not have received the entry yet.
  existing = PAA.Learning.Task.Entry.documents.findOne
    'character._id': characterId
    taskId: taskId

  return if existing

  actionId = LOI.Memory.Action.do PAA.Learning.Task.Entry.Action.type, characterId, situation, {}

  entry = _.extend
    character:
      _id: characterId
    action:
      _id: actionId
    taskId: taskId
    time: new Date()
  ,
    data

  PAA.Learning.Task.Entry.documents.insert entry
