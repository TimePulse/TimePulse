module InvoicesHelper
  def invoice_client_selector()
    if @client
      select_tag( :client_id, options_for_select(client_selector_array_with_hours, @client.id), { :include_blank => "", :class => "invoice-client-selector" })
    else
      select_tag( :client_id, options_for_select(client_selector_array_with_hours), { :include_blank => "", :class => "invoice-client-selector"  })
    end
  end

  def client_selector_array_with_hours
    @client_array ||= Client.all.to_a.collect{ |c| [
       "#{c.name} - (#{WorkUnit.for_client(c).uninvoiced.completed.billable.sum(:hours)}) ",
       c.id
    ]}
  end

  def invoice_item_footer(items)
    totals = { :hours => 0, :total => 0 }
    items.each do |item|
      totals[:hours] += item.hours
      totals[:total] += item.total
    end
    content_tag(:tfoot) do
      content_tag(:th, 'Total') +
      content_tag(:th, '&nbsp;', nil, false) +
      content_tag(:th, totals[:hours]) +
      content_tag(:th, number_to_currency(totals[:total], :precision => 2))
    end
  end

  def work_unit_hours_td(work_unit, &block)
    rate = work_unit.rate
    attributes = {:class => "hours"}
    if rate
      attributes[:'data-rate-id'] = rate.id
      attributes[:'data-rate-name'] = rate.name
      attributes[:'data-rate-amount'] = rate.amount
    end
    content_tag(:td, attributes, &block)
  end
end
