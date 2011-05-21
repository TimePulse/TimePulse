module HhmmToDecimal

  def convert_hours_from_hhmm
    return unless params[:work_unit] && params[:work_unit][:hours]
    params[:work_unit][:hours] = convert_hhmm(params[:work_unit][:hours])
  end    

  def convert_hhmm(str)
    if str =~ /:/
      arr = str.split(':')
      return  arr[0].to_i + arr[1].to_i/60.0
    end
    str
  end
  
end
