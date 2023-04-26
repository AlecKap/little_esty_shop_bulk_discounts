class NagerService
  def get_url(url)
    response = HTTParty.get(url)
    parsed_image = JSON.parse(response.body, symbolize_names: true)
  end

  def list_of_holidays
    get_url("https://date.nager.at/api/v3/NextPublicHolidays/US")
  end
end