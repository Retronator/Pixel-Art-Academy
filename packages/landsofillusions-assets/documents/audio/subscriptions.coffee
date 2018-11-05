LOI = LandsOfIllusions

# Subscription to a specific sprite.
LOI.Assets.Audio.forLocation.publish (locationId) ->
  check locationId, String

  LOI.Assets.Audio.forLocation.query locationId
