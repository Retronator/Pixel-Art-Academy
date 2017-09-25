AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Components.CheckInConversations extends AM.Component
  @register "PixelArtAcademy.PixelBoy.Apps.Components.CheckInConversations"

  onCreated: ->
    super

    checkIn = @data()
    PAA.Practice.CheckIn.conversationsForCheckInId.subscribe @, checkIn._id

  conversations: ->
    checkIn = @data()
    return unless checkIn.conversations?.length

    # Get conversation documents based on check-in's array of conversation ids.
    LOI.Conversations.Conversation.documents.find
      _id:
        $in: checkIn.conversations
    ,
      sort:
        startTime: -1
  
  events: ->
    super.concat
      'submit .new-conversation-form': @onSubmitNewConversationForm

  onSubmitNewConversationForm: (event) ->
    event.preventDefault()

    checkIn = @data()

    # Get the new text.
    $text = @$('.new-conversation-form .text')
    text = $text.val().trim()

    # Don't do anything if you can't find a non-whitespace character.
    return unless /\S/.test text

    # Disable the form controls.
    $formControls = @$('.new-conversation-form :input')
    $formControls.prop('disabled', true)

    PAA.Practice.CheckIn.newConversation checkIn._id, LOI.characterId(), text, (error) =>
      #  Enable the form controls.
      $formControls.prop('disabled', false)

      if error
        console.error error
        return

      # Everything went OK, clear what the user has written.
      $text.val('')
