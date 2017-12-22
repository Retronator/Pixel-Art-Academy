AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pages.Admin.Components.AdminPage extends AM.Component
  @id: -> 'PixelArtAcademy.Pages.Admin.Components.AdminPage'
  @register @id()

  template: -> @constructor.id()

  constructor: (@options) ->
    super

    @scriptsComponent = new @options.scriptsComponentClass if @options.scriptsComponentClass
    @_documentPage = new @options.adminComponentClass

  documentPage: ->
    @_documentPage.renderComponent?(@currentComponent()) or null

  document: ->
    id = AB.Router.getParameter 'documentId'
    @options.documentClass.documents.findOne id
