import consumer from "./consumer"

consumer.subscriptions.create("MarkAsReadChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    $("#unread_count").text(data["unread_notifications_count"]);
    const els = document.querySelectorAll('.is_read_false')
    for (const el of [...els]) {
      el.classList.add("is_read_true");
      el.classList.remove("is_read_false");
    };
  }
});
