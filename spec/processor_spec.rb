# frozen_string_literal: true

require 'spec_helper'
require 'github/client'
require 'github/processor'

RSpec.describe Github::Processor do
  let(:token) { 'fake_token' }
  let(:repo_url) { 'https://api.github.com/repos/fake_owner/fake_repo' }
  let(:client) { Github::Client.new(token, repo_url) }
  let(:processor) { described_class.new(client) }

  describe '#issues' do
    it 'prints closed issues sorted by closed_at descending' do
      stub_request(:get, "#{repo_url}/issues?state=closed&per_page=100")
        .to_return(
          status: 200,
          body: [
            { 'title' => 'Issue 1', 'state' => 'closed', 'closed_at' => '2025-01-01T00:00:00Z' },
            { 'title' => 'Issue 2', 'state' => 'closed', 'closed_at' => '2025-02-01T00:00:00Z' }
          ].to_json
        )

      expect { processor.issues(open: false) }.to output(/Issue 2.*Issue 1/m).to_stdout
    end

    it 'prints open issues sorted by created_at descending' do
      stub_request(:get, "#{repo_url}/issues?state=open&per_page=100")
        .to_return(
          status: 200,
          body: [
            { 'title' => 'Open 1', 'state' => 'open', 'created_at' => '2025-03-01T00:00:00Z' },
            { 'title' => 'Open 2', 'state' => 'open', 'created_at' => '2025-04-01T00:00:00Z' }
          ].to_json
        )

      expect { processor.issues(open: true) }.to output(/Open 2.*Open 1/m).to_stdout
    end
  end
end
