module AnnotationsHelper
  include ProjectsHelper

  def recent_annotation_row_tag(annotations, token = nil, cssclass = nil, &block)
    content_tag(:tr,
                 :id => token,
                 :class => ['annotations', cssclass ]
                ) do
      yield
    end
  end

  def recent_annotation_details_row_tag(token = nil, cssclass = nil, &block)
      content_tag(:tr,
                   :id => "details-#{token}",
                   :class => ['recent_annotation_details', cssclass ]
                  ) do
      yield
    end
  end
end
