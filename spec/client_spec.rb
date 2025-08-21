# frozen_string_literal: true

require 'spec_helper'
require 'github/client'
require 'github/processor'

RSpec.describe Github::Client do
  let(:token) { 'fake_token' }
  let(:repo_url) { 'https://api.github.com/repos/fake_owner/fake_repo' }
  let(:client) { described_class.new(token, repo_url) }

  describe '#paginate' do
    it 'fetches all pages and concatenates results' do
      # Mock page 1
      stub_request(:get, "#{repo_url}/issues?state=open&per_page=100")
        .to_return(
          status: 200,
          body: [{ 'id' => 1, 'title' => 'First issue' }].to_json,
          headers: { 'Link' => '<https://api.github.com/repos/fake_owner/fake_repo/issues?page=2>; rel="next"' }
        )

      # Mock page 2
      stub_request(:get, "#{repo_url}/issues?page=2")
        .to_return(
          status: 200,
          body: [{ 'id' => 2, 'title' => 'Second issue' }].to_json
        )

      result = client.paginate('/issues?state=open&per_page=100')
      expect(result.size).to eq(2)
      expect(result.map { |i| i['title'] }).to eq(['First issue', 'Second issue'])
    end

    it 'handles rate limiting gracefully' do
      stub_request(:get, "#{repo_url}/issues?state=open&per_page=100")
        .to_return(status: 403)

      expect do
        client.paginate('/issues?state=open&per_page=100')
      end.not_to raise_error
    end
  end

  describe '#parse_links' do
    it 'returns an empty hash when header is nil' do
      expect(client.send(:parse_links, nil)).to eq({})
    end

    it 'parses a single next link correctly' do
      header = '<https://api.github.com/repos/fake_owner/fake_repo/issues?page=2>; rel="next"'
      expect(client.send(:parse_links, header)).to eq({
                                                        'next' => 'https://api.github.com/repos/fake_owner/fake_repo/issues?page=2'
                                                      })
    end

    it 'parses multiple links correctly' do
      header = '<https://api.github.com/repos/fake_owner/fake_repo/issues?page=2>; rel="next", ' \
               '<https://api.github.com/repos/fake_owner/fake_repo/issues?page=4>; rel="last", ' \
               '<https://api.github.com/repos/fake_owner/fake_repo/issues?page=1>; rel="first", ' \
               '<https://api.github.com/repos/fake_owner/fake_repo/issues?page=1>; rel="prev"'

      expect(client.send(:parse_links, header)).to eq({
                                                        'next' => 'https://api.github.com/repos/fake_owner/fake_repo/issues?page=2',
                                                        'last' => 'https://api.github.com/repos/fake_owner/fake_repo/issues?page=4',
                                                        'first' => 'https://api.github.com/repos/fake_owner/fake_repo/issues?page=1',
                                                        'prev' => 'https://api.github.com/repos/fake_owner/fake_repo/issues?page=1'
                                                      })
    end
  end
end
