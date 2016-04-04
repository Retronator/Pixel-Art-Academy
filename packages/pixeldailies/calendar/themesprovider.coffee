AE = Artificial.Everywhere
PAA = PixelArtAcademy

class PAA.PixelDailies.ThemesCalendarProvider extends PAA.Apps.Calendar.Provider
  constructor: ->
    super

  subscriptionName: ->
    'pixelDailiesThemes'

  # Returns all events for a specific day.
  getEvents: (dayDate) ->
    # Return all themes that were posted on that date.
    query =
      hashtag:
        $exists: true

    dateRange = new AE.DateRange
      year: dayDate.getFullYear()
      month: dayDate.getMonth()
      day: dayDate.getDate()

    query = dateRange.addToMongoQuery query, 'date'

    themes = PAA.PixelDailies.Theme.documents.find query,
      fields:
        tweetData: 0

    # Return the array of components (+ data contexts) that will render the events.
    for theme in themes.fetch()
      component: new PAA.PixelDailies.ThemeCalendarComponent()
      dataContext: theme
