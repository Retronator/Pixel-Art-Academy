AM = Artificial.Mirage
FM = FataMorgana

class FM.TabbedView extends FM.View
  # tabs: array of tabs shown in this view
  #   caption: the text identifying the tab
  #   active: true for the tab that is currently expanded
  @id: -> 'FataMorgana.TabbedView'
  @register @id()

  activeClass: ->
    tab = @currentData()
    'active' if tab.active

  activeTab: ->
    tabbedViewData = @data()

    _.find tabbedViewData.tabs, (tab) => tab.active

  events: ->
    super(arguments...).concat
      'click .tab': @onClickTab

  onClickTab: (event) ->
    clickedTab = @currentData()
    tabbedViewData = @data()

    if clickedTab.active
      # We clicked on an active tab, so we want to close it.
      clickedTab.active = false

    else
      # Switch to another tab.
      for tab in tabbedViewData.tabs
        tab.active = tab is clickedTab

    @interface.saveData()
