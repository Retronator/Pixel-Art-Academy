AB = Artificial.Base
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Admin.Patreon extends AM.Component
  @id: -> 'Retronator.Store.Pages.Admin.Patreon'
  @register @id()

  @importPledges: new AB.Method name: "#{@id()}.importPledges"
  @updateCurrentPledges: new AB.Method name: "#{@id()}.updateCurrentPledges"
  @refreshClient: new AB.Method name: "#{@id()}.refreshClient"
  @grantEarlyKeycards: new AB.Method name: "#{@id()}.grantEarlyKeycards"
  @fillMissingPatronIDs: new AB.Method name: "#{@id()}.fillMissingPatronIDs"
  @deleteStalePledges: new AB.Method name: "#{@id()}.deleteStalePledges"

  events: ->
    super(arguments...).concat
      'click .update-current-pledges': @onClickUpdateCurrentPledges
      'submit .upload-form': @onSubmitUploadForm
      'submit .refresh-form': @onSubmitRefreshForm
      'click .grant-early-keycards': @onClickGrantEarlyKeycards
      'click .fill-missing-patron-ids': @onClickFillMissingPatronIds
      'click .delete-stale-pledges': @onClickDeleteStalePledges

  onClickUpdateCurrentPledges: (event) ->
    @constructor.updateCurrentPledges()

  onClickGrantEarlyKeycards: (event) ->
    @constructor.grantEarlyKeycards()

  onSubmitUploadForm: (event) ->
    event.preventDefault()

    csvFile = @$('.csv-file')[0].files[0]
    manualList = @$('.manual-input').val()
    dateParts = @$('.date').val().split '-'
    date = new Date Date.UTC dateParts[0], dateParts[1] - 1, dateParts[2]

    submitData = (data) =>
      @constructor.importPledges date, data

    if manualList.length
      submitData manualList

    else
      reader = new FileReader()

      reader.onload = (event) =>
        submitData event.target.result

      reader.readAsText csvFile

  onSubmitRefreshForm: (event) ->
    event.preventDefault()

    refreshToken = @$('.refresh-token').val()
    @constructor.refreshClient refreshToken

  onClickFillMissingPatronIds: (event) ->
    @constructor.fillMissingPatronIDs()

  onClickDeleteStalePledges: (event) ->
    @constructor.deleteStalePledges()
