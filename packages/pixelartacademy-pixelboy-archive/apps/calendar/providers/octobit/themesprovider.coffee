AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Calendar = PAA.PixelBoy.Apps.Calendar

class Calendar.Providers.Octobit.ThemesProvider extends Calendar.Provider
  @calendarComponentClass: ->
    Calendar.Providers.Octobit.ThemeComponent

  @id: -> 'Calendar.Providers.Octobit.ThemesProvider'
  @displayName: -> "Octobit"

  constructor: ->
    super

    @themes = [
      {date: new Date(2017, 9, 1), cute: 'clown', notCute: 'clown'}
      {date: new Date(2017, 9, 2), cute: 'astronaut', notCute: 'alien'}
      {date: new Date(2017, 9, 3), cute: 'prey', notCute: 'predator'}
      {date: new Date(2017, 9, 4), cute: 'fresh', notCute: 'rotten'}
      {date: new Date(2017, 9, 5), cute: 'four legs max', notCute: 'too many legs'}
      {date: new Date(2017, 9, 6), cute: 'crush', notCute: 'creep'}
      {date: new Date(2017, 9, 7), cute: 'tree house', notCute: 'ghost town'}
      {date: new Date(2017, 9, 8), cute: 'good witch', notCute: 'bad bitch'}
      {date: new Date(2017, 9, 9), cute: 'breakfast', notCute: 'poison'}
      {date: new Date(2017, 9, 10), cute: 'playground', notCute: 'isolated'}
      {date: new Date(2017, 9, 11), cute: 'theme park', notCute: 'freak show'}
      {date: new Date(2017, 9, 12), cute: 'dolls', notCute: 'possession'}
      {date: new Date(2017, 9, 13), cute: 'cartoon', notCute: 'horror movie'}
      {date: new Date(2017, 9, 14), cute: 'sushi', notCute: 'kaiju'}
      {date: new Date(2017, 9, 15), cute: 'road trip', notCute: 'road kill'}
      {date: new Date(2017, 9, 16), cute: 'babies', notCute: 'teenagers'}
      {date: new Date(2017, 9, 17), cute: 'flora', notCute: 'thorns'}
      {date: new Date(2017, 9, 18), cute: 'tea party', notCute: 'cult'}
      {date: new Date(2017, 9, 19), cute: 'butterfly', notCute: 'hurricane'}
      {date: new Date(2017, 9, 20), cute: 'rainbow', notCute: 'monochrome'}
      {date: new Date(2017, 9, 21), cute: 'blanket fort', notCute: 'basement'}
      {date: new Date(2017, 9, 22), cute: 'puppy', notCute: 'savage'}
      {date: new Date(2017, 9, 23), cute: 'mushrooms', notCute: 'radiation'}
      {date: new Date(2017, 9, 24), cute: 'tiny house', notCute: 'claustrophobia'}
      {date: new Date(2017, 9, 25), cute: 'coral reef', notCute: 'deep sea'}
      {date: new Date(2017, 9, 26), cute: 'baby pink', notCute: 'ash grey'}
      {date: new Date(2017, 9, 27), cute: 'birthday cake', notCute: 'old'}
      {date: new Date(2017, 9, 28), cute: 'campfire', notCute: 'urban legend'}
      {date: new Date(2017, 9, 29), cute: 'nap', notCute: 'insomnia'}
      {date: new Date(2017, 9, 30), cute: 'old friend', notCute: 'bully'}
      {date: new Date(2017, 9, 31), cute: 'happy ending', notCute: 'everybody dies'}
    ]

  subscriptionName: ->
    # Octobit themes are hard-coded.
    null

  # Returns all events for a specific day.
  getEvents: (dayDate) ->
    targetTime = (new Date(dayDate.getFullYear(), dayDate.getMonth(), dayDate.getDate())).getTime()

    theme = _.find @themes, (theme) => theme.date.getTime() is targetTime

    if theme then [theme] else []
