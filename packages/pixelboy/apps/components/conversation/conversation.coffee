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

  formattedText: ->
    line = @currentData()
    text = line.text

    # DANGER ZONE:
    # We are using direct HTML injection with triple braces, i.e. {{{formattedText}}}, so make sure we escape properly.
    div = document.createElement 'div'
    div.appendChild document.createTextNode text
    escapedText = div.innerHTML
    
    # Replace urls with links.
    urlRegex = /(https?):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])?/

    formattedText = escapedText.replace urlRegex, (url, protocol, domain, path) =>
      urlText = domain

      if path
        # Make sure the path is not longer than 10 characters.
        path = "/…#{path.substring(path.length-8)}" if path.length > 10

        # Add it to the domain.
        urlText = "#{urlText}#{path}"

      # Link should be 2 shades lighter than the text.
      linkColor = line.character.colorObject 2

      "<a href='#{url}' target='_blank' style='color:##{linkColor.getHexString()};'>#{urlText}</a>"

    formattedText

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
