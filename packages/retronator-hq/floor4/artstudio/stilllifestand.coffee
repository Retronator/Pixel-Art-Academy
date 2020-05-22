LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio.StillLifeStand extends PAA.StillLifeStand
  @id: -> 'Retronator.HQ.ArtStudio.StillLifeStand'
  @url: -> 'retronator/artstudio/stilllife'

  @fullName: -> "still life stand"
  @shortName: -> "stand"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @descriptiveName: -> "Still life ![stand](use stand)."
  @description: ->
    "
      A stand is placed in the middle of the studio with various items on display.
      Artists use this as a reference to study lighting and practice drawing and painting technique.
    "

  @startingItems: -> [
    type: PAA.Items.StillLifeItems.Apple.Green.id()
  ,
    type: PAA.Items.StillLifeItems.Apple.Green.id()
  ,
    type: PAA.Items.StillLifeItems.Apple.Green.id()
  ,
    type: PAA.Items.StillLifeItems.Orange.id()
  ,
    type: PAA.Items.StillLifeItems.Orange.id()
  ]

  @initialize()

  # Listener

  onCommand: (commandResponse) ->
    stand = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], stand.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToItem stand
