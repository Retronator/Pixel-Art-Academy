AE = Artificial.Everywhere
AT = Artificial.Telepathy
AM = Artificial.Mummification

# Steamworks wrapper.
class AT.Steam.App
  constructor: (data) ->
    @subscribed = data.isSubscribed
    @buildId = data.appBuildId
    @availableGameLanguages = data.availableGameLanguages
    @currentGameLanguage = data.currentGameLanguage
    @currentBetaName = data.currentBetaName
