AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Calendar extends PAA.PixelPad.App
  # weeklyGoals: an object of weekly goals set by the player
  #   daysWithActivities: how many days in a week need to contain activities
  #   totalHours: how many hours in a week need to be spent on activities
  #   archive: stores historical settings as recorded at the end of each week
  #     {year}
  #       {month}
  #         {day}: date of Monday that started the week
  #           daysWithActivities
  #           totalHours
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Calendar'
  @url: -> 'calendar'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Calendar"
  @description: ->
    "
      It's used to track all your activities.
    "

  @initialize()

  @setDaysWithActivities: (value) -> @_setWeeklyGoal 'daysWithActivities', value
  @setTotalHours: (value) -> @_setWeeklyGoal 'totalHours', value

  @_setWeeklyGoal: (goal, value) ->
    @state "weeklyGoals.#{goal}", value

    archiveProperty = @archivePropertyForDate new Date()
    @state "weeklyGoals.archive.#{archiveProperty}.#{goal}", value

    # Set the current goals publicly to profile.

    profileData = _.pick @state("weeklyGoals"), ['daysWithActivities', 'totalHours']
    LOI.Character.updateProfile LOI.characterId(), 'weeklyGoals', profileData

  @archivedWeeklyGoalsForDate: (date) ->
    archiveProperty = @archivePropertyForDate date
    @state "weeklyGoals.archive.#{archiveProperty}"

  @archivePropertyForDate: (date) ->
    dayOfWeek = date.getDay()
    dayOfWeek = 7 if dayOfWeek is 0
    monday = new Date date.getFullYear(), date.getMonth(), date.getDate() + 1 - dayOfWeek

    "#{monday.getFullYear()}.#{monday.getMonth()}.#{monday.getDate()}"

  constructor: ->
    super arguments...

    @resizable false

    @monthView = new ReactiveField null
    @goalSettings = new ReactiveField null

    # Copy current weekly goals to archive, from the last set archive date forward.
    archive = @state "weeklyGoals.archive"

    if archive
      years = _.sortBy _.map(_.keys(archive), (year) => parseInt year), (year) -> year

      if years.length
        year = _.last years
        yearData = archive[year]
        months = _.sortBy _.map(_.keys(yearData), (month) => parseInt month), (month) -> month

        if months.length
          month = _.last months
          monthData = yearData[month]
          days = _.sortBy _.map(_.keys(monthData), (day) => parseInt day), (day) -> day

          if days.length
            day = _.last days

            # Start on the last archive date.
            date = new Date year, month, day
            now = new Date
            currentGoals = _.cloneDeep _.omit @state('weeklyGoals'), 'archive'

            loop
              # Advance one week.
              date = new Date date.getTime() + 7 * 24 * 60 * 60 * 1000 # 7 days
              break if date > now

              # Archive current weekly goals to that date.
              archiveProperty = @constructor.archivePropertyForDate date
              @state "weeklyGoals.archive.#{archiveProperty}", currentGoals

  onCreated: ->
    super arguments...
    
    @monthView new @constructor.MonthView @
    @goalSettings new @constructor.GoalSettings @

    @autorun (computation) =>
      goalSettings = @goalSettings()

      if goalSettings.isCreated() and goalSettings.visible()
        @setFixedPixelPadSize 200, 230

      else
        @setFixedPixelPadSize 310, 230

  onBackButton: ->
    goalSettings = @goalSettings()
    return unless goalSettings.visible()

    # Directly quit if goal hasn't been set. Note that we should not use goal settings' version of has goal
    # since that one determines if a goal has been set in the UI (and not yet transfered to the game state).
    return unless @hasGoal()

    # We have a goal, so just return to the month view.
    goalSettings.close()

    # Inform that we've handled the back button.
    true

  # Tells if the goal has been set in the state.
  hasGoal: ->
    for goal in ['daysWithActivities', 'totalHours']
      return true if @state "weeklyGoals.#{goal}"

    false
