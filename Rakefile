desc "Scrapes the JSON and outputs into htdocs/index.json"
task :update_cellar do
  root = File.dirname(__FILE__)
  `ruby "#{root + "/scrape_yourround.rb"}" > "#{root + "/htdocs/index.json"}"`
end
