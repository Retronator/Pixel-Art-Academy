AE = Artificial.Everywhere
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.Time extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time'

  @displayName: -> "Taking the time"

  @chapter: -> C1

  Goal = @

  class @SetDesiredTime extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.SetDesiredTime'
    @goal: -> Goal

    @directive: -> "Set desired time to draw"

    @instructions: -> """
      With the Calendar app, set how much time you want to spend drawing per week.
    """

    @initialize()

    @completedConditions: ->
      return unless weeklyGoals = PAA.PixelBoy.Apps.Calendar.state 'weeklyGoals'

      weeklyGoals.daysWithActivities or weeklyGoals.totalHours

  class @MeaningfulAndManageable extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.MeaningfulAndManageable'
    @goal: -> Goal

    @directive: -> "Analyze meaningful and manageable activities"

    @instructions: -> """
      Go through the M & M sheet in the Calendar app to set your activities and desired times.
    """

    @predecessors: -> [Goal.SetDesiredTime]

    @groupNumber: -> -1

    @initialize()

  class @StartLog extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.StartLog'
    @goal: -> Goal

    @directive: -> "Start Captain's Log"

    @instructions: -> """
      Create your first journal, the Captain's Log, which holds records of all completed activities. Use it to
      compare actual and desired time spent on drawing.
    """

    @predecessors: -> [Goal.SetDesiredTime]

    @initialize()

  class @SetDailyAlarm extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.SetDailyAlarm'
    @goal: -> Goal

    @directive: -> "Set daily alarm"

    @instructions: -> """
      Using your phone, create a daily recurring alarm to check up on your drawing activities.
    """

    @predecessors: -> [Goal.SetDesiredTime]

    @groupNumber: -> 1

    @initialize()

  class @ScheduleSessions extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.ScheduleSessions'
    @goal: -> Goal

    @directive: -> "Schedule drawing sessions"

    @instructions: -> """
      Using the Calendar app, schedule times for your drawing sessions.
    """

    @predecessors: -> [Goal.SetDesiredTime]

    @groupNumber: -> 2

    @initialize()

  class @ExportCalendar extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.ExportCalendar'
    @goal: -> Goal

    @directive: -> "Export calendar"

    @instructions: -> """
      Export your weekly timetable to display the drawing sessions in your own calendar software.
    """

    @predecessors: -> [Goal.ScheduleSessions]

    @groupNumber: -> 2

    @initialize()

  class @ReachDesiredTime extends PAA.Learning.Task.Automatic
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.ReachDesiredTime'
    @goal: -> Goal

    @directive: -> "Spend your desired time drawing"

    @instructions: -> """
      By the end of Admission Week, spend the desired time doing drawing and related activities.
    """

    @predecessors: -> [Goal.SetDesiredTime]

    @interests: -> ['desired drawing time']

    @initialize()

    @daysWithActivitiesInLast7Days: ->
      return unless LOI.characterId()

      activities = @_getActivities()

      # Quantize activities to separate days.
      dates = for activity in activities
        year: activity.time.getFullYear()
        month: activity.time.getMonth()
        day: activity.time.getDate()

      uniqueDates = _.uniqWith dates, _.isEqual

      uniqueDates.length

    @totalHoursInLast7Days: ->
      return unless LOI.characterId()

      activities = @_getActivities()

      # Quantize activities to 15 minute blocks.
      quarters = for activity in activities
        year: activity.time.getFullYear()
        month: activity.time.getMonth()
        day: activity.time.getDate()
        hour: activity.time.getHours()
        quarter: Math.floor activity.time.getMinutes() / 15

      uniqueQuarters = _.uniqWith quarters, _.isEqual

      uniqueQuarters.length / 4 # hours

    @_getActivities: ->
      @_subscribeToActivitiesInLast7Days()

      now = new Date()

      characterId = LOI.characterId()
      time = $gte: new Date now.getFullYear(), now.getMonth(), now.getDate() - 6

      _.flatten [
        PAA.Practice.Journal.Entry.documents.fetch
          'journal.character._id': characterId
          time: time
        ,
          fields:
            time: 1
      ,
        PAA.Learning.Task.Entry.documents.fetch
          'character._id': characterId
          time: time
        ,
          fields:
            time: 1
      ]

    @_subscribeToActivitiesInLast7Days: ->
      now = new Date()
      year = now.getFullYear()
      month = now.getMonth()
      day = now.getDate()

      # Create a date range of 7 days from end of today backwards.
      dateRange = new AE.DateRange
        start: new Date year, month, day - 6
        end: new Date year, month, day + 1

      characterId = LOI.characterId()

      PAA.Practice.Journal.Entry.activityForCharacter.subscribe characterId, dateRange
      PAA.Learning.Task.Entry.activityForCharacter.subscribe characterId, dateRange

    @completedConditions: ->
      return unless weeklyGoals = PAA.PixelBoy.Apps.Calendar.state 'weeklyGoals'

      if weeklyGoals.daysWithActivities
        return unless @daysWithActivitiesInLast7Days() >= weeklyGoals.daysWithActivities

      if weeklyGoals.totalHours
        return unless @totalHoursInLast7Days() >= weeklyGoals.totalHours

      true

  @tasks: -> [
    @SetDesiredTime
    # @MeaningfulAndManageable
    # @StartLog
    # @SetDailyAlarm
    # @ScheduleSessions
    # @ExportCalendar
    @ReachDesiredTime
  ]

  @finalTasks: -> [
    @ReachDesiredTime
  ]

  @initialize()
