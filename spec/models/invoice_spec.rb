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
    it { should have_many(:bulk_discounts).through(:merchants) }
    it { should have_many :transactions}
  end

  describe "instance methods" do
    describe 'total_discounted_invoice_rev' do
      it 'returns total discounted revenue of an invoice' do
        @merchant1 = Merchant.create!(name: 'Hair Care')
        @merchant2 = Merchant.create!(name: 'Cub Foods')
        @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
        @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
        @item_2 = Item.create!(name: "chips", description: "crunchy good", unit_price: 5, merchant_id: @merchant1.id)
        @item_9 = Item.create!(name: "cosmic brownies", description: "chocolate goodness", unit_price: 5, merchant_id: @merchant2.id)
        @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
        @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 15, unit_price: 10, status: 2)
        @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 10, unit_price: 10, status: 1)
        @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 5, unit_price: 10, status: 1)
        @ii_4 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 1)
        @ii_5 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_9.id, quantity: 12, unit_price: 10, status: 1)
        @bulk_disc1 = BulkDiscount.create!(name: "Super Savings Discount", discount_percent: 0.25, quantity_threshold: 10, merchant_id: @merchant1.id)
        @bulk_disc2 = BulkDiscount.create!(name: "Summer Sale", discount_percent: 0.20, quantity_threshold: 10, merchant_id: @merchant1.id)
        
        expect(@invoice_1.total_discounted_invoice_rev(@merchant1.id)).to eq(247.5)
      end
    end

    describe 'total revenue' do
      it "returns the total invoice revenue without discounts" do
        @merchant1 = Merchant.create!(name: 'Hair Care')
        @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
        @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
        @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
        @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
        @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)

        expect(@invoice_1.total_revenue).to eq(100)
      end
    end

    describe 'total_admin_discounted_invoice_rev' do
      it 'returns total revenue of invoice items whose merchant has a discount' do
        @merchant1 = Merchant.create!(name: 'Hair Care')
        @merchant2 = Merchant.create!(name: 'Cub Foods')
        @merchant3 = Merchant.create!(name: 'Whole Foods')
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
        
        expect(@invoice_1.total_admin_discounted_invoice_rev).to eq(367.5)
      end
    end

    describe 'total_admin_discounted_invoice_rev' do
      it 'returns total revenue of invoice items whose merchant has a discount' do
        @merchant1 = Merchant.create!(name: 'Hair Care')
        @merchant2 = Merchant.create!(name: 'Cub Foods')
        @merchant3 = Merchant.create!(name: 'Whole Foods')
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
        
        expect(@invoice_1.total_admin_discounted_invoice_rev).to eq(367.5)
      end
    end

    describe '#revenue_of_merch_no_discoutns' do
      it 'returns the total revenue of invoice items 
        whose merchants do not have bulk discounts' do
        @merchant1 = Merchant.create!(name: 'Hair Care', active_discount: true)
        @merchant2 = Merchant.create!(name: 'Cub Foods', active_discount: false)
        @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
        @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
        @item_2 = Item.create!(name: "chips", description: "crunchy good", unit_price: 5, merchant_id: @merchant1.id)
        @item_9 = Item.create!(name: "cosmic brownies", description: "chocolate goodness", unit_price: 5, merchant_id: @merchant2.id)
        @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
        @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 15, unit_price: 10, status: 2)
        @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 10, unit_price: 10, status: 1)
        @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 5, unit_price: 10, status: 1)
        @ii_4 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 1)
        @ii_5 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_9.id, quantity: 12, unit_price: 10, status: 1)
        @bulk_disc1 = BulkDiscount.create!(name: "Super Savings Discount", discount_percent: 0.25, quantity_threshold: 10, merchant_id: @merchant1.id)
        @bulk_disc2 = BulkDiscount.create!(name: "Summer Sale", discount_percent: 0.20, quantity_threshold: 10, merchant_id: @merchant1.id)
          
        expect(@invoice_1.revenue_of_merch_no_discoutns).to eq(120)
      end
    end

    describe 'total_admin_invoice_revenue_incl_discounts' do
      it 'returns the total admin invoice revenue including all 
        invoice items and there applied discount(if any)' do
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

        
        expect(@invoice_1.total_admin_invoice_revenue_incl_discounts).to eq(487.5)
      end
    end
    
  end
end
