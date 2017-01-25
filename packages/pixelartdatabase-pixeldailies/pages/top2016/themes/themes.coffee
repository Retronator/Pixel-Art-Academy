AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Top2016.Themes extends AM.Component
  @register 'PixelArtDatabase.PixelDailies.Pages.Top2016.Themes'

  # Subscriptions
  @themes: new AB.Subscription name: "#{@componentName()}.themes"

  mixins: -> [@infiniteScroll]

  constructor: ->
    super

    @infiniteScroll = new PADB.PixelDailies.Pages.Top2016.Components.Mixins.InfiniteScroll

  onCreated: ->
    super

    @autorun (computation) =>
      @constructor.themes.subscribe @, @infiniteScroll.limit()

  onRendered: ->
    super

  months: ->
    monthsWithThemes = 0

    months = for monthNumber in [0...12]
      month =
        number: monthNumber
        themesCount: 0

      firstDay = new Date 2016, monthNumber, 1
      firstDayDayOfWeek = firstDay.getDay()
      month.paddingDays = ('' for i in [0...firstDayDayOfWeek])

      month.days = for dayNumber in [1..AE.DateHelper.daysInMonth(monthNumber, 2016)]
        day =
          number: dayNumber

        dayRange = new AE.DateRange
          year: 2016
          month: monthNumber
          day: dayNumber

        themeQuery = {}
        dayRange.addToMongoQuery themeQuery, 'time'

        day.theme = PADB.PixelDailies.Theme.documents.findOne themeQuery
        day.hashtag = day.theme?.hashtags?[0]

        if day.theme
          month.themesCount++

          day.topSubmission = PADB.PixelDailies.Submission.documents.findOne
            'theme._id': day.theme._id

        day

      monthsWithThemes++ if month.themesCount

      month

    @infiniteScroll.updateCount monthsWithThemes

    months

  monthName: ->
    month = @currentData()
    monthDate = new Date 2016, month.number

    monthDate.toLocaleString Artificial.Babel.userLanguagePreference()[0] or 'en-US',
      month: 'long'

  hasThemeClass: ->
    day = @currentData()
    'has-theme' if day.hashtag

  topSubmissionImage: ->
    day = @currentData()
    day.topSubmission?.images[0]

  events: ->
    super.concat
      'mouseenter .day': @onMouseenterDay
      'mouseleave .day': @onMouseleaveDay

  onMouseenterDay: (event) ->
    $(event.target).find('video')[0]?.play()

  onMouseleaveDay: (event) ->
    $(event.target).find('video')[0]?.pause()
