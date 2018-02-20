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
      searchTerms: [@GeneratedField 'self', ['name', 'synonyms'], (interest) =>
        searchTerms = []

        if interest.synonyms
          for synonym in interest.synonyms
            # Use lowercase letters only (strips symbols and deburrs the string).
            searchTerms.push _.lowerCase synonym

        if interest.name?.translations
          allTranslationData = AB.Translation.allTranslationData interest.name

          for translation in allTranslationData
            searchTerms.push _.lowerCase translation.translationData.text
        
        [interest._id, searchTerms]
      ]

  # Methods

  @insert: @method 'insert'
  @update: @method 'update'

  # Subscriptions

  @all: @subscription 'all'
  
  @forSearchTerm: @subscription 'forSearchTerm',
    query: (searchTerm) =>
      return unless searchTerm.length
      # Use lowercase letters only (strips symbols and deburrs the string).
      words = _.lowerCase(searchTerm).split ' '

      searchTerms = []

      # Search term needs to appear at the start of a word. Note that we need to escape the backslashes.
      searchTerms.push searchTerms: new RegExp "(?:^#{word}|\\s#{word})", 'i' for word in words

      @documents.find $and: searchTerms

  # Convenience method to return the first interest matching the search term.
  @find: (searchTerm) ->
    @forSearchTerm.query(searchTerm).fetch()[0]
