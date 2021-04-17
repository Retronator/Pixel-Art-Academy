AB = Artificial.Babel
AM = Artificial.Mummification
AT = Artificial.Telepathy
LOI = LandsOfIllusions
RA = Retronator.Accounts

# A base thing for non-playable characters. Wraps around the
# character instance with a static non-player character document
class LOI.Character.Actor extends LOI.Character.Person
  @instances = {}

  @initialize: ->
    super arguments...
    
    # Create the actions location.
    parent = @
    
    class @Actions extends LOI.Adventure.Location
      @id: -> "#{parent.id()}.Actions"

      @initialize()

    # Add the NPC to database.
    if Meteor.isServer and not Meteor.settings.startEmpty
      Document.startup => @_addActorToDatabase()

  @_actorIdsBeingAdded = []

  @_addActorToDatabase: ->
    # Make sure we didn't already add them.
    id = @id()
    return if LOI.Character.documents.findOne thingId: id

    # Make sure we aren't already adding them.
    return if id in @_actorIdsBeingAdded

    # We need the admin user to add this character to.
    return unless admin = RA.User.documents.findOne username: 'admin'

    # Fetch the data.
    return unless assetUrls = @assetUrls?()

    version = @version()
    documentUrl = Meteor.absoluteUrl "#{assetUrls}.json?#{version}"

    @_actorIdsBeingAdded.push id

    # Note: We need to get the document asynchronously since the server is still setting up at this point.
    AT.RequestHelper.requestUntilSucceeded
      url: documentUrl
      retryAfterSeconds: 60
      callback: (result) =>
        character = result.data

        # Replace the user to admin.
        character.user = _id: admin._id

        # Create a translation for the name.
        fullNameTranslationId = AB.Translation.documents.insert lastEditTime: new Date
        AB.Translation.update fullNameTranslationId, Artificial.Babel.defaultLanguage, @fullName()
        character.avatar.fullName = _id: fullNameTranslationId

        # Insert the character with a proper document ID and save
        # the thing ID on the document to prevent multiple insertions.
        character._id = Random.id()
        character.thingId = @id()
        LOI.Character.documents.insert character

  constructor: ->
    super arguments...

    # Agent's main avatar will be the character avatar from the instance, so we manually create the avatar based on
    # this thing. This way we can use some universal avatar values that hold for all actors (like description).
    @thingAvatar = @avatar

    id = @id()
    @instance = @constructor.instances[id]

    unless @instance
      # We must provide an NPC document for creating the character instance of this actor.
      nonPlayerCharacterDocument = new ReactiveField null

      @instance = Tracker.nonreactive => new LOI.Character.Instance id, nonPlayerCharacterDocument
      @constructor.instances[id] = @instance

      # Load the NPC document.
      if assetUrls = @constructor.assetUrls?()
        version = @constructor.version()
        documentUrl = "#{assetUrls}.json?#{version}"

        HTTP.get documentUrl, (error, result) =>
          if error
            console.error error
            return

          document = new LOI.NonPlayerCharacter EJSON.parse result.content

          # Wait for avatar translations to be ready.
          Tracker.autorun (computation) =>
            return unless @thingAvatar.getTranslation LOI.Adventure.Thing.Avatar.translationKeys.fullName
            computation.stop()

            # Inject avatar properties.
            document.avatar ?= {}

            _.extend document.avatar,
              fullName: @thingAvatar.getTranslation LOI.Adventure.Thing.Avatar.translationKeys.fullName
              shortName: @thingAvatar.getTranslation LOI.Adventure.Thing.Avatar.translationKeys.shortName
              pronouns: @thingAvatar.pronouns()
              color: @thingAvatar.color()

            version = @constructor.version()

            _.extend document.avatar,
              textures:
                paletteData:
                  url: "#{assetUrls}-palettedata.png?#{version}"
                normals:
                  url: "#{assetUrls}-normals.png?#{version}"

            nonPlayerCharacterDocument document

            console.log "NPC document loaded", @id(), document if LOI.debug

    @avatar = @instance.avatar

    # Person state for actors is saved in the thing state directly.
    @personStateAddress = @stateAddress
    @personState = @state

    # Create a collection with all current actions.
    @actionsLocation = new @constructor.Actions
    @actionDocuments = new AM.CollectionWrapper =>
      return unless LOI.adventureInitialized()
      
      situation = new LOI.Adventure.Situation
        location: @actionsLocation
        
      situation.things()

  destroy: ->
    # Reinstate the thing avatar so that it will get destroyed (and not the instance's!).
    @avatar = @thingAvatar

    super arguments...

  ready: ->
    conditions = [
      super arguments...
      @thingAvatar.ready()
      @instance.ready()
    ]

    console.log "Actor ready?", @id(), conditions if LOI.debug

    _.every conditions

  # Avatar pass-through methods go to the thing avatar.
  fullName: -> @thingAvatar?.fullName()
  shortName: -> @thingAvatar?.shortName()
  pronouns: -> @thingAvatar?.pronouns()
  nameAutoCorrectStyle: -> @thingAvatar?.nameAutoCorrectStyle()
  nameNounType: -> @thingAvatar?.nameNounType()

  descriptiveName: ->
    # Only use thing's descriptive name if it's actually defined.
    if @constructor.descriptiveName()
      @thingAvatar?.descriptiveName()

    else
      super arguments...

  description: -> @thingAvatar?.description()
  color: -> @thingAvatar?.color()
  dialogTextTransform: -> @thingAvatar?.dialogTextTransform()
  dialogueDeliveryType: -> @thingAvatar?.dialogueDeliveryType()

  recentActions: (requireInitialHangoutCompleted = false) ->
    [] # TODO: Provide actions via storyline.
    
  getActions: (query = {}) ->
    for actionDocument in @actionDocuments.find(query).fetch()
      new LOI.Memory.Action actionDocument
