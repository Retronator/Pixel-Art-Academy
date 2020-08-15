AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.StudyGuide.Activity.insert.method (goalId) ->
  check goalId, String
  LOI.Authorize.admin()

  # Create the new activity.
  PAA.StudyGuide.Activity.documents.insert {goalId}

  # Create the goal class.
  PAA.StudyGuide.initializeGoal goalId

PAA.StudyGuide.Activity.update.method (activityId, data) ->
  check activityId, Match.DocumentId
  check data,
    finalTasks: Match.Optional [Match.OptionalOrNull String]
    finalGroupNumber: Match.OptionalOrNull Number
    requiredInterests: Match.Optional [Match.OptionalOrNull String]

  LOI.Authorize.admin()

  activity = PAA.StudyGuide.Activity.documents.findOne activityId
  throw new AE.ArgumentException "Activity does not exist." unless activity

  # Update the activity with new data.
  PAA.StudyGuide.Activity.documents.update activityId, $set: data

  # Reinitialize the goal.
  goalClass = PAA.Learning.Goal.getClassForId activity.goalId
  goalClass.initialize()

PAA.StudyGuide.Activity.insertTask.method (activityId, taskId, taskType) ->
  check activityId, Match.DocumentId
  check taskId, String
  taskTypes = PAA.Learning.Task.getTypes()
  check taskType, Match.Where (value) => value in taskTypes
  LOI.Authorize.admin()

  activity = PAA.StudyGuide.Activity.documents.findOne activityId
  throw new AE.ArgumentException "Activity does not exist." unless activity

  # Make sure the task doesn't exist yet.
  if _.find(activity.tasks, (task) -> task.id is taskId)
    throw new AE.ArgumentException "Task #{taskId} already exist for activity with goal #{activity.goalId}."

  # Add the task.
  PAA.StudyGuide.Activity.documents.update activityId,
    $push:
      tasks:
        id: taskId
        type: taskType

  # Create the task class.
  PAA.StudyGuide.initializeTask activity.goalId, taskId, taskType

PAA.StudyGuide.Activity.updateTask.method (activityId, taskId, data) ->
  check activityId, Match.DocumentId
  check taskId, String
  check data,
    icon: Match.Optional Match.Where (value) => value in _.values PAA.Learning.Task.Icons
    interests: Match.Optional [Match.OptionalOrNull String]
    requiredInterests: Match.Optional [Match.OptionalOrNull String]
    predecessors: Match.Optional [Match.OptionalOrNull String]
    predecessorsCompleteType: Match.Optional Match.Where (value) => value in _.values PAA.Learning.Task.PredecessorsCompleteType
    groupNumber: Match.Optional Number

  LOI.Authorize.admin()

  activity = PAA.StudyGuide.Activity.documents.findOne activityId
  throw new AE.ArgumentException "Activity does not exist." unless activity

  # Make sure the task exists.
  unless _.find(activity.tasks, (task) -> task.id is taskId)
    throw new AE.ArgumentException "Task #{taskId} for activity with goal #{activity.goalId} does not exist."

  # Update the activity with new data.
  $set = {}

  for property, value of data
    $set["tasks.$.#{property}"] = value

  PAA.StudyGuide.Activity.documents.update
    _id: activity._id
    'tasks.id': taskId
  ,
    {$set}

  # Reinitialize the task and goal.
  taskClass = PAA.Learning.Task.getClassForId taskId
  taskClass.initialize()

  goalClass = PAA.Learning.Goal.getClassForId activity.goalId
  goalClass.initialize()

PAA.StudyGuide.Activity.removeTask.method (activityId, taskId) ->
  check activityId, Match.DocumentId
  check taskId, String
  LOI.Authorize.admin()

  activity = PAA.StudyGuide.Activity.documents.findOne activityId
  throw new AE.ArgumentException "Activity does not exist." unless activity

  # Make sure the task exists.
  unless _.find(activity.tasks, (task) -> task.id is taskId)
    throw new AE.ArgumentException "Task #{taskId} for activity with goal #{activity.goalId} does not exist."

  # Remove the task.
  PAA.StudyGuide.Activity.documents.update activityId,
    $pull:
      tasks:
        id: taskId

  # Clean up the translations.
  Artificial.Babel.Translation.documents.remove namespace: taskId

  # Reinitialize the goal.
  goalClass = PAA.Learning.Goal.getClassForId activity.goalId
  goalClass.initialize()
