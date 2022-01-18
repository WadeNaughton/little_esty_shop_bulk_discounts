class InvoiceItem < ApplicationRecord
  validates_presence_of :invoice_id,
                        :item_id,
                        :quantity,
                        :unit_price,
                        :status

  belongs_to :invoice
  belongs_to :item
  has_many :discounts, through: :item

  enum status: [:pending, :packaged, :shipped]

  def self.incomplete_invoices
    invoice_ids = InvoiceItem.where("status = 0 OR status = 1").pluck(:invoice_id)
    Invoice.order(created_at: :asc).find(invoice_ids)
  end

  def discount_find(id)
    discounts = Discount.order(:quantity_limit)
    invoice_item = InvoiceItem.find(id)
    discount_new = nil
    discounts.each do |discount|
      if invoice_item.quantity >= discount.quantity_limit
        discount_new = discount
      end
    end
    discount_new
  end
end
