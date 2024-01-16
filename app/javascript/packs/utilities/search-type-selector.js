document.addEventListener('turbolinks:load', function() {
  if (!document.querySelector('.searches-show-variants')) return

  document.querySelector('.search-with-filters-button-area').addEventListener('click', showSearchWithFiltersControlPanel)
  document.querySelector('.search-full-text-button-area').addEventListener('click', showSearchFullTextControlPanel)
})

function showSearchWithFiltersControlPanel(event) {
  document.querySelector('.search-result-list').innerHTML = ''
  document.querySelector('.paginate-links-list').innerHTML = ''

  document.querySelector('.search-with-filters-form').classList.remove('hide')
  if (document.querySelector('.old-search-area')) {
    document.querySelector('.old-search-area').classList.remove('hide')
  }
  document.querySelector('.search-with-filters-button-area').classList.add('search-view-item-selected')

  document.querySelector('.search-full-text-form').classList.add('hide')
  document.querySelector('.search-full-text-button-area').classList.remove('search-view-item-selected')
}

function showSearchFullTextControlPanel(event) {
  document.querySelector('.search-result-list').innerHTML = ''
  document.querySelector('.paginate-links-list').innerHTML = ''
  
  document.querySelector('.search-full-text-form').classList.remove('hide')
  if (document.querySelector('.old-search-area')) {
    document.querySelector('.old-search-area').classList.add('hide')
  }
  document.querySelector('.search-full-text-button-area').classList.add('search-view-item-selected')
  
  document.querySelector('.search-with-filters-form').classList.add('hide')
  document.querySelector('.search-with-filters-button-area').classList.remove('search-view-item-selected')
}

export function assignClickListenersToFiltersButtons() {
  var searchFilterButtons = [].slice.call(document.querySelectorAll('.search-with-filters-form .search-select-filter-button'))
  for (var i = 0; i < searchFilterButtons.length; i++) {
    searchFilterButtons[i].addEventListener('click', swichSelectedSearchFilter)
  }
}

function swichSelectedSearchFilter(event) {
  var filter = this.dataset.searchFilter
  var filterItem = this.dataset.searchFilterItem
  if (this.classList.contains('search-view-item-selected')) {
    hideFilter(this, filter, filterItem)
    this.querySelector('input').value = 0
  } else {
    showFilter(this, filter, filterItem)
    this.querySelector('input').value = 1
  }
}

function showFilter(thisElement, filter, filterItem) {
  thisElement.classList.add('search-view-item-selected')
  document.querySelector('.' + filter).classList.remove('hide')
  if (filterItem) {
    document.querySelector('.' + filterItem).classList.remove('hide')
  }
  var filterSelectedItemsCounter = document.querySelector('.' + filter).dataset.searchFilterSelectedItemsCounter
  if (filterSelectedItemsCounter) {
    document.querySelector('.' + filter).dataset.searchFilterSelectedItemsCounter = parseInt(filterSelectedItemsCounter) + 1
  } else {
    document.querySelector('.' + filter).dataset.searchFilterSelectedItemsCounter = '1'
  }
}

function hideFilter(thisElement, filter, filterItem) {
  thisElement.classList.remove('search-view-item-selected')
  if (filterItem) {
    document.querySelector('.' + filterItem).classList.add('hide')
  } else {
    document.querySelector('.' + filter).classList.add('hide')
  }
  
  var filterSelectedItemsCounter = document.querySelector('.' + filter).dataset.searchFilterSelectedItemsCounter
  if (filterSelectedItemsCounter) {
    manageFilterCounter(filterSelectedItemsCounter, filter)
  }
}

function manageFilterCounter(filterSelectedItemsCounter, filter) {
  filterSelectedItemsCounter -= 1
  document.querySelector('.' + filter).dataset.searchFilterSelectedItemsCounter = filterSelectedItemsCounter
  if (filterSelectedItemsCounter === 0) {
    document.querySelector('.' + filter).classList.add('hide')
  }
}
