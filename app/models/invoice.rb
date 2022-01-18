class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  enum status: [:cancelled, 'in progress', :complete]

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def discount_revenue
      invoice_items.joins(:discounts)
    .select('invoice_items.id, max((invoice_items.unit_price * invoice_items.quantity) * (discounts.percent_discount / 100.0)) as total_discount')
    .where('invoice_items.quantity >= discounts.quantity_limit')
    .group('invoice_items.id')
    .sum(&:total_discount)
  end

  def discount_items
    invoice_items.joins(:discounts)
  .select('invoice_items.*, max((invoice_items.unit_price * invoice_items.quantity) * (discounts.percent_discount / 100.0)) as total_discount')
  .where('invoice_items.quantity >= discounts.quantity_limit')
  .group('invoice_items.id, discounts.id')
  .order(total_discount: :desc)


  end
end
