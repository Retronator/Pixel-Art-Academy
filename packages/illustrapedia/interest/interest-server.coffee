AB = Artificial.Babel
AM = Artificial.Mummification
IL = Illustrapedia

class IL.Interest extends IL.Interest
  @Meta
    name: @id()
    replaceParent: true

  # Creates an interest document if it can't be found.
  @initialize: (interest) ->
    return if @find interest

    # Create translation for the name.
    nameTranslationId = AB.Translation.documents.insert {}
    AB.Translation.update nameTranslationId, Artificial.Babel.defaultLanguage, interest

    IL.Interest.documents.insert
      name:
        _id: nameTranslationId
