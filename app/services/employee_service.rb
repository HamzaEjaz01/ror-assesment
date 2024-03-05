require 'net/http'
require 'net/https'

class EmployeeService
  API_URL = 'https://dummy-employees-api-8bad748cda19.herokuapp.com/employees'.freeze

  class << self
    def fetch_employees(page = nil)
      uri = build_uri(page: page)
      parse_response(Net::HTTP.get(uri))
    end

    def fetch_employee(id)
      uri = build_uri(id: id)
      parse_response(Net::HTTP.get(uri))
    end

    def create_employee(params)
      uri = build_uri
      send_request(uri, Net::HTTP::Post, params)
    end

    def update_employee(id, params)
      uri = build_uri(id: id)
      send_request(uri, Net::HTTP::Put, params)
    end

    private

    def build_uri(page: nil, id: nil)
      url = API_URL
      url += "/#{id}" if id
      url += "?page=#{page}" if page && !url.include?("?page=")
      URI(url)
    end

    def send_request(uri, method, params = nil)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      request = method.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = params.to_json if params

      response = http.request(request)
      parse_response(response.body)
    end

    def parse_response(response_body)
      JSON.parse(response_body)
    end
  end
end
