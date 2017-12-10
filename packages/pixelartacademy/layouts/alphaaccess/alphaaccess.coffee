AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Layouts.AlphaAccess extends BlazeComponent
  @register 'PixelArtAcademy.Layouts.AlphaAccess'

  @title: ->
    "Pixel Art Academy // Alpha backers build"

  loading: ->
    Meteor.loggingIn()

  characters: ->
    user = Retronator.Accounts.User.documents.findOne Meteor.userId(),
      fields:
        characters: 1

    user?.characters

  events: ->
    super.concat
      'click .load-character': @onClickLoadCharacter

  onClickLoadCharacter: (event) ->
    characterId = @currentData()._id
    LOI.switchCharacter characterId
