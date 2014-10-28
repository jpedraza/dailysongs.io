//= require templates/player

var Player = function() {
  this.options = {
    autoLoad     : true,
    autoPlay     : false,
    onload       : this.onLoad.bind(this),
    onfinish     : this.onFinish.bind(this),
    whileplaying : this.onProgress.bind(this)
  };

  this.bindEventListeners();
};

Player.prototype = {
  element  : document.getElementById("player"),
  template : JST["templates/player"],

  bindEventListeners: function() {
    document.addEventListener("keypress", this.onKeyPress.bind(this), false);
  },

  formatTime: function(seconds) {
    var minutes = Math.floor(seconds / 60),
        seconds = Math.round(seconds % 60);

    if (seconds < 10) {
      seconds = "0" + seconds;
    }

    return [minutes, seconds].join(":");
  },

  play: function(data) {
    if (this.data && this.data.id == data.id) {
      return;
    }

    if (this.player) {
      this.player.destruct();
      this.player = null;
    }

    this.data    = data;
    this.loading = true;
    this.render();

    SC.stream("/tracks/" + data.id, this.options, function(player) {
      this.player = player.play();
    }.bind(this));
  },

  playNext: function() {
    var all     = Array.prototype.slice.call(document.querySelectorAll("[data-id]")),
        current = document.querySelector("[data-id='" + (this.data ? this.data.id : 0) + "']"),
        next    = all[all.indexOf(current) + 1];

    if (next) {
      this.play(next.dataset);
    }
  },

  render: function() {
    this.element.innerHTML = this.template({
      song     : this.data,
      loading  : this.loading,
      duration : this.formatTime(this.data.duration)
    });
  },

  onFinish: function() {
    this.playNext();
  },

  onKeyPress: function(event) {
    switch (event.which) {
      case 32: // Space
        if (this.player) {
          this.player.togglePause();
        } else {
          this.playNext();
        }

        event.preventDefault();
      break;
    }
  },

  onLoad: function() {
    this.loading = false;
    this.render();
  },

  onProgress: function() {
    var bar      = this.element.querySelector(".bar span"),
        time     = this.time || this.element.querySelector(".time"),
        position = Math.round(this.player.position / 1000);

    bar.style.width = ((position / this.data.duration) * 100) + "%";
    time.innerText = this.formatTime(position);
  }
};

Player = new Player();
