class HolidayFacade

  def holiday_info
    holidays = service.list_of_holidays[0..2]
    holidays.map do |holiday|
      Holiday.new(holiday)
    end
  end
  
  def service
    NagerService.new
  end
end