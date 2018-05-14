AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Calendar.MonthView extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Calendar.MonthView'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @ActivityTypes:
    JournalEntries: 'JournalEntries'

  constructor: (@calendar) ->
    super

  mixins: -> [
    PAA.PixelBoy.Components.Mixins.PageTurner
  ]

  onCreated: ->
    super

    @weekdays = [1..7]

    today = new Date()

    @year = new ReactiveField today.getFullYear()
    @month = new ReactiveField today.getMonth()
    @now = new ReactiveField Date.now()
    
    @subscriptionDateRange = new ReactiveField null, EJSON.equals

    # Automatically update subscription date range to include the 
    # earliest and latest month ever displayed in this session.
    @autorun (computation) =>
      year = @year()
      month = @month()

      # We want to react only to year and month changes.
      Tracker.nonreactive =>
        # Add one month of padding to preload data for previous/next
        # month (and include non-month days shown in current month).
        minMonthTime = new Date(year, month - 1, 1).getTime()
        maxMonthTime = new Date(year, month + 2, 1).getTime()

        dateRange = @subscriptionDateRange()

        if dateRange
          startTime = Math.min minMonthTime, dateRange.start().getTime()
          endTime = Math.max maxMonthTime, dateRange.end().getTime()

        else
          startTime = minMonthTime
          endTime = maxMonthTime

        dateRange = new AE.DateRange
          start: new Date startTime
          end: new Date endTime

        @subscriptionDateRange dateRange

    # Subscribe to activities.
    @autorun (computation) =>
      dateRange = @subscriptionDateRange()
      characterId = LOI.characterId()

      PAA.Practice.Journal.Entry.activityForCharacter.subscribe @, characterId, dateRange

    @weeks = ComputedField =>
      characterId = LOI.characterId()

      weeks = []

      year = @year()
      month = @month()
      now = @now()

      firstDayOfMonth = new Date year, month, 1

      # We want to start on Monday, so we need to apply this offset. Note that Sunday returns 0 gor getDay().
      dayOfWeek = firstDayOfMonth.getDay()
      dayOfWeek = 7 if dayOfWeek is 0
      startOffset = 2 - dayOfWeek
      date = new Date year, month, startOffset

      # Add weeks until first day of the week is in the next month.
      weekOffset = 0

      while date.getFullYear() < year or date.getMonth() <= month and date.getFullYear() <= year
        weekStartTime = new Date(year, month, startOffset + weekOffset * 7 ).getTime()
        weekEndTime = new Date(year, month, startOffset + (weekOffset + 1) * 7).getTime()

        week =
          days: []
          active: weekStartTime <= now < weekEndTime

        for dayOfWeek in [0..6]
          day = startOffset + weekOffset * 7 + dayOfWeek

          date = new Date year, month, day
          dayRange = new AE.DateRange {year, month, day}

          # Generate activities.
          activities = []

          query =
            'journal.character._id': characterId

          dayRange.addToMongoQuery query, 'time'

          journalEntries = PAA.Practice.Journal.Entry.documents.find(query).fetch()

          if journalEntries.length
            activities.push
              type: @constructor.ActivityTypes.JournalEntries
              data: journalEntries
              
          activities = _.sortBy activities, 'time'

          week.days.push {date, activities}

        week.daysWithActivities =
          count: _.sumBy week.days, (day) => if day.activities.length then 1 else 0
          goal: PAA.PixelBoy.Apps.Calendar.archivedWeeklyGoalsForDate(date)?.daysWithActivities

        week.daysWithActivities.goalReached = week.daysWithActivities.count >= week.daysWithActivities.goal

        weeks.push week

        weekOffset++

        # Calculate new day for the while loop to analyze if it is still included.
        date = new Date year, month, startOffset + weekOffset * 7

      weeks

  previousPage: ->
    newMonth = @month() - 1

    if newMonth is -1
      newMonth = 11
      @year @year() - 1

    @month newMonth

  nextPage: ->
    newMonth = @month() + 1

    if newMonth is 12
      newMonth = 0
      @year @year() + 1

    @month newMonth

  yearName: ->
    year = @year()

    return "Historic year" if year < 2015
    return "Future year" if year > 2022

    @yearNames =
      2015: "Kickstarter year"
      2016: "Prototype year"
      2017: "Foundation year"
      2018: "Admission year"
      2019: "Freshman year"
      2020: "Sophomore year"
      2021: "Junior year"
      2022: "Senior year"

    @yearNames[year]

  includesTodayClass: ->
    weeks = @weeks()

    firstDay = _.first(weeks).days[0].date
    lastDay = _.last(weeks).days[6].date

    'includes-today' if firstDay.getTime() <= @now() < lastDay.getTime() + 1000 * 60 * 60 * 24

  weeksCountClass: ->
    "weeks-count-#{@weeks().length}"

  weekdayIndicator: ->
    weekday = @currentData()

    exampleDay = new Date 2018, 0, weekday
    exampleDay.toLocaleString AB.currentLanguage(), weekday: 'narrow'

  activeWeekClass: ->
    week = @currentData()

    'active' if week.active

  dayInDisplayedMonthClass: ->
    day = @currentData()
    activeMonth = @month()

    'in-displayed-month' if day.date.getMonth() is activeMonth

  todayClass: ->
    day = @currentData()

    dayStartTime = day.date.getTime()
    dayEndTime = dayStartTime + 1000 * 60 * 60 * 24

    'today' if dayStartTime <= @now() < dayEndTime

  displayedMonthName: ->
    startOfMonth = new Date @year(), @month(), 1
    startOfMonth.toLocaleString AB.currentLanguage(), year: 'numeric', month: 'long'

  activitiesAreJournalEntries: -> @activitiesAreType @constructor.ActivityTypes.JournalEntries
    
  activitiesAreType: (type) ->
    activity = @currentData()
    activity.type is type

  progressBarPercentage: ->
    week = @currentData()

    # If we don't have a goal, consider it done.
    return 100 unless week.daysWithActivities.goal

    Math.round week.daysWithActivities.count / week.daysWithActivities.goal * 100

  progressBarStyle: ->
    percentage = Math.min 100, @progressBarPercentage()

    width: "#{percentage}%"

  visibleClass: ->
    goalSettings = @calendar.goalSettings()
    'visible' unless goalSettings.isCreated() and not goalSettings.hasGoal()

  events: ->
    super.concat
      'click .previous-month-button': @onClickPreviousMonthButton
      'click .next-month-button': @onClickNextMonthButton
      'click .active .weekly-goals': @onClickActiveWeeklyGoals

  onClickPreviousMonthButton: (event) ->
    @previousPage()

  onClickNextMonthButton: (event) ->
    @nextPage()

  onClickActiveWeeklyGoals: (event) ->
    @calendar.goalSettings().visible true
