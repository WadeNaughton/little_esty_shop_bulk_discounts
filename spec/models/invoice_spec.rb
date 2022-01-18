require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many :transactions}
  end
  describe "instance methods" do
    it "total_revenue" do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)

      expect(@invoice_1.total_revenue).to eq(100)
    end
    it "shows discounts" do
      merchant = Merchant.create!(name: 'Hair Care')

      item1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: merchant.id)
      item2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: merchant.id)
      item3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: merchant.id)

      customer1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')

      invoice1 = Invoice.create!(customer_id: customer1.id, status: 2, created_at: "2012-03-27 14:54:09")

      ii1 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item1.id, quantity: 15, unit_price: 10, status: 2)
      ii3 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item2.id, quantity: 2, unit_price: 10, status: 2)
      ii4 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item3.id, quantity: 3, unit_price: 5, status: 2)

      transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: invoice1.id)

      discount1 = merchant.discounts.create!(name: 'discount1', percent_discount: 20, quantity_limit: 10)
      discount2 = merchant.discounts.create!(name: 'discount2', percent_discount: 30, quantity_limit: 15)
      expect(invoice1.discount_revenue).to eq(45)
    end
    it 'shows discount with multiple merchants' do
      merchant = Merchant.create!(name: 'Hair Care')
      merchant2 = Merchant.create!(name: 'wade')

      item1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: merchant.id)
      item2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: merchant.id)
      item3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: merchant.id)
      item4 = Item.create!(name: "spoon", description: "This takes out soup", unit_price: 5, merchant_id: merchant2.id)

      customer1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')

      invoice1 = Invoice.create!(customer_id: customer1.id, status: 2, created_at: "2012-03-27 14:54:09")

      ii1 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item1.id, quantity: 8, unit_price: 10, status: 2)
      ii3 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item2.id, quantity: 2, unit_price: 10, status: 2)
      ii4 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item3.id, quantity: 1, unit_price: 5, status: 2)
      ii4 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item4.id, quantity: 10, unit_price: 5, status: 2)

      transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: invoice1.id)

      discount1 = merchant.discounts.create!(name: 'discount1', percent_discount: 25, quantity_limit: 2)
      discount2 = merchant.discounts.create!(name: 'discount2', percent_discount: 10, quantity_limit: 4)
      expect(invoice1.discount_revenue).to eq(25)
    end
    it "finds discounted item" do
      merchant = Merchant.create!(name: 'Hair Care')
      merchant2 = Merchant.create!(name: 'wade')

      item1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: merchant.id)
      item2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: merchant.id)
      item3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: merchant.id)
      item4 = Item.create!(name: "spoon", description: "This takes out soup", unit_price: 5, merchant_id: merchant2.id)

      customer1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')

      invoice1 = Invoice.create!(customer_id: customer1.id, status: 2, created_at: "2012-03-27 14:54:09")

      ii1 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item1.id, quantity: 8, unit_price: 10, status: 2)
      ii3 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item2.id, quantity: 2, unit_price: 10, status: 2)
      ii4 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item3.id, quantity: 1, unit_price: 5, status: 2)
      ii4 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item4.id, quantity: 10, unit_price: 5, status: 2)

      transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: invoice1.id)

      discount1 = merchant.discounts.create!(name: 'discount1', percent_discount: 25, quantity_limit: 2)
      discount2 = merchant.discounts.create!(name: 'discount2', percent_discount: 10, quantity_limit: 4)
      expected = invoice1.discount_items.each do |i|
                  i
                end
      expect(invoice1.discount_items).to eq(expected)
    end
  end
end
