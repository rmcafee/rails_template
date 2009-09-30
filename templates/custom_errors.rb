# This customizes how errors are viewed
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  msg = instance_tag.error_message 
  msg = msg.last if msg.class == Array # get first if multiple error messages (.size only returns length, not dealing w/ an errors object)    
  html_tag =~ /type=\"(hidden)\"/ ? html_tag : "<span class=\"fieldWithErrors\">#{html_tag}<span class=\"error\">#{msg}<\/span></span>"
  # html_tag =~ /type=\"(checkbox|hidden)\"/ ? html_tag : "#{html_tag}\n<small class=\"message\">#{msg}<\/small>" # check_boxes have double input fields
end