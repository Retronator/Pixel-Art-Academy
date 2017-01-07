RA = Retronator.Accounts
RS = Retronator.Store

Meteor.methods
  'Retronator.Store.Pages.Admin.Scripts.ConvertPreOrders': ->
    RA.authorizeAdmin()

    console.log "Converting pre-orders …"

    preOrdersCollection = new DirectCollection 'RetronatorStorePurchases'

    preOrdersCollection.findEach {}, {}, (preOrder) =>
      # Retronator Store Purchase format:
      
      # time: when the purchase was created
      # stripeCustomerId: customer id returned from stripe API
      # name: name on card as entered at checkout
      # email: email to which this purchase belongs
      # item: the item that was purchased
      #   _id
      #   name
      
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
      # STRIPE PAYMENT
      # authorizedOnly: true if the amount was not actually collected and this is just an intended payment
      # stripeCustomerId: customer id returned from stripe API

      console.log "Converting pre-order", preOrder

      # Did we already convert this pre-order?
      existingTransaction = RS.Transactions.Transaction.documents.findOne preOrder._id

      if existingTransaction
        # Now also find the existing payment.
        paymentId = existingTransaction.payments[0]._id

        console.log "Updating existing transaction", existingTransaction

      # Figure out if this is a pre-order of the basic or the full game.
      switch preOrder.item._id
        when 'wdMKrYTYKY9uxrT56' 
          itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.BasicGame
          price = 10
        
        when 'RyEHscfZn9AoAuGYu'
          itemCatalogKey = RS.Items.CatalogKeys.Bundles.PixelArtAcademy.PreOrder.FullGame
          price = 20

      paymentData =
        type: RS.Transactions.Payment.Types.StripePayment
        amount: price
        authorizedOnly: true
        stripeCustomerId: preOrder.stripeCustomerId

      if paymentId
        result = RS.Transactions.Payment.documents.update paymentId, paymentData
        console.log "Updating payment, result:", result

      else
        paymentId = RS.Transactions.Payment.documents.insert paymentData
        console.log "Inserting payment, result:", paymentId

      item = RS.Transactions.Item.documents.findOne catalogKey: itemCatalogKey
      console.log "Item is", item

      result = RS.Transactions.Transaction.documents.upsert preOrder._id,
        _id: preOrder._id
        time: preOrder.time
        email: preOrder.email
        payments: [
          _id: paymentId
        ]
        items: [
          item:
            _id: item._id
          price: price
        ]
      console.log "Upserting transaction, result:", result
