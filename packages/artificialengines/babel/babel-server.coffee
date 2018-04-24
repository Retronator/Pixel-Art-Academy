AE = Artificial.Everywhere

class Artificial.Babel extends Artificial.Babel
  # Useful for passing to language conversion functions such as toLocaleString.
  @currentLanguage: -> @defaultLanguage()

  # Creates a new translation with the default text or updates it if it
  # already exists. It returns the id of the new or existing translation.
  @createTranslation: (namespace, key, defaultText) ->
    existing = @Translation.documents.findOne
      namespace: namespace
      key: key

    if existing
      Artificial.Babel.Translation.update existing._id, @defaultLanguage, defaultText if defaultText

      existing._id

    else
      Artificial.Babel.Translation.insert namespace, key, defaultText
      
  # Returns a translation that has already been created.
  @existingTranslation: (namespace, key) ->
    throw new AE.ArgumentNullException "Namespace must be provided." unless namespace?
    throw new AE.ArgumentNullException "Key must be provided." unless key?

    @Translation.documents.findOne
      namespace: namespace
      key: key
