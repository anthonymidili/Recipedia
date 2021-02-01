global.clearNotifications =
  poll: ->
    setTimeout @markAsRead, 20000

  markAsRead: ->
    Rails.ajax
      type: 'PATCH'
      url: '/notifications/mark_as_read.js'

document.addEventListener 'turbolinks:load', ->
  notifications = document.getElementById('notifications')
  if (notifications)
    clearNotifications.poll()
