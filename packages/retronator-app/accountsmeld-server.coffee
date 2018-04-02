RA = Retronator.Accounts
LOI = LandsOfIllusions

# When two user accounts are merged together due to same verified emails, update all references pointing to the user
# that is about to be deleted. We can't use meldDBCallback, because that happens once the source user is already
# removed. So we need to act inside the melding action, which we now also have to provide.
Document.startup ->
  AccountsMeld.configure
    meldUserCallback: (sourceUser, targetUser) ->
      console.log "Melding user", sourceUser._id, "into", targetUser._id

      # Delete source user's game state, so we don't have multiple states per user.
      LOI.GameState.documents.remove 'user._id': sourceUser._id

      # Point all the references from the source user to the target.
      RA.User.substituteDocument sourceUser._id, targetUser._id

      # Take the older createdAt time.
      createdAt: if sourceUser.createdAt < targetUser.createdAt then sourceUser.createdAt else targetUser.createdAt
      # Give priority to the target user's profile settings.
      profile: _.defaults {}, targetUser.profile, sourceUser.profile
