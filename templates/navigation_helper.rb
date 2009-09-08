module NavigationHelper
  def nav_item(current, name, path, klass = "", &block)
    klass += ' current' if current
    html =  "<li class='#{klass}'>"
    html += link_to name, path
    html += block_given? ? capture(&block) : ''
    html += "</li>"
    return html
  end
end