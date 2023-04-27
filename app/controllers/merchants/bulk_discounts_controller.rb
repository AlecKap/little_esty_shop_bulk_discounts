class Merchants::BulkDiscountsController < ApplicationController
  before_action :find_merchant, only: [:index, :new, :create, :destroy]

  def index
    @holidays = HolidayFacade.new.holiday_info
  end

  def new
    @discount = BulkDiscount.new
  end

  def create
    @discount = @merchant.bulk_discounts.new(bulk_discount_params)
    if @discount.save
      @merchant.update(active_discount: true)
      redirect_to merchant_bulk_discounts_path(@merchant)
    else
      flash[:error] = "Please fill in all fields, did you not read?"
      render :new
    end
  end

  def destroy
    discount = BulkDiscount.find(params[:id]).destroy
    if @merchant.bulk_discounts.empty?
      @merchant.update(active_discount: false)
    end
    redirect_to merchant_bulk_discounts_path(params[:merchant_id])
  end

  private

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

  def bulk_discount_params
    params.require(:bulk_discount).permit(:name, :discount_percent, :quantity_threshold)
  end
end