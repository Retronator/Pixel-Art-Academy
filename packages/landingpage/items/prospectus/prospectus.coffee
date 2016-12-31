AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary
Action = LOI.Adventure.Ability.Action

class PAA.LandingPage.Items.Prospectus extends LOI.Adventure.Item
  @id: -> 'PixelArtAcademy.LandingPage.Items.Prospectus'
  @url: -> 'about'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Retropolis Academy of Art prospectus"

  @shortName: -> "prospectus"

  @description: ->
    "
      It's a pamphlet about the game called Pixel Art Academy.
    "

  @initialize()

  constructor: ->
    super

    @addAbilityToActivateByReading()

  onCreated: ->
    super
