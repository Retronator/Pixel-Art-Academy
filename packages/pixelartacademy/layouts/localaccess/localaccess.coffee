AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Layouts.LocalAccess extends BlazeLayoutComponent
  @register 'PixelArtAcademy.Layouts.LocalAccess'

  loading: ->
    Meteor.loggingIn()

  characters: ->
    user = LOI.Accounts.User.documents.findOne Meteor.userId(),
      fields:
        characters: 1

    user?.characters

  renderPage: (parentComponent) ->
    @_renderRegion 'page', parentComponent

  renderIntro: (parentComponent) ->
    @_renderRegion 'intro', parentComponent
