# class MainController < ApplicationController
#   def index
#   end
# end

require 'xmlsimple'
require 'open-uri'

class MainController < ApplicationController
  def index
  end

  helper_method :population_by_sex

  def initialize()
    super
    page = open("http://api.census.gov/data/2010/sf1/variables.xml")
    @variables = XmlSimple.xml_in(page.read)['vars'][0]['var']
    # @data_array = "{\"34\": \"4279600\", \"42\": \"6190363\"}"
    @data_array = ""
    @query_title = "Please Select a Query"
  end

  def query
    # can access: params[:field]
    # set @data_array to the newly formatted query
    @query_title = params[:field]
    
    render :index
  end
  
  def get_all_state_info(variable_id)
    states = ["1","2","4","5","6","8","9","10","11","12","13","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","44","45","46","47","48","49","50","51","53","54","55","56","72"]
    states_population = Hash.new
    states.each{|state|
      page = open("http://api.census.gov/data/2010/sf1?key=d00e83d203212bfab72100f4b5c32448e5ca8647&get="+variable_id+"&for=state:"+state)
      info = page.read
      states_population[state] = info.match(/"[0-9]+"/)[0].gsub(/"/,"" ).to_i
    }
    return states_population
  end
  
  def population_by_age_race_sex(age, race, sex)
    variable_id=""
    @variables.each{|variable|
      if (variable['xml:id'] && variable['label'] && variable['concept'])
        if (variable['concept'].downcase.include?("sex by age ("+race+") [209]") && variable['label'].downcase.include?(sex+": !! "+age+" years"))
          variable_id = variable['xml:id']
          break
        end
      end
      }
    if (variable_id!="")
      return get_all_state_info(variable_id)
    end
  end

  def population_by_age(age)
    variable_id_male=""
    variable_id_female=""
    @variables.each{|variable|
      if (variable['xml:id'] && variable['label'] && variable['concept'])
        if (variable['concept'].downcase.include?("sex by age [209]") && variable['label'].downcase.include?("male: !! "+age+" years"))
          variable_id_male = variable['xml:id']
          break
        end
      end
      }
    @variables.each{|variable|
      if (variable['xml:id'] && variable['label'] && variable['concept'])
        if (variable['concept'].downcase.include?("sex by age [209]") && variable['label'].downcase.include?("female: !! "+age+" years"))
          variable_id_female = variable['xml:id']
          break
        end
      end
      }
    if (variable_id_male!="" && variable_id_female!="")
      total_population= Hash.new
      male_population = get_all_state_info(variable_id_male)
      female_population = get_all_state_info(variable_id_female)
      male_population.each {|state, population|
        total_population[state] = population + female_population[state]  
      }
      return total_population
    end    
  end
  
  def population_by_race(race)
    variable_id=""
    @variables.each{|variable|
      if (variable['xml:id'] && variable['label'] && variable['concept'])
        if (variable['concept'].downcase.include?("sex by age ("+race+") [209]") && variable['label'].downcase.include?("people who are "+race))
          variable_id = variable['xml:id']
          break
        end
      end
      }
    if (variable_id!="")
      return get_all_state_info(variable_id)
    end
  end
  
  def population_by_sex(sex)
    variable_id=""
    @variables.each{|variable|
      if (variable['xml:id'] && variable['label'] && variable['concept'])
        if (variable['concept'].downcase.include?("sex by age [209]") && variable['label'].downcase == ("male:"))
          variable_id = variable['xml:id']
          break
        end
      end
      }
    if (variable_id!="")
      if (sex=="male")
        return get_all_state_info(variable_id)
      else
        male_population = get_all_state_info(variable_id)
        variable_id_total=""
        @variables.each{|variable|
          if (variable['xml:id'] && variable['label'] && variable['concept'])
            if (variable['concept'].downcase.include?("sex by age [209]") && variable['label'].downcase == ("total population"))
              variable_id_total = variable['xml:id']
              break
            end
          end
        }
        if (variable_id_total !="")
          female_population = Hash.new
          total_population = get_all_state_info(variable_id_total)
          total_population.each {|state, population|
            female_population[state] = population - male_population[state]  
          }
        end
        return female_population
      end
    end
  end
  
  def population_by_age_race(age, race)
    variable_id_male=""
    variable_id_female=""
    @variables.each{|variable|
      if (variable['xml:id'] && variable['label'] && variable['concept'])
        if (variable['concept'].downcase.include?("sex by age ("+race+") [209]") && variable['label'].downcase.include?("male: !! "+age+" years"))
          variable_id_male = variable['xml:id']
          break
        end
      end
      }
    @variables.each{|variable|
      if (variable['xml:id'] && variable['label'] && variable['concept'])
        if (variable['concept'].downcase.include?("sex by age ("+race+") [209]") && variable['label'].downcase.include?("female: !! "+age+" years"))
          variable_id_female = variable['xml:id']
          break
        end
      end
      }
    if (variable_id_male!="" && variable_id_female!="")
      total_population= Hash.new
      male_population = get_all_state_info(variable_id_male)
      female_population = get_all_state_info(variable_id_female)
      male_population.each {|state, population|
        total_population[state] = population + female_population[state]  
      }
      return total_population
    end
  end
  
  def population_by_race_sex(race, sex)
    variable_id=""
    @variables.each{|variable|
      if (variable['xml:id'] && variable['label'] && variable['concept'])
        if (variable['concept'].downcase.include?("sex by age ("+race+") [209]") && variable['label'].downcase == ("male:"))
          variable_id = variable['xml:id']
          break
        end
      end
      }
    if (variable_id!="")
      if (sex=="male")
        return get_all_state_info(variable_id)
      else
        male_population = get_all_state_info(variable_id)
        variable_id_total=""
        @variables.each{|variable|
          if (variable['xml:id'] && variable['label'] && variable['concept'])
            if (variable['concept'].downcase.include?("sex by age ("+race+") [209]") && variable['label'].downcase == ("people who are "+race))
              variable_id_total = variable['xml:id']
              break
            end
          end
        }
        if (variable_id_total !="")
          female_population = Hash.new
          total_population = get_all_state_info(variable_id_total)
          total_population.each {|state, population|
            female_population[state] = population - male_population[state]  
          }
        end
        return female_population
      end
    end 
  end
  
  def population_by_age_sex(age,sex)
    variable_id=""
    @variables.each{|variable|
      if (variable['xml:id'] && variable['label'] && variable['concept'])
        if (variable['concept'].downcase.include?("sex by age [209]") && variable['label'].downcase.include?(sex+": !! "+age+" years"))
          variable_id = variable['xml:id']
          break
        end
      end
      }
    if (variable_id!="")
      return get_all_state_info(variable_id)
    end 
  end
  
end

#info = MainController.new
# puts info.population_by_age_race_sex("12","white alone","male")
# puts ""
# puts info.population_by_age("12")
# puts ""
# puts info.population_by_race("white alone")
# puts ""
# puts info.population_by_sex("female");
# puts ""
# puts info.population_by_sex("male")
# puts ""
# puts info.population_by_age_race("12","white alone")
# puts ""
# puts info.population_by_age_sex("12","male")
# puts ""
# puts info.population_by_race_sex("white alone", "male")
# puts ""
# puts info.population_by_race_sex("white alone", "female")


