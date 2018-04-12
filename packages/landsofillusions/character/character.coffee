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
  # behavior: avatar data for character's behavior design
  # profile: miscellaneous information that the user is free to edit as they please
  #   age: integer, 13 to 150
  #   country: ISO region code
  #   aspiration: any string
  #   favorites: an object of strings for various categories
  # designApproved: whether the character has finished the design stage
  # behaviorApproved: whether the character has finished the behavior stage
  # activated: whether the character has been deployed in the world
  @Meta
    name: @id()
    fields: =>
      user: @ReferenceField RA.User, ['displayName', 'publicName'], false, 'characters', ['displayName', 'avatar.fullName', 'activated']
      ownerName: @GeneratedField 'self', ['user'], (character) ->
        ownerName = character.user?.publicName or null
        [character._id, ownerName]
      debugName: @GeneratedField 'self', ['avatar'], (character) ->
        displayName = character.avatar?.fullName?.translations?.best?.text or null
        [character._id, displayName]
      avatar:
        fullName: @ReferenceField AB.Translation, ['translations'], false
        shortName: @ReferenceField AB.Translation, ['translations'], false
  
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

  @approveDesign: @method 'approveDesign'
  @approveBehavior: @method 'approveBehavior'
  @activate: @method 'activate'

  # Subscriptions

  @forId: @subscription 'forId'
  @forCurrentUser: @subscription 'forCurrentUser'
  @activatedForCurrentUser: @subscription 'activatedForCurrentUser'

  # Singletons

  @instances = {}
  
  @getInstance: (idOrDocument) ->
    id = idOrDocument?._id or idOrDocument
    return unless id

    unless @instances[id]
      Tracker.nonreactive =>
        @instances[id] = new @Instance id

    @instances[id]

  @people = {}

  @getPerson: (id) ->
    unless @people[id]
      Tracker.nonreactive =>
        @people[id] = new @Person id

    @people[id]
    
  @formatText: (text, keyword, character) ->
    pronouns = character.avatar.pronouns()

    getPronoun = (key) =>
      LOI.adventure.parser.vocabulary.getPhrases("Pronouns.#{key}.#{pronouns}")?[0]

    text = text.replace new RegExp("_#{keyword}_", 'g'), (match) ->
      character.avatar.shortName()

    text = text.replace new RegExp("_#{_.toUpper keyword}_", 'g'), (match) ->
      _.toUpper character.avatar.shortName()

    text = text.replace new RegExp("_#{keyword}'s_", 'g'), (match) ->
      # TODO: Add a way to localize possession grammar.
      name = character.avatar.shortName()
      lastLetter = _.last name
      if lastLetter is 's' then "#{name}'" else "#{name}'s"

    for pronounPair in [
      ['they', 'Subjective']
      ['them', 'Objective']
      ['their', 'Adjective']
      ['theirs', 'Possessive']
    ]
      text = text.replace new RegExp("_(t|T)#{pronounPair[0].substring(1)}_", 'g'), (match, pronounCase) ->
        pronoun = getPronoun pronounPair[1]

        if pronounCase is 'T' then pronoun = _.upperFirst pronoun

        pronoun

    text = text.replace /_are_/g, (match) ->
      # We assume neutral pronouns use plural verbs.
      # TODO: Can we make this assumption? Probably depends on language's properties.
      numberCategory = if pronouns is LOI.Avatar.Pronouns.Neutral then 'Plural' else 'Singular'
      LOI.adventure.parser.vocabulary.getPhrases("Verbs.Be.Present.3rdPerson.#{numberCategory}")?[0]

    text
