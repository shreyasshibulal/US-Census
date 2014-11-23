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
    var = params[:field]
    @data_array = get_all_state_info(var)
    Datum.new(:key => var, :value => @data_array).save
    @query_title = var
    render :index
  end
  
  def get_all_state_info(variable_id)
    all_states_info = "{"
      page = open("http://api.census.gov/data/2010/sf1?key=d00e83d203212bfab72100f4b5c32448e5ca8647&get="+variable_id+"&for=state:*")
      info = page.read
      info.scan(/\[".*?(?=")",".*?(?=")"\]/){|state_info| 
        values = state_info.match(/(")(.*?(?="))(",")(.*?(?="))(")/).captures
        not_needed, value, not_needed, state, not_needed = values
        if (value != variable_id && state != "state")
          all_states_info=all_states_info+"\""+state+"\":\""+value+"\","
        end
      }
      return all_states_info.gsub(/,$/,"}")
  end
  def dictionary_to_hash(dictionary)
    hash = Hash.new
    dictionary.scan(/".*?(?=")":".*?(?=")"/){|entry|
      not_needed, key, not_needed, value, not_needed =  entry.match(/(")(.*?(?="))(":")(.*?(?="))(")/).captures
      hash[key] = value.to_i
      }
      return hash
  end
  def hash_to_dictionary(hash)
    dictionary= "{"
    hash.each{|key, value|
      dictionary = dictionary +"\""+key+"\":\""+value.to_s+"\","
    }
    return dictionary.gsub(/,$/,"}")
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
      male_population = dictionary_to_hash(get_all_state_info(variable_id_male))
      female_population = dictionary_to_hash(get_all_state_info(variable_id_female))
      male_population.each {|state, population|
        total_population[state] = population + female_population[state]  
      }
      return hash_to_dictionary(total_population)
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
        male_population = dictionary_to_hash(get_all_state_info(variable_id))
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
          total_population = dictionary_to_hash(get_all_state_info(variable_id_total))
          total_population.each {|state, population|
            female_population[state] = population - male_population[state]  
          }
        end
        return hash_to_dictionary(female_population)
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
      male_population = dictionary_to_hash(get_all_state_info(variable_id_male))
      female_population = dictionary_to_hash(get_all_state_info(variable_id_female))
      male_population.each {|state, population|
        total_population[state] = population + female_population[state]  
      }
      return hash_to_dictionary(total_population)
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
        male_population = dictionary_to_hash(get_all_state_info(variable_id))
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
          total_population = dictionary_to_hash(get_all_state_info(variable_id_total))
          total_population.each {|state, population|
            female_population[state] = population - male_population[state]  
          }
        end
        return hash_to_dictionary(female_population)
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


