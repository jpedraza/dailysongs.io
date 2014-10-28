var Songs = {
  initialize: function() {
    this.bindEventListeners();
  },

  bindEventListeners: function() {
    document.addEventListener("click", this.onClick.bind(this), false);
  },

  onClick: function(event) {
    var target = event.target;
        id     = target && target.getAttribute("data-id");

    if (!id) {
      return;
    }

    Player.play(target.dataset);

    event.preventDefault();
  }
};
