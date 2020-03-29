clearNotifications =
  poll: ->
    setTimeout @markAsRead, 10000

  markAsRead: ->
    Rails.ajax
      url: '/notifications/mark_as_read.js'
      type: 'patch'

global.setUnreadCount =
  setCount: (count) ->
    if count > 0
      $('#unread_count').show()
      $('#unread_count').text(count)
    else
      $('#unread_count').hide()
    @poll()

  poll: ->
    setTimeout @updateCount, 10000

  updateCount: ->
    Rails.ajax
      url: '/notifications/unread_count.js'
      type: 'get'

document.addEventListener 'turbolinks:load', ->
  if $('#unread_notifications').length > 0
    clearNotifications.poll()

  if $('#unread_count').length > 0
    setUnreadCount.setCount($('#unread_count').data('unread-count'))
