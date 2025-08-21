# frozen_string_literal: true

require 'httparty'
require 'json'

module Github
  # Client for interacting with GitHub REST API
  # Handles authentication, pagination, and GET requests.
  class Client
    def initialize(token, repo_url)
      @token = token
      @repo_url = repo_url
    end

    # Fetch all pages of results for a given API path
    #
    # @param path [String] API path including query params
    # @return [Array<Hash>] concatenated results from all pages
    #
    # Separation of concerns ensures the pagination logic can be reused across different API calls
    # without changing the processor or other client code.
    def paginate(path)
      results = []
      url = "#{@repo_url}#{path}"

      loop do
        response = HTTParty.get(url, headers: headers)

        case response.code
        when 200
          results.concat(JSON.parse(response.body))
        when 401
          raise 'Unauthorized: check your GitHub token'
        when 403
          warn 'Rate limited by GitHub API. Try again later.'
          break
        when 404
          raise "Resource not found at #{url}"
        else
          raise "Unexpected GitHub API error: #{response.code} - #{response.message}"
        end

        links = parse_links(response.headers['link'])
        break unless links['next']

        url = links['next']
      end

      results
    end

    private

    # Standard headers for GitHub API requests, including token auth.
    #
    # @return [Hash]
    def headers
      {
        'Authorization' => "Bearer #{@token}",
        'User-Agent' => 'Github Client'
      }
    end

    # Parse the Link header into a hash, e.g.:
    # '<url>; rel="next", <url>; rel="last"' => { "next" => url, "last" => url }
    #
    # @param header [String, nil]
    # @return [Hash]
    def parse_links(header)
      return {} unless header

      header.split(',').map do |part|
        url, rel = part.match(/<(.+)>; rel="(.+)"/).captures
        [rel, url]
      end.to_h
    end
  end
end
