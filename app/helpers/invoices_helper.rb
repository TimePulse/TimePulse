module InvoicesHelper
  def invoice_client_selector()
    if @client
      select_tag( :client_id, options_for_select(client_selector_array_with_hours, @client.id), { :include_blank => "" })
    else
      select_tag( :client_id, options_for_select(client_selector_array_with_hours), { :include_blank => "" })
    end
  end

  def client_selector_array_with_hours
    @client_array ||= Client.find(:all).collect{ |c| [
       "#{c.name} - (#{WorkUnit.for_client(c).uninvoiced.completed.billable.sum(:hours)}) ",
       c.id
    ]}
  end

  def work_unit_stop_time(work_unit)
    if (work_unit.stop_time)
      work_unit.stop_time.try(:to_s, :time)
    else
     link_to("Fix",
       fix_work_unit_path(:id => work_unit.id),
       :id => "fix_" + dom_id(work_unit),
       :class => 'fix_work_unit_button'
     )
    end
  end
end
