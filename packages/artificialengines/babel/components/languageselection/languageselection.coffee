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

  currentLanguage: ->
    AB.Language.documents.findOne
      code: _.splitLanguageRegion(@languageRegion()).languageCode

  currentRegion: ->
    AB.Region.documents.findOne
      code: _.splitLanguageRegion(@languageRegion()).regionCode

  languages: ->
    AB.Language.documents.find()

  regions: ->
    if @showAllRegions()
      AB.Region.documents.find()

    else
      # Show only top-ranked regions of this language.
      return unless language = @currentLanguage()

      topRank = language.regions[0]?.rank
      languageRegions = _.filter language.regions, (languageRegion) -> languageRegion.rank is topRank
      regionIds = (languageRegion.region._id for languageRegion in languageRegions)

      AB.Region.documents.find
        _id:
          $in: regionIds

  nativeLanguageName: ->
    language = @currentData()

    # Refresh language name to get translations.
    language.name.refresh()

    # Get whatever translation is set under this language's code (or leave blank if it isn't).
    language.name.translationData(language.code)?.text

  events: ->
    super.concat
      'click .abcls-current-language': @onClickCurrentLanguage
      'click .abcls-language': @onClickLanguage
      'click .abcls-current-region': @onClickCurrentRegion
      'click .abcls-no-region': @onClickNoRegion
      'click .abcls-region': @onClickRegion
      'click .abcls-show-all-regions-button': @onClickShowAllRegionsButton

  onClickCurrentLanguage: (event) ->
    @showLanguages not @showLanguages()
    @showRegions false

  onClickLanguage: (event) ->
    language = @currentData()

    @save _.joinLanguageRegion language.code

    @showLanguages false
    @showAllRegions false

  onClickCurrentRegion: (event) ->
    @showRegions not @showRegions()
    @showLanguages false

  onClickNoRegion: (event) ->
    @save _.joinLanguageRegion @currentLanguage().code

    @showRegions false

  onClickRegion: (event) ->
    region = @currentData()

    @save _.joinLanguageRegion @currentLanguage().code, region.code

    @showRegions false

  onClickShowAllRegionsButton: (event) ->
    @showAllRegions true
