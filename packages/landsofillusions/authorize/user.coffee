LOI = LandsOfIllusions

# Confirms that the user can play the game.
LOI.Authorize.player = ->
  user = Retronator.user()

  # Players are people that can create game characters.
  return if user.hasItem Retronator.Store.Items.CatalogKeys.LandsOfIllusions.Character.Creation

  throw new AE.UnauthorizedException "You do not have administrator privileges to perform this action."

# Confirms administrator privileges.
LOI.Authorize.admin = ->
  user = Retronator.user()

  return if user.hasItem Retronator.Store.Items.CatalogKeys.Retronator.Admin

  throw new AE.UnauthorizedException "You do not have administrator privileges to perform this action."
