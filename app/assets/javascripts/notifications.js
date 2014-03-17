$(".notification").on("click", function(event) {
  var target_url = $(event.currentTarget).data("target-url");
  var notification_id = $(event.currentTarget).data("id");

  $.ajax("/notifications/"+notification_id, {
    type: "POST",
    data: { "_method": "delete" }
    });

  if (target_url === "#") {
    location.reload();
  } else {
    window.location.href = target_url;
  }
});