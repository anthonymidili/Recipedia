global.setUnreadCount =
  poll: ->
    setTimeout @updateCount, 20000

  updateCount: ->
    Rails.ajax
      url: '/notifications/unread_count.js'
      type: 'get'

jQuery ->
  if $('#unread_count').length > 0
    setUnreadCount.poll()

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
