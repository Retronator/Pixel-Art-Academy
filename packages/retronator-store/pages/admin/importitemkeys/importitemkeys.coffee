AM = Artificial.Mirage
AB = Artificial.Babel
RS = Retronator.Store

class RS.Pages.Admin.ImportItemKeys extends AM.Component
  @register 'Retronator.Store.Pages.Admin.ImportItemKeys'

  onCreated: ->
    RS.Item.all.subscribe @
    
  items: ->
    RS.Item.documents.fetch
      catalogKey: /key/i

  events: ->
    super(arguments...).concat
      'submit .upload-form': @onSubmitUploadForm

  onSubmitUploadForm: (event) ->
    event.preventDefault()

    textFile = @$('.text-file')[0].files[0]
    manualList = @$('.manual-input').val()
    itemId = @$('.item').val()
    passphrase = @$('.passphrase').val()

    submitData = (data) ->
      encryptedData = CryptoJS.AES.encrypt("HEADER#{data}", passphrase).toString()
      Meteor.call 'Retronator.Store.importItemKeys', itemId, encryptedData

    if manualList.length
      submitData manualList

    else
      reader = new FileReader()

      reader.onload = (event) ->
        submitData event.target.result

      reader.readAsText textFile
