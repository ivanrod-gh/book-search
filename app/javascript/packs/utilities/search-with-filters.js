import { assignClickListenersToFiltersButtons } from "./search-type-selector.js"

document.addEventListener('turbolinks:load', function() {
  if (!document.querySelector('.searches-show-variants')) return

  prepareSearchWithFiltersForm()

  $('.paginate-area').on('ajax:success', function(e) {
    managePagination(e.detail[0])
  }).on('ajax:error', function (e) {
    $('.search-result-list').html('')
    $('.paginate-links-list').html('')
    $('.search-result-list').append($('.server-respond-error-warning-message-template').clone(true)
      .attr('class', 'server-respond-error-warning-message'))
  })

  $('.old-search-area').on('ajax:success', function(e) {
    manageOldSearch(e.detail[0])
  })
})

function prepareSearchWithFiltersForm() {
  cloneSearchWithFiltersForm()
  assignAjajListenerToSearchWithFiltersForm()
  assignClickListenersToFiltersButtons()
}
  
function cloneSearchWithFiltersForm() {
  $('.search-with-filters-form-area').html($('.search-with-filters-form-template').clone(true, true)
    .attr('class', 'search-with-filters-form'))
}

function assignAjajListenerToSearchWithFiltersForm() {
  $('.search-with-filters-form').on('ajax:success', function(e) {
    manageSearchResults(e.detail[0])
  }).on('ajax:error', function (e) {
    $('.search-result-list').html('')
    $('.paginate-links-list').html('')
    $('.search-result-list').append($('.server-respond-error-warning-message-template').clone(true)
      .attr('class', 'server-respond-error-warning-message'))
  })
}

function manageSearchResults(data) {
  $('.search-result-list').html('')
  $('.paginate-links-list').html('')

  if (data.books) {
    showBooks(data)
    manageInitialPaginator(data)
    addUserBooksListeners()
    prepareOldSearchSelector(data)
  } else {
    showNothingFoundWarning()
  }
}

function showBooks(data) {
  var books = data.books
  $('.search-result-list').append($('.search-with-filters-book-header-template').clone(true)
    .attr('class', 'search-with-filters-book-header'))
  var books_count = books.length
  var genreSelected
  if (!$('.search-select-filter-button[data-search-filter="search-filter-genre-int-id"]').hasClass('search-view-item-selected')) {
    var genreSelected = 1
  }
  var dates = []
  for (var i = 0; i < books_count; i++) {
    var book = books[i].book
    
    if (genreSelected) {
      book['genre_names'] = extractGenreNames(book)
    }

    var date_added = book.date.split('T')[0]
    if (!dates.includes(date_added)) {
      $('.search-result-list').append($('.book-date-added-data-message-template').clone(true)
        .attr('class', 'book-date-added-data-message-' + date_added))
      $('.book-date-added-data-message-' + date_added + ' .date-added').html(date_added)
      dates.push(date_added)
    }
    if (data.user.id) {
      showBookForAuthorizedUser(data, book)
    } else {
      $('.search-result-list').append(require("../templates/searches/with_filters/book_unauthorized.handlebars")({ book: book }))
    }
  }
}
function extractGenreNames(book) {
  var genre_names = []
  for (var i = 0; i < book.genres.length; i++) {
    genre_names.push(book.genres[i].name)
  }
  return genre_names.join(', ')
}

function showBookForAuthorizedUser(data, book) {
  if (data.user.book_ids.includes(book.id)) {
    $('.search-result-list').append(require("../templates/searches/with_filters/book_authorized.handlebars")({ book: book, user_id: data.user.id, button_remove: true }))
  } else {
    $('.search-result-list').append(require("../templates/searches/with_filters/book_authorized.handlebars")({ book: book, user_id: data.user.id, button_add: true }))
  }
}

function manageInitialPaginator(data) {
  var query = generateSearchQuery(data)
  $('.paginate-data').attr('search-query', query)
  $('.paginate-data').attr('search-results-count', data.results.count)
  $('.paginate-data').attr('search-results-per-page', data.results.per_page)

  createPaginator(0, data.results.count, data.results.per_page, query)
}

function generateSearchQuery(data) {
  var query = '/searches/with_filters?'
  jQuery.each(data.params, function (name, value) {
    if (name === 'page') { return }
    query = query + name + '=' + value + '&'
  })

  return query
}

function createPaginator(currentPageIndex, resultsCount, resultsPerPage, query) {
  var lastPageIndex = Math.ceil(resultsCount / resultsPerPage) - 1
  var minimumPageIndex = currentPageIndex - 4
  if (minimumPageIndex < 0 ) {
    minimumPageIndex = 0
  }
  var maximumPageIndex = currentPageIndex + 4
  if (maximumPageIndex > lastPageIndex) {
    maximumPageIndex = lastPageIndex
  }

  if (minimumPageIndex != 0) {
    $('.paginate-links-list').append(require("../templates/shared/search_page_link.handlebars")
      ({ query: query + 'page=0', page_text: 1 }))
    $('.paginate-links-list').append('<span>..</span>')
  }
  var markCurrentPage
  for (var i = minimumPageIndex; i <= maximumPageIndex; i++) {
    if (currentPageIndex === i) {
      markCurrentPage = true
    } else {
      markCurrentPage = null
    }
    $('.paginate-links-list').append(require("../templates/shared/search_page_link.handlebars")
      ({ query: query + 'page=' + i, page_text: i + 1, markCurrentPage: markCurrentPage }))
  }
  if (maximumPageIndex != lastPageIndex) {
    $('.paginate-links-list').append('<span>..</span>')
    $('.paginate-links-list').append(require("../templates/shared/search_page_link.handlebars")
      ({ query: query + 'page=' + lastPageIndex, page_text: lastPageIndex + 1 }))
  }
}

function addUserBooksListeners() {
  $('.user-book-buttons-area').on('ajax:success', function(e) {
    manageUserBook(e.detail[0], this)
  })
}

function prepareOldSearchSelector(data) {
  if (data.user.searches_updated_at_and_id) {
    $('.old-search-area select').html(require("../templates/searches/with_filters/search_selector_values.handlebars")({ searches_updated_at_and_id: data.user.searches_updated_at_and_id }))
  }
}

function manageUserBook(data, buttonsArea) {
  if (data.maximum_books_count) {
    alert(data.maximum_books_count[0])
  } else if (data.persisted) {
    $(buttonsArea).find('.button-add').addClass('hide')
    $(buttonsArea).find('.button-remove').removeClass('hide')
  } else {
    $(buttonsArea).find('.button-add').removeClass('hide')
    $(buttonsArea).find('.button-remove').addClass('hide')
  }
}

function showNothingFoundWarning() {
  $('.search-result-list').append($('.search-nothing-found-warning-message-template').clone(true)
      .attr('class', 'search-nothing-found-warning-message'))
}

function managePagination(data) {
  $('.search-result-list').html('')
  $('.paginate-links-list').html('')
  if (data.books) {
    showBooks(data)
    manageDataAttributePaginator(data)
    addUserBooksListeners()
  } else {
    showNothingFoundWarning()
  }
}

function manageDataAttributePaginator(data) {
  var currentPageIndex = parseInt(data.params.page)
  var resultsCount = $('.paginate-data').attr('search-results-count')
  var resultsPerPage = $('.paginate-data').attr('search-results-per-page')
  var query = $('.paginate-data').attr('search-query')

  createPaginator(currentPageIndex, resultsCount, resultsPerPage, query)
}

function manageOldSearch(data) {
  var search = data.search

  if (!search) return

  prepareSearchWithFiltersForm()

  if (search.genre_filter) { assignGenreFilter(search) }
  if (search.start_date_filter) { assignStartDateFilter(search) }
  if (search.end_date_filter) { assignEndDateFilter(search) }
  if (search.rating_litres_average_filter) { assignRatingLitresAverageFilter(search) }
  if (search.rating_litres_votes_count_filter) { assignRatingLitresVotesCountFilter(search) }
  if (search.rating_livelib_average_filter) { assignRatingLivelibAverageFilter(search) }
  if (search.rating_livelib_votes_count_filter) { assignRatingLivelibVotesCountFilter(search) }
  if (search.writing_year_filter) { assignWritingYearFilter(search) }
  if (search.pages_count_filter) { assignPagesCountFilter(search) }
  if (search.comments_count_filter) { assignCommentsCountFilter(search) }
}

function assignGenreFilter(search) {
  $('.search-select-filter-button[data-search-filter="search-filter-genre-int-id"]')[0].click()
  if (search.genre_int_id) {
    $('.search-filter-genre-int-id select').val(search.genre_int_id)
  }
}

function assignStartDateFilter(search) {
  $('.search-select-filter-button[data-search-filter-item="search-filter-start-date-added"]')[0].click()
  if (search.start_date_added_1i) {
    $('.search-filter-start-date-added select#_start_date_added_1i').val(search.start_date_added_1i)
  }
  if (search.start_date_added_2i) {
    $('.search-filter-start-date-added select#_start_date_added_2i').val(search.start_date_added_2i)
  }
}

function assignEndDateFilter(search) {
  $('.search-select-filter-button[data-search-filter-item="search-filter-end-date-added"]')[0].click()
  if (search.end_date_added_1i) {
    $('.search-filter-end-date-added select#_end_date_added_1i').val(search.end_date_added_1i)
  }
  if (search.end_date_added_2i) {
    $('.search-filter-end-date-added select#_end_date_added_2i').val(search.end_date_added_2i)
  }
}

function assignRatingLitresAverageFilter(search) {
  $('.search-select-filter-button[data-search-filter-item="search-filter-rating-litres-average"]')[0].click()
  if (search.rating_litres_average) {
    $('.search-filter-rating-litres-average input').val(search.rating_litres_average)
  }
}

function assignRatingLitresVotesCountFilter(search) {
  $('.search-select-filter-button[data-search-filter-item="search-filter-rating-litres-votes-count"]')[0].click()
  if (search.rating_litres_votes_count) {
    $('.search-filter-rating-litres-votes-count input').val(search.rating_litres_votes_count)
  }
}

function assignRatingLivelibAverageFilter(search) {
  $('.search-select-filter-button[data-search-filter-item="search-filter-rating-livelib-average"]')[0].click()
  if (search.rating_livelib_average) {
    $('.search-filter-rating-livelib-average input').val(search.rating_livelib_average)
  }
}

function assignRatingLivelibVotesCountFilter(search) {
  $('.search-select-filter-button[data-search-filter-item="search-filter-rating-livelib-votes-count"]')[0].click()
  if (search.rating_livelib_votes_count) {
    $('.search-filter-rating-livelib-votes-count input').val(search.rating_livelib_votes_count)
  }
}

function assignWritingYearFilter(search) {
  $('.search-select-filter-button[data-search-filter="search-filter-writing-year"]')[0].click()
  if (search.writing_year) {
    $('.search-filter-writing-year input').val(search.writing_year)
  }
}

function assignPagesCountFilter(search) {
  $('.search-select-filter-button[data-search-filter="search-filter-pages-count"]')[0].click()
  if (search.pages_count) {
    $('.search-filter-pages-count input').val(search.pages_count)
  }
}

function assignCommentsCountFilter(search) {
  $('.search-select-filter-button[data-search-filter="search-filter-comments-count"]')[0].click()
  if (search.comments_count) {
    $('.search-filter-comments-count input').val(search.comments_count)
  }
}
