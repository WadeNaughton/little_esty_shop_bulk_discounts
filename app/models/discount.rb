class Discount < ApplicationRecord
  belongs_to :merchant

  validates_presence_of :name,
                        :percent_discount,
                        :quantity_limit
end
