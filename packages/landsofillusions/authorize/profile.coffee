AE = Artificial.Everywhere
AM = Artificial.Mummification
LOI = LandsOfIllusions
Persistence = AM.Document.Persistence

LOI.Authorize.profileAction = (profileId) ->
  # You need to be logged-in to perform actions with a profile.
  user = Retronator.requireUser()
  
  # Profile must exist.
  profile = Persistence.Profile.documents.findOne profileId
  throw new AE.ArgumentException "Profile not found." unless profile

  # The profile must belong to the logged-in user, or it is an admin performing the action.
  profileBelongsToUser = profileId in user.profileIds

  unless profileBelongsToUser or user.hasItem Retronator.Store.Items.CatalogKeys.Retronator.Admin
    throw new AE.UnauthorizedException "The profile must belong to you."
  
  profile
