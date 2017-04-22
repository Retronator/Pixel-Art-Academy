LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

class PAA.Season1.Episode0.Chapter3 extends LOI.Adventure.Chapter
  C3 = @

  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3'

  @fullName: -> "Making of a Cyborg"
  @number: -> 3

  @url: -> 'chapter3'

  @sections: -> [
    C3.Construct
  ]

  @initialize()

  constructor: ->
    super

    @inventory = new @constructor.Inventory parent: @

  inventory: ->
    [
      C3.Items.OperatorLink
    ]

  scenes: -> [
    @inventory
  ]
