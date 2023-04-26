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
    bulk_discounts.where("merchants.id = #{merch_id}")
    .select("invoice_items.*, MIN((invoice_items.quantity * invoice_items.unit_price) * 
      case 
        when invoice_items.quantity >= bulk_discounts.quantity_threshold 
        then (1 - bulk_discounts.discount_percent) 
        else 1 end) as tot_discount_revenue")
    .group('invoice_items.id')
    .sum(&:tot_discount_revenue)
  end

  def total_admin_discounted_invoice_rev
   bulk_discounts.select("invoice_items.*, MIN((invoice_items.quantity * invoice_items.unit_price) * 
    case 
      when invoice_items.quantity >= bulk_discounts.quantity_threshold 
      then (1 - bulk_discounts.discount_percent) 
      else 1 end) as tot_discount_revenue")
  .group('invoice_items.id')
  .sum(&:tot_discount_revenue)
  end

  def revenue_of_merch_no_discoutns
    merchants.where(merchants: {active_discount: false})
    .sum('invoice_items.quantity * invoice_items.unit_price')
  end

  def total_admin_invoice_revenue_incl_discounts
    (self.total_admin_discounted_invoice_rev) + (self.revenue_of_merch_no_discoutns)
  end
end
