class BulkDiscountsController < ApplicationController
  before_action :find_bulk_discount, only: [:show, :edit, :update]
  
  def show
  end

  def edit
  end

  def update
    @discount.update(bulk_discount_params)
    if @discount.save
      redirect_to bulk_discount_path(@discount)
    else
      flash[:error] = "You MUST NOT leave any field blank!"
      render :edit
    end
  end

  private

  def bulk_discount_params
    params.require(:bulk_discount).permit(:name, :discount_percent, :quantity_threshold)
  end

  def find_bulk_discount
    @discount = BulkDiscount.find(params[:id])
  end
end
