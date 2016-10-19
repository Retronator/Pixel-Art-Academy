AB = Artificial.Babel

# Set initial language preference.
setLanguagePreference = ->
  languagePreference = null
  
  if Meteor.isClient
    # On the client, try to load the language preference from local storage.
    storedLanguagePreference = localStorage.getItem AB.LanguagePreferenceLocalStorageKey
    languagePreference = EJSON.parse storedLanguagePreference if storedLanguagePreference

    # If we didn't have it stored yet, we can look at the navigator properties.
    languagePreference ?= navigator.languages
    languagePreference ?= [navigator.language] if navigator.language
  
  # Fallback to the hardcoded value.
  languagePreference ?= ['en-US', 'en']
  
  AB.userLanguagePreference languagePreference

setLanguagePreference()
