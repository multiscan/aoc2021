require 'net/http'

class BaseAOC
  def self.from_data(day=self::DAY)
    fn = sprintf("data/%02d.d", day)
    data = load_file(fn)
    unless data
      data=download_data(day)
      File.open(file, 'w') {|f| f.write(data)}
    end
    self.new(data)
  end

  def self.from_test_data(day=self::DAY)
    fn = sprintf("testdata/%02d.d", day)
    data=load_file(fn)
    raise "Missing or unreadable test data file #{fn}" unless data
    self.new(data)
  end

 private

  def self.load_file(path)
    if File.exists?(path)
      open(path) { |f| f.read }
    else
      nil
    end
  end

  def self.download_data(day)
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
end