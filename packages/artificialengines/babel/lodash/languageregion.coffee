# Operations to join and split language-region pairs.

_.mixin
  # Converts 'en-US' into {languageCode: 'en', regionCode: 'us'}
  splitLanguageRegion: (languageRegionString) ->
    if languageRegionString
      parts = languageRegionString.toLowerCase().split('-')

    else
      parts = [null, null]

    languageCode: parts[0]
    regionCode: parts[1]

  # Converts 'en', 'us' or {languageCode: 'en', regionCode: 'us'} into 'en-US'
  joinLanguageRegion: (languageCodeOrObject, regionCode) ->
    if _.isObject languageCodeOrObject
      {languageCode, regionCode} = languageCodeOrObject

    else
      languageCode = languageCodeOrObject

    languageRegionString = languageCode.toLowerCase()
    languageRegionString += "-#{regionCode.toUpperCase()}" if regionCode

    languageRegionString
