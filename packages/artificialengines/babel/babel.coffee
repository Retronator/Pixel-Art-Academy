class Artificial.Babel
  @LanguagePreferenceLocalStorageKey:  "Artificial.Babel.languagePreference"

  # Set default language preference.
  defaultLanguagePreference = null

  if Meteor.isClient
    # On the client we can look at the navigator properties.
    defaultLanguagePreference ?= navigator.languages
    defaultLanguagePreference ?= [navigator.language] if navigator.language

  # Fallback to the hardcoded value.
  defaultLanguagePreference ?= ['en-US', 'en']

  @_userLanguagePreference = new ReactiveField defaultLanguagePreference

  @userLanguagePreference: (value) ->
    if value
      @_userLanguagePreference value

      # Also write it to local storage.
      encodedValue = EJSON.stringify value
      localStorage.setItem Artificial.Babel.LanguagePreferenceLocalStorageKey, encodedValue

    @_userLanguagePreference()

  # Extra functionality on the babel server.
  if Meteor.isServer
    # Set the default language for new translations.
    @defaultLanguage = 'en-US'

    # Boolean whether to insert the key as a translation under default language.
    @insertKeyForDefaultLanguage = true

# On the user, try to load the language preference from local storage.
if Meteor.isClient
  languagePreference = localStorage.getItem Artificial.Babel.LanguagePreferenceLocalStorageKey
  Artificial.Babel._userLanguagePreference EJSON.parse languagePreference if languagePreference
