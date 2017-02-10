LOI = LandsOfIllusions

class LOI.Adventure.Scene
  @location: -> throw new AE.NotImplementedException

  things: -> [] # Override to provide a list of things that should be present at this location.
