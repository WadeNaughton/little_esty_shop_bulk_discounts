class DiscountsController < ApplicationController

  def index
    @merchant = Merchant.find(params[:merchant_id])
  end

  def show

  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    @discount = @merchant.discounts.create!(discount_params)
    @discount.save
    redirect_to merchant_discounts_path(@merchant)
  end

  def discount_params
    params.permit(:name, :percent_discount, :quantity_limit)
  end
end
