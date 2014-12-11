require 'spec_helper'

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
    expect($main.dictionary_to_hash($main.population_by_age_race_sex("12", "white alone", "male"))["34"]).not_to eq(nil)
  end

  it "should query by value" do
    expect($main.query_helper("PCT012A119")).not_to eq(nil)
  end

  it "should query by multiple values" do
    expect($main.query_helper("PCT012A119,PCT012A120")).not_to eq(nil)
  end

  it "should handle values that don't exist in database" do
    expect($main.query_helper("PCT012A128")).not_to eq(nil)
  end

  it "should query by sex" do
    expect($main.search_helper("male", "all", "all")).not_to eq(nil)
  end

  it "should query with females" do
    expect($main.population_by_sex("female")).not_to eq(nil)
  end

  it "should query with females and race" do
    expect($main.population_by_race_sex("white alone", "female")).not_to eq(nil)
  end

  it "should query by sex and race" do
    expect($main.search_helper("male", "all", "white alone")).not_to eq(nil)
  end

  it "should query by sex and race and age" do
    expect($main.search_helper("male", "12-14", "white alone")).not_to eq(nil)
  end

  it "should query by race" do
    expect($main.search_helper("all", "all", "white alone")).not_to eq(nil)
  end

  it "should query by age" do
    expect($main.search_helper("all", "12-14", "all")).not_to eq(nil)
  end

  it "should query by race and age" do
    expect($main.search_helper("all", "12-14", "white alone")).not_to eq(nil)
  end

  it "should query by sex and age" do
    expect($main.search_helper("male", "12-14", "all")).not_to eq(nil)
  end
end