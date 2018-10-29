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

    # Start on the goal settings screen if no goal has been set.
    @visible = new ReactiveField not @hasGoal()
    
  hasGoal: ->
    for goal in ['daysWithActivities', 'totalHours']
      return true if @calendar.state "weeklyGoals.#{goal}"

    false

  visibleClass: ->
    'visible' if @visible()

  daysPerWeekOptions: ->
    [0..7]

  checkedAttribute: ->
    daysPerWeek = @currentData()
    daysWithActivities = @calendar.state "weeklyGoals.daysWithActivities"

    checked: 'checked' if daysPerWeek is daysWithActivities

  daysPerWeek: ->
    @calendar.state "weeklyGoals.daysWithActivities"

  hoursPerWeek: ->
    daysWithActivities = @calendar.state "weeklyGoals.daysWithActivities"

    switch daysWithActivities
      when 1 then "5 min–1 hour"
      when 2 then "15 min–1.5 hours"
      when 3 then "30 min–2 hours"
      when 4 then "1–2.5 hours"
      when 5 then "1h 30 min–3 hours"
      when 6 then "1h 45 min–3.5 hours"
      when 7 then "2–4 hours"

  difficulty: ->
    difficulty = @calendar.state("weeklyGoals.daysWithActivities") or 0
    
    totalHours = @calendar.state "weeklyGoals.totalHours"
    
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

    PAA.PixelBoy.Apps.Calendar.setDaysWithActivities daysPerWeek

  onClickConfirmButton: (event) ->
    if @hasGoal()
      @visible false

    else
      @calendar.os.go()

  # Components

  class @ActivityHoursPerWeek extends AM.DataInputComponent
    @register 'PixelArtAcademy.PixelBoy.Apps.Calendar.GoalSettings.HoursPerWeek'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Number
      @customAttributes =
        min: 0
        step: 1

    load: ->
      PAA.PixelBoy.Apps.Calendar.state 'weeklyGoals.totalHours'

    save: (value) ->
      if value > 0
        value *= @_saveFactor()

      else
        value = null

      PAA.PixelBoy.Apps.Calendar.setTotalHours value

    _saveFactor: ->
      1

  class @ActivityHoursPerDay extends @ActivityHoursPerWeek
    @register 'PixelArtAcademy.PixelBoy.Apps.Calendar.GoalSettings.HoursPerDay'

    load: ->
      return unless hoursPerWeek = super arguments...

      Math.round(hoursPerWeek / 0.7) / 10

    _saveFactor: ->
      7
