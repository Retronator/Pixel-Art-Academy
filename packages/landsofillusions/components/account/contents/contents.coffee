AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts

class LOI.Components.Account.Contents extends LOI.Components.Account.Page
  @register 'LandsOfIllusions.Components.Account.Contents'
  @url: -> 'contents'
  @displayName: -> 'Contents'

  @initialize()

  account: ->
    @ancestorComponent LOI.Components.Account

  accountUrl: ->
    # Return the root url of the account, since url points to
    # the current active url (depending on which page is active).
    @account().constructor.url()

  pages: ->
    # Return all pages after contents.
    @account().pages

  currentPage: ->
    page = @currentData()

    # This page is the current page if its URL is the second router parameter.
    page.url() is AB.Router.getParameter 'parameter2'
