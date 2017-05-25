AB = Artificial.Babel
AM = Artificial.Mummification

class AB.Region extends AM.Document
  @id: -> 'Artificial.Babel.Region'
  # code: ISO 3166-1 region code
  # name: the name of the region
  #   _id
  @Meta
    name: @id()
    fields: =>
      name: @ReferenceField AB.Translation, [], false

  @all: @subscription 'all'

  # Inserts a region into the database.
  @create: (regionData) ->
    regionCode = regionData.code

    # Transform name entries into a translation document.
    nameEntries = regionData.name
    regionData.name =
      _id: @_createNameTranslation regionCode

    # Remove the default translation, since we'll use only the ones provided
    # in the data, but it was already created by default, using the key.
    AB.Translation.remove regionData.name._id, Artificial.Babel.defaultLanguage

    # Update translations of the name.
    for nameLanguageCode, name of nameEntries
      AB.Translation.update regionData.name._id, nameLanguageCode, name

    # Upsert the document with its region code.
    AB.Region.documents.upsert code: regionData.code, regionData

  @_createNameTranslation: (regionCode, defaultText) ->
    namespace = "Artificial.Babel.Region.Names"
    AB.createTranslation namespace, regionCode, defaultText
