AM = Artificial.Mirage
AB = Artificial.Babel
ABs = Artificial.Base
LOI = LandsOfIllusions

class LOI.Pages.Admin.Memories.Latest extends AM.Component
  @id: -> 'LandsOfIllusions.Pages.Admin.Memories.Latest'
  @register @id()

  onCreated: ->
    super arguments...

    @memoriesLimit = new ReactiveField 50

    @autorun (computation) =>
      LOI.Memory.all.subscribe @, @memoriesLimit()

    @autorun (computation) =>
      memoryIds = (memory._id for memory in LOI.Memory.documents.fetch())
      return unless memoryIds.length

      LOI.Memory.Action.forMemories.subscribe @, memoryIds

  memories: ->
    LOI.Memory.documents.find {},
      sort:
        endTime: -1

  firstAction: ->
    memory = @currentData()
    LOI.Memory.Action.documents.findOne memory.actions[0]?._id

  events: ->
    super(arguments...).concat
      'click .display-more-button': @onClickDisplayMoreButton

  onClickDisplayMoreButton: (event) ->
    @memoriesLimit @memoriesLimit() + 50
