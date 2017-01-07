RA = Retronator.Accounts

###
  This method used to be able to import any kind of users, but has now been modified to only correctly update
  Kickstarter backers. It is to be removed as soon as the integrity of the converted backers data (into transactions)
  has been confirmed.
###

Meteor.methods
  'Retronator.Accounts.importUsers': (rewardTierId, encodedData) ->
    check rewardTierId, Match.OptionalOrNull Match.DocumentId
    check encodedData, String

    RA.authorizeAdmin()

    unless Meteor.settings.dataUploadPassphrase
      console.warn "You need to specify the data upload passphrase in the settings file and don't forget to run the server with the --settings flag pointing to it."
      throw new Meteor.Error 'invalid-operation', "Passphrase not specified."

    passphrase = Meteor.settings.dataUploadPassphrase

    csvData = CryptoJS.AES.decrypt(encodedData, passphrase).toString(CryptoJS.enc.Latin1)

    throw new Meteor.Error 'unauthorized', "Invalid passphrase." unless 'HEADER' is csvData.substring 0, 6

    # Strip the header.
    csvData = csvData.substring 6

    lines = csvData.match /[^\r\n]+/g
    console.log "Importing", lines.length - 1, "users …"

    # Create a regex that matches commas, but not inside quoted strings.
    commaRegex = /,(?=(?:(?:[^\"]*\"){2})*[^\"]*$)/

    # Create a map of data columns to indices. Possible parts are:
    #   Backer Number,Backer UID,Backer Name,Email,Shipping Country,Shipping Amount,
    #   Reward Minimum,Reward ID,Pledge Amount,Pledged At,Rewards Sent?,Pledged Status,Notes,Twitter
    parts = lines[0].split commaRegex

    columnIndices = {}

    for index in [0...parts.length]
      columnIndices[parts[index]] = index

    importedDataUserCollection = new DirectCollection 'LandsOfIllusionsAccountsImportedDataUsers'

    # Now create a backer for each remaining line using the column mapping.
    usersCount = 0
    for line in lines[1..]
      parts = line.split commaRegex

      # Strip double quotes form strings.
      parts[i] = parts[i].replace(/^"(.*)"$/, '$1') for i in [0...parts.length]

      # See if the reward id is included in the data.
      #rewardId = if parts[columnIndices['Reward ID']] then parseInt parts[columnIndices['Reward ID']] else null
      #dataRewardTierId = if rewardId then Retronator.Store.Transactions.Item.documents.findOne(rewardId: rewardId)._id else null

      # If no default reward ID is passed to the method and the reward is not included in the data we can't do anything.
      #continue unless dataRewardTierId or rewardTierId

      # Convert parts to ImportedData.User.
      backerId = parseInt parts[columnIndices['Backer UID']] if parts[columnIndices['Backer UID']]
      console.log "We have a backer with ID", backerId
      return unless backerId

      existing = importedDataUserCollection.findOne backerId: backerId

      user = {}
      user.backerNumber = parseInt parts[columnIndices['Backer Number']] if parts[columnIndices['Backer Number']]
      user.backerId = parseInt parts[columnIndices['Backer UID']] if parts[columnIndices['Backer UID']]
      user.name = parts[columnIndices['Backer Name']] if parts[columnIndices['Backer Name']]
      user.email = parts[columnIndices['Email']].toLowerCase() if parts[columnIndices['Email']]
      user.twitter = parts[columnIndices['Twitter']].toLowerCase() if parts[columnIndices['Twitter']]

      shipping = {}
      shipping.country = parts[columnIndices['Shipping Country']] if parts[columnIndices['Shipping Country']]
      shipping.amount = parseFloat parts[columnIndices['Shipping Amount']].match(/-?\d+\.\d+/)[0] if parts[columnIndices['Shipping Amount']]
      user.shipping = shipping unless _.isEmpty shipping

      if existing
        user['reward.minimum'] = parseFloat parts[columnIndices['Reward Minimum']].match(/-?\d+\.\d+/)[0] if parts[columnIndices['Reward Minimum']]
        user['reward.rewardId'] = parseInt parts[columnIndices['Reward ID']] if parts[columnIndices['Reward ID']]

        # Just set tier name for no reward.
        unless user['reward.minimum']
          user['reward.tier.name'] = 'No reward'

      else
        user.reward = {}
        user.reward.minimum = parseFloat parts[columnIndices['Reward Minimum']].match(/-?\d+\.\d+/)[0] if parts[columnIndices['Reward Minimum']]
        user.reward.rewardId = parseInt parts[columnIndices['Reward ID']] if parts[columnIndices['Reward ID']]

        unless user.reward.minimum
          user.reward.tier = name: 'No reward'

      pledge = {}
      pledge.amount = parseFloat parts[columnIndices['Pledge Amount']].match(/-?\d+\.\d+/)[0] if parts[columnIndices['Pledge Amount']]
      pledge.status = parts[columnIndices['Pledge Status']] if parts[columnIndices['Pledge Status']]
      pledge.time = new Date(parts[columnIndices['Pledged At']]) if parts[columnIndices['Pledged At']]
      pledge.rewardsSent = parts[columnIndices['Rewards Sent?']] if parts[columnIndices['Rewards Sent?']]
      user.pledge = pledge unless _.isEmpty pledge

      user.notes = parts[columnIndices['Notes']] if parts[columnIndices['Notes']]

      ###
      pledgeTime = new Date(parts[columnIndices['Pledged At']]) if parts[columnIndices['Pledged At']]
      console.log "The time pledged was", pledgeTime

      usersCount += importedDataUserCollection.update
        backerId: backerId
      ,
        $set:
          'pledge.time': pledgeTime

###

      console.log "Upserting", user

      if existing
        usersCount += importedDataUserCollection.update
          backerId: backerId
        ,
          $set: user

      else
        importedDataUserCollection.insert user

        usersCount++

    console.log "Successfully imported", usersCount, "users."
