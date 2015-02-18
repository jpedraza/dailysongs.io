//= require templates/player

var Player = function() {
  this.bindEventListeners();
};

Player.prototype = {
  volume   : 1.0,
  template : JST["templates/player"],
  elements : {
    player: document.getElementById("player")
  },

  bindEventListeners: function() {
    document.addEventListener("keydown", this.onKeyDown.bind(this), false);
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

  getOptions: function(data) {
    return {
      autoplay : true,
      buffer   : true,
      format   : "mp3",
      onend    : this.onFinish.bind(this),
      onload   : this.onLoad.bind(this),
      urls     : ["http://api.soundcloud.com/tracks/" + data.id + "/stream?client_id=" + this.client_id],
      volume   : this.volume
    };
  },

  play: function(data) {
    if (this.data && this.data.id == data.id) {
      this.toggle();

      return;
    }

    if (this.instance) {
      clearInterval(this.interval);

      this.dispatch("stop", this.data.id);
      this.instance.stop(this.id);
      this.instance.unload(this.id);
      this.instance = null;
    }

    this.data    = data;
    this.loading = true;
    this.render();
    this.dispatch("play", data.id);

    this.instance = new Howl(this.getOptions(data));
    this.instance.play(function(id) {
      this.id = id;
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

  toggle: function() {
    var method = (this.paused = !this.paused) ? "pause" : "play";

    this.instance._clearEndTimer(this.id);
    this.instance[method](this.id);
    this.dispatch(method, this.data.id);
  },

  onFinish: function() {
    this.playNext();
  },

  onKeyDown: function(event) {
    switch (event.which) {
      case 32: // Space
        if (this.instance) {
          this.toggle();
        } else {
          this.playNext();
        }

        event.preventDefault();
      break;

      case 38: // Up
        this.volume = Math.min(1.0, this.volume += 0.1);
        this.instance.volume(this.volume);

        event.preventDefault();
      break;

      case 40: // Down
        this.volume = Math.max(0.1, this.volume -= 0.1);
        this.instance.volume(this.volume);

        event.preventDefault();
      break;
    }
  },

  onLoad: function() {
    this.paused  = false;
    this.loading = false;
    this.render();
    this.interval = setInterval(this.onProgress.bind(this), 500);
  },

  onProgress: function() {
    var elements   = this.elements,
        duration   = this.data.duration,
        position   = Math.round(this.instance.pos(null, this.id)),
        remaining  = duration - position,
        percentage = (position / duration) * 100;

    elements.bar.style.width = percentage + "%";
    elements.position.innerText = this.formatTime(position);
    elements.remaining.innerText = "-" + this.formatTime(remaining);
  }
};

Player = new Player();
