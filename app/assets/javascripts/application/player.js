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
    var element = this.elements.player;

    element.addEventListener("click", this.onSeek.bind(this), false);
    element.addEventListener("click", this.onPurchase.bind(this), false);

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

  formatTime: function(time) {
    var minutes = Math.floor(time / 60),
        seconds = Math.round(time % 60);

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
      urls     : ["http://api.soundcloud.com/tracks/" + data.remoteId + "/stream?client_id=" + this.client_id],
      volume   : this.volume
    };
  },

  play: function(data) {
    if (this.data && this.data.remoteId === data.remoteId) {
      this.toggle();

      return;
    }

    this.stop();
    this.data  = data;
    this.state = "loading";
    this.render();
    this.dispatch("play", data.remoteId);

    this.instance = new Howl(this.getOptions(data));
    this.instance.play(function(id) {
      this.id = id;
    }.bind(this));
  },

  render: function() {
    var element = this.elements.player;

    // Force the browser to notice the content changing to fix an issue with a
    // tip replacing the player before rendering.
    element.innerHTML = "";
    element.offsetHeight;
    element.innerHTML = this.template({
      song       : this.data,
      state      : this.state,
      formatTime : this.formatTime
    });

    this.elements = {
      bar       : element.querySelector(".bar span"),
      player    : element,
      position  : element.querySelector(".position"),
      remaining : element.querySelector(".remaining")
    };
  },

  stop: function() {
    clearInterval(this.interval);

    if (this.data) {
      this.dispatch("stop", this.data.remoteId);
      this.data = null;
    }

    if (this.instance) {
      this.instance.stop();
      this.instance.unload();
      this.instance = null;
    }
  },

  toggle: function() {
    var method = (this.paused = !this.paused) ? "pause" : "play";

    this.instance._clearEndTimer(this.id);
    this.instance[method]();
    this.dispatch(method, this.data.remoteId);
  },

  onFinish: function() {
    var all     = Array.prototype.slice.call(document.querySelectorAll("[data-remote-id]")),
        current = document.querySelector("[data-remote-id='" + (this.data ? this.data.remoteId : 0) + "']"),
        next    = all[all.indexOf(current) + 1];

    if (next) {
      this.play(next.dataset);
    } else {
      this.state = null;
      this.stop();
      this.render();
    }
  },

  onKeyDown: function(event) {
    var instance = this.instance;

    switch (event.which) {
      case 32: // Space
        var data    = this.data,
            dataset = document.querySelector(".selected").dataset;

        if (data && data.remoteId === dataset.remoteId) {
          this.toggle();
        } else {
          this.play(dataset);
        }

        event.preventDefault();
      break;

      case 38: // Up
      case 40: // Down
        if (!instance) {
          break;
        }

        if (event.which === 38) {
          this.volume = Math.min(1.0, this.volume += 0.1);
        } else {
          this.volume = Math.max(0.1, this.volume -= 0.1);
        }

        instance.volume(this.volume);

        event.preventDefault();
      break;

      case 77: // M
        if (!instance || this.paused) {
          break;
        }

        this.muted = !this.muted;

        // Globally mute and unmute so it's consistent between songs.
        Howler[this.muted ? "mute" : "unmute"]();

        // Restore volume when unmuting as Howler will default to zero when
        // creating a song while globally muted.
        if (!this.muted) {
          instance.volume(this.volume);
        }
      break;
    }
  },

  onLoad: function() {
    this.state  = "playing";
    this.paused = false;
    this.render();
    this.interval = setInterval(this.onProgress.bind(this), 500);
  },

  onProgress: function(position) {
    position = position || Math.round(this.instance.pos());

    var elements   = this.elements,
        duration   = this.data.duration,
        remaining  = duration - position,
        percentage = (position / duration) * 100;

    elements.bar.style.width = percentage + "%";
    elements.position.innerText = this.formatTime(position);
    elements.remaining.innerText = "-" + this.formatTime(remaining);
  },

  onPurchase: function(event) {
    var target = event.srcElement;

    if (target.nodeName !== "A" || target.parentNode.className !== "purchase") {
      return;
    }

    if (window.ga) {
      ga("send", "event", "buy", "click", this.data.purchaseType);
    }
  },

  onSeek: function(event) {
    var bar    = this.elements.bar,
        target = event.srcElement;

    if (!this.instance || !bar || target !== bar && target !== bar.parentNode) {
      return;
    }

    var offset   = event.offsetX / bar.parentNode.offsetWidth,
        position = this.data.duration * offset;

    this.instance.pos(position);
    this.onProgress(position);
  }
};

Player = new Player();
