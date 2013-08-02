require 'spec_helper'

describe RatesHelper do
  describe :options_for_rates_users do
    before :each do
      @rate = Factory(:rate)
      @all_users = [Factory(:user)]
    end

    it "generates options tags" do
      options_for_rates_users(@rate).should have_selector('option')
    end
  end
end
