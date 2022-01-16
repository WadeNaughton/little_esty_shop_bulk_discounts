FactoryBot.define do
  factory :discount do
    name { "MyString" }
    percent_discount { 1 }
    quantity_limit { 1 }
    merchant { nil }
  end
end
