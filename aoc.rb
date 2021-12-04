require 'net/http'

def load_data(day)
	url="https://adventofcode.com/2021/day/#{day}/input"
	file=sprintf("data/%02d.d", day)
	if File.exists?(file)
		data = open(file) { |f| f.read }
	else
		data=download_data(day)
		File.open(file, 'w') {|f| f.write(data)}
	end
	data
end

def download_data(day)
	s=ENV['SESSION']
	if s.nil?
		raise "Session code not found. Please add SESSION='...' in your .env file"
	end
	http = Net::HTTP.new('adventofcode.com', 443)
	http.use_ssl = true
	path = "/2021/day/#{day}/input"
	headers = {
    'Cookie' => "session=#{s}",
  }
  resp = http.get(path, headers)
  raise "Could not download data for day #{day}" unless resp.code == '200'
  return resp.body
end