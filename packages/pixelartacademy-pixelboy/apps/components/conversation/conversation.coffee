AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Components.Conversation extends AM.Component
  @register "PixelArtAcademy.PixelBoy.Apps.Components.Conversation"

  onCreated: ->
    super

    # Subscribe to get full conversation data.
    @autorun (computation) =>
      return unless conversationId = @data()

      LOI.Conversations.Conversation.forId.subscribe @, conversationId

  # Returns fully populated conversation.
  conversation: ->
    conversationId = @data()
    LOI.Conversations.Conversation.documents.findOne conversationId

  characterInstance: ->
    line = @currentData()
    LOI.Character.getInstance line.character?._id

  showAvatar: ->
    # Temporarily disabling avatars due to performance issues.
    return false
    
    return unless character = @characterInstance()

    # We have avatar if the body field has any data and the data is ready.
    character.document()?.avatar.body and character.avatar.body.ready() and character.avatar.outfit.ready()

  avatarHeadPart: ->
    character = @characterInstance()

    character.avatar.body.properties.head.part

  textStyle: ->
    line = @currentData()

    # Set the color to character's color.
    if line.character
      color: "##{line.character.colorObject()?.getHexString()}"

    else
      color: "##{LOI.palette()?.color(0, 4).getHexString()}"

  linkColor: ->
    line = @currentData()

    # Link should be 2 shades lighter than the text.
    line.character?.colorObject 2

  events: ->
    super.concat
      'submit .new-line-form': @submitNewLineForm

  submitNewLineForm: (event) ->
    event.preventDefault()

    conversation = @data()
    text = @$('.new-line-text').val()

    LOI.Conversations.Line.insert conversation._id, LOI.characterId(), text, (error) =>
      if error
        console.error error
        return

      # Clear the entry form.
      @$('.new-line-text').val('')
