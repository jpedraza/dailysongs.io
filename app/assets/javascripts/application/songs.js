var Songs = {
  elements : {
    content: document.querySelector("#content")
  },
  paths : {
    play  : "M4 4 L28 16 L4 28 z",
    pause : "M4 4 H12 V28 H4 z M20 4 H28 V28 H20 z"
  },

  initialize: function() {
    this.bindEventListeners();
  },

  bindEventListeners: function() {
    document.addEventListener("click",   this.onClick.bind(this),   false);
    document.addEventListener("keydown", this.onKeyDown.bind(this), false);
    document.addEventListener("pause",   this.onPause.bind(this),   false);
    document.addEventListener("play",    this.onPlay.bind(this),    false);
    document.addEventListener("scroll",  this.onScroll.bind(this),  false);
    document.addEventListener("stop",    this.onStop.bind(this),    false);
  },

  setPosition: function(offset) {
    var content  = document.querySelector("#content"),
        all      = Array.prototype.slice.call(content.querySelectorAll("[data-remote-id]")),
        current  = content.querySelector(".selected"),
        next     = all[all.indexOf(current) + offset];

    if (!next) {
      return;
    }

    if (current) {
      current.classList.remove("selected");
    }

    next.classList.add("selected");

    var height    = window.innerHeight,
        padding   = 64,
        rectangle = next.getBoundingClientRect();

    if (rectangle.bottom + padding > height) {
      window.scrollBy(0, rectangle.bottom - height + padding);
    } else if (rectangle.top - padding < 0) {
      window.scrollBy(0, rectangle.top - padding);
    }
  },

  setState: function(id, state, active) {
    var element = document.querySelector("[data-remote-id='" + id + "']"),
        path    = element.querySelector("path");

    path.setAttribute("d", this.paths[state]);
    element.classList[active ? "add" : "remove"]("active");
    element.classList[active ? "add" : "remove"]("selected");
  },

  onClick: function(event) {
    var target = event.target,
        id     = target && target.getAttribute("data-remote-id");

    while (!id) {
      target = target.parentNode;

      if (!target || !target.getAttribute) {
        return;
      }

      id = target.getAttribute("data-remote-id");
    }

    Player.play(target.dataset);

    event.preventDefault();
  },

  onKeyDown: function(event) {
    switch (event.which) {
      case 74: // J
        this.setPosition(1);

        event.preventDefault();
      break;

      case 75: // K
        this.setPosition(-1);

        event.preventDefault();
      break;
    }
  },

  onPause: function(event) {
    this.setState(event.detail.id, "play", true);
  },

  onPlay: function(event) {
    this.setState(event.detail.id, "pause", true);
  },

  onScroll: function(event) {
    var remaining = document.body.scrollHeight - window.innerHeight -
                      window.pageYOffset;

    if (remaining > 128 || this.loading) {
      return;
    }

    this.loading = true;

    document.removeEventListener("scroll", this.onScroll);

    var element = this.elements.content.querySelector(".group:last-child li:last-child"),
        url     = "/?date=" + element.dataset.publishedOn,
        request = new XMLHttpRequest();

    request.open("GET", url);
    request.setRequestHeader("Accept", "text/javascript");
    request.setRequestHeader("X-Requested-With", "XMLHttpRequest");
    request.onreadystatechange = this.onScrollLoad.bind(this);
    request.send();
  },

  onScrollLoad: function(event) {
    var request = event.srcElement;

    if (request.readyState !== 4) {
      return;
    }

    var html = request.responseText.trim();

    if (!html) {
      return;
    }

    this.loading = false;
    this.elements.content.innerHTML += html;

    document.addEventListener("scroll", this.onScroll.bind(this), false);
  },

  onStop: function(event) {
    this.setState(event.detail.id, "play", false);
  }
};
