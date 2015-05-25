var Songs = {
  checked  : 0,
  elements : {
    form       : document.querySelector("form"),
    publish    : document.querySelector("a.publish"),
    deletion   : Array.prototype.slice.call(document.querySelectorAll("a.delete")),
    checkboxes : Array.prototype.slice.call(document.querySelectorAll("input.publish"))
  },

  initialize: function() {
    this.bindEventListeners();
  },

  bindEventListeners: function() {
    var onChange = this.onChange.bind(this),
        onDelete = this.onDelete.bind(this);

    this.elements.publish.addEventListener("click", this.onPublish.bind(this), false);
    this.elements.deletion.forEach(function(checkbox) {
      checkbox.addEventListener("click", onDelete, false);
    });
    this.elements.checkboxes.forEach(function(checkbox) {
      checkbox.addEventListener("change", onChange, false);
    });
  },

  onChange: function(event) {
    var publish = this.elements.publish;

    if (event.srcElement.checked) {
      this.checked += 1;
    } else {
      this.checked -= 1;
    }

    if (this.checked > 0) {
      publish.classList.add("enabled");
    } else {
      publish.classList.remove("enabled");
    }
  },

  onDelete: function(event) {
    event.preventDefault();

    if (!confirm("Are you sure you want to delete this song?")) {
      return;
    }

    var element = event.target,
        url     = element.getAttribute("href"),
        token   = document.querySelector("[name=authenticity_token]").value,
        request = new XMLHttpRequest();

    request.open("DELETE", url);
    request.setRequestHeader("X-CSRF-Token", token);
    request.onreadystatechange = function() {
      if (request.readyState !== 4 || request.status !== 200) {
        return;
      }

      var item = element.parentNode.parentNode.parentNode,
          list = item.parentNode;

      item.remove();

      if (list.querySelectorAll("li").length === 0) {
        list.parentNode.parentNode.remove();
      }
    };
    request.send();
  },

  onPublish: function(event) {
    if (this.checked > 0) {
      this.elements.form.submit();
    }

    event.preventDefault();
  }
};
