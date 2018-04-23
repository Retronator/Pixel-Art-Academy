PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

class C1.Goals.Time extends PAA.Learning.Goal
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time'

  @displayName: -> "Taking the time"

  Goal = @

  class @SetDesiredTime extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.SetDesiredTime'

    @directive: -> "Set desired time to draw"

    @instructions: -> """
      With the Calendar app, set how much time you want to spend drawing per week.
    """

    @initialize()

  class @MeaningfulAndManageable extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.MeaningfulAndManageable'

    @directive: -> "Analyze meaningful and manageable activities"

    @instructions: -> """
      Go through the M & M sheet in the Calendar app to set your activities and desired times.
    """

    @predecessors: -> [Goal.SetDesiredTime]

    @groupNumber: -> -1

    @initialize()

  class @StartLog extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.StartLog'

    @directive: -> "Start Captain's Log"

    @instructions: -> """
      Create your first journal, the Captain's Log, which holds records of all completed activities. Use it to
      compare actual and desired time spent on drawing.
    """

    @predecessors: -> [Goal.SetDesiredTime]

    @initialize()

  class @SetDailyAlarm extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.SetDailyAlarm'

    @directive: -> "Set daily alarm"

    @instructions: -> """
      Using your phone, create a daily recurring alarm to check up on your drawing activities.
    """

    @predecessors: -> [Goal.SetDesiredTime]

    @groupNumber: -> 1

    @initialize()

  class @ScheduleSessions extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.ScheduleSessions'

    @directive: -> "Schedule drawing sessions"

    @instructions: -> """
      Using the Calendar app, schedule times for your drawing sessions.
    """

    @predecessors: -> [Goal.SetDesiredTime]

    @groupNumber: -> 2

    @initialize()

  class @ExportCalendar extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.ExportCalendar'

    @directive: -> "Export calendar"

    @instructions: -> """
      Export your weekly timetable to display the drawing sessions in your own calendar software.
    """

    @predecessors: -> [Goal.ScheduleSessions]

    @groupNumber: -> 2

    @initialize()

  class @ReachDesiredTime extends PAA.Learning.Task
    @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Goals.Time.ReachDesiredTime'

    @directive: -> "Spend your desired time drawing"

    @instructions: -> """
      By the end of Admission Week, spend the desired time doing drawing (and related) activities.
    """

    @predecessors: -> [Goal.StartLog]

    @interests: -> ['desired drawing time']

    @initialize()

  @tasks: -> [
    @SetDesiredTime
    @MeaningfulAndManageable
    @StartLog
    @SetDailyAlarm
    @ScheduleSessions
    @ExportCalendar
    @ReachDesiredTime
  ]

  @finalTasks: -> [
    @ReachDesiredTime
  ]

  @initialize()
