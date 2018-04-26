AE = Artificial.Everywhere

class Artificial.Babel
  # Default language when new translations are inserted.
  @defaultLanguage = 'en-US'
  
  @cacheUrl = '/artificial/babel/cache.json'

  # Returns an array of languages, ordered by their priority.
  @languagePreference: -> throw new AE.NotImplementedException "Provide language preference."

  # Useful for passing to language conversion functions such as toLocaleString.
  @currentLanguage: -> @languagePreference[0]
