LOI = LandsOfIllusions

LOI.Memory.Progress.forProfile.publish (profileId) ->
  check profileId, Match.DocumentId

  # Only allow to subscribe to your own profile.
  LOI.Authorize.profileAction profileId
  
  # Create the progress document if it doesn't exist yet.
  progress = LOI.Memory.Progress.documents.findOne 'profileId': profileId
  
  unless progress
    LOI.Memory.Progress.documents.insert
      profileId: profileId
      observedMemories: []
  
  LOI.Memory.Progress.documents.find 'profileId': profileId
