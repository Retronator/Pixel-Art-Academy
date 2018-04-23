AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Components.CheckInConversations extends AM.Component
  @register "PixelArtAcademy.PixelBoy.Apps.Components.CheckInConversations"

  conversations: ->
    checkIn = @data()

    # Check if we have any conversations already.
    return [] unless checkIn.conversations

    # Do not return any invalid conversations.
    _.without checkIn.conversations, [null, undefined]

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
