module TooltipHelper

  class TimePulseTooltipHelper
    include ProjectsHelper
    include ActionView::Helpers
    include ActionView::Context

    def initialize(item, token)
      @item = item
      @token = token
    end

    attr_reader :item, :token

    def table_html
      data_hash.keys.map do |key|
        "<dt>#{CGI::escapeHTML(key || "")}</dt><dd>#{CGI::escapeHTML(data_hash[key] || "")}</dd>".html_safe
      end.join().html_safe
    end

    def to_html
      content_tag( :div, :id => "tooltip_for_#{token}", :class => "lrd-tooltip") do
        content_tag(:dl) do
          table_html
        end
      end
    end
  end

  class WorkUnitTooltipHelper < TimePulseTooltipHelper
    def formatted_work_unit_time(time)
      time.nil? ? "-" : time.to_s(:short_datetime)
    end

    def data_hash
      {
        "Project:"  =>  short_name_with_client(item.project),
        "Notes:"    =>  item.annotated? ? item.notes : "Needs Annotation!",
        "Hours:"    =>  item.hours.to_s,
        "Started:"  =>  formatted_work_unit_time(item.start_time),
        "Finished:" =>  formatted_work_unit_time(item.stop_time)
      }
    end

  end

  class ActivityTooltipHelper < TimePulseTooltipHelper

    def data_hash
      {
        labels[0]   =>  short_name_with_client(item.project),
        labels[1]   =>  item.description,
        labels[2]   =>  item.reference_1,
        labels[3]   =>  item.reference_2,
        labels[4]   =>  item.time.to_s(:short_datetime)
      }
    end
  end

  class CommitTooltipHelper < ActivityTooltipHelper
    def labels
      ["Project:", "Message:", "Commit ID:", "Branch", "Time:"]
    end
  end

  class PivotalTooltipHelper < ActivityTooltipHelper
    def labels
      ["Project:", "Description:", "Story ID:", "Current State", "Time:"]
    end
  end

  def tooltip_for(work_unit, token)
    WorkUnitTooltipHelper.new(work_unit, token).to_html
  end

  def commit_tooltip_for(commit, token)
    CommitTooltipHelper.new(commit, token).to_html
  end

  def pivotal_tooltip_for(pivotal, token)
    PivotalTooltipHelper.new(pivotal, token).to_html
  end
end
