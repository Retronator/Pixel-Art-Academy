AM = Artificial.Mirage
AB = Artificial.Babel
RS = Retronator.Store

class RS.Pages.Admin.ItemKeys extends AM.Component
  @register 'Retronator.Store.Pages.Admin.ItemKeys'

  onCreated: ->
    RS.Item.all.subscribe @
    
    @itemKeysOverview = new ReactiveField []
    
    Meteor.call 'Retronator.Store.itemKeysOverview', (error, result) =>
      @itemKeysOverview result
    
  items: ->
    RS.Item.documents.fetch
      isKey: true

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
