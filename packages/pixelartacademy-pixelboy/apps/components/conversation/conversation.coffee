AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Components.Conversation extends AM.Component
  @register "PixelArtAcademy.PixelBoy.Apps.Components.Conversation"

  onCreated: ->
    super

    conversation = @data()
    LOI.Conversations.Line.forConversation.subscribe @, conversation._id

    @characterIds = new ComputedField =>
      # Go over all lines and add character IDs.
      ids = (line.character?._id for line in @lines().fetch())

      _.without ids, undefined, null

    @_characters = {}

    # A map of character instances by ids.
    @characters = new ComputedField =>
      # Destroy previous instances.
      character.destroy() for characterId, character of @_characters

      @_characters = {}

      for characterId in @characterIds()
        @_characters[characterId] = new LOI.Character.Instance characterId

      @_characters

  onDestroyed: ->
    super

    character.destroy() for characterId, character of @_characters

  lines: ->
    conversation = @data()

    LOI.Conversations.Line.documents.find
      'conversation._id': conversation._id
    ,
      sort:
        time: 1

  characterInstance: ->
    line = @currentData()
    @characters()[line.character?._id]

  showAvatar: ->
    return unless character = @characterInstance()

    # We have avatar if the body field has any data.
    character.document()?.avatar.body

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
