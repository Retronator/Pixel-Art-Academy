AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Delta = require 'quill-delta'

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

PAA.StudyGuide.Activity.remove.method (activityId) ->
  check activityId, Match.DocumentId

  LOI.Authorize.admin()

  activity = PAA.StudyGuide.Activity.documents.findOne activityId
  throw new AE.ArgumentException "Activity does not exist." unless activity

  # Clean up the translations.
  tasks = activity.tasks or []
  Artificial.Babel.Translation.documents.remove namespace: activity.goalId
  Artificial.Babel.Translation.documents.remove namespace: task.id for task in tasks

  # Remove the goal and tasks from the registry.
  PAA.Learning.Goal.removeClassForId activity.goalId
  PAA.Learning.Task.removeClassForId task.id for task in tasks

  # Remove the activity.
  PAA.StudyGuide.Activity.documents.remove activityId

PAA.StudyGuide.Activity.renameGoalId.method (activityId, newGoalId) ->
  check activityId, Match.DocumentId
  check newGoalId, String

  LOI.Authorize.admin()

  activity = PAA.StudyGuide.Activity.documents.findOne activityId
  throw new AE.ArgumentException "Activity does not exist." unless activity
  throw new AE.ArgumentException "Goal's ID is already #{newGoalId}." if activity.goalId is newGoalId

  # Rename translation namespaces.
  tasks = activity.tasks or []
  taskIds = (task.id for task in tasks)

  rename = (id) => id.replace activity.goalId, newGoalId

  for namespace in [activity.goalId, taskIds...]
    newNamespace = rename namespace

    Artificial.Babel.Translation.documents.update {namespace},
      $set: namespace: newNamespace
    ,
      multi: true

  # Update the activity with new goal ID.
  newTasks = _.cloneDeep tasks

  for task in newTasks
    task.id = rename task.id
    _.transform task.predecessors, rename if task.predecessors

  $set =
    goalId: newGoalId
    tasks: newTasks

  $set.finalTasks = _.map activity.finalTasks, rename if activity.finalTasks

  PAA.StudyGuide.Activity.documents.update activityId, {$set}

  # Remove the old goal and tasks from the registry.
  PAA.Learning.Goal.removeClassForId activity.goalId
  PAA.Learning.Task.removeClassForId task.id for task in tasks

  # Create the new goal and task classed.
  PAA.StudyGuide.initializeTask newGoalId, task.id, task.type for task in newTasks
  PAA.StudyGuide.initializeGoal newGoalId

  # Rename goals in study plans.
  fieldGoalId = activity.goalId.replace /\./g, '_'
  newFieldGoalId = newGoalId.replace /\./g, '_'
  studyPlanGoalsField = 'state.things.PixelArtAcademy.PixelPad.Apps.StudyPlan.goals'

  LOI.GameState.documents.update
    "#{studyPlanGoalsField}.#{fieldGoalId}": $exists: true
  ,
    $rename:
      "#{studyPlanGoalsField}.#{fieldGoalId}": "#{studyPlanGoalsField}.#{newFieldGoalId}"
  ,
    multi: true

  # Rename tasks in task entries.
  for taskId in taskIds
    PAA.Learning.Task.Entry.documents.update {taskId},
      $set:
        taskId: rename taskId
    ,
      multi: true

PAA.StudyGuide.Activity.insertTask.method (activityId, taskId, taskType) ->
  check activityId, Match.DocumentId
  check taskId, String
  check taskType, Match.Where (value) => value in PAA.Learning.Task.getTypes()
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

  # Remove the task from the registry.
  PAA.Learning.Task.removeClassForId taskId

PAA.StudyGuide.Activity.renameTaskId.method (activityId, taskId, newTaskId) ->
  check activityId, Match.DocumentId
  check taskId, String
  check newTaskId, String
  LOI.Authorize.admin()

  throw new AE.ArgumentException "No renaming requested." if taskId is newTaskId

  activity = PAA.StudyGuide.Activity.documents.findOne activityId
  throw new AE.ArgumentException "Activity does not exist." unless activity

  # Make sure the task exists.
  task = _.find activity.tasks, (task) -> task.id is taskId
  throw new AE.ArgumentException "Task #{taskId} for activity with goal #{activity.goalId} does not exist." unless task

  # Rename translation namespaces.
  Artificial.Babel.Translation.documents.update
    namespace: taskId
  ,
    $set: namespace: newTaskId
  ,
    multi: true

  newTasks = _.cloneDeep activity.tasks

  rename = (id) => if id is taskId then newTaskId else id

  for task in newTasks
    task.id = rename task.id
    _.transform task.predecessors, rename if task.predecessors

  $set = tasks: newTasks
  $set.newFinalTasks = _.map activity.tasks, rename if activity.tasks

  # Update the activity with new task ID.
  PAA.StudyGuide.Activity.documents.update activityId, {$set}

  # Remove the old task from the registry.
  PAA.Learning.Task.removeClassForId taskId

  # Reinitialize the task and goal.
  PAA.StudyGuide.initializeTask activity.goalId, newTaskId, task.type

  goalClass = PAA.Learning.Goal.getClassForId activity.goalId
  goalClass.initialize()

  # Rename task in task entries.
  PAA.Learning.Task.Entry.documents.update {taskId},
    $set:
      taskId: newTaskId
  ,
    multi: true

PAA.StudyGuide.Activity.changeTaskType.method (activityId, taskId, newTaskType) ->
  check activityId, Match.DocumentId
  check taskId, String
  check newTaskType, Match.Where (value) => value in PAA.Learning.Task.getTypes()
  LOI.Authorize.admin()

  activity = PAA.StudyGuide.Activity.documents.findOne activityId
  throw new AE.ArgumentException "Activity does not exist." unless activity

  # Make sure the task exists.
  task = _.find activity.tasks, (task) -> task.id is taskId
  throw new AE.ArgumentException "Task #{taskId} for activity with goal #{activity.goalId} does not exist." unless task

  throw new AE.ArgumentException "No change requested." if task.type is newTaskType

  # Update task type.
  PAA.StudyGuide.Activity.documents.update
    _id: activity._id
    'tasks.id': taskId
  ,
    $set:
      "tasks.$.type": newTaskType

  # Remove the old task from the registry.
  PAA.Learning.Task.removeClassForId taskId

  # Reinitialize the task and goal.
  PAA.StudyGuide.initializeTask activity.goalId, taskId, newTaskType

  goalClass = PAA.Learning.Goal.getClassForId activity.goalId
  goalClass.initialize()

PAA.StudyGuide.Activity.updateArticle.method (activityId, updateDeltaOperations) ->
  check activityId, Match.DocumentId
  check updateDeltaOperations, Array
  LOI.Authorize.admin()

  activity = PAA.StudyGuide.Activity.documents.findOne activityId
  throw new AE.ArgumentException "Activity does not exist." unless activity

  contentDelta = new Delta activity.article or [insert: '\n']
  updateDelta = new Delta updateDeltaOperations
  newContentDelta = contentDelta.compose updateDelta

  # Update the text.
  PAA.StudyGuide.Activity.documents.update activityId,
    $set:
      article: newContentDelta.ops
