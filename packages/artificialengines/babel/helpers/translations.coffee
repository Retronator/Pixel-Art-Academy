AB = Artificial.Babel

# A helper that initializes translations for provided keys and reactively provides translated strings on the client.
class AB.Helpers.Translations
  @initialize: (translationNamespace, defaultTranslations) ->
    return unless Meteor.isServer

    Document.startup =>
      return if Meteor.settings.startEmpty

      for translationKey, defaultText of defaultTranslations
        AB.createTranslation translationNamespace, translationKey, defaultText if defaultText

  constructor: (translationNamespace) ->
    # Subscribe to this thing's translations.
    translationSubscription = AB.subscribeNamespace translationNamespace

    translationsField = new ComputedField =>
      return unless translationSubscription.ready()

      translations = {}

      for translation in AB.existingTranslations translationSubscription
        translated = AB.translate translation
        translations[translation.key] = translated.text if translated.language

      translations

    translations = ->
      translationsField()

    # Allow correct handling of instanceof operator.
    Object.setPrototypeOf translations, @constructor.prototype

    translations.ready = ->
      translationSubscription.ready()

    translations.stop = ->
      translationSubscription.stop()
      translationsField.stop()

    # Return the translations function (return must be explicit).
    return translations
