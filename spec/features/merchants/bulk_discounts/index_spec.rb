require 'rails_helper'

RSpec.describe 'dashboard/bulk_discounts index spec'do
  before :each do
    test_data
    visit merchant_bulk_discounts_path(@merchant1)
  end
    
  describe 'As a merchant when I visit my bulk discount index page' do
    it 'I see all of my bulk discounts including their percentage discount and quantity thresholds' do
      within "#bulk_discount_#{@bulk_disc1.id}" do
        expect(page).to have_content(@bulk_disc1.name)
        expect(page).to have_content(@bulk_disc1.discount_percent * 100)
        expect(page).to have_content(@bulk_disc1.quantity_threshold)
        expect(page).to_not have_content(@bulk_disc2.name)
        expect(page).to_not have_content(@bulk_disc2.discount_percent * 100)
        expect(page).to_not have_content(@bulk_disc2.quantity_threshold)
      end
      
      within "#bulk_discount_#{@bulk_disc2.id}" do
        expect(page).to have_content(@bulk_disc2.name)
        expect(page).to have_content(@bulk_disc2.discount_percent * 100)
        expect(page).to have_content(@bulk_disc2.quantity_threshold)
        expect(page).to_not have_content(@bulk_disc1.name)
        expect(page).to_not have_content(@bulk_disc1.discount_percent * 100)
        expect(page).to_not have_content(@bulk_disc1.quantity_threshold)
      end
    end

    it 'each bulk discounts name links to its show page' do 
      save_and_open_page
      within "#bulk_discount_#{@bulk_disc1.id}" do
        expect(page).to have_link "#{@bulk_disc1.name}"
        click_link "#{@bulk_disc1.name}"
        
        expect(current_path).to eq(bulk_discount_path(@bulk_disc1))
      end
      
      visit merchant_bulk_discounts_path(@merchant1)
      
      within "#bulk_discount_#{@bulk_disc2.id}" do
        expect(page).to have_link "#{@bulk_disc2.name}"
        
        click_link "#{@bulk_disc2.name}"
        
        expect(current_path).to eq(bulk_discount_path(@bulk_disc2))
      end
    end
    
    it 'I see a link to create a new discount, 
      when I click this link I am taken to a new page ' do
      expect(page).to have_link "Create a new Bulk Discount"

      click_link "Create a new Bulk Discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1))
    end

    describe 'Merchant Bulk Discount Delete' do
      it 'next to each bulk discount I see a link to delete it' do
        within "#bulk_discount_#{@bulk_disc1.id}" do
          expect(page).to have_button("Delete #{@bulk_disc1.name}")
        end

        within "#bulk_discount_#{@bulk_disc2.id}" do
          expect(page).to have_button("Delete #{@bulk_disc2.name}")
        end
      end
    
      it 'when I click this link, I am redirected back to the bulk discounts
        index page And I no longer see the discount listed' do
        within "#bulk_discount_#{@bulk_disc1.id}" do
          
          click_button("Delete #{@bulk_disc1.name}")
        end
        expect(page).to_not have_content(@bulk_disc1.name)
        
        within "#bulk_discount_#{@bulk_disc2.id}" do

          click_button("Delete #{@bulk_disc2.name}")
        end
        expect(page).to_not have_content(@bulk_disc2.name)
      end

      it 'I see the name and date of the next 3 upcoming US holidays' do
        holidays = HolidayFacade.new.holiday_info
        
        within "#upcoming_holidays" do
          expect(page).to have_content("Next Three Upcoming Holidays")
          expect(page).to have_content("#{holidays[0].name}")
          expect(page).to have_content("#{holidays[0].date}")
          expect(page).to have_content("#{holidays[1].name}")
          expect(page).to have_content("#{holidays[1].date}")
          expect(page).to have_content("#{holidays[2].name}")
          expect(page).to have_content("#{holidays[2].date}")
        end

        expect(holidays).to be_a(Array)
        expect(holidays.first).to be_a(Holiday)
        expect(holidays.size).to be(3)
      end
    end
  end
end