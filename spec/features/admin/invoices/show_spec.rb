require 'rails_helper'

describe 'Admin Invoices Show Page' do
  describe 'As an admin when I visit an admin invoice show page' do
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
      
      expect(page).to_not have_content("$#{@ii_3.unit_price}")
      expect(page).to_not have_content(@ii_3.status)
    end
    
    it 'should display the total revenue the invoice will generate' do
      expect(page).to have_content("Total Revenue Before Discounts: $#{@i1.total_revenue}")
      
      expect(page).to_not have_content(@i2.total_revenue)
    end
    
    it 'should have status as a select field that updates the invoices status' do
      within("#status-update-#{@i1.id}") do
        select('cancelled', :from => 'invoice[status]')
        expect(page).to have_button('Update Invoice')
        click_button 'Update Invoice'
        
        expect(current_path).to eq(admin_invoice_path(@i1))
        expect(@i1.status).to eq('completed')
      end
    end
  end

  describe 'user story 8' do
    describe 'As an admin when I visit an admin invoice show page' do
      it 'I see the total discounted revenue from this 
        invoice which includes bulk discounts in the calculation' do
        @merchant1 = Merchant.create!(name: 'Hair Care', active_discount: true)
        @merchant2 = Merchant.create!(name: 'Cub Foods', active_discount: true)
        @merchant3 = Merchant.create!(name: 'Whole Foods', active_discount: false)
        @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
        @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
        @item_2 = Item.create!(name: "chips", description: "crunchy good", unit_price: 5, merchant_id: @merchant1.id)
        @item_9 = Item.create!(name: "cosmic brownies", description: "chocolate goodness", unit_price: 5, merchant_id: @merchant2.id)
        @item_10 = Item.create!(name: "brownies", description: "chocolates", unit_price: 5, merchant_id: @merchant3.id)
        @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
        @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 15, unit_price: 10, status: 2)
        @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 10, unit_price: 10, status: 1)
        @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 5, unit_price: 10, status: 1)
        @ii_4 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 1)
        @ii_5 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_9.id, quantity: 12, unit_price: 10, status: 1)
        @ii_5 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_10.id, quantity: 12, unit_price: 10, status: 1)
        @bulk_disc1 = BulkDiscount.create!(name: "Super Savings Discount", discount_percent: 0.25, quantity_threshold: 10, merchant_id: @merchant1.id)
        @bulk_disc2 = BulkDiscount.create!(name: "Summer Sale", discount_percent: 0.20, quantity_threshold: 12, merchant_id: @merchant1.id)
        @bulk_disc3 = BulkDiscount.create!(name: " Sale", discount_percent: 0.20, quantity_threshold: 15, merchant_id: @merchant2.id)
        visit admin_invoice_path(@invoice_1)
        save_and_open_page
        
        expect(page).to have_content("Total Revenue Including Discounts: $487.50")
      end
    end
  end
end

