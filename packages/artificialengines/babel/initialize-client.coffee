AB = Artificial.Babel

# Set initial language preference.
languagePreference = navigator.languages
languagePreference ?= [navigator.language] if navigator.language

# Fallback to the hardcoded value.
languagePreference ?= ['en-US', 'en']

AB.userLanguagePreference languagePreference
