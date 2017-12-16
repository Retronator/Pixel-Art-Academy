AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pages.Admin.Components.Index extends AM.Component
  @register 'PixelArtAcademy.Pages.Admin.Components.Index'

  constructor: (@options) ->
    super

    @options.nameField ?= 'name'

  onCreated: ->
    super

    @options.documentClass.all.subscribe @, =>
      # Always show the first document if none is displayed.
      @autorun (computation) =>
        documentId = FlowRouter.getParam 'documentId'

        # Make sure the current document exists.
        return if documentId and @options.documentClass.documents.findOne documentId

        # Switch to the first document on the display list (or no document if we can't find it).
        firstDocument = @documents().fetch()[0]

        FlowRouter.setParams documentId: firstDocument?._id or null

  onDestroyed: ->
    super

  documents: ->
    sort = _id: 1
    sort[@options.nameField] = 1

    @options.documentClass.documents.find {},
      sort: sort

  nameOrId: ->
    data = @currentData()
    data[@options.nameField] or "#{data._id.substring 0, 5}…"

  activeClass: ->
    'active' if @currentData()._id is FlowRouter.getParam 'documentId'

  events: ->
    super.concat
      'click .add-document': @onClickAddDocument
      'click .document': @onClickDocument

  onClickAddDocument: ->
    newId = Random.id()
    @options.documentClass.insert _id: newId, (error) =>
      return console.error if error

      # Switch to the new document.
      FlowRouter.setParams documentId: newId

  onClickDocument: ->
    FlowRouter.setParams documentId: @currentData()._id
