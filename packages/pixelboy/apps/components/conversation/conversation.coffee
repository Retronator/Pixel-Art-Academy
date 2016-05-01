AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Components.Conversation extends AM.Component
  @register "PixelArtAcademy.PixelBoy.Apps.Components.Conversation"

  onCreated: ->
    super

    conversation = @data()
    @subscribe 'LandsOfIllusions.Conversations.Line.linesForConversation', conversation._id

  lines: ->
    conversation = @data()

    LOI.Conversations.Line.documents.find
      'conversation._id': conversation._id
    ,
      sort:
        time: 1

  textStyle: ->
    line = @currentData()

    # Set the color to character's color.
    color: "##{line.character.colorObject()?.getHexString()}"

  events: ->
    super.concat
      'submit .new-line-form': @submitNewLineForm

  submitNewLineForm: (event) ->
    event.preventDefault()

    conversation = @data()
    text = @$('.new-line-text').val()

    Meteor.call 'LandsOfIllusions.Conversations.Line.insert', conversation._id, LOI.characterId(), text, (error) =>
      if error
        console.error error
        return

      # Clear the entry form.
      @$('.new-line-text').val('')
