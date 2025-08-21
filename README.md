# GitHub REST Client (Ruby)

This is a ruby command-line application to fetch and display GitHub issues from any public repository using the GitHub REST API. Features include fetching **open or closed issues**, automatically handling **pagination** to retrieve all issues, displaying issues sorted by `created_at` (for open issues) or `closed_at` (for closed issues), minimal dependencies (`httparty` and `logger`), and full test coverage with **RSpec + WebMock**.

To set up, clone the repository and install dependencies:

```bash
git clone https://github.com/coderalert0/canopy
cd canopy
bundle install
```

Export your GitHub personal access token:
```
export TOKEN=your_personal_access_token
```

To fetch closed issues from a repository:
```
ruby process.rb https://api.github.com/repos/paper-trail-gem/paper_trail
```

To fetch open issues, pass the --open flag:
```
ruby process.rb https://api.github.com/repos/paper-trail-gem/paper_trail --open
```

Sample output:
```
Polymorphic `whodunnit` - closed - Closed at: 2025-07-28T02:11:46Z
Homogenize the effects of the `synchronize_version_creation_timestamp` option - closed - Closed at: 2025-07-14T02:11:34Z
Homogenize effects of synchronize_version_creation_timestamp for create event - closed - Closed at: 2025-07-14T02:11:33Z
```

Run tests using:
```
bundle exec rspec
```

Notes: only the REST API is implemented (no GraphQL), pagination is automatic, logger is used for formatted output, fully tested with mock responses