class Datum < ActiveRecord::Base
      validates :key, :presence => true
      validates :value, :presence => true
end
