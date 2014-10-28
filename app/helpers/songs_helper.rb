module SongsHelper
  def date_to_weekday(date)
    if date.today?
      "Today"
    elsif Date.yesterday == date
      "Yesterday"
    else
      date.strftime("%A")
    end
  end
end
