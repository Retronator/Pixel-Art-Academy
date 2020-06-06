AT = Artificial.Telepathy
RA = Retronator.Accounts
RS = Retronator.Store

class RA.Patreon extends RA.Patreon
  @updateCurrentPledgeForPatron: (patronId) ->
    @updateCurrentPledges patronId

  # Update current pledges for all or a single patron.
  @updateCurrentPledges: (singlePatronId) ->
    if singlePatronId
      console.log "Updating current Patreon pledge for patron #{singlePatronId} …"

    else
      console.log "Updating current Patreon pledges …"

    AT.Patreon.campaigns().then (campaigns) ->
      unless campaigns
        console.error "Could not access Patreon campaigns."
        return

      campaign = campaigns[0].data

      AT.Patreon.pledges(campaign.id).then (pledges) ->
        unless pledges
          console.error "Could not access Patreon pledges"
          return

        # Update intended pledges. These are recorded by setting authorizedOnly on their payments.
        if singlePatronId
          existingPledgeTransactions = RS.Transaction.documents.fetch
            patreon: singlePatronId
            payments:
              $elemMatch:
                type: RS.Payment.Types.PatreonPledge
                authorizedOnly: true

        else
          existingPledgeTransactions = RS.Transaction.documents.fetch
            payments:
              $elemMatch:
                type: RS.Payment.Types.PatreonPledge
                authorizedOnly: true

        CatalogKeys = RS.Items.CatalogKeys
        getItemId = (catalogKey) -> RS.Item.documents.findOne({catalogKey})._id

        patreonKeycardId = getItemId CatalogKeys.Retronator.Patreon.PatreonKeycard
        patronClubMemberId = getItemId CatalogKeys.Retropolis.PatronClubMember

        playerAccessId = getItemId CatalogKeys.PixelArtAcademy.PlayerAccess

        avatarEditorId = getItemId CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
        ideaGardenAccessId = getItemId CatalogKeys.Retropolis.IdeaGardenAccess

        alphaAccessId = getItemId CatalogKeys.PixelArtAcademy.AlphaAccess
        secretLabAccessId = getItemId CatalogKeys.Retropolis.SecretLabAccess

        for pledge in pledges when not pledge.data.attributes.declined_since
          patron = pledge.data.relationships.patron
          patronId = patron.data.id

          # If we're updating a single patron, make sure the pledge belongs to them before processing.
          continue if singlePatronId and patronId isnt singlePatronId

          patronEmail = patron.data.attributes.email

          pledgeAmount = pledge.data.attributes.amount_cents / 100
          pledgeDate = new Date pledge.data.attributes.created_at

          existingPledgeTransaction = _.find existingPledgeTransactions, (transaction) -> transaction.patreon is patronId

          # Prepare updatable payment data (patron attributes that can change over time).
          paymentData =
            amount: pledgeAmount
            patronEmail: patronEmail

          # Prepare updatable transaction data.
          transactionData =
            time: pledgeDate
            email: patronEmail

          # Award the patron keycard and patron club membership to all.
          items = [
            item: _id: patreonKeycardId
          ,
            item: _id: patronClubMemberId
          ]

          # Give player access to pledges of $2 and above.
          items.push item: _id: playerAccessId if pledgeAmount >= 2

          # Give avatar editor and idea garden access to pledges of $4 and above.
          if pledgeAmount >= 4
            items.push item: _id: avatarEditorId
            items.push item: _id: ideaGardenAccessId

          # Give alpha access and secret lab access to pledges of $8 and above.
          if pledgeAmount >= 8
            items.push item: _id: alphaAccessId
            items.push item: _id: secretLabAccessId

          transactionData.items = items

          if existingPledgeTransaction
            transactionId = existingPledgeTransaction._id
            paymentId = existingPledgeTransaction.payments[0]._id

            # Remove the transaction from the array so we know it has been processed.
            existingPledgeTransactions = _.without existingPledgeTransactions, existingPledgeTransaction

            # See if payment needs updating.
            payment = RS.Payment.documents.findOne paymentId

            paymentUpdateNeeded = false

            for property, value of paymentData
              paymentUpdateNeeded = true unless EJSON.equals payment[property], value

            if paymentUpdateNeeded
              # Update payment.
              RS.Payment.documents.update paymentId,
                $set: paymentData

            # See if transaction needs updating
            transactionUpdateNeeded = false

            for property, value of transactionData
              unless EJSON.equals existingPledgeTransaction[property], value
                if property is 'items'
                  # For items we need to manually check if each is present
                  # since our array only has item IDs and would not pass as equal.
                  for item in value
                    itemInTransaction = _.find existingPledgeTransaction.items, (itemInTransaction) -> itemInTransaction._id is item._id
                    transactionUpdateNeeded = true unless itemInTransaction

                else
                  transactionUpdateNeeded = true

            # Update transaction.
            if transactionUpdateNeeded
              RS.Transaction.documents.update transactionId,
                $set: transactionData

          else
            # Create transaction and payment for this patron.
            _.extend paymentData,
              type: RS.Payment.Types.PatreonPledge
              authorizedOnly: true
              patronId: patronId

            paymentId = RS.Payment.documents.insert paymentData

            _.extend transactionData,
              patreon: patronId
              payments: [_id: paymentId]

            transactionId = RS.Transaction.documents.insert transactionData

          # See if any new payments have been processed. First find current patronage.
          payments = RS.Payment.documents.fetch
            authorizedOnly: {$ne: true}
            invalid: false
            $or: [
              patronId: patronId
            ,
              patronEmail: patronEmail
            ]

          totalRecordedAmount = _.sum (payment.amount for payment in payments)

          # Compare it to patron's actual patronage.
          totalHistoricalAmount = pledge.data.attributes.total_historical_amount_cents / 100

          if totalRecordedAmount < totalHistoricalAmount
            paymentAmount = totalHistoricalAmount - totalRecordedAmount
            console.log "New Patreon payment of $#{paymentAmount} detected for #{patronEmail}."

            # Create transaction and payment.
            paymentId = RS.Payment.documents.insert
              type: RS.Payment.Types.PatreonPledge
              patronEmail: patronEmail
              patronId: patronId
              amount: paymentAmount

            RS.Transaction.documents.insert
              time: new Date()
              email: patronEmail
              payments: [{_id: paymentId}]

        # If any pledges are left in existing pledges, it means they are not active anymore and we should remove them.
        for transaction in existingPledgeTransactions
          RS.Transaction.documents.remove transaction._id
          RS.Payment.documents.remove transaction.payments[0]._id

        console.log "Updating completed."

# Initialize on startup.
Document.startup ->
  return unless AT.Patreon.initialized
  return if Meteor.settings.startEmpty

  # Update pledges every day.
  new Cron =>
    console.log "Daily Patreon pledges update."
    RA.Patreon.updateCurrentPledges()
  ,
    hour: 1
    minute: 0
