clearNotifications =
  poll: ->
    setTimeout @markAsRead, 10000

  markAsRead: ->
    Rails.ajax
      url: '/notifications/mark_as_read.js'
      type: 'patch'

document.addEventListener 'turbolinks:load', ->
  if $('#unread_notifications').length > 0
    clearNotifications.poll()
