require "rails_helper"

describe SongsHelper, "#date_to_weekday" do
  it "returns date as a weekday" do
    date   = 3.days.ago
    result = date_to_weekday(date)

    expect(result).to eq(date.strftime("%A"))
  end

  it "returns relative time for today" do
    result = date_to_weekday(Date.today)

    expect(result).to eq("Today")
  end

  it "returns relative time for yesterday" do
    result = date_to_weekday(Date.yesterday)

    expect(result).to eq("Yesterday")
  end
end
