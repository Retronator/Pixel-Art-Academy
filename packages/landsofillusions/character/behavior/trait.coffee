AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Character.Behavior.Personality.Trait extends AM.Document
  # primaryFactor
  #   type: type number 1-5
  #   sign: 1 or -1
  # secondaryFactor
  #   type: type number 1-5
  #   sign: 1 or -1
  # name
  @Meta
    name: 'Trait'
    collection: LOI.Character.Behavior.Personality.Traits
