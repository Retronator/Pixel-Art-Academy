LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Residence.Kitchen.Watermelon extends PAA.Items.StillLifeItems.Watermelon
  @id: -> 'Retronator.HQ.Residence.Kitchen.Watermelon'
  @stillLifeItemType: -> PAA.Items.StillLifeItems.Watermelon.id()

  @initialize()

  isVisible: -> true
