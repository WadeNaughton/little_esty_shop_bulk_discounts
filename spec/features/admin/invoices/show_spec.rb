require 'rails_helper'

describe 'Admin Invoices Index Page' do
  before :each do
    @m1 = Merchant.create!(name: 'Merchant 1')

    @c1 = Customer.create!(first_name: 'Yo', last_name: 'Yoz', address: '123 Heyyo', city: 'Whoville', state: 'CO', zip: 12345)
    @c2 = Customer.create!(first_name: 'Hey', last_name: 'Heyz')

    @i1 = Invoice.create!(customer_id: @c1.id, status: 2, created_at: '2012-03-25 09:54:09')
    @i2 = Invoice.create!(customer_id: @c2.id, status: 1, created_at: '2012-03-25 09:30:09')

    @item_1 = Item.create!(name: 'test', description: 'lalala', unit_price: 6, merchant_id: @m1.id)
    @item_2 = Item.create!(name: 'rest', description: 'dont test me', unit_price: 12, merchant_id: @m1.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 12, unit_price: 2, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 6, unit_price: 1, status: 1)
    @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_2.id, quantity: 87, unit_price: 12, status: 2)

    visit admin_invoice_path(@i1)
  end

  it 'should display the id, status and created_at' do
    expect(page).to have_content("Invoice ##{@i1.id}")
    expect(page).to have_content("Created on: #{@i1.created_at.strftime("%A, %B %d, %Y")}")

    expect(page).to_not have_content("Invoice ##{@i2.id}")
  end

  it 'should display the customers name and shipping address' do
    expect(page).to have_content("#{@c1.first_name} #{@c1.last_name}")
    expect(page).to have_content(@c1.address)
    expect(page).to have_content("#{@c1.city}, #{@c1.state} #{@c1.zip}")

    expect(page).to_not have_content("#{@c2.first_name} #{@c2.last_name}")
  end

  it 'should display all the items on the invoice' do
    expect(page).to have_content(@item_1.name)
    expect(page).to have_content(@item_2.name)

    expect(page).to have_content(@ii_1.quantity)
    expect(page).to have_content(@ii_2.quantity)

    expect(page).to have_content("$#{@ii_1.unit_price}")
    expect(page).to have_content("$#{@ii_2.unit_price}")

    expect(page).to have_content(@ii_1.status)
    expect(page).to have_content(@ii_2.status)

    expect(page).to_not have_content(@ii_3.quantity)
    expect(page).to_not have_content("$#{@ii_3.unit_price}")
    expect(page).to_not have_content(@ii_3.status)
  end

  it 'should display the total revenue the invoice will generate' do
    expect(page).to have_content("Total Revenue: $#{@i1.total_revenue}")

    expect(page).to_not have_content(@i2.total_revenue)
  end

  it 'should have status as a select field that updates the invoices status' do
    within("#status-update-#{@i1.id}") do
      select('cancelled', :from => 'invoice[status]')
      expect(page).to have_button('Update Invoice')
      click_button 'Update Invoice'

      expect(current_path).to eq(admin_invoice_path(@i1))
      expect(@i1.status).to eq('complete')
    end
  end
  describe 'merchant invoice discounts' do
    it "I see total discounted revenue from this invoice which include bulk discounts" do
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
      visit admin_invoice_path(invoice1)
      expect(page).to have_content("Discounted Price: $45.00")
      expect(page).to have_content("New Price: $140.00")
    end

    it "does not apply a discount" do
      merchant = Merchant.create!(name: 'Hair Care')

      item1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: merchant.id)
      item2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: merchant.id)
      item3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: merchant.id)

      customer1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')

      invoice1 = Invoice.create!(customer_id: customer1.id, status: 2, created_at: "2012-03-27 14:54:09")

      ii1 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item1.id, quantity: 8, unit_price: 10, status: 2)
      ii3 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item2.id, quantity: 2, unit_price: 10, status: 2)
      ii4 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item3.id, quantity: 3, unit_price: 5, status: 2)

      transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: invoice1.id)

      discount1 = merchant.discounts.create!(name: 'discount1', percent_discount: 20, quantity_limit: 10)
      discount2 = merchant.discounts.create!(name: 'discount2', percent_discount: 30, quantity_limit: 15)
      visit admin_invoice_path(invoice1)

      expect(page).to have_content("Discounted Price: $0.00")
      expect(page).to have_content("New Price: $115.00")
    end
    it "applies both discounts" do
      merchant = Merchant.create!(name: 'Hair Care')

      item1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: merchant.id)
      item2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: merchant.id)
      item3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: merchant.id)

      customer1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')

      invoice1 = Invoice.create!(customer_id: customer1.id, status: 2, created_at: "2012-03-27 14:54:09")

      ii1 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item1.id, quantity: 8, unit_price: 10, status: 2)
      ii3 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item2.id, quantity: 2, unit_price: 10, status: 2)
      ii4 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item3.id, quantity: 1, unit_price: 5, status: 2)

      transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: invoice1.id)

      discount1 = merchant.discounts.create!(name: 'discount1', percent_discount: 20, quantity_limit: 2)
      discount2 = merchant.discounts.create!(name: 'discount2', percent_discount: 25, quantity_limit: 4)
      visit admin_invoice_path(invoice1)
      expect(page).to have_content("Discounted Price: $24.00")
      expect(page).to have_content("New Price: $81.00")
    end
    it "text" do
      merchant = Merchant.create!(name: 'Hair Care')

      item1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: merchant.id)
      item2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: merchant.id)
      item3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: merchant.id)

      customer1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')

      invoice1 = Invoice.create!(customer_id: customer1.id, status: 2, created_at: "2012-03-27 14:54:09")

      ii1 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item1.id, quantity: 8, unit_price: 10, status: 2)
      ii3 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item2.id, quantity: 2, unit_price: 10, status: 2)
      ii4 = InvoiceItem.create!(invoice_id: invoice1.id, item_id: item3.id, quantity: 1, unit_price: 5, status: 2)

      transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: invoice1.id)

      discount1 = merchant.discounts.create!(name: 'discount1', percent_discount: 25, quantity_limit: 2)
      discount2 = merchant.discounts.create!(name: 'discount2', percent_discount: 10, quantity_limit: 4)
      visit admin_invoice_path(invoice1)
      expect(page).to have_content("Discounted Price: $25.00")
      expect(page).to have_content("New Price: $80.00")
    end
    it "applies discount only to specific merchants items" do
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
      visit admin_invoice_path(invoice1)
      expect(page).to have_content("Discounted Price: $25.00")
      expect(page).to have_content("New Price: $130.00")
    end
  end
end
