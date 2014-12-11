require 'spec_helper'

# require_relative '../app/controllers/application_controller'
# require_relative '../app/controllers/data_controller'
# require_relative '../app/controllers/main_controller'
# require_relative '../app/models/datum'



describe "Main Controller" do

  before :all do
    $main = MainController.new
    $data = $main.get_all_state_info("PCT012A119")
  end

  it "should do stuff right" do
    expect($main.dictionary_to_hash($data)["34"]).not_to eq(nil)
  end    

  it "should convert hash to dict and back" do
    expect($data).to eq($main.hash_to_dictionary($main.dictionary_to_hash($data))) 
  end

  it "should query correctly" do
    puts $main.population_by_age_race_sex("12", "white alone", "male")
  end
end