AM = Artificial.Mirage
AB = Artificial.Babel
ABs = Artificial.Base
LOI = LandsOfIllusions

class LOI.Pages.Admin.Memories.ActionsLog extends AM.Component
  @id: -> 'LandsOfIllusions.Pages.Admin.Memories.ActionsLog'
  @register @id()

  onCreated: ->
    super arguments...

    @actionsLimit = new ReactiveField 50

    @autorun (computation) =>
      LOI.Memory.Action.all.subscribe @, @actionsLimit()

  actions: ->
    LOI.Memory.Action.documents.find {},
      sort:
        time: -1

  locationName: ->
    action = @currentData()
    action.locationId.substring action.locationId.lastIndexOf('.') + 1

  typeName: ->
    action = @currentData()
    action.type.substring action.type.lastIndexOf('.') + 1

  events: ->
    super(arguments...).concat
      'click .display-more-button': @onClickDisplayMoreButton

  onClickDisplayMoreButton: (event) ->
    @actionsLimit @actionsLimit() + 50
