LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1

Vocabulary = LOI.Parser.Vocabulary

class C1.Items.AdmissionEmail extends LOI.Emails.Email
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Items.AdmissionEmail'

  @translations: ->
    from: "Retropolis Academy of Art"
    subject: "Admission to our program"
    text: """
      Dear _char_,

      We were delighted to receive your application to participate in our on-campus program at the Retropolis Academy of Art. We are happy to inform you that admission week has now started.

      As explained in the admissions section on our website, your first step is to pick up a PixelBoy 2000 from your nearest Retronator store. Based on your location, this is:

      Retronator Headquarters<br/>
      176 2nd Street<br/>
      San Francisco, CA

      Your PixelBoy will include further instructions. Once you activate it, you will have 7 days to complete your assignments.

      The admissions process is completely transparent. You will know how you're doing all along the way and we will be there to help you succeed.

      We'd wish you good luck, but where you're going, luck has nothing to do with it. The final decision is automatic, based only on your commitment performance, and completely dependent on your actions.

      Good work, and see you soon!

      Sincerely,<br/>
      Retropolis Academy of Art Admissions
    """

  @initialize()

  gameDate: ->
    return unless LOI.adventure.gameState()

    # The admission email should arrive when the character was accepted.
    return unless acceptedTime = C1.readOnlyState('application')?.acceptedTime
    
    new LOI.GameDate acceptedTime

  sender: ->
    name: @translations()?.from
    address: 'academy.of.art@retropolis.city'

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
