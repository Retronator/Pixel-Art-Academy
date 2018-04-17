AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Items.Sync.Memories.Components.ActionsPreview extends AM.Component
  @id: -> 'LandsOfIllusions.Items.Sync.Memories.Components.ActionsPreview'
  @register @id()

  onCreated: ->
    super

    @memories = @ancestorComponentOfType LOI.Items.Sync.Memories

  characters: ->
    memory = @data()

    _.uniq _.map memory.actions, (action) => action.character?._id

  characterImageUrl: ->
    characterId = @currentData()
    @memories.getCharacterImage characterId
    
  textStyle: ->
    action = @currentData()

    color: "##{LOI.Avatar.colorObject(action.character.avatar.color).getHexString()}"

  actions: ->
    memory = @data()

    _.sortBy memory.actions, (action) => action.time.getTime()
