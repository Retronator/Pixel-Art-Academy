LOI = LandsOfIllusions

Activity = LOI.Character.Behavior.Activity

class LOI.Character.Behavior.Activities extends LOI.Character.Part.Property.Array
  hoursSleep: ->
    # Find sleep focal point.
    sleepActivity = _.find @parts(), (activityPart) =>
      activityName = activityPart.properties.key.options.dataLocation()
      activityName is Activity.Keys.Sleep

    sleepActivity?.properties.hoursPerWeek.options.dataLocation() or 0

  hoursAfterSleep: ->
    24 * 7 - @hoursSleep()

  hoursJobSchool: ->
    total = 0

    # Find job and sleep focal points.
    for activityName in [Activity.Keys.Job, Activity.Keys.School]
      activity = _.find @parts(), (activityPart) =>
        activityPart.properties.key.options.dataLocation() is activityName

      total += activity?.properties.hoursPerWeek.options.dataLocation() or 0

    total

  hoursAfterJobSchool: ->
    @hoursAfterSleep() - @hoursJobSchool()

  hoursActivities: ->
    total = 0

    for activityPart in @parts()
      activityKey = activityPart.properties.key.options.dataLocation()

      continue if activityKey in [Activity.Keys.Job, Activity.Keys.School, Activity.Keys.Sleep]

      total += activityPart.properties.hoursPerWeek.options.dataLocation()

    total

  extraHoursPerWeek: ->
    @hoursAfterJobSchool() - @hoursActivities()

  extraHoursPerDay: ->
    Math.round(@extraHoursPerWeek() / 0.7) / 10

  extraHoursTooLow: ->
    @extraHoursPerWeek() < 20

  extraHoursTooHigh: ->
    @extraHoursPerWeek() > 50

  activePersonalActivities: ->
    activities = []

    for activityPart in @parts()
      activityKey = activityPart.properties.key.options.dataLocation()

      continue if activityKey in [Activity.Keys.Job, Activity.Keys.School, Activity.Keys.Sleep]

      activityHours = activityPart.properties.hoursPerWeek.options.dataLocation()

      activities.push activityPart if activityHours

    activities

  toString: ->
    activities = []

    for activityPart in @parts()
      activityHoursPerWeek = activityPart.properties.hoursPerWeek.options.dataLocation()
      activities.push activityPart if activityHoursPerWeek > 0

    # TODO: Replace with translated names.
    activityNames = for activity in activities
      name = activity.properties.key.options.dataLocation()
      hoursPerWeek = activity.properties.hoursPerWeek.options.dataLocation()

      # Add hours per week to drawing string.
      if name is Activity.Keys.Drawing
        "#{hoursPerWeek}h/week #{_.lowerFirst name}"

      else
        _.lowerFirst name

    "#{_.upperFirst activityNames.join ', '}."
