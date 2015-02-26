var Songs = {
  checked: 0,

  initialize: function() {
    this.findElements();
    this.bindEventListeners();
  },

  bindEventListeners: function() {
    var onChange = this.onChange.bind(this);

    this.elements.publish.addEventListener("click", this.onPublish.bind(this), false);
    this.elements.checkboxes.forEach(function(checkbox) {
      checkbox.addEventListener("change", onChange, false);
    });
  },

  findElements: function() {
    this.elements = {
      form       : document.querySelector("form"),
      publish    : document.querySelector("a.publish"),
      checkboxes : Array.prototype.slice.call(document.querySelectorAll("input.publish"))
    }
  },

  onPublish: function(event) {
    if (this.checked > 0) {
      this.elements.form.submit();
    }

    event.preventDefault();
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
  }
};
