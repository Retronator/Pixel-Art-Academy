RA = Retronator.Accounts
LOI = LandsOfIllusions

# Confirms that the user can play the game.
LOI.Authorize.player = ->
  user = Retronator.user()

  return if user.hasItem Retronator.Store.Items.CatalogKeys.PixelArtAcademy.PlayerAccess

  throw new AE.UnauthorizedException "You are not a player and cannot perform this action."

# Confirms that the user has alpha access.
LOI.Authorize.alphaAccess = ->
  user = Retronator.user()

  return if user.hasItem Retronator.Store.Items.CatalogKeys.PixelArtAcademy.AlphaAccess

  throw new AE.UnauthorizedException "You are not a player and cannot perform this action."

# Confirms administrator privileges.
LOI.Authorize.admin = ->
  RA.authorizeAdmin()
