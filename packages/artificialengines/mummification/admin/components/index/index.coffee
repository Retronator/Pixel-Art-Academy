AB = Artificial.Base
AM = Artificial.Mummification

class AM.Admin.Components.Index extends Artificial.Mirage.Component
  @register 'Artificial.Mummification.Admin.Components.Index'

  constructor: (@options) ->
    super arguments...

    @options.nameField ?= 'name'

  onCreated: ->
    super arguments...

    @options.documentClass.all.subscribe @, =>
      # Unselect the current document if it gets deleted.
      @autorun (computation) =>
        documentId = AB.Router.getParameter 'documentId'

        # Make sure the current document exists.
        return if documentId and @options.documentClass.documents.findOne documentId

        # Route back to index.
        @goToDocument null

  documentTypeName: -> @options.singularName
  
  showRemoveButton: -> @options.documentClass.remove and AB.Router.getParameter 'documentId'

  documents: ->
    sort = _id: 1
    sort[@options.nameField] = 1

    @options.documentClass.documents.find {},
      sort: sort

  nameOrId: ->
    data = @currentData()
    return @options.nameFunction data if @options.nameFunction
    
    name = data[@options.nameField]

    if name instanceof Artificial.Babel.Translation
      translation = Artificial.Babel.translate name
      name = translation.text if translation.language

    name or "#{data._id.substring 0, 5}…"

  goToDocument: (documentId) ->
    # Switch to document, but don't create history so that it's easy to get back out from the admin page.
    AB.Router.setParameters
      documentId: documentId
    ,
      createHistory: false

  activeClass: ->
    'active' if @currentData()._id is AB.Router.getParameter 'documentId'

  events: ->
    super(arguments...).concat
      'click .add-document': @onClickAddDocument
      'click .remove-document': @onClickRemoveDocument
      'click .document': @onClickDocument

  onClickAddDocument: ->
    newId = Random.id()
    @options.documentClass.insert _id: newId, (error) =>
      return console.error if error

      # Switch to the new document.
      @goToDocument newId
      
  onClickRemoveDocument: ->
    documentId = AB.Router.getParameter 'documentId'
    @options.documentClass.remove documentId, (error) =>
      return console.error if error
      
      # Route back to index.
      @goToDocument null

  onClickDocument: ->
    @goToDocument @currentData()._id
