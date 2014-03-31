require 'date'

module AdminHelper
  def parse_logs
    request_text = `cat #{Rails.root.to_s}/log/production.log`
    request_text.split("\nStarted ").map {|x| parse_request(x)}
  end

  def parse_request(request)
    {}.tap do |out|
      begin
        lines = request.split("\n")

        data = lines[0].match(/(\w+) "([^"]+)" for ([0-9.]+) at (.+)/)
        out[:request_type] = data[1]
        out[:url] = data[2]
        out[:ip] = data[3]
        out[:request_time] = DateTime.parse(data[4])

        data = lines[1].match(/Processing by (.+) as (\w+)/)
        out[:action] = data[1]
        out[:format] = data[2]

        out[:uni_id] = lines[3].match(/Current user is \w+ \w+, (\d+)/)[1].to_i

        data = lines.last.match(/Completed (\d+) \w+ in ([0-9.]+)ms/)
        out[:response_code] = data[1].to_i
        out[:time_taken] = data[2].to_f
      rescue => e
        p [e, request]
      end
    end
  end
end