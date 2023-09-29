document.addEventListener('turbolinks:load', function() {
  if (!document.querySelector('.search-index')) return

  $('.search-with-filters-form').on('ajax:success', function(e) {
    manageSearchResults(e.detail[0])
  }).on('ajax:error', function (e) {
    $('.search-result-list').html('')
    $('.paginate-links-list').html('')
    $('.search-result-list').append($('.server-respond-error-warning-message-template').clone(true)
      .attr('class', 'server-respond-error-warning-message'))
  })

  $('.paginate-area').on('ajax:success', function(e) {
    managePagination(e.detail[0])
  }).on('ajax:error', function (e) {
    $('.search-result-list').html('')
    $('.paginate-links-list').html('')
    $('.search-result-list').append($('.server-respond-error-warning-message-template').clone(true)
      .attr('class', 'server-respond-error-warning-message'))
  })
})

function manageSearchResults(data) {
  console.log(data)
  $('.search-result-list').html('')
  $('.paginate-links-list').html('')

  var books = data.books
  if (books) {
    showBooks(books)
    manageInitialPaginator(data)
  } else {
    showNothingFoundWarning()
  }
}

function showBooks(books) {
  $('.search-result-list').append($('.search-with-filters-book-header-template').clone(true)
    .attr('class', 'search-with-filters-book-header'))
  var books_count = books.length
  var genreSelected
  if (!$('.search-select-filter-genre-button').hasClass('search-view-item-selected')) {
    var genreSelected = 1
  }
  var dates = []
  for (var i = 0; i < books_count; i++) {
    book = books[i].book
    
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

    $('.search-result-list').append(require("../templates/searches/with_filters/book.handlebars")({ book: book }))
  }
}

function extractGenreNames(book) {
  var genre_names = []
  for (var i = 0; i < book.genres.length; i++) {
    genre_names.push(book.genres[i].name)
  }
  return genre_names.join(', ')
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
    $('.paginate-links-list').append(require("../templates/searches/with_filters/page_link.handlebars")
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
    $('.paginate-links-list').append(require("../templates/searches/with_filters/page_link.handlebars")
      ({ query: query + 'page=' + i, page_text: i + 1, markCurrentPage: markCurrentPage }))
  }
  if (maximumPageIndex != lastPageIndex) {
    $('.paginate-links-list').append('<span>..</span>')
    $('.paginate-links-list').append(require("../templates/searches/with_filters/page_link.handlebars")
      ({ query: query + 'page=' + lastPageIndex, page_text: lastPageIndex + 1 }))
  }
}

function showNothingFoundWarning() {
  $('.search-result-list').append($('.search-nothing-found-warning-message-template').clone(true)
      .attr('class', 'search-nothing-found-warning-message'))
}

function managePagination(data) {
  console.log(data)

  $('.search-result-list').html('')
  $('.paginate-links-list').html('')
  var books = data.books
  if (books) {
    showBooks(books)
    manageDataAttributePaginator(data)
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
