Date::DATE_FORMATS[:ordinalized] = lambda do |date|
  date.strftime("%B %-d").sub(/\d+/) do |day|
    day.to_i.ordinalize
  end
end
