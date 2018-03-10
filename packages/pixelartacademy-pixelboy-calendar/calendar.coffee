AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Calendar extends PAA.PixelBoy.App
  # weeklyGoals: an object of weekly goals set by the player
  #   daysWithActivities: how many days in a week need to contain activities
  #   totalHours: how many hours in a week need to be spent on activities
  #   archive: stores historical settings as recorded at the end of each week
  #     {year}
  #       {month}
  #         {day}: date of Monday that started the week
  #           daysWithActivities
  #           totalHours
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Calendar'
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

  @archivedWeeklyGoalsForDate: (date) ->
    archiveProperty = @archivePropertyForDate date
    @state "weeklyGoals.archive.#{archiveProperty}"

  @archivePropertyForDate: (date) ->
    dayOfWeek = date.getDay()
    dayOfWeek = 7 if dayOfWeek is 0
    monday = new Date date.getFullYear(), date.getMonth(), date.getDate() + 1 - dayOfWeek

    "#{monday.getFullYear()}.#{monday.getMonth()}.#{monday.getDate()}"

  constructor: ->
    super

    @resizable false

    @monthView = new ReactiveField null
    @goalSettings = new ReactiveField null

  onCreated: ->
    super
    
    @monthView new @constructor.MonthView @
    @goalSettings new @constructor.GoalSettings @

    @autorun (computation) =>
      goalSettings = @goalSettings()

      if goalSettings.isCreated() and goalSettings.visible()
        width = 200
        height = 230

      else
        width = 310
        height = 230

      @minWidth width
      @minHeight height

      @maxWidth width
      @maxHeight height

  onBackButton: ->
    goalSettings = @goalSettings()
    return unless goalSettings.visible()

    # Directly quit if goal hasn't been set.
    return unless goalSettings.hasGoal()

    # We have a goal, so just return to the month view.
    goalSettings.visible false

    # Inform that we've handled the back button.
    true
