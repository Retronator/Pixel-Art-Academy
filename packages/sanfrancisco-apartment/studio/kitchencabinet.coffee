LOI = LandsOfIllusions
PAA = PixelArtAcademy
Studio = SanFrancisco.Apartment.Studio

Vocabulary = LOI.Parser.Vocabulary

class Studio.KitchenCabinet extends PAA.Items.StillLifeItems.Container
  @id: -> 'SanFrancisco.Apartment.Studio.KitchenCabinet'
  @fullName: -> "kitchen cabinet"
  @shortName: -> "cabinet"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @descriptiveName: -> "Kitchen ![cabinet](look at cabinet) with essential tableware."
  @description: ->
    "
      The kitchen cabinet is storing tableware … or whatever else _char_ put in it.
    "

  @startingItemQuantities: ->
    "#{PAA.Items.StillLifeItems.Bowl.Large.Average.id()}": 1

  @initialize()
