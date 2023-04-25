class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants

  enum status: [:cancelled, 'in progress', :completed]

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end
  

  def total_discounted_invoice_rev(merch_id)
    total_discount_revenue = bulk_discounts.where("merchants.id = #{merch_id}")
    .select("invoice_items.*, MIN((invoice_items.quantity * invoice_items.unit_price) * 
    case 
      when invoice_items.quantity >= bulk_discounts.quantity_threshold 
      then (1 - bulk_discounts.discount_percent) 
      else 1 end) as tot_discount_revenue")
    .group('invoice_items.id')
    
    total_discount_revenue.sum(&:tot_discount_revenue)
  end
end
