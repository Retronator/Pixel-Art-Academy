AB = Artificial.Babel

# Set initial language preference.
setLanguagePreference = ->
  languagePreference = null
  
  if Meteor.isClient
    # On the client, we can initialize with the navigator properties.
    languagePreference ?= navigator.languages
    languagePreference ?= [navigator.language] if navigator.language
  
  # Fallback to the hardcoded value.
  languagePreference ?= ['en-US', 'en']
  
  AB.userLanguagePreference languagePreference

setLanguagePreference()
