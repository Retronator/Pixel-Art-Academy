AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Learning.Task.Entry.insert.method (characterId, situation, taskId, data) ->
  check characterId, Match.DocumentId
  # Note: Situation will be checked in the Action do call.
  checkData taskId, data

  LOI.Authorize.characterAction characterId

  # Make sure we don't already have an entry for this task. This should not
  # raise an exception since the client might not have received the entry yet.
  existing = PAA.Learning.Task.Entry.documents.findOne
    'character._id': characterId
    taskId: taskId

  return if existing

  entry = _.extend
    character:
      _id: characterId
    taskId: taskId
    time: new Date()
  ,
    data

  # If this task entry was completed during gameplay, also create an action.
  # Otherwise it could have been done externally such us in the Study Guide.
  if situation
    actionId = LOI.Memory.Action.do PAA.Learning.Task.Entry.Action.type, characterId, situation, {}

    entry.action =
      _id: actionId

  PAA.Learning.Task.Entry.documents.insert entry

PAA.Learning.Task.Entry.insertForUser.method (taskId, data) ->
  checkData taskId, data

  user = Retronator.requireUser()

  # Make sure we don't already have an entry for this task. This should not
  # raise an exception since the client might not have received the entry yet.
  existing = PAA.Learning.Task.Entry.documents.findOne
    'user._id': user._id
    taskId: taskId

  return if existing

  entry = _.extend
    user:
      _id: user._id
    taskId: taskId
    time: new Date()
  ,
    data

  PAA.Learning.Task.Entry.documents.insert entry

PAA.Learning.Task.Entry.remove.method (entryId) ->
  check entryId, Match.DocumentId

  # Make sure we have an entry for this task.
  existing = PAA.Learning.Task.Entry.documents.findOne entryId

  throw new AE.ArgumentException "The requested entry could not be found." unless existing

  # Make sure the task belongs to a character that belongs to the user.
  throw new AE.ArgumentException "The requested entry was not made by a character." unless existing.character
  LOI.Authorize.characterAction existing.character._id

  # It is now safe to remove the entry.
  PAA.Learning.Task.Entry.documents.remove entryId

PAA.Learning.Task.Entry.removeForUser.method (entryId) ->
  check entryId, Match.DocumentId

  user = Retronator.requireUser()

  # Make sure we have an entry for this task.
  existing = PAA.Learning.Task.Entry.documents.findOne
    _id: entryId
    'user._id': user._id

  throw new AE.ArgumentException "The requested entry could not be found." unless existing

  PAA.Learning.Task.Entry.documents.remove entryId

checkData = (taskId, data) ->
  check taskId, String
  check data, Match.OptionalOrNull
    upload: Match.Optional
      picture:
        url: String
    survey: Match.Optional Object

  return unless data

  taskClass = PAA.Learning.Task.getClassForId taskId

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
