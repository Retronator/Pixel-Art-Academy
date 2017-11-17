AB = Artificial.Base
AM = Artificial.Mirage
RA = Retronator.Accounts
RS = Retronator.Store

class RS.Pages.Admin.Patreon extends AM.Component
  @id: -> 'Retronator.Store.Pages.Admin.Patreon'
  @register @id()

  @importPledges: new AB.Method name: "#{@id()}.importPledges"
  @updateCurrentPledges: new AB.Method name: "#{@id()}.updateCurrentPledges"

  events: ->
    super.concat
      'click .update-current-pledges': @onClickUpdateCurrentPledges
      'submit .upload-form': @onSubmitUploadForm

  onClickUpdateCurrentPledges: (event) ->
    @constructor.updateCurrentPledges()

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
