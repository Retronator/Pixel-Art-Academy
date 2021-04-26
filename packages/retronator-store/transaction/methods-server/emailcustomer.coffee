RS = Retronator.Store
AB = Artificial.Base
AT = Artificial.Telepathy

RS.Transaction.emailCustomer = ({customer, payments, shoppingCart, taxInfo, invoice}) ->
  unless customer.email
    # We don't have user's email, so we can't send them the email (for example, if they logged in with Twitter only).
    # Exception is not thrown so that the method completes, but we can't continue with emailing.
    console.warning "Email was not sent for customer", customer, "payments", payments, "shoppingCart", shoppingCart
    return

  email = new AT.EmailComposer
  
  if customer.name
    email.addParagraph "Hey #{customer.name},"

  else
    email.addParagraph "Hey,"

  itemNamesList = for cartItem in shoppingCart.items()
    cartItem.item.name.refresh().translate().text

  email.addParagraph "We have received your purchase order for:\n
                      #{itemNamesList.join '\n'}"

  email.addParagraph "Thank you so much for you tip of $#{shoppingCart.tipAmount()} as well!" if shoppingCart.tipAmount()

  for payment in payments
    switch payment.type
      when RS.Payment.Types.StripePayment
        email.addParagraph "You should receive a separate email from Stripe that confirms your payment of $#{payment.amount}."

        email.addParagraph "We generated an invoice with full VAT (value-added tax) information, which you can access at:"

        invoiceUrl = AB.Router.createUrl RS.Pages.Invoice, accessSecret: invoice.accessSecret
        email.addLinkParagraph invoiceUrl, "Invoice"

      when RS.Payment.Types.StoreCredit
        email.addParagraph "We #{if payments.length > 1 then "also " else ""}applied your store credit of $#{payment.storeCreditAmount} towards the purchase."

  email.addParagraph "Thank you so much for your order!"
  
  email.addParagraph "Best,\n
                      Matej 'Retro' Jan // Retronator"
  
  email.addParagraph "p.s. If you run into any trouble, the fastest way to talk to me is on Discord.
                      You can join the server I'm on at the link below, and don't forget to choose the Pixel Art Academy role in the lobby:"

  email.addLinkParagraph 'https://discord.gg/d6V8Say', "Indie Games House Discord"

  email.addParagraph "p.p.s. Don't miss the ever-growing library of learning resources and activities in the in-game
                      Study Guide. It's a great way to continue your learning journey once you're finished with
                      the story of the current alpha version (end of Admission Week). Read it here:"

  email.addLinkParagraph 'https://retropolis.city/academy-of-art/study-guide', "Retropolis Academy of Art Study Guide"

  email.end()
  
  Email.send
    from: "hi@retronator.com"
    to: customer.email
    subject: "Retronator Store Purchase Confirmation"
    text: email.text
    html: email.html
