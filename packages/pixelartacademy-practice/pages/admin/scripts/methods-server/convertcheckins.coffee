AB = Artificial.Base
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Practice.Pages.Admin.Scripts.convertCheckIns.method ->
  RA.authorizeAdmin()

  console.log "Converting check-ins to journal entries …"

  characters = LOI.Character.documents.find(
    {}
  ,
    fields:
      _id: true
  ).fetch()

  journalsCount = 0
  
  for character in characters
    checkIns = PAA.Practice.CheckIn.documents.find(
      'character._id': character._id
    ,
      sort: time: 1
    ).fetch()

    entries = []
            
    # Convert each check-in into an entry, except empty check-ins (no text or image).
    for checkIn, index in checkIns when checkIn.text or checkIn.image
      entry =
        time: checkIn.time
        order: index
        content: [
          insert:
            timestamp:
              time: checkIn.time
              timezoneOffset: 0
          attributes:
            language: 'en-US'
        ]

      if checkIn.image
        value =
          url: checkIn.image.url

        value.sourceWebsiteUrl = checkIn.post.url if checkIn.post

        entry.content.push
          insert:
            picture: value

      text = checkIn.text or ''

      # Transform double new lines into single.
      text = text.replace /\n\n/g, '\n'

      # Make sure the text ends on a new line.
      text += '\n' unless _.last(text) is '\n'

      entry.content.push
        insert: text

      entries.push entry

    continue unless entries.length

    # We made entries for this character so create a new journal for them.
    journalId = PAA.Practice.Journal.documents.insert
      character:
        _id: character._id
      design:
        type: PAA.Practice.Journal.Design.Type.Traditional
        size: PAA.Practice.Journal.Design.Size.Small
        orientation: PAA.Practice.Journal.Design.Orientation.Portrait
        bindingPosition: PAA.Practice.Journal.Design.BindingPosition.Left
        paper:
          type: PAA.Practice.Journal.Design.PaperType.Quad
          spacing: 5
          color:
            hue: LOI.Assets.Palette.Atari2600.hues.brown
            shade: 7
        cover:
          color:
            hue: LOI.Assets.Palette.Atari2600.hues.grey
            shade: 2

    journalsCount++

    for entry in entries
      entry.journal = _id: journalId

      # Insert the entry.
      PAA.Practice.Journal.Entry.documents.insert entry

  # Award alpha access to anyone who made some entries.
  alphaAccessId = RS.Item.documents.findOne(catalogKey: RS.Items.CatalogKeys.PixelArtAcademy.AlphaAccess)._id

  users = RA.User.documents.find(
    {}
  ,
    fields:
      displayName: true
      characters: true
      items: true
  ).fetch()

  for user in users when user.characters
    madeEntries = false

    for character in user.characters
      if PAA.Practice.Journal.documents.findOne('character._id': character._id)
        madeEntries = true
        break

    continue unless madeEntries

    console.log "User", user.displayName, "made journal entries."

    # See if the user already has alpha access.
    continue if _.find user.items, (item) => item.catalogKey is RS.Items.CatalogKeys.PixelArtAcademy.AlphaAccess

    console.log "Granting alpha to user ID", user._id

    RS.Transaction.documents.insert
      time: new Date()
      user:
        _id: user._id
      items: [
        item:
          _id: alphaAccessId
      ]

  console.log "Created #{journalsCount} journals."
