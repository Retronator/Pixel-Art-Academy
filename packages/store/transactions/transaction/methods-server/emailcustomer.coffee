RS = Retronator.Store
AT = Artificial.Telepathy

RS.Transactions.Transaction.emailCustomer = ({customer, payments, shoppingCart}) ->
  unless customer.email
    # We don't have user's email, so we can't send them the email (for example, if they logged in with Twitter only).
    # Exception is not thrown so that the method completes, but we can't continue with emailing.
    console.warning "Email was not sent for customer", customer, "payments", payments, "shoppingCart", shoppingCart
    return

  unless customer.name
    # We don't have the user's name, which we use below. While it doesn't break things, something's probably wrong.
    console.warning "Email sent didn't have the customer's name. Customer was", customer, "payments", payments, "shoppingCart", shoppingCart

  email = new AT.EmailComposer
  
  email.addParagraph "Hey#{if customer.name then " #{customer.name}" else ""},"

  itemNamesList = for cartItem in shoppingCart.items()
    cartItem.item.name.refresh().translate().text

  email.addParagraph "We have received your purchase order for:\n
                      #{itemNamesList.join '\n'}"

  email.addParagraph "Thank you so much for you tip of $#{shoppingCart.tipAmount()} as well!" if shoppingCart.tipAmount()

  for payment in payments
    switch payment.type
      when RS.Transactions.Payment.Types.StripePayment
        email.addParagraph "At this point your credit card was only authorized. We will
                            collect the purchase price of $#{payment.amount} when the game's first public release
                            happens at the end of this year. You will be emailed beforehand in case you need to cancel
                            your purchase at that time."

      when RS.Transactions.Payment.Types.StoreCredit
        email.addParagraph "We #{if payments.length > 1 then "also " else ""}applied your store credit of $#{payment.storeCreditAmount} towards the purchase."

  email.addParagraph "Thank you so much for your order!"
  
  email.addParagraph "Best,\n
                      Matej 'Retro' Jan // Retronator"
  
  email.addParagraph "p.s. We have a secret Facebook group for the game. If you want
                      to join, just reply and let me know the email you use for Facebook
                      and I'll send you an invite. That way you can follow the development
                      as we go along. Hope to see you there."
  
  email.end()
  
  Email.send
    from: "hi@retronator.com"
    to: customer.email
    subject: "Retronator Store Purchase Confirmation"
    text: email.text
    html: email.html
