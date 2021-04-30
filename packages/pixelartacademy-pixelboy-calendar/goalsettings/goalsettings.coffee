AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Calendar.GoalSettings extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Calendar.GoalSettings'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  constructor: (@calendar) ->
    super arguments...
  
  onCreated: ->
    super arguments...

    # Prepare field for temporarily storing new weekly goals.
    @draftWeeklyGoals = new ReactiveField null

    # Start on the goal settings screen if no goal has been set.
    @visible = new ReactiveField not @hasGoal()

  close: ->
    # Remove draft changes.
    @draftWeeklyGoals null

    # Only proceed/return to the calendar view if a goal has been set.
    if @hasGoal()
      @visible false

    else
      @calendar.os.go()

  getWeeklyGoalsField: (field) =>
    # Return the draft field or the game state field if draft was not set.
    draftField = @draftWeeklyGoals()?[field]

    if draftField isnt undefined then draftField else @calendar.state "weeklyGoals.#{field}"

  setWeeklyGoalsField: (field, value) =>
    draftWeeklyGoals = @draftWeeklyGoals() or {}
    draftWeeklyGoals[field] = value
    @draftWeeklyGoals draftWeeklyGoals

  # Tells if the goal has currently been set in the settings UI.
  hasGoal: ->
    for goal in ['daysWithActivities', 'totalHours']
      return true if @getWeeklyGoalsField goal

    false

  visibleClass: ->
    'visible' if @visible()

  daysPerWeekOptions: ->
    [0..7]

  daysPerWeekCheckedAttribute: ->
    daysPerWeekOption = @currentData()
    daysWithActivities = @getWeeklyGoalsField 'daysWithActivities'

    checked: 'checked' if daysPerWeekOption is daysWithActivities

  daysPerWeek: ->
    @getWeeklyGoalsField 'daysWithActivities'

  hoursPerWeek: ->
    daysWithActivities = @getWeeklyGoalsField 'daysWithActivities'

    switch daysWithActivities
      when 1 then "5 min–1 hour"
      when 2 then "15 min–1.5 hours"
      when 3 then "30 min–2 hours"
      when 4 then "1–2.5 hours"
      when 5 then "1h 30 min–3 hours"
      when 6 then "1h 45 min–3.5 hours"
      when 7 then "2–4 hours"

  difficulty: ->
    difficulty = @getWeeklyGoalsField('daysWithActivities') or 0
    
    totalHours = @getWeeklyGoalsField 'totalHours'
    
    if totalHours
      if totalHours >= 14 then difficulty = Math.max difficulty, 7
      else if totalHours >= 10 then difficulty = Math.max difficulty, 6
      else if totalHours >= 7 then difficulty = Math.max difficulty, 5
      else if totalHours >= 4 then difficulty = Math.max difficulty, 4
      else if totalHours >= 2 then difficulty = Math.max difficulty, 3
      else if totalHours >= 1 then difficulty = Math.max difficulty, 2
      else difficulty = Math.max difficulty, 1
        
    names = [
      "very easy"
      "easy"
      "medium"
      "hard"
      "very hard"
      "hardcore"
      "ultimate"
    ]

    names[difficulty - 1]

  events: ->
    super(arguments...).concat
      'change .days-per-week .option-input': @onChangeDaysPerWeekOptionInput
      'click .confirm-button': @onClickConfirmButton

  onChangeDaysPerWeekOptionInput: (event) ->
    # We convert 0 to null to disable this goal.
    daysPerWeek = parseInt($(event.target).val()) or null

    @setWeeklyGoalsField 'daysWithActivities', daysPerWeek

  onClickConfirmButton: (event) ->
    # Copy changes if they were made.
    if draftWeeklyGoals = @draftWeeklyGoals()
      unless draftWeeklyGoals.daysWithActivities is undefined
        PAA.PixelBoy.Apps.Calendar.setDaysWithActivities draftWeeklyGoals.daysWithActivities

      unless draftWeeklyGoals.totalHours is undefined
        PAA.PixelBoy.Apps.Calendar.setTotalHours draftWeeklyGoals.totalHours

    @close()

  # Components

  class @ActivityHoursPerWeek extends AM.DataInputComponent
    @register 'PixelArtAcademy.PixelBoy.Apps.Calendar.GoalSettings.HoursPerWeek'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Number
      @customAttributes =
        min: 0
        step: 1

    onCreated: ->
      super arguments...

      @goalSettings = @ancestorComponentOfType PAA.PixelBoy.Apps.Calendar.GoalSettings

    load: ->
      @goalSettings.getWeeklyGoalsField 'totalHours'

    save: (value) ->
      if value > 0
        value *= @_saveFactor()

      else
        value = null

      @goalSettings.setWeeklyGoalsField 'totalHours', value

    _saveFactor: ->
      1

  class @ActivityHoursPerDay extends @ActivityHoursPerWeek
    @register 'PixelArtAcademy.PixelBoy.Apps.Calendar.GoalSettings.HoursPerDay'

    load: ->
      return unless hoursPerWeek = super arguments...

      Math.round(hoursPerWeek / 0.7) / 10

    _saveFactor: ->
      7
