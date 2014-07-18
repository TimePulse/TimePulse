module SelectBoxItHelpers

  def have_select_box_selector(base_id)
    container_id = base_id + "SelectBoxItContainer"
    have_selector(container_id)
  end

  def select_box_it_select(item, options = {})
    if !options[:from]
      raise "You must pass a key :from with the value of the name of the select field to choose from"
    end
    base_id = options[:from]
    arrow_id = "#" + base_id + "SelectBoxItArrowContainer"
    options_id = "#" + base_id + "SelectBoxItOptions"
    find(arrow_id).click
    within options_id do
      find('li', :text => item).click
    end
  end

end
