LOI = LandsOfIllusions

class LOI.Adventure.Scene extends LOI.Adventure.Thing
  @location: -> throw new AE.NotImplementedException

  @fullName: -> "" # Scenes don't need to be named.

  things: -> [] # Override to provide a list of things that should be present at this location.
