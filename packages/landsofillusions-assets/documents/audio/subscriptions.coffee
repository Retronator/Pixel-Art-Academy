LOI = LandsOfIllusions

LOI.Assets.Audio.forLocation.publish (locationId) ->
  check locationId, String

  LOI.Assets.Audio.forLocation.query locationId, true

LOI.Assets.Audio.forNamespace.publish (path) ->
  check path, String
  
  LOI.Assets.Audio.forNamespace.query path, true
