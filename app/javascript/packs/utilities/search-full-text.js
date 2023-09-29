document.addEventListener('turbolinks:load', function() {
  if (!document.querySelector('.search-index')) return

  $('.search-full-text-form').on('ajax:success', function(e) {
    manageSearchResults(e.detail[0])
  }).on('ajax:error', function (e) {
    $('.search-result-list').html('')
    $('.search-result-list').append($('.server-respond-error-warning-message-template').clone(true)
      .attr('class', 'server-respond-error-warning-message'))
  })
})

function manageSearchResults(data) {
  console.log(data)
  $('.search-result-list').html('')

  var restrictedChars
  var shortQueryLengthData
  var maximumBooksCount
  var maximumAuthorsCount
  if (data.warning) {
    restrictedChars = data.warning.restricted_chars
    shortQueryLengthData = data.warning.query_length_data
  }
  if (data.warning && data.warning.maximum_results_count_data) {
    maximumBooksCount = data.warning.maximum_results_count_data.books
    maximumAuthorsCount = data.warning.maximum_results_count_data.authors
  }
  var books = data.books
  var authors = data.authors

  if (shortQueryLengthData) {
    showShortQueryWarning(shortQueryLengthData)
  } else if (restrictedChars) {
    showRestrictedCharsWarning(restrictedChars)
  } else if (books || authors) {
    manageFullTextSearchBooksAndAuthors(books, authors, maximumBooksCount, maximumAuthorsCount)
  } else {
    showNothingFoundWarning()
  }
}

function showShortQueryWarning(shortQueryLengthData) {
  $('.search-result-list').append($('.search-full-text-minimum-length-warning-message-template').clone(true)
      .attr('class', 'search-full-text-minimum-length-warning-message'))
  $('.search-full-text-minimum-length-warning-message .query-minimum-length').html(shortQueryLengthData['minimum'])
  $('.search-full-text-minimum-length-warning-message .query-maximum-length').html(shortQueryLengthData['maximum'])
  $('.search-full-text-minimum-length-warning-message .query-current-length').html(shortQueryLengthData['current'])
}

function showRestrictedCharsWarning(restrictedChars) {
  $('.search-result-list').append($('.search-full-text-restricted-chars-warning-message-template').clone(true)
      .attr('class', 'search-full-text-restricted-chars-warning-message'))
  $('.search-full-text-restricted-chars-warning-message .restricted-chars-list').html(restrictedChars)
}

function manageFullTextSearchBooksAndAuthors(books, authors, maximumBooksCount, maximumAuthorsCount) {
  if (books) { showFullTextSearchBooksResults(books) }
  if (maximumBooksCount) { showMaximumResultsCountWarning(maximumBooksCount, 'books') }
  if (authors) { showFullTextSearchAuthorsResults(authors) }
  if (maximumAuthorsCount) { showMaximumResultsCountWarning(maximumAuthorsCount, 'authors') }
}

function showFullTextSearchBooksResults(books) {
  $('.search-result-list').append($('.search-full-text-book-message-template').clone(true)
    .attr('class', 'search-full-text-book-message'))
  $('.search-result-list').append($('.search-full-text-book-header-template').clone(true)
    .attr('class', 'search-full-text-book-header'))
  var books_count = books.length
  for (var i = 0; i < books_count; i++) {
    book = books[i].book
    $('.search-result-list').append(require("../templates/searches/full_text/book.handlebars")({ book: book }))
  }
}

function showFullTextSearchAuthorsResults(authors) {
  $('.search-result-list').append($('.search-full-text-author-message-template').clone(true)
    .attr('class', 'search-full-text-author-message'))
  $('.search-result-list').append($('.search-full-text-author-header-template').clone(true)
    .attr('class', 'search-full-text-author-header'))
  var authors_count = authors.length
  for (var i = 0; i < authors_count; i++) {
    author = authors[i].author
    $('.search-result-list').append(require("../templates/searches/full_text/author.handlebars")({ author: author }))
  }
}

function showMaximumResultsCountWarning(maximumResultsCount, resource) {
  $('.search-result-list').append($('.search-full-text-maximum-results-warning-message-template').clone(true)
      .attr('class', 'search-full-text-maximum-' + resource + '-warning-message'))
  $('.search-full-text-maximum-' + resource + '-warning-message .results-count').html(maximumResultsCount)
}

function showNothingFoundWarning() {
  $('.search-result-list').append($('.search-nothing-found-warning-message-template').clone(true)
      .attr('class', 'search-nothing-found-warning-message'))
}
