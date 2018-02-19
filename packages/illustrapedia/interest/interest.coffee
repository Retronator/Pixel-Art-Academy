AB = Artificial.Babel
AM = Artificial.Mummification
IL = Illustrapedia

class IL.Interest extends AM.Document
  @id: -> 'Illustrapedia.Interest'
  # name: the canonical name of the interest
  #   _id
  #   translations
  # synonyms: array of strings that indicate this interest.
  # searchTerms: auto-generated array of words that match this interest.
  @Meta
    name: @id()
    fields: =>
      name: @ReferenceField AB.Translation, ['translations'], false
      searchTerms: [@GeneratedField 'self', ['name', 'synonyms'], (interest) ->
        searchTerms = []

        if interest.synonyms
          for synonym in interest.synonyms
            searchTerms.push synonym.toLowerCase()

        if interest.name?.translations
          allTranslationData = AB.Translation.allTranslationData interest.name

          for translation in allTranslationData
            searchTerms.push translation.translationData.text.toLowerCase()
        
        [interest._id, searchTerms]
      ]

  # Methods

  @insert: @method 'insert'
  @update: @method 'update'

  # Subscriptions

  @all: @subscription 'all'
