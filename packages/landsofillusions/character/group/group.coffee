AM = Artificial.Mummification
LOI = LandsOfIllusions

# Groups manually defined by the player for their character.
class LOI.Character.Group extends AM.Document
  @id: -> 'LandsOfIllusions.Character.Group'
  # character: the character
  #   _id
  #   debugName
  # groupId: group ID as used in Adventure Group
  # members: array of characters in this group
  #   _id
  #   debugName
  @Meta
    name: @id()
    fields: =>
      character: @ReferenceField LOI.Character, ['debugName']
      members: [@ReferenceField LOI.Character, ['debugName']]

  # Methods
  
  @addMember: @method 'addMember'
  
  # Subscriptions

  @forCharacterId: @subscription 'forCharacterId'

  @isCharacterMember: (groupId, characterIdOrInstance) ->
    group = LOI.Character.Group.documents.findOne
      'character._id': LOI.characterId()
      groupId: groupId

    return unless group

    group.isCharacterMember characterIdOrInstance

  isCharacterMember: (characterIdOrInstance) ->
    characterId = characterIdOrInstance._id or characterIdOrInstance

    _.find @members, (member) => member._id is characterId
