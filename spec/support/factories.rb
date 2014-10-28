FactoryGirl.define do
  factory :song do
    data { build(:remote_song) }
  end

  factory :remote_song, class: ActiveSupport::HashWithIndifferentAccess do
    id 172471838
    title "deadmau5 - Some Chords (Dillon Francis Remix)"
    duration 120_000
    artwork_url "https://i1.sndcdn.com/artworks-000094203188-eu8ewg-large.jpg"
    permalink_url "http://soundcloud.com/mau5trap/deadmau5-some-chords-dillon-francis-remix"

    initialize_with do
      ActiveSupport::HashWithIndifferentAccess.new(attributes)
    end
  end
end
