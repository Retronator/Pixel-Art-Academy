AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

# A base thing for non-playable characters. Wraps around the
# character instance with a static non-player character document
class LOI.Character.Actor extends LOI.Character.Person
  constructor: ->
    # We must provide an NPC document for creating the character instance of this actor.
    @nonPlayerCharacterDocument = new ReactiveField null
    @instance = new LOI.Character.Instance @id(), @nonPlayerCharacterDocument

    # We let Thing construct itself last since it'll need the character avatar (via the instance) ready.
    super
    
    # Person state for actors is saved in the thing state directly.
    @personStateAddress = @stateAddress
    @personState = @state

    # Load the NPC document.
    if documentUrl = @constructor.nonPlayerCharacterDocumentUrl?()
      url = @versionedUrl "/packages/#{documentUrl}"

      HTTP.call 'GET', url, (error, result) =>
        if error
          console.error error
          return

        document = new LOI.NonPlayerCharacter EJSON.parse result.content

        @autorun (computation) =>
          # Inject avatar properties.
          document.avatar ?= {}

          _.extend document.avatar,
            fullName: @avatar.getTranslation LOI.Adventure.Thing.Avatar.translationKeys.fullName
            pronouns: @avatar.pronouns()
            color: @avatar.color()

          @nonPlayerCharacterDocument document

  recentActions: ->
    # TODO: Provide actions via storyline.
