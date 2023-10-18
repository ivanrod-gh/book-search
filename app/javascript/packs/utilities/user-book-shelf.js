document.addEventListener('turbolinks:load', function() {
  if (!document.querySelector('.users-books-shelf')) return

  $('.show-books-button-area').on('ajax:success', function(e) {
    manageUserBooks(e.detail[0])
  })

  $('.paginate-area').on('ajax:success', function(e) {
    managePagination(e.detail[0])
  })


  $('.user-books-destroy-all-link-area').on('ajax:success', function(e) {
    manageDestoyAllUserBooks(e.detail[0])
  })

  $('.show-books-button-area a')[0].click()
})

function manageUserBooks(data) {
  $('.user-books-list').html('')
  $('.paginate-links-list').html('')

  if (data.books) {
    showBooks(data)
    managePaginator(data)
    addUserBooksListeners()
  } else {
    showNothingFoundWarning()
  }
}

function showBooks(data) {
  var books = data.books
  $('.user-books-list').append($('.user-books-header-template').clone(true)
    .attr('class', 'user-books-header'))
  var books_count = books.length
  for (var i = 0; i < books_count; i++) {
    book = books[i].book
    book['genre_names'] = extractGenreNames(book)
    $('.user-books-list').append(require("../templates/user_books/book.handlebars")({ book: book, user_id: data.user.id }))
  }
}

function extractGenreNames(book) {
  var genre_names = []
  for (var i = 0; i < book.genres.length; i++) {
    genre_names.push(book.genres[i].name)
  }
  return genre_names.join(', ')
}

function managePaginator(data) {
  var query = '/users/books_show?'
  var page
  if (data.params.page) {
    page = data.params.page
  } else {
    page = 0
  }
  createPaginator(page, data.results.count, data.results.per_page, query)
}

function createPaginator(currentPageIndex, resultsCount, resultsPerPage, query) {
  var lastPageIndex = Math.ceil(resultsCount / resultsPerPage) - 1
  var markCurrentPage

  for (var i = 0; i <= lastPageIndex; i++) {
    if (currentPageIndex === i) {
      markCurrentPage = true
    } else {
      markCurrentPage = null
    }
    $('.paginate-links-list').append(require("../templates/shared/search_page_link.handlebars")
      ({ query: query + 'page=' + i, page_text: i + 1, markCurrentPage: markCurrentPage }))
  }
}

function managePagination(data) {
  $('.user-books-list').html('')
  $('.paginate-links-list').html('')
  if (data.books) {
    showBooks(data)
    managePaginator(data)
    addUserBooksListeners()
  } else {
    showNothingFoundWarning()
  }
}

function addUserBooksListeners() {
  $('.user-book').on('ajax:success', function(e) {
    manageUserBook(e.detail[0], this)
  })
}

function manageUserBook(data, userBook) {
  if (!data.persisted) {
    userBook.remove()
  }
  if ($('.user-book').length == 0) {
    manageBooksAtPageRunOut()
  }
}

function manageBooksAtPageRunOut() {
  var page_link = $('.to-page-link.search-view-item-selected')
  if (page_link) {
    page_link[0].click()
  } else {
    $('.show-books-button-area a')[0].click()
  }
}

function showNothingFoundWarning() {
  $('.user-books-list').append($('.user-books-nothing-found-warning-message-template').clone(true)
    .attr('class', 'user-books-nothing-found-warning-message'))
}

function manageDestoyAllUserBooks(data) {
  if (data.all_destroyed) {
    $('.show-books-button-area a')[0].click()
  }
}
