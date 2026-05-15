AE = Artificial.Everywhere
AT = Artificial.Telepathy
AM = Artificial.Mummification

# Steamworks wrapper.
class AT.Steam.Cloud
  constructor: (data) ->
    @enabledForAccount = data.isEnabledForAccount
    @enabledForApp = new ReactiveField data.isEnabledForApp

  setEnabledForApp: (value) ->
    enabled = await Desktop.call 'steam', 'setEnabledForApp', value
    return unless enabled?
    
    @enabledForApp enabled
