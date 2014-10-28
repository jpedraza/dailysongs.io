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
  template: JST["templates/player"],
  elements: {
    player: document.getElementById("player")
  },

  bindEventListeners: function() {
    document.addEventListener("keypress", this.onKeyPress.bind(this), false);
  },

  dispatch: function(name, id) {
    var event = new CustomEvent(name, {
      detail: {
        id: id
      }
    });

    document.dispatchEvent(event);
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

    if (this.instance) {
      this.dispatch("stop", this.data.id);
      this.instance.destruct();
      this.instance = null;
    }

    this.data    = data;
    this.loading = true;
    this.render();
    this.dispatch("play", data.id);

    SC.stream("/tracks/" + data.id, this.options, function(player) {
      this.instance = player.play();
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
    var element = this.elements.player;

    element.innerHTML = this.template({
      song     : this.data,
      loading  : this.loading,
      duration : this.formatTime(this.data.duration)
    });

    this.elements = {
      bar       : element.querySelector(".bar span"),
      player    : element,
      position  : element.querySelector(".position"),
      remaining : element.querySelector(".remaining")
    };
  },

  onFinish: function() {
    this.playNext();
  },

  onKeyPress: function(event) {
    switch (event.which) {
      case 32: // Space
        var instance = this.instance;

        if (instance) {
          instance.togglePause();

          this.dispatch(instance.paused ? "pause" : "play", this.data.id);
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
    var duration   = this.data.duration,
        position   = Math.round(this.instance.position / 1000),
        remaining  = duration - position,
        percentage = (position / duration) * 100;

    this.elements.bar.style.width = percentage + "%";
    this.elements.position.innerText = this.formatTime(position);
    this.elements.remaining.innerText = "-" + this.formatTime(remaining);
  }
};

Player = new Player();
