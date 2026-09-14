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

    AT.Patreon.campaigns().then (campaigns) =>
      unless campaigns
        console.error "Could not access Patreon campaigns."
        return

      unless campaigns.length
        console.error "Patreon returned no campaigns for the configured creator access token."
        return

      campaign = campaigns[0]

      AT.Patreon.members(campaign.id).then (members) =>
        unless members
          console.error "Could not access Patreon campaign members."
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
        getItemId = (catalogKey) => RS.Item.documents.findOne({catalogKey})._id

        patreonKeycardId = getItemId CatalogKeys.Retronator.Patreon.PatreonKeycard
        earlyBirdKeycardId = getItemId CatalogKeys.Retronator.Patreon.EarlyBirdKeycard
        patronClubMemberId = getItemId CatalogKeys.Retropolis.PatronClubMember

        for member in members
          patronId = member.relationships?.user?.data?.id

          unless patronId
            console.error "Could not update Patreon member #{member.id}: user relationship is missing."
            continue

          # If we're updating a single patron, make sure the membership belongs to them before processing.
          continue if singlePatronId and patronId isnt singlePatronId

          patronEmail = member.attributes.email

          # Replace reconstructed historical charges with the campaign-currency lifetime support reported by Patreon.
          RA.Patreon._updateLifetimeSupportPayment member, patronId, patronEmail, earlyBirdKeycardId

          # Only active patrons should have a transaction that grants current membership perks.
          continue unless member.attributes.patron_status is 'active_patron'

          pledgeAmountCents = member.attributes.currently_entitled_amount_cents
          pledgeDateValue = member.attributes.pledge_relationship_start
          pledgeDate = new Date pledgeDateValue if pledgeDateValue

          unless _.isNumber(pledgeAmountCents) and pledgeDate and not _.isNaN(pledgeDate.getTime())
            console.error "Could not update current Patreon pledge for #{patronEmail or patronId}: pledge data is missing."
            continue

          pledgeAmount = pledgeAmountCents / 100

          existingPledgeTransaction = _.find existingPledgeTransactions, (transaction) => transaction.patreon is patronId

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
                  # For items we need to manually check if same item IDs are present
                  # since our array only has item IDs and would not pass as equal.
                  newItemIds = (transactionItem.item._id for transactionItem in value)
                  oldItemIds = (transactionItem.item._id for transactionItem in existingPledgeTransaction.items)

                  transactionUpdateNeeded = true if _.xor(newItemIds, oldItemIds).length

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

        # If any pledges are left in existing pledges, it means they are not active anymore and we should remove them.
        for transaction in existingPledgeTransactions
          RS.Transaction.documents.remove transaction._id
          RS.Payment.documents.remove transaction.payments[0]._id

        console.log "Updating completed."

  @_updateLifetimeSupportPayment: (member, patronId, patronEmail, earlyBirdKeycardId) ->
    campaignLifetimeSupportCents = member.attributes.campaign_lifetime_support_cents

    # A missing lifetime support amount is different from zero. Avoid deleting
    # payment history when Patreon returns an incomplete member resource.
    unless _.isNumber campaignLifetimeSupportCents
      console.error "Could not consolidate Patreon payments for #{patronEmail or patronId}: lifetime support is missing."
      return

    campaignLifetimeSupport = campaignLifetimeSupportCents / 100
    lastChargeDateValue = member.attributes.last_charge_date
    lastChargeDate = new Date lastChargeDateValue if lastChargeDateValue

    # A positive lifetime support amount should always have a corresponding last charge date. Avoid replacing history
    # with an invalid date if Patreon returns an incomplete member resource.
    if campaignLifetimeSupport and (not lastChargeDate or _.isNaN lastChargeDate.getTime())
      console.error "Could not consolidate Patreon payments for #{patronEmail or patronId}: last charge date is missing."
      return

    identifiedPatronPayments = RS.Payment.documents.fetch
      type: RS.Payment.Types.PatreonPledge
      patronId: patronId

    knownPatronEmails = (payment.patronEmail for payment in identifiedPatronPayments when payment.patronEmail)
    knownPatronEmails.push patronEmail if patronEmail

    if patronUser = RA.User.documents.findOne patreonId: patronId
      for registeredEmail in patronUser.registered_emails or [] when registeredEmail.verified
        knownPatronEmails.push registeredEmail.address

    knownPatronEmails = _.uniq knownPatronEmails

    paymentPatronSelectors = [patronId: patronId]

    # Older imported payments have no patron ID, so use their email without accidentally claiming payments belonging
    # to another Patreon account that later used the same address. Include earlier known addresses in case the patron
    # has since changed the email shared by Patreon.
    for knownPatronEmail in knownPatronEmails
      paymentPatronSelectors.push {patronId: null, patronEmail: knownPatronEmail}

    existingPayments = RS.Payment.documents.fetch
      type: RS.Payment.Types.PatreonPledge
      authorizedOnly: {$ne: true}
      $or: paymentPatronSelectors

    existingPaymentIds = (payment._id for payment in existingPayments)
    existingTransactions = if existingPaymentIds.length then RS.Transaction.documents.fetch 'payments._id': $in: existingPaymentIds else []

    # Preserve the legacy Early Bird keycard while discarding old pledge-tier rewards.
    preservedItems = []

    for transaction in existingTransactions
      for transactionItem in transaction.items or []
        continue unless transactionItem.item._id is earlyBirdKeycardId
        continue if _.find preservedItems, (preservedItem) => preservedItem.item._id is transactionItem.item._id
        preservedItems.push item: _id: transactionItem.item._id

    validExistingPayments = _.filter existingPayments, (payment) => payment.invalid isnt true

    findValidPaymentForTransaction = (transaction) =>
      _.find validExistingPayments, (payment) =>
        _.find transaction.payments, (transactionPayment) => transactionPayment._id is payment._id

    # Prefer retaining the valid transaction that already has the
    # Early Bird keycard so its ownership history remains stable.
    consolidatedTransaction = _.find existingTransactions, (transaction) =>
      hasEarlyBirdKeycard = _.find transaction.items or [], (transactionItem) =>
        transactionItem.item._id is earlyBirdKeycardId

      hasEarlyBirdKeycard and findValidPaymentForTransaction transaction

    consolidatedTransaction ?= _.find existingTransactions, findValidPaymentForTransaction

    if consolidatedTransaction
      consolidatedPayment = findValidPaymentForTransaction consolidatedTransaction

    consolidatedPayment ?= validExistingPayments[0]
    consolidatedPaymentId = consolidatedPayment?._id

    # A member who has never paid should not have a collected Patreon payment or transaction.
    unless campaignLifetimeSupport
      existingTransactionIds = (transaction._id for transaction in existingTransactions)

      if existingTransactionIds.length
        RS.Transaction.documents.remove _id: $in: existingTransactionIds

      if existingPaymentIds.length
        RS.Payment.documents.remove _id: $in: existingPaymentIds

      return

    paymentData =
      amount: campaignLifetimeSupport
      patronId: patronId

    paymentData.patronEmail = patronEmail if patronEmail

    if consolidatedPayment
      paymentUpdateNeeded = _.some paymentData, (value, property) =>
        not EJSON.equals consolidatedPayment[property], value

      if paymentUpdateNeeded
        RS.Payment.documents.update consolidatedPayment._id,
          $set: paymentData

    else
      _.extend paymentData, type: RS.Payment.Types.PatreonPledge
      consolidatedPaymentId = RS.Payment.documents.insert paymentData

    transactionData =
      time: lastChargeDate
      patreon: patronId

    transactionData.email = patronEmail if patronEmail

    if consolidatedTransaction
      # Reuse the selected transaction and update its last-charge information in place.
      transactionUpdateNeeded = _.some transactionData, (value, property) =>
        not EJSON.equals consolidatedTransaction[property], value

      # Reference fields contain expanded documents, so compare item IDs instead of the complete values.
      oldItemIds = (transactionItem.item._id for transactionItem in consolidatedTransaction.items or [])
      preservedItemIds = (transactionItem.item._id for transactionItem in preservedItems)

      # See if items have changed.
      if _.xor(oldItemIds, preservedItemIds).length
        transactionData.items = preservedItems
        transactionUpdateNeeded = true

      oldPaymentIds = (transactionPayment._id for transactionPayment in consolidatedTransaction.payments)

      # The consolidated transaction must reference only the single retained payment.
      unless oldPaymentIds.length is 1 and oldPaymentIds[0] is consolidatedPaymentId
        transactionData.payments = [_id: consolidatedPaymentId]
        transactionUpdateNeeded = true

      if transactionUpdateNeeded
        RS.Transaction.documents.update consolidatedTransaction._id,
          $set: transactionData

    else
      # No usable historical transaction exists, so create one for the consolidated payment.
      _.extend transactionData,
        items: preservedItems
        payments: [_id: consolidatedPaymentId]

      RS.Transaction.documents.insert transactionData

    # Remove all historical charge records except for the consolidated payment and transaction retained above.
    extraTransactionIds = (transaction._id for transaction in existingTransactions)
    extraTransactionIds = _.without extraTransactionIds, consolidatedTransaction._id if consolidatedTransaction
    RS.Transaction.documents.remove _id: $in: extraTransactionIds if extraTransactionIds.length

    extraPaymentIds = (payment._id for payment in existingPayments)
    extraPaymentIds = _.without extraPaymentIds, consolidatedPayment._id if consolidatedPayment
    RS.Payment.documents.remove _id: $in: extraPaymentIds if extraPaymentIds.length

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
