require 'rails_helper'

RSpec.describe 'dashboard/bulk_discounts index spec'do
  before :each do
    test_data
    visit bulk_discount_path(@bulk_disc1)
  end

  describe 'As a merchant, when I visit my bulk discount show page' do
    it 'I see the bulk discount quantity threshold and percentage discount' do
      expect(page).to have_content(@bulk_disc1.name)
      expect(page).to have_content(@bulk_disc1.discount_percent.to_i)
      expect(page).to have_content(@bulk_disc1.quantity_threshold)
    end

    describe 'Merchant Bulk Discount Edit' do
      it 'I see a link to edit the bulk discount.' do
        expect(page).to have_link("Edit #{@bulk_disc1.name}")
      end
       
      it 'When I click this link, I am taken to a 
        new page with a form to edit the discount' do

        click_link("Edit #{@bulk_disc1.name}")

        expect(current_path).to eq(edit_bulk_discount_path(@bulk_disc1))
      end
    end
  end
end