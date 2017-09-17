AB = Artificial.Babel
AM = Artificial.Mummification

class AB.Language extends AM.Document
  @id: -> 'Artificial.Babel.Language'
  # code: ISO 639-1 language code
  # name: the name of the language
  #   _id
  # regions: ordered array of regions this language is used in
  #   region: region document
  #     _id
  #     code
  #   rank: which rank this language has in that region.
  @Meta
    name: @id()
    fields: =>
      name: @ReferenceField AB.Translation, [], false
      regions: [
        region: @ReferenceField AB.Region, ['code']
      ]

  @all: @subscription 'all'

  # Inserts a language into the database.
  @create: (languageData) ->
    languageCode = languageData.code

    # Transform name entries into a translation document.
    nameEntries = languageData.name
    languageData.name =
      _id: @_createNameTranslation languageCode

    # Remove the default translation, since we'll use only the ones provided
    # in the data, but it was already created by default, using the key.
    AB.Translation.removeLanguage languageData.name._id, Artificial.Babel.defaultLanguage

    # Update translations of the name.
    for nameLanguageCode, name of nameEntries
      AB.Translation.update languageData.name._id, nameLanguageCode, name

    # Upsert the document with its language code.
    AB.Language.documents.upsert code: languageData.code, languageData

  @addRegion: (languageCode, regionCode, rank) ->
    language = AB.Language.documents.findOne code: languageCode
    region = AB.Region.documents.findOne code: regionCode

    return unless language and region

    regions = language.regions or []

    # Don't insert the region if it's already there.
    languageRegion = _.find regions, (existingRegion) => existingRegion.region._id is region._id

    unless languageRegion
      languageRegion =
        region:
          _id: region._id

      regions.push languageRegion

    languageRegion.rank = rank

    # Sort regions by rank
    regions = _.sortBy regions, 'rank'

    AB.Language.documents.update language._id,
      $set:
        regions: regions

  @_createNameTranslation: (languageCode, defaultText) ->
    namespace = "Artificial.Babel.Language.Names"
    AB.createTranslation namespace, languageCode, defaultText
