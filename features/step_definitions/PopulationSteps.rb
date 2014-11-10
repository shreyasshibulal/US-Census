Given(/^I am on the main page$/) do
  visit root_path
  assert find_by_id('PA')['class'] == "white"
end

Given(/^I have not selected a query$/) do
  # pass
end

Then(/^my two states should be white$/) do
  assert find_by_id('PA')['class'] == "white"
  assert find_by_id('NJ')['class'] == "white"
end

When(/^I query for male population count$/) do
  # pass
end

Then(/^State (\d+) should match (\d+)$/) do |arg1, arg2|
  info = MainController.new
  pctMale = info.population_by_sex("male")
  pctMale[arg1] == arg2
end

# When "I select a query" do
#     select('Population of Men', from: 'querySelect')
# end

# Then(/^my results should be shown$/) do
#     puts find_by_id('PA')['class']
#   assert find_by_id('PA')['class'] != "white"
#   assert find_by_id('NJ')['class'] != "white"
# end

# Given(/^I select Population of Males$/) do
#   select('Population of Men', from: 'querySelect')
# end

# Then(/^the states should be colored appropriately$/) do
#   assert find_by_id('PA')['class'] == "red1"
#   assert find_by_id('NJ')['class'] == "pink"
# end

# Given(/^I am viewing a result$/) do
#     select('Population of Men', from: 'querySelect')
#     # find_by_id('querySelect').find(:xpath, 'option[2]').select_option
# end

# Given(/^I mouse over a state$/) do
#   find_by_id('PA').hover
# end

# Then(/^I should see that states value$/) do
#     assert page.has_content?("PA: 6,190,363")
# end