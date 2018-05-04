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
  
  email.addParagraph "p.s. We have a secret Facebook group for the game. If you want
                      to join, just reply and let me know the email you use for Facebook
                      and I'll send you an invite."

  email.addParagraph "p.p.s. There is a lo-fi prototype of the drawing activities available
                      in the form of articles in Retronator Magazine. Currently it's a hidden
                      draft, but it already has a ton of knowledge and 50 tasks to complete.
                      You can start learning at:"

  email.addLinkParagraph 'https://medium.com/retronator-magazine/pixel-art-academy-study-guide-3ae5f772a83a', "Pixel Art Academy Study Guide"

  email.end()
  
  Email.send
    from: "hi@retronator.com"
    to: customer.email
    subject: "Retronator Store Purchase Confirmation"
    text: email.text
    html: email.html
