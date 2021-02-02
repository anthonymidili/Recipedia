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
    $("#unread_count").text(data["unread_notifications_count"]);

    // Perform when notifying user.
    const notification_partial = data["notification_partial"];
    if (notification_partial) {
      $("#unread_notifications").show();
      $("#unread_notifications_list").prepend(notification_partial);
    }
  }
});
