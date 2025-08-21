# frozen_string_literal: true

require 'json'
require 'logger'

module Github
  # Processor for formatting and printing GitHub issues.
  # Depends on the Github::Client for fetching data.
  class Processor
    # @param client [Github::Client] REST client instance
    # @param logger [Logger] optional logger for output
    def initialize(client, logger: Logger.new($stdout))
      @client = client
      @logger = logger
    end

    # Fetch and print issues, sorted by date
    #
    # @param open [Boolean] true for open issues, false for closed
    # @return [void]
    def issues(open: true)
      state = open ? 'open' : 'closed'
      issues = @client.paginate("/issues?state=#{state}&per_page=100")

      sorted_issues = issues.sort_by do |issue|
        state == 'closed' ? issue['closed_at'] : issue['created_at']
      end.reverse

      sorted_issues.each do |issue|
        message = if issue['state'] == 'closed'
                    "#{issue['title']} - #{issue['state']} - Closed at: #{issue['closed_at']}"
                  else
                    "#{issue['title']} - #{issue['state']} - Created at: #{issue['created_at']}"
                  end

        @logger.info(message)
      end
    end
  end
end
