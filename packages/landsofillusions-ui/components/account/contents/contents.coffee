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

  constructor: (@account) ->
    super arguments...

  accountUrl: ->
    # Return the root url of the account, since url points to
    # the current active url (depending on which page is active).
    @account.constructor.url()

  currentPage: ->
    page = @currentData()
    currentPage = @account.pages[@account.currentPageNumber() - 1]

    page is currentPage

  events: ->
    super(arguments...).concat
      'click .page-link': @onClickPageLink

  onClickPageLink: (event) ->
    page = @currentData()
    return if @account.options.useUrlRouting

    pageIndex = _.indexOf @account.pages, page
    @account.currentPageNumber pageIndex + 1
