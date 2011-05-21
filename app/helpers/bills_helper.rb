module BillsHelper       

  def bill_user_selector()
    if @user
      select_tag( :user_id, options_for_select(user_selector_array, @user.id), { :include_blank => "" })
    else
      select_tag( :user_id, options_for_select(user_selector_array), { :include_blank => "" })
    end
  end
  
  def user_selector_array
    @user_array ||= User.find(:all).collect{ |c| [
       "#{c.name} - (#{c.work_units.unbilled.completed.billable.sum(:hours)}) ", 
       c.id        
    ]}
  end
end
