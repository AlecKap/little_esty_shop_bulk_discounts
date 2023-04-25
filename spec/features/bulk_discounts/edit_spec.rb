require 'rails_helper'

RSpec.describe 'Bulk Dicsount edit page' do
  before(:each) do
    test_data
    visit edit_bulk_discount_path(@bulk_disc1)
  end

  describe 'As a merchant, when i visit the Bulk Discount edit page' do
    it 'I see a form to edit the bulk discount and I see that the 
      discounts current attributes are pre-poluated in the form' do 
      expect(page).to have_field("Discount Name", with: "#{@bulk_disc1.name}")
      expect(page).to have_field("Discount Percent", with: "#{@bulk_disc1.discount_percent}")
      expect(page).to have_field("Quantity Threshold", with: "#{@bulk_disc1.quantity_threshold}")
      expect(page).to have_button("Update Bulk discount")
    end
    
    it 'When I change any/all of the information and click submit
      I am redirected to the bulk discounts show page
      and see that the discounts attributes have been updated' do
      expect(current_path).to eq(edit_bulk_discount_path(@bulk_disc1))
      
      fill_in 'Discount Name', with: "Crazy Deals"
      fill_in 'Discount Percent', with: 0.15
      fill_in 'Quantity Threshold', with: 10
      
      click_button 'Update Bulk discount'
      save_and_open_page
      expect(current_path).to eq(bulk_discount_path(@bulk_disc1))
      expect(page).to have_content("Bulk Discount Name: Crazy Deals")
      expect(page).to have_content("Discount Percentage: 15%")
      expect(page).to have_content("Quantity Threshold: 10")
    end

    it 'if I leave a field empty, the discount is not updated,
      I am not redirected back to the discount show page,
      and I am asked to fill out the form correctly.' do
      expect(current_path).to eq(edit_bulk_discount_path(@bulk_disc1))
      
      fill_in 'Discount Name', with: ""
      fill_in 'Discount Percent', with: 15.00
      fill_in 'Quantity Threshold', with: 10
      
      click_button 'Update Bulk discount'

      expect(page).to have_field("Discount Name")
      expect(page).to have_field("Discount Percent")
      expect(page).to have_field("Quantity Threshold")
      expect(page).to have_button("Update Bulk discount")
      expect(page).to have_content("You MUST NOT leave any field blank!")
    end
  end
end
