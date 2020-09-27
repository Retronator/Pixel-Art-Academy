AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# After Study Guide activities are ready, initialize their goals and tasks.
Document.startup =>
  for activity in PAA.StudyGuide.Activity.documents.fetch()
    # Initialize activity tasks.
    if activity.tasks
      for task in activity.tasks
        PAA.StudyGuide.initializeTask activity.goalId, task.id, task.type

    # Initialize a goal based on this activity.
    PAA.StudyGuide.initializeGoal activity.goalId
