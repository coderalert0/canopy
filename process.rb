# frozen_string_literal: true

require_relative 'lib/github/client'
require_relative 'lib/github/processor'

# Entry point script for running the GitHub client/processor.
# Usage:
#   TOKEN=your_pat ruby process.rb https://api.github.com/repos/owner/repo
#
# Example:
#   TOKEN=github_pat_xx ruby process.rb https://api.github.com/repos/paper-trail-gem/paper_trail

token = ENV['TOKEN']
repo_url = ARGV[0]
open_flag = ARGV.include?('--open')

abort 'Usage: TOKEN=xxx ruby process.rb <repo_url> [--open]' unless token && repo_url

client = Github::Client.new(token, repo_url)
processor = Github::Processor.new(client)
processor.issues(open: open_flag)
