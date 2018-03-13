LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Memory.Action extends AM.Document
  @id: -> 'LandsOfIllusions.Memory.Action'
  # time: when this action was done
  # memory: which memory this action belongs to.
  #   _id
  # character: character who did this action
  #   _id
  #   avatar
  #     fullName
  #     color
  # type: what kind of action this is
  # content: extra information defining what was done in this action
  #   say: character says something
  #     text: the text being said
  @Meta
    name: @id()
    fields: =>
      memory: @ReferenceField LOI.Memory, [], true, 'actions', ['time', 'character', 'type', 'content']
      character: @ReferenceField LOI.Character, ['avatar.fullName', 'avatar.color'], false
      
  @Types:
    Say: 'Say'

  # Methods

  @insert: @method 'insert'
  @changeContent: @method 'changeContent'

  # Subscriptions

  @forMemory: @subscription 'forMemory'
