AB = Artificial.Base
AM = Artificial.Mummification

class AM.Admin.Components.AdminPage extends Artificial.Mirage.Component
  @id: -> 'Artificial.Mummification.Admin.Components.AdminPage'
  @register @id()

  template: -> @constructor.id()

  constructor: (@options) ->
    super arguments...

    @scriptsComponent = new @options.scriptsComponentClass if @options.scriptsComponentClass
    @_documentPage = new @options.adminComponentClass

  documentPage: ->
    @_documentPage.renderComponent?(@currentComponent()) or null

  document: ->
    id = AB.Router.getParameter 'documentId'
    @options.documentClass.documents.findOne id
