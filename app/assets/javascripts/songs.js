var Songs = {
  paths: {
    play  : "M4 4 L28 16 L4 28 z",
    pause : "M4 4 H12 V28 H4 z M20 4 H28 V28 H20 z"
  },

  initialize: function() {
    this.bindEventListeners();
  },

  bindEventListeners: function() {
    document.addEventListener("click", this.onClick.bind(this), false);
    document.addEventListener("pause", this.onPause.bind(this), false);
    document.addEventListener("play",  this.onPlay.bind(this),  false);
    document.addEventListener("stop",  this.onStop.bind(this),  false);
  },

  setState: function(id, state, active) {
    var element = document.querySelector("[data-id='" + id + "']"),
        path    = element.querySelector("path");

    path.setAttribute("d", this.paths[state]);
    element.classList[active ? "add" : "remove"]("active");
  },

  onClick: function(event) {
    var target = event.target;
        id     = target && target.getAttribute("data-id");

    if (!id) {
      return;
    }

    Player.play(target.dataset);

    event.preventDefault();
  },

  onPause: function(event) {
    this.setState(event.detail.id, "play", true);
  },

  onPlay: function(event) {
    this.setState(event.detail.id, "pause", true);
  },

  onStop: function(event) {
    this.setState(event.detail.id, "play", false);
  }
};
