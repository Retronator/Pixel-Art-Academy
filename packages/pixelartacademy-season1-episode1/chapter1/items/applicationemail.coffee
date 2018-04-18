LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Items.ApplicationEmail extends LOI.Emails.Email
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Items.ApplicationEmail'

  @translations: ->
    from: "Retropolis Academy of Art"
    subject: "Application received"
    text: """
      Dear _char_,

      Thank you for your interest in studying at Retropolis Academy of Art. We are confirming that we have received your application. 
      
      Admissions are currently open so it will take just a day or two for us to arrange the start of your admission week. We'll email you again soon.

      Sincerely,<br/>
      Retropolis Academy of Art Admissions
    """

  @initialize()

  gameTime: ->
    return unless LOI.adventure.readOnlyGameState()

    # The application email should arrive when the character has applied.
    return unless applicationTime = C1.readOnlyState('application')?.applicationTime
    
    new LOI.GameDate applicationTime

  sender: ->
    name: @translations()?.from
    address: 'academyofart@retropolis.city'

  recipient: ->
    character: LOI.character()

  subject: -> @translations()?.subject

  body: ->
    character = LOI.character()

    text = @translations()?.text

    # Do variable substitution.
    text = text.replace /_char_/g, character.avatar.fullName()

    # Create the html version by treating it as markdown.
    converter = new Showdown.converter()
    html = converter.makeHtml text

    # Remove HTML from text.
    text = text.replace /<br\/>/g, ''

    {text, html}
