AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StudyGuide.Activity extends PAA.StudyGuide.Activity
  @Meta
    name: @id()
    replaceParent: true

  @initializeAll: (component) ->
    subscribeProvider = component or Meteor
    autorunProvider = component or Tracker

    # Subscribe to all activities.
    activitiesSubscription = @all.subscribe subscribeProvider

    # Fetch all activities, which triggers their initialization.
    autorunProvider.autorun =>
      for activity in @documents.fetch()
        # Initialize activity tasks.
        if activity.tasks
          for task in activity.tasks
            PAA.StudyGuide.initializeTask activity.goalId, task.id, task.type

        # Initialize a goal based on this activity.
        PAA.StudyGuide.initializeGoal activity.goalId

    # Return the subscription so that the caller can check if activities are ready.
    activitiesSubscription
