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
end
