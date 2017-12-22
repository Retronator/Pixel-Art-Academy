LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Adventure extends LOI.Adventure
  @id: -> 'Retronator.HQ.Adventure'
  @register @id()

  template: -> 'LandsOfIllusions.Adventure'
