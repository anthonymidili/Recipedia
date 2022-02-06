window.clearNotifications = {
  poll: function() {
    return setTimeout(this.markAsRead, 10000);
  },
  markAsRead: function() {
    return Rails.ajax({
      type: 'PATCH',
      url: '/notifications/mark_as_read.js'
    });
  }
};

document.addEventListener('turbo:load', function() {
  var notifications;
  notifications = document.getElementById('notifications');
  if (notifications) {
    return clearNotifications.poll();
  }
});
