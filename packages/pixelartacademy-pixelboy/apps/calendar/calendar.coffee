AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Calendar extends PAA.PixelBoy.App
  @register 'PixelArtAcademy.PixelBoy.Apps.Calendar'

  displayName: ->
    "Pixel Art Calendar"

  urlName: ->
    'calendar'

  onCreated: ->
    super

    # Create calendar providers.
    @providers = [
      new PAA.PixelDailies.ThemesCalendarProvider()
      new PAA.Practice.CheckInsCalendarProvider()
    ]

    today = new Date()
    @displayedMonth = new ReactiveField new Date today.getFullYear(), today.getMonth(), 1

    # Reactively add a subscription to the range of a full month.
    @autorun =>
      date = @displayedMonth()

      # Call subscribes outside of autorun so they don't disappear on recomputation.
      Tracker.afterFlush =>
        for provider in @providers
          provider.subscribeToMonthOf date, @

  # Helpers
  showNextMonthButton: ->
    # Only show next month button if selected date is less than today.
    today = new Date()
    thisMonth = new Date today.getFullYear(), today.getMonth(), 1
    @displayedMonth().getTime() < thisMonth.getTime()

  displayedMonthText: ->
    date = @displayedMonth()
    languagePreference = AB.userLanguagePreference()
    date.toLocaleDateString languagePreference,
      month: 'long'
      year: 'numeric'

  days: ->
    selectedDate = @displayedMonth()
    lastDay = selectedDate.daysInMonth()

    # If this is the current month, just show the days so far.
    today = new Date()
    lastDay = today.getDate() if today.getFullYear() is selectedDate.getFullYear() and today.getMonth() is selectedDate.getMonth()

    new Date selectedDate.getFullYear(), selectedDate.getMonth(), day for day in [lastDay..1]

  calendarEvents: ->
    date = @parentDataWith (data) => _.isDate data
    provider = @currentData()

    provider.getEvents date

  renderEvent: ->
    event = @parentDataWith 'component'

    event.component.renderComponent @currentComponent()

  renderCalendarComponent: ->
    calendarProvider = @parentDataWith (data) => data instanceof PAA.PixelBoy.Apps.Calendar.Provider
    calendarComponentClass = calendarProvider.constructor.calendarComponentClass()

    calendarComponent = new calendarComponentClass
    calendarComponent.renderComponent @currentComponent()

  # Events

  events: ->
    super.concat
      'click .previous-month': @onClickPreviousMonth
      'click .next-month': @onClickNextMonth

  onClickPreviousMonth: (event) ->
    date = @displayedMonth()
    @displayedMonth new Date date.getFullYear(), date.getMonth() - 1, 1

  onClickNextMonth: (event) ->
    date = @displayedMonth()
    @displayedMonth new Date date.getFullYear(), date.getMonth() + 1, 1
