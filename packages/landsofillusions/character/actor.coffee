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
            pronouns: @thingAvatar.pronouns()
            color: @thingAvatar.color()

          if textureUrls = @constructor.textureUrls?()
            _.extend document.avatar,
              textures:
                paletteData:
                  url: "#{textureUrls}-palettedata.png"
                normals:
                  url: "#{textureUrls}-normals.png"

          nonPlayerCharacterDocument document

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

    _.every conditions

  description: ->
    @thingAvatar.description()

  recentActions: ->
    [] # TODO: Provide actions via storyline.
    
  getActions: (query = {}) ->
    for actionDocument in @actionDocuments.find(query).fetch()
      new LOI.MemoryAction actionDocument
