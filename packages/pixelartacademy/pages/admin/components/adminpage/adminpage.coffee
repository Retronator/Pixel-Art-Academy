AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pages.Admin.Components.AdminPage extends AM.Component
  @register 'PixelArtAcademy.Pages.Admin.Components.AdminPage'

  constructor: (@options) ->
    super

    @_documentPage = new @options.adminComponentClass()

  documentPage: ->
    @_documentPage.renderComponent?(@currentComponent()) or null

  document: ->
    id = FlowRouter.getParam 'documentId'
    @options.documentClass.documents.findOne id
