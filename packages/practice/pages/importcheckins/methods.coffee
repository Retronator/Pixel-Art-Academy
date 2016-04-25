LOI = LandsOfIllusions
PAA = PixelArtAcademy

Meteor.methods
  'PixelArtAcademy.Practice.importCheckIns': (encodedData) ->
    check encodedData, String

    LOI.authorizeAdmin()

    return if LOI.isRunningLocally()

    unless Meteor.settings.dataUploadPassphrase
      console.warn "You need to specify the data upload passphrase in the settings file and don't forget to run the server with the --settings flag pointing to it."
      throw new Meteor.Error 'invalid-operation', "Passphrase not specified."

    passphrase = Meteor.settings.dataUploadPassphrase

    csvData = CryptoJS.AES.decrypt(encodedData, passphrase).toString(CryptoJS.enc.Latin1)

    throw new Meteor.Error 'unauthorized', "Invalid passphrase." unless 'HEADER' is csvData.substring 0, 6

    # Strip the header.
    csvData = csvData.substring 6

    # Create a regex that matches newlines, but not inside quoted strings.
    newlineRegex = /\r?\n(?=(?:(?:[^\"]*\"){2})*[^\"]*$)/

    lines = csvData.split newlineRegex
    console.log "Importing", lines.length - 1, "check-ins …"

    # Create a regex that matches commas, but not inside quoted strings.
    commaRegex = /,(?=(?:(?:[^\"]*\"){2})*[^\"]*$)/

    # Create a map of data columns to indices. Possible parts are:
    #   Timestamp,Backer email,Daily summary,Link to image,Feedback (optional),
    #   Backer Email,Link to your image,Anything else you wanted to share?
    parts = lines[0].split commaRegex

    columnIndices = {}

    for index in [0...parts.length]
      columnIndices[parts[index]] = index

    # Now create a check-in for each remaining line using the column mapping.
    checkInsCount = 0
    for line in lines[1..]
      parts = line.split commaRegex

      # Strip double quotes form strings.
      parts[i] = parts[i].replace(/^"(.*)"$/, '$1') for i in [0...parts.length]

      # Convert parts to ImportedData.User.
      checkIn = {}
      checkIn.timestamp = new Date(parts[columnIndices['Timestamp']])

      # 1 Week Challenge format:
      checkIn.backerEmail = parts[columnIndices['Backer email']] if parts[columnIndices['Backer email']]
      checkIn.text = parts[columnIndices['Daily summary']] if parts[columnIndices['Daily summary']]
      checkIn.image = parts[columnIndices['Link to image']] if parts[columnIndices['Link to image']]
      checkIn.feedback = parts[columnIndices['Feedback (optional)']] if parts[columnIndices['Feedback (optional)']]

      # Getting Started Study format:
      checkIn.backerEmail = parts[columnIndices['Backer Email']] if parts[columnIndices['Backer Email']]
      checkIn.image = parts[columnIndices['Link to your image']] if parts[columnIndices['Link to your image']]
      checkIn.feedback = parts[columnIndices['Anything else you wanted to share?']] if parts[columnIndices['Anything else you wanted to share?']]

      checkInsCount++
      PAA.Practice.ImportedData.CheckIn.documents.upsert
        timestamp: checkIn.timestamp
        backerEmail: checkIn.backerEmail
      ,
        checkIn

    console.log "Successfully imported", checkInsCount, "check-ins."
