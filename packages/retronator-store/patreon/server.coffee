AT = Artificial.Telepathy
RA = Retronator.Accounts
RS = Retronator.Store

class RA.Patreon extends RA.Patreon
  @updateCurrentPledges: ->
    AT.Patreon.campaigns().then (campaigns) ->
      campaign = campaigns[0].data

      AT.Patreon.pledges(campaign.id).then (pledges) ->
        # Update intended pledges. These are recorded by setting authorizedOnly on their payments.
        existingPledgeTransactions = RS.Transaction.documents.find(
          payments:
            $elemMatch:
              type: RS.Payment.Types.PatreonPledge
              authorizedOnly: true
        ).fetch()

        CatalogKeys = RS.Items.CatalogKeys
        getItemId = (catalogKey) -> RS.Item.documents.findOne({catalogKey})._id

        patreonKeycardId = getItemId CatalogKeys.Retronator.Patreon.PatreonKeycard
        patronClubMemberId = getItemId CatalogKeys.Retropolis.PatronClubMember

        playerAccessId = getItemId CatalogKeys.PixelArtAcademy.PlayerAccess

        avatarEditorId = getItemId CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
        ideaGardenAccessId = getItemId CatalogKeys.Retropolis.IdeaGardenAccess

        alphaAccessId = getItemId CatalogKeys.PixelArtAcademy.AlphaAccess
        secretLabAccessId = getItemId CatalogKeys.Retropolis.SecretLabAccess

        for pledge in pledges
          patron = pledge.data.relationships.patron
          patronId = patron.data.id
          patronEmail = patron.data.attributes.email

          pledgeAmount = pledge.data.attributes.amount_cents / 100
          pledgeDate = new Date pledge.data.attributes.created_at

          existingPledgeTransaction = _.find existingPledgeTransactions, (transaction) -> transaction.patreon is patronId

          if existingPledgeTransaction
            transactionId = existingPledgeTransaction._id
            paymentId = existingPledgeTransaction.payments[0]._id

            # Remove the transaction from the array so we know it has been processed.
            existingPledgeTransactions = _.without existingPledgeTransactions, existingPledgeTransaction

          else
            # Create transaction and payment for this patron.
            paymentId = RS.Payment.documents.insert
              type: RS.Payment.Types.PatreonPledge
              authorizedOnly: true
              patronId: patronId

            transactionId = RS.Transaction.documents.insert
              patreon: patronId
              payments: [_id: paymentId]

          # Update payment.
          RS.Payment.documents.update paymentId,
            $set:
              amount: pledgeAmount
              patronEmail: patronEmail

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

          # Update transaction.
          RS.Transaction.documents.update transactionId,
            $set:
              time: pledgeDate
              email: patronEmail
              items: items

        # If any pledges are left in existing pledges it means they are not active anymore and we should remove them.
        for transaction in existingPledgeTransactions
          RS.Transaction.documents.remove transaction._id
          RS.Payment.documents.remove transaction.payments[0]._id

# Initialize on startup.
Document.startup ->
  return unless AT.Patreon.initialized
  return if Meteor.settings.startEmpty

  # Update pledges every day.
  new Cron =>
    console.log "Updating current Patreon pledges."
    RA.Patreon.updateCurrentPledges()
  ,
    hour: 1
    minute: 0
