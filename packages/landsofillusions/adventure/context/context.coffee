AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Context extends LOI.Adventure.Thing
  # The maximum height of context's illustration. By default there is no illustration (height 0).
  @illustrationHeight: -> 0
  illustrationHeight: -> @constructor.illustrationHeight()

  @fullName: -> null # Contexts don't need to be named.
