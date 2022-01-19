class Item < ApplicationRecord
  validates_presence_of :name,
                        :description,
                        :unit_price,
                        :merchant_id
                        
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices
  has_many :discounts, through: :merchant


  enum status: [:disabled, :enabled]

  def best_day
    invoices
    .joins(:invoice_items)
    .where('invoices.status = 2')
    .select('invoices.*, sum(invoice_items.unit_price * invoice_items.quantity) as money')
    .group(:id)
    .order("money desc", "created_at desc")
    .first&.created_at&.to_date
  end

  def discounts_applied(quantity)
    discounts.where('? >= discounts.quantity_limit', quantity)
                  .order(percent_discount: :desc).first
  end

end
