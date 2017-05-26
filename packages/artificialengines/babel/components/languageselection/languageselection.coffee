AB = Artificial.Babel
AM = Artificial.Mirage

# Component for choosing a language and region.
class AB.Components.LanguageSelection extends AM.Component
  template: -> 'Artificial.Babel.Components.LanguageSelection'

  load: ->
    throw new AE.NotImplementedException "You must implement the load method."

  save: (value) ->
    throw new AE.NotImplementedException "You must implement the save method."

  onCreated: ->
    super

    # Subscribe to all languages, regions and the translations of their names.
    AB.Language.all.subscribe @
    AB.Region.all.subscribe @

    @subscribe 'Artificial.Babel.Translation', 'Artificial.Babel.Language.Names'
    @subscribe 'Artificial.Babel.Translation', 'Artificial.Babel.Region.Names'

    @showLanguages = new ReactiveField false
    @showRegions = new ReactiveField false
    @showAllRegions = new ReactiveField false

    # Cache loaded language to minimize reactivity.
    @languageRegion = new ComputedField => @load()

    @languageFilter = new ReactiveField ''
    @regionFilter = new ReactiveField ''

    @languageSearch = new @constructor.Search @languageFilter
    @regionSearch = new @constructor.Search @regionFilter

    # Cache languages and regions with their translations pulled in.
    @languages = new ComputedField =>
      for language in AB.Language.documents.find().fetch()
        language.name.refresh()
        language

    @regions = new ComputedField =>
      for region in AB.Region.documents.find().fetch()
        region.name.refresh()
        region

    # Cache language and region name translations.
    @languageNames = new ComputedField =>
      for language in @languages()
        language: language
        name: language.name.translate(AB.userLanguagePreference())?.text
        nativeName: language.name.translationData(language.code)?.text

    # Cache language and region name translations.
    @regionNames = new ComputedField =>
      for region in @regions()
        region: region
        name: region.name.translate(AB.userLanguagePreference())?.text

  currentLanguage: ->
    AB.Language.documents.findOne
      code: _.splitLanguageRegion(@languageRegion()).languageCode

  currentRegion: ->
    AB.Region.documents.findOne
      code: _.splitLanguageRegion(@languageRegion()).regionCode

  filteredLanguageNames: ->
    # Filter by translated and native name and language code.
    languageFilter = @languageFilter().toLowerCase()

    _.filter @languageNames(), (language) =>
      _.some [
        _.startsWith(language.name?.toLowerCase(), languageFilter)
        _.startsWith(language.nativeName?.toLowerCase(), languageFilter)
        _.startsWith(language.language.code, languageFilter)
      ]

  filteredRegionNames: ->
    regionFilter = @regionFilter().toLowerCase()

    # If we're searching, search within all regions.
    if @showAllRegions() or regionFilter.length
      regions = @regionNames()

    else
      # Show only top-ranked regions of this language.
      return unless language = @currentLanguage()

      topRank = language.regions?[0]?.rank
      languageRegions = _.filter language.regions, (languageRegion) -> languageRegion.rank is topRank
      regionIds = (languageRegion.region._id for languageRegion in languageRegions)

      regions = _.filter @regionNames(), (region) =>
        region.region._id in regionIds

    # Filter by translated name and region code.
    _.filter regions, (region) =>
      _.some [
        _.startsWith(region.name?.toLowerCase(), regionFilter)
        _.startsWith(region.region.code, regionFilter)
      ]

  showAllRegionsButton: ->
    not @showAllRegions() and not @regionFilter()

  events: ->
    super.concat
      'click .abcls-current-language': @onClickCurrentLanguage
      'click .abcls-no-language': @onClickNoLanguage
      'click .abcls-language': @onClickLanguage
      'click .abcls-current-region': @onClickCurrentRegion
      'click .abcls-no-region': @onClickNoRegion
      'click .abcls-region': @onClickRegion
      'click .abcls-show-all-regions-button': @onClickShowAllRegionsButton

  onClickCurrentLanguage: (event) ->
    @showLanguages not @showLanguages()
    @showRegions false

    # Clear out and focus on the search field.
    @languageFilter ''

    Tracker.afterFlush =>
      @$('.abcls-languages .abcls-search input').focus()

  onClickNoLanguage: (event) ->
    @save ''

    @showLanguages false

  onClickLanguage: (event) ->
    languageName = @currentData()

    @save _.joinLanguageRegion languageName.language.code

    @showLanguages false
    @showAllRegions false

  onClickCurrentRegion: (event) ->
    @showRegions not @showRegions()
    @showLanguages false

    # Clear out and focus on the search field.
    @regionFilter ''

    Tracker.afterFlush =>
      @$('.abcls-regions .abcls-search input').focus()

  onClickNoRegion: (event) ->
    @save _.joinLanguageRegion @currentLanguage().code

    @showRegions false

  onClickRegion: (event) ->
    regionName = @currentData()

    @save _.joinLanguageRegion @currentLanguage().code, regionName.region.code

    @showRegions false

  onClickShowAllRegionsButton: (event) ->
    @showAllRegions true

  # Components

  class @Search extends AM.DataInputComponent
    @register 'Artificial.Babel.Components.LanguageSelection.Search'

    constructor: (@field) ->
      super

    load: ->
      @field()

    save: (value) ->
      @field value

    placeholder: ->
      @translate("Search").text
