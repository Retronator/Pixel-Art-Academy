AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Apps.Calendar extends AM.Component
  @register 'PixelArtAcademy.Apps.Calendar'

  onCreated: ->
    super

    # Create calendar providers.
    @providers = [
      new PAA.PixelDailies.ThemeCalendarProvider()
    ]

    today = new Date()
    @currentMonth = new ReactiveField new Date today.getFullYear(), today.getMonth(), 1

    # Reactively add a subscription to the range of a full month.
    @autorun =>
      date = @currentMonth()

      # Call subscribes outside of autorun so they don't disappear on recomputation.
      Tracker.afterFlush =>
        for provider in @providers
          provider.subscribeToMonthOf date, @

  # Helpers

  currentMonthText: ->
    date = @currentMonth()
    languagePreference = AB.userLanguagePreference()
    date.toLocaleDateString languagePreference,
      month: 'long'
      year: 'numeric'

  days: ->
    date = @currentMonth()

    new Date date.getFullYear(), date.getMonth(), day for day in [1..date.daysInMonth()]

  calendarEvents: ->
    date = @parentDataWith -> _.isDate @
    provider = @currentData()

    provider.getEvents date

  # Events

  events: ->
    super.concat
      'click .previous-month': @onClickPreviousMonth
      'click .next-month': @onClickNextMonth

  onClickPreviousMonth: (event) ->
    date = @currentMonth()
    @currentMonth new Date date.getFullYear(), date.getMonth() - 1, 1

  onClickNextMonth: (event) ->
    date = @currentMonth()
    @currentMonth new Date date.getFullYear(), date.getMonth() + 1, 1
