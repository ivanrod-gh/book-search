document.addEventListener('turbolinks:load', function() {
  if (!document.querySelector('.searches-show-variants')) return

  document.querySelector('.warning-main').addEventListener('click', showWarning)
  document.querySelector('.warning-main').addEventListener('click', hideWarning)
})

function showWarning(event) {
  if (event.target.className != "warning-show-message-link") return
  event.preventDefault()

  this.querySelector('.warning-message').classList.remove('hide')
  this.querySelector('.warning-show-message-holder').classList.add('hide')
  this.querySelector('.warning-hide-message-holder').classList.remove('hide')
}

function hideWarning(event) {
  if (event.target.className != "warning-hide-message-link") return
  event.preventDefault()

  this.querySelector('.warning-message').classList.add('hide')
  this.querySelector('.warning-show-message-holder').classList.remove('hide')
  this.querySelector('.warning-hide-message-holder').classList.add('hide')
}
