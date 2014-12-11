# class MainController < ApplicationController
#   def index
#   end
# end

require 'xmlsimple'
require 'open-uri'

# class CreateProducts < ActiveRecord::Migration
#   def change
#       change_column :data, :value, :text
#     end
#   end
# end

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

  def get_all_state_info(variable_id)
    if (Datum.where("key = ?", variable_id).blank?)
      all_states_info = "{"
      begin 
        page = open("http://api.census.gov/data/2010/sf1?key=d00e83d203212bfab72100f4b5c32448e5ca8647&get="+variable_id+"&for=state:*")
      rescue
        return ""
      end
      info = page.read
      info.scan(/\[".*?(?=")",".*?(?=")"\]/){|state_info| 
        values = state_info.match(/(")(.*?(?="))(",")(.*?(?="))(")/).captures
        not_needed, value, not_needed, state, not_needed = values
        if (value != variable_id && state != "state")
          all_states_info=all_states_info+"\""+state+"\":\""+value+"\","
        end
      }
      all_state_info = all_states_info.gsub(/,$/,"}")
      Datum.new(:key => variable_id, :value =>all_state_info).save
      return all_states_info
    else
      return Datum.where("key = ?", variable_id).first[:value]
    end
  end

  def query_helper(vars)
    sum = Hash.new
    vars.split(",").each { |var|
      if (var == "," || var == "")
        next
      end
      info = dictionary_to_hash(get_all_state_info(var))
      if (sum["01"])
        info.each {|state, population|
        sum[state] = sum[state] + population  
      }
      else
        sum = info
      end
      }
    @data_array = hash_to_dictionary(sum)
  end

  def query
    # can access: params[:field]
    # set @data_array to the newly formatted query
    @query_title = params[:field]
    query_helper(params[:field])
    
    render :index
  end

  def search_helper(sex, age, race)
    if (sex!="all" && age=="all" && race=="all")
      if (sex=="f")
        return population_by_sex("female")
      else
        return population_by_sex("male")
      end
    elsif (sex=="all" && age!="all" && race=="all")
      min,hyphen,max=age.match(/([0-9]+)(-)([0-9]+)/).captures
      sum= Hash.new
      (min.to_i..max.to_i).each {|i|
        info = dictionary_to_hash(population_by_age(i.to_s))
        if (sum["01"])
          info.each {|state, population|
            sum[state] = sum[state] + population  
          }
        else
          sum = info
        end
      }
      @data_array = hash_to_dictionary(sum)
    elsif (sex=="all" && age=="all" && race!="all")
      sum = Hash.new
      race.split(",").each{ |individual_race|
        if (individual_race == "," || individual_race == "")
          next
        end
        info = dictionary_to_hash(population_by_race(individual_race))
        if (sum["01"])
          info.each {|state, population|
            sum[state] = sum[state] + population  
          }
        else
          sum = info
        end
      }
      @data_array = hash_to_dictionary(sum)   
    elsif (sex!="all" && age!="all" && race=="all")
      if (sex=="f")
        actual_sex="female"
      else
        actual_sex="male"
      end
      min,hyphen,max=age.match(/([0-9]+)(-)([0-9]+)/).captures
      sum= Hash.new
      (min.to_i..max.to_i).each {|i|
        info = dictionary_to_hash(population_by_age_sex(i.to_s,actual_sex))
        if (sum["01"])
          info.each {|state, population|
            sum[state] = sum[state] + population  
          }
        else
          sum = info
        end
      }
      @data_array = hash_to_dictionary(sum)
      
    elsif (sex!="all" && age=="all" && race!="all")
      
      if (sex=="f")
        actual_sex="female"
      else
        actual_sex="male"
      end
      sum = Hash.new
      race.split(",").each{ |individual_race|
        if (individual_race == "," || individual_race == "")
          next
        end
        info = dictionary_to_hash(population_by_race_sex(individual_race,actual_sex))
        if (sum["01"])
          info.each {|state, population|
            sum[state] = sum[state] + population  
          }
        else
          sum = info
        end    
       }
      @data_array =hash_to_dictionary(sum)
       
    elsif (sex=="all" && age!="all" && race!="all")
      sum = Hash.new
      min,hyphen,max=age.match(/([0-9]+)(-)([0-9]+)/).captures
       race.split(",").each{|individual_race|
        if (individual_race == "," || individual_race == "")
          next
        end
        (min.to_i..max.to_i).each {|i|
        info = dictionary_to_hash(population_by_age_race(i.to_s,individual_race))
        if (sum["01"])
          info.each {|state, population|
            sum[state] = sum[state] + population  
          }
        else
          sum = info
        end
        }
      }
      @data_array =hash_to_dictionary(sum)
    elsif (sex!="all" && age!="all" && race!="all")
      if (sex=="f")
        actual_sex="female"
      else
        actual_sex="male"
      end
      sum = Hash.new
      min,hyphen,max=age.match(/([0-9]+)(-)([0-9]+)/).captures
       race.split(",").each{|individual_race|
        if (individual_race == "," || individual_race == "")
          next
        end
        (min.to_i..max.to_i).each {|i|
        info = dictionary_to_hash(population_by_age_race_sex(i.to_s,individual_race,actual_sex))
        if (sum["01"])
          info.each {|state, population|
            sum[state] = sum[state] + population  
          }
        else
          sum = info
        end
        }
      }
      @data_array =hash_to_dictionary(sum)
    end
  end

  def search     # can access: params[:sex], params[:age], params[:race]
    # where sex == "m|f|all" age == "[min]-[max]" and race == '[race1],[race2]...'
    # any field could be 'all', for total
    # eg. /search/m/47-49/white,hispanic
    # eg. /search/f/all/white
    # eg. /search/all/45-45/black
    @query_title = params
    search_helper(params[:sex], params[:age], params[:race].gsub("_", " "))
  
    render :index
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
        if (variable['concept'].downcase.include?("sex by age ("+race+") [209]") && variable['label'].downcase.include?(sex+": !! "+age+" year"))
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
        if (variable['concept'].downcase.include?("sex by age [209]") && variable['label'].downcase.include?("male: !! "+age+" year"))
          variable_id_male = variable['xml:id']
          break
        end
      end
      }
    @variables.each{|variable|
      if (variable['xml:id'] && variable['label'] && variable['concept'])
        if (variable['concept'].downcase.include?("sex by age [209]") && variable['label'].downcase.include?("female: !! "+age+" year"))
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
        if (variable['concept'].downcase.include?("sex by age ("+race+") [209]") && variable['label'].downcase.include?("male: !! "+age+" year"))
          variable_id_male = variable['xml:id']
          break
        end
      end
      }
    @variables.each{|variable|
      if (variable['xml:id'] && variable['label'] && variable['concept'])
        if (variable['concept'].downcase.include?("sex by age ("+race+") [209]") && variable['label'].downcase.include?("female: !! "+age+" year"))
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
        if (variable['concept'].downcase.include?("sex by age [209]") && variable['label'].downcase.include?(sex+": !! "+age+" year"))
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
