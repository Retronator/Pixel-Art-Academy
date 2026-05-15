AE = Artificial.Everywhere
AT = Artificial.Telepathy
AM = Artificial.Mummification

# Steamworks wrapper.
class AT.Steam.Player
  constructor: (data) ->
    @name = data.name
    @level = data.level
    @accountId = data.steamId.accountId
    @steamId32 = data.steamId.steamId32
    @steamId64 = data.steamId.steamId64
