module ApplicationHelper
  def csrf_meta_tags
    [
      tag("meta", name: "csrf-param", content: request_forgery_protection_token),
      tag("meta", name: "csrf-token", content: form_authenticity_token)
    ].join("\n  ").html_safe if protect_against_forgery?
  end

  def tag(name, options = nil, open = false, escape = true)
    "<#{name}#{tag_options(options, escape)}>".html_safe
  end
end
