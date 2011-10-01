require "rubygems"
require "nokogiri"
require "json"
require "curb"

url = "http://www.yourround.co.uk/Pub/Leeds/Mr-Foley's-Cask-Ale-House/LS1-5RG.aspx"
body_str = Curl::Easy.http_get(url).body_str
# body_str = DATA.read
doc = Nokogiri::HTML(body_str)

drinks = doc.css(".popupMenu")

drinks = drinks.select {|d| d[:id] =~ /ctl00_ctl00_MenuContentPlaceHolder_MainContentPlaceHolder_ListView\d+_ctrl\d+_ctl\d+/i }

class Drink
  attr_accessor :brewer, :beer, :type, :abv, :notes

  def initialize brewer, beer, type, abv, notes
    self.abv = abv || ""
    self.brewer = brewer
    self.beer = beer
    self.type = type
    self.notes = notes.gsub /\s{2,}/, " "
  end

  def to_json *args
    {
      :brewer => brewer.to_s,
      :beer => beer.to_s,
      :type => type.to_s,
      :abv => abv.to_s,
      :notes => notes.to_s
    }.to_json *args
  end
end

drinks = drinks.map do |d|
  x = d.text.strip
  type = x[/Beer Type: (.+)ABV/, 1]
  abv = x[/ABV: ([\d%.]+)/, 1]
  notes = x[/Tasting Notes: (.+)/, 1]
  row = d.parent.parent
  brewer = row.next_sibling.children.first.text.strip
  beer = row.next_sibling.next_sibling.children.first.text.strip

  Drink.new(brewer, beer, type, abv, notes)
end

print({"current" => drinks}.to_json)
