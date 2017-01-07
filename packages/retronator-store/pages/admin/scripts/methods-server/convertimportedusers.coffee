RA = Retronator.Accounts
RS = Retronator.Store

Meteor.methods
  'Retronator.Store.Pages.Admin.Scripts.ConvertImportedUsers': ->
    RA.authorizeAdmin()

    console.log "Converting imported users …"

    importedDataUserCollection = new DirectCollection 'LandsOfIllusionsAccountsImportedDataUsers'

    convertedCount = 0

    importedDataUserCollection.findEach {}, {}, (importedDataUser) =>
      # Imported Data User format:

      # backerNumber: kickstarter backer number
      # backerId: kickstarter backer UID
      # name: kickstarter backer Name
      # email: email to be used in reward matching
      # twitter: twitter handle to be used in reward matching
      # shipping:
      #   country: the shipping country for physical rewards
      #   amount: how much of pledge amount was included for shipping
      # reward:
      #   minimum: reward minimum amount in $ as imported from the kickstarter database
      #   tier:
      #     _id
      #     name: the display name of the reward tier
      # pledge:
      #   amount: kickstarter pledge amount in $
      #   time: when the backer pledged at

      # Retronator Store Transaction format:
      
      # time: when the transaction was conducted
      # email: user email entered for this transaction if user was not logged in during payment
      # items: array of items received in this transaction
      #   item: the item document
      #     _id
      #   price: price of the item at the time of the purchase, unless item was a received gifted
      # payments: array of payments used in this transaction
      #   _id

      # Retronator Store Payment format:

      # type: what kind of payment this was
      # amount: USD value added to the balance with this payment
      #
      # KICKSTARTER PLEDGE
      # backerEmail: Kickstarter user's email who made the pledge
      # project: name of the project the pledge is associated with
      # backerNumber: kickstarter backer number
      # backerId: kickstarter backer UID
      # backerName: kickstarter backer Name

      debug = false

      console.log "Converting imported user", importedDataUser if debug

      # Did we already convert this user?
      existingTransaction = RS.Transactions.Transaction.documents.findOne importedDataUser._id

      if existingTransaction and existingTransaction.payments.length
        # Now also find the existing payment.
        paymentId = existingTransaction.payments[0]._id

        console.log "Updating existing transaction", existingTransaction._id if debug

      # Was there a pledge amount? Then we need to make a payment.
      payments = []

      if importedDataUser.pledge?.amount
        paymentData =
          type: RS.Transactions.Payment.Types.KickstarterPledge
          amount: importedDataUser.pledge.amount
          backerEmail: importedDataUser.email
          project: RS.Transactions.Payment.Projects.PixelArtAcademy
          backerNumber: importedDataUser.backerNumber
          backerId: importedDataUser.backerId
          backerName: importedDataUser.name

        if paymentId
          result = RS.Transactions.Payment.documents.update paymentId, paymentData
          console.log "Updating payment, result:", result if debug

        else
          paymentId = RS.Transactions.Payment.documents.insert paymentData
          console.log "Inserting payment, result:", paymentId if debug

        payments = [
          _id: paymentId
        ]

      # Figure out which item we have.
      switch importedDataUser.reward.tier.name
        when 'No reward' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.NoReward
        when 'Pixel Art Academy - THE GAME!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.BasicGame
        when 'Pixel Art Academy - Early bird: YOUR OWN CHARACTER!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.EarlyFullGame
        when 'Pixel Art Academy - YOUR OWN CHARACTER!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.FullGame
        when 'Pixel Art Academy - Early bird: GAME ALPHA!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.EarlyAlphaAccess
        when 'Pixel Art Academy - GAME ALPHA!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.AlphaAccess
        when 'Pixel Art Academy - Avatar track: CUSTOM ITEM!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.AvatarTrack.CustomItem
        when 'Pixel Art Academy - Artist track: CLASS HELP!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.ArtistTrack.ClassHelp
        when 'Pixel Art Academy - Avatar track: UNIQUE ITEM!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.AvatarTrack.UniqueItem
        when 'Pixel Art Academy - Artist track: PAINTOVER!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.ArtistTrack.Paintover
        when 'Pixel Art Academy - Avatar track: UNIQUE CUSTOM AVATAR!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.AvatarTrack.UniqueCustomAvatar
        when 'Pixel Art Academy - Artist track: PAINTOVER VIDEO!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.ArtistTrack.PaintoverVideo
        when 'Pixel Art Academy - Art collector: ZX COSMOPOLIS!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.ArtCollector.ZXCosmopolis
        when 'Pixel Art Academy - Art collector: PIXEL CHINA MOUNTAINS!' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.ArtCollector.PixelChinaMountains
        when 'Pixel Art Academy - Complimentary full game access' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Complimentary.FullGame
        when 'Pixel Art Academy - Complimentary alpha game access' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Complimentary.AlphaAccess
        when 'Pixel Art Academy - Complimentary press access' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Complimentary.Press
        when 'Pixel Art Academy - Complimentary basic game access' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Complimentary.BasicGame
        when 'Pixel Art Academy - Complimentary Idea Garden game access' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Complimentary.IdeaGarden
        when 'Pixel Art Academy - Complimentary Secret Lab game access' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Complimentary.SecretLab
        when 'Pixel Art Academy - Complimentary Patron Club game access' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Complimentary.PatronClub
        when 'Pixel Art Academy - Complimentary Investor game access' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Complimentary.Investor
        when 'Pixel Art Academy - Complimentary V.I.P. game access' then itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Complimentary.VIP
        when 'Retronator' then itemCatalogKey = RS.Items.CatalogKeys.Retronator.Admin
        else
          console.error "Tier name", importedDataUser.reward.tier.name, "not found."
          return

      unless itemCatalogKey
        console.error "Catalog key wasn't found", importedDataUser.reward.tier.name
        return

      console.log "Searching for catalog key", itemCatalogKey if debug

      item = RS.Transactions.Item.documents.findOne catalogKey: itemCatalogKey

      unless item
        console.error 'Item for key', itemCatalogKey, 'was not found.'
        return

      console.log "Item is", item.catalogKey if debug

      transactionItems = [
        item:
          _id: item._id
      ]

      if importedDataUser.reward?.minimum
        transactionItems[0].price = importedDataUser.reward?.minimum

      # See if we have to add the shipping item.
      if importedDataUser.shipping?.amount
        shippingItem = RS.Transactions.Item.documents.findOne catalogKey: RS.Items.CatalogKeys.PixelArtAcademy.Kickstarter.ArtworkShipping

        transactionItems.push
          item:
            _id: shippingItem._id
          price: importedDataUser.shipping.amount

      pledgeTime = new Date(importedDataUser.pledge?.time) or new Date 2016, 1, 1

      transaction =
        _id: importedDataUser._id
        time: pledgeTime
        payments: payments
        items: transactionItems

      transaction.email = importedDataUser.email if importedDataUser.email
      transaction.twitter = importedDataUser.twitter if importedDataUser.twitter

      console.log "Upserting transaction", transaction if debug

      result = RS.Transactions.Transaction.documents.upsert importedDataUser._id, transaction

      console.log "Upserting transaction, result:", result if debug

      convertedCount++
      console.log "So far converted", convertedCount
