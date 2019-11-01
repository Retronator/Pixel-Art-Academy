RS = Retronator.Store

class Migration extends Document.MajorMigration
  name: "Migrate stripeCustomerId field to a payment method."

  forward: (document, collection, currentSchema, newSchema) ->
    count = 0

    paymentMethodsCollection = new DirectCollection 'Retronator.Store.PaymentMethods'

    collection.findEach
      _schema: currentSchema
      stripeCustomerId:
        $exists: true
    ,
      (document) ->
        # Create stripe payment method object with stripe customer ID.
        paymentMethod =
          _id: Random.id()
          type: 'Stripe'
          customerId: document.stripeCustomerId

        # Save the payment method
        paymentMethodsCollection.insert paymentMethod

        # Replace stripe customer id field with payment method reference.
        count += collection.update _id: document._id,
          $set:
            paymentMethod:
              _id: paymentMethod._id
            _schema: newSchema
          $unset:
            stripeCustomerId: true

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

  backward: (document, collection, currentSchema, oldSchema) ->
    count = 0

    paymentMethodsCollection = new DirectCollection 'Retronator.Store.PaymentMethods'

    collection.findEach
      _schema: currentSchema
      type: 'StripePayment'
      paymentMethod:
        $exists: true
    ,
      (document) =>
        paymentMethod = paymentMethodsCollection.findOne document.paymentMethod._id
        stripeCustomerId = paymentMethod.customerId

        count += collection.update _id: document._id,
          $set:
            stripeCustomerId: stripeCustomerId
            _schema: oldSchema
          $unset:
            paymentMethod: true

        paymentMethodsCollection.remove _id: paymentMethod._id

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

RS.Payment.addMigration new Migration()
