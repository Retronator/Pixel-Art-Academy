AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Character extends AM.Document
  @id: -> 'LandsOfIllusions.Character'
  # user: the owner of this character
  #   _id
  #   displayName
  #   publicName
  # ownerName: public name of the owner of this character
  # archivedUser: the owner, archived on retirement of the character
  #   _id
  # lastEditTime: for database content characters, time of last export
  # contactEmail: the email to which character-related communication should be sent
  # debugName: auto-generated best translation of the full name of this character for debugging (do not use in the game!).
  # avatar: information for the representation of the character
  #   fullName: how the character is named
  #     _id
  #     translations
  #   pronouns: enumeration of the gender of pronouns used by the character (Feminine/Masculine/Neutral).
  #   color: character's favorite color as used in the world, for example, in dialogs
  #     hue: ramp index in the Atari 2600 palette
  #     shade: relative shade from -2 to +2
  #   body: avatar data for character's body representation
  #   outfit: avatar data for character's current clothes/accessories
  #   textures: pre-rendered avatar texture maps
  #     needUpdate: boolean whether body or outfit have changed and the textures need to be re-rendered
  #     version: integer version that increases on each render
  #     paletteData: the base texture with color information
  #       url
  #     normals: texture map with normals
  #       url
  # behavior: avatar data for character's behavior design
  # profile: miscellaneous information that the user is free to edit as they please
  #   age: integer, 13 to 150
  #   country: ISO region code
  #   aspiration: any string
  #   favorites: an object of strings for various categories
  #   weeklyGoals: character's current commitment goal
  #     daysWithActivities: how many days in a week need to contain activities
  #     totalHours: how many hours in a week need to be spent on activities
  # designApproved: whether the character has finished the design stage
  # behaviorApproved: whether the character has finished the behavior stage
  # activated: whether the character has been deployed in the world
  @Meta
    name: @id()
    fields: =>
      user: Document.ReferenceField RA.User, ['displayName', 'publicName'], false, 'characters', ['displayName', 'avatar.fullName', 'activated']
      ownerName: Document.GeneratedField 'self', ['user'], (character) ->
        ownerName = character.user?.publicName or null
        [character._id, ownerName]
      debugName: Document.GeneratedField 'self', ['avatar'], (character) ->
        displayName = character.avatar?.fullName?.translations?.best?.text or null
        [character._id, displayName]
      avatar:
        fullName: Document.ReferenceField AB.Translation, ['translations'], false
  
  # Methods

  @insert: @method 'insert'
  @removeUser: @method 'removeUser'

  @updateName: @method 'updateName'
  @updatePronouns: @method 'updatePronouns'
  @updateColor: @method 'updateColor'
  @updateAvatarBody: @method 'updateAvatarBody'
  @updateAvatarOutfit: @method 'updateAvatarOutfit'
  @updateBehavior: @method 'updateBehavior'
  @updateProfile: @method 'updateProfile'
  @updateContactEmail: @method 'updateContactEmail'
  @renderAvatarTextures: @method 'renderAvatarTextures'

  @approveDesign: @method 'approveDesign'
  @approveBehavior: @method 'approveBehavior'
  @activate: @method 'activate'

  # Subscriptions

  @all: @subscription 'all'
  @allLive: @subscription 'allLive'
  @forId: @subscription 'forId'
  @forCurrentUser: @subscription 'forCurrentUser'
