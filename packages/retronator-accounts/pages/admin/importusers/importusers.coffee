AM = Artificial.Mirage
RA = Retronator.Accounts

class RA.Pages.Admin.ImportUsers extends AM.Component
  @register 'Retronator.Accounts.Pages.Admin.ImportUsers'
  
  # TODO: Upgrade to Retronator Accounts.

  onCreated: ->
    Meteor.subscribe 'LandsOfIllusions.Accounts.RewardTier.all'
  
  rewards: ->
    return
    LOI.Accounts.RewardTier.documents.find()

  events: ->
    super.concat
      'submit .upload-form': @onSubmitUploadForm

  onSubmitUploadForm: (event) ->
    event.preventDefault()

    rewardTierId = @$('.reward-tier').val() or null
    csvFile = @$('.csv-file')[0].files[0]
    manualList = @$('.manual-input').val()
    manualType = $('.manual-type').val()
    passphrase = @$('.passphrase').val()

    submitData = (data) ->
      encryptedData = CryptoJS.AES.encrypt(data, passphrase).toString()
      Meteor.call 'Retronator.Accounts.importUsers', rewardTierId, encryptedData

    if manualList.length
      submitData "HEADER#{manualType}\n#{manualList}"

    else
      reader = new FileReader()

      reader.onload = (event) ->
        submitData "HEADER#{event.target.result}"

      reader.readAsText csvFile
