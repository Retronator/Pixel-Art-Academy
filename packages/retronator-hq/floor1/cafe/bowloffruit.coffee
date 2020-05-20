LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Cafe.BowlOfFruit extends PAA.Items.StillLifeItems.Container
  @id: -> 'Retronator.HQ.Cafe.BowlOfFruit'
  @fullName: -> "bowl of fruit"
  @shortName: -> "bowl"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @descriptiveName: -> "![Bowl](look at bowl) of fruit."
  @description: ->
    # Reference to The Sims 4.
    "
      The bowl of fruit is keeping healthy snacks on hand, or at least, where other people can see them.
    "

  @startingItemQuantities: ->
    "#{PAA.Items.StillLifeItems.Banana.id()}": 2
    "#{PAA.Items.StillLifeItems.Kiwi.id()}": 3
    "#{PAA.Items.StillLifeItems.Mango.id()}": 1

  @initialize()
