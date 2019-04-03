AB = Artificial.Babel
AM = Artificial.Mummification
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
      if documentUrl = @constructor.nonPlayerCharacterDocumentUrl?()
        url = @versionedUrl "/packages/#{documentUrl}"

        HTTP.call 'GET', url, (error, result) =>
          if error
            console.error error
            return

          document = new LOI.NonPlayerCharacter EJSON.parse result.content

          # Inject avatar properties.
          document.avatar ?= {}

          _.extend document.avatar,
            fullName: @thingAvatar.getTranslation LOI.Adventure.Thing.Avatar.translationKeys.fullName
            shortName: @thingAvatar.getTranslation LOI.Adventure.Thing.Avatar.translationKeys.shortName
            pronouns: @thingAvatar.pronouns()
            color: @thingAvatar.color()

          if textureUrls = @constructor.textureUrls?()
            version = @constructor.version()

            _.extend document.avatar,
              textures:
                paletteData:
                  url: "#{textureUrls}-palettedata.png?#{version}"
                normals:
                  url: "#{textureUrls}-normals.png?#{version}"

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
  descriptiveName: -> @thingAvatar?.descriptiveName()
  description: -> @thingAvatar?.description()
  color: -> @thingAvatar?.color()
  dialogTextTransform: -> @thingAvatar?.dialogTextTransform()
  dialogueDeliveryType: -> @thingAvatar?.dialogueDeliveryType()

  recentActions: ->
    [] # TODO: Provide actions via storyline.
    
  getActions: (query = {}) ->
    for actionDocument in @actionDocuments.find(query).fetch()
      new LOI.Memory.Action actionDocument
