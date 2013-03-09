class PrototypeController < ApplicationController
  before_filter :default
  
  def display_page
    init_layout
    @layout ? render(:template => "prototype#{@request_path}", :layout => @layout) : render(:template => "prototype#{@request_path}")
  rescue ActionView::MissingTemplate
    @layout ? render(:template => "prototype#{@request_path}/index", :layout => @layout) : render(:template => "prototype#{@request_path}/index")
  end
  
  private

  def init_layout
    layout_path = File.join(Rails.root, "app/views/layouts/prototype")
    if File.exist?(layout_path)
      potential_layout = @request_path.split('/').reject { |x| x.blank? }.first
      Dir.chdir(layout_path) do
        matching_layout = Dir.glob("#{potential_layout}*")
        @layout = "prototype#{@request_path}" unless matching_layout.blank?
      end
    end
  end
  
  def default
    render(:template => "prototype/index") if request.path == "/"
    @request_path = request.path.gsub("/prototype","")
  end
end