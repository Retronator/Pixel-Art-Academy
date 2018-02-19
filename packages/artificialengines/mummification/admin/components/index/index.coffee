AB = Artificial.Base
AM = Artificial.Mummification

class AM.Admin.Components.Index extends Artificial.Mirage.Component
  @register 'Artificial.Mummification.Admin.Components.Index'

  constructor: (@options) ->
    super

    @options.nameField ?= 'name'

  onCreated: ->
    super

    @options.documentClass.all.subscribe @, =>
      # Always show the first document if none is displayed.
      @autorun (computation) =>
        documentId = AB.Router.getParameter 'documentId'

        # Make sure the current document exists.
        return if documentId and @options.documentClass.documents.findOne documentId

        # Switch to the first document on the display list (or no document if we can't find it).
        firstDocument = @documents().fetch()[0]

        AB.Router.setParameters documentId: firstDocument?._id or null

  onDestroyed: ->
    super

  documents: ->
    sort = _id: 1
    sort[@options.nameField] = 1

    @options.documentClass.documents.find {},
      sort: sort

  nameOrId: ->
    data = @currentData()
    name = data[@options.nameField]

    if name instanceof Artificial.Babel.Translation
      translation = Artificial.Babel.translate name
      name = translation.text if translation.language

    name or "#{data._id.substring 0, 5}…"

  activeClass: ->
    'active' if @currentData()._id is AB.Router.getParameter 'documentId'

  events: ->
    super.concat
      'click .add-document': @onClickAddDocument
      'click .document': @onClickDocument

  onClickAddDocument: ->
    newId = Random.id()
    @options.documentClass.insert _id: newId, (error) =>
      return console.error if error

      # Switch to the new document.
      AB.Router.setParameters documentId: newId

  onClickDocument: ->
    AB.Router.setParameters documentId: @currentData()._id
