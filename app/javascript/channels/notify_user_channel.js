import consumer from "./consumer"

consumer.subscriptions.create("NotifyUserChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    // Update notification bell unread count.
    $("#unread_count").text(data.unread_notifications_count);

    // Perform when clearing notifications.
    if (data.clear_notifications == true) {
      $("li").removeClass("is_read_false");
    }
  }
});
