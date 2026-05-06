AE = Artificial.Everywhere
AT = Artificial.Telepathy
AM = Artificial.Mummification

# Steamworks wrapper.
class AT.Steam
  @test = true
  
  @available = new ReactiveField null
  @instance = new ReactiveField null
  
  if Meteor.isDesktop and Meteor.settings.public.steamId
    @initialize()
    
  else if @test
    Meteor.startup =>
      @instance new @ EJSON.parse '{"apps":{"isSubscribed":true,"appBuildId":123,"appOwner":{"steamId64":{"$bigint":"123"},"steamId32":"STEAM_0:1:123","accountId":123},"availableGameLanguages":["english"],"currentGameLanguage":"english","currentBetaName":""},"cloud":{"isEnabledForAccount":true,"isEnabledForApp":false},"localPlayer":{"steamId":{"steamId64":{"$bigint":"123"},"steamId32":"STEAM_0:1:123","accountId":123},"name":"Test","level":1,"ipCountry":"US"},"utils":{"appId":123,"isSteamRunningOnSteamDeck":false}}'
      @available true
    
  else
    @available false
  
  @initialize: ->
    steamData = await Desktop.call 'steam', 'initialize', Number.parseInt Meteor.settings.public.steamId
    @available steamData?
    @instance new @ steamData if steamData

  constructor: (data) ->
    @player = new @constructor.Player data.localPlayer
    @cloud = new @constructor.Cloud data.cloud
    @app = new @constructor.App data.apps

Template.registerHelper 'steam', -> AT.Steam.instance()
