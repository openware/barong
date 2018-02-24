require "rubygems/version"
require "net/http"
require "json"
require "uri"

#
# Returns bot's username in GitHub.
#
# @return [String]
def bot_username
  ENV.fetch("BOT_USERNAME", "rubykube-bot")
end

#
# Returns bot's displayed name in commits.
#
# @return [String]
def bot_name
  ENV.fetch("BOT_NAME", "Rubykube Bot")
end

#
# Returns bot's displayed email in commits.
#
# @return [String]
def bot_email
  ENV.fetch("BOT_EMAIL", "bot@rubykube.io")
end

#
# Returns GitHub repository slug in form of :user|:organization/:repository.
#
# @return [String]
def repository_slug
  ENV.fetch("REPOSITORY_SLUG", "rubykube/peatio")
end

#
# Increments the newest available version which is in stage of development (master),
# and publishes it on the GitHub.
#
# The requirements for this to work are:
#  1) Repository has some tagged versions.
#  2) The latest version is not released yet (e.g. there is no version-specific branch like "1-3-stable").
#
# If you are on 1.1 and you want to start developing 1.2 do the following:
#  1) Create branch "1-1-stable", and push up-to-date source to it.
#  2) Push the same to master branch.
#  3) Push new commit(s) to master, and tag master as 1.2.0.
#  4) Future pushes to master will be treated as new patch version number.
#
def bump_from_master_branch
  # Get latest version of Peatio.
  return unless (latest_version = versions.last)

  # Find a branch which is specific the version.
  # Comparision is based only on major and minor version numbers since
  # these type of branches are named with a convention like: "1-0-stable", "2-4-stable", and so on.
  linked_branch = version_specific_branches.find { |b| b[:version].segments == latest_version.segments[0...2] }
  # If branch exists it means that version has been already released.
  return if linked_branch

  # Increment patch version number, tag, and push.
  candidate_version = Gem::Version.new(latest_version.segments.dup.tap { |s| s[2] += 1 }.join("."))
  tag_n_push(candidate_version.to_s) unless versions.include?(candidate_version)
end

#
# Increments the version which is in stage of support (version-specific branches only),
# and publishes it on the GitHub.
#
# The method expects branch name in form of "X-Y-stable", like "2-0-stable".
# It tags the current Git commit to the next patch number version, and pushes it to Git repository.
#
# @param name [String]
#   Branch name.
def bump_from_version_specific_branch(name)
  # This helps to ensure branch does exist.
  branch = version_specific_branches.find { |b| b[:name] == name }
  return unless branch

  # Find latest version for the branch (compare by major and minor).
  # We use find here since versions are sorted in descending order.
  latest_version = versions.reverse.find { |v| v.segments[0...2] == branch[:version].segments }
  return unless latest_version

  # Increment patch version number, tag, and push.
  candidate_version = Gem::Version.new(latest_version.segments.dup.tap { |s| s[2] += 1 }.join("."))
  tag_n_push(candidate_version.to_s) unless versions.include?(candidate_version)
end

#
# Configures Git user name & email, creates Git tag, and pushes the tag to repository.
#
# @param tag [String]
def tag_n_push(tag)
  %x( git config --global user.email "#{bot_email}" )
  %x( git config --global user.name "#{bot_name}" )
  %x( git tag #{tag} -a -m "Automatically generated tag from TravisCI build #{ENV.fetch("TRAVIS_BUILD_NUMBER")}." )
  %x( git push https://#{bot_username}:#{ENV.fetch("GITHUB_API_KEY")}@github.com/#{repository_slug} #{tag} )
end

#
# Loads all Peatio tags, and returns them in ascending order.
#
# @return [Array<Gem::Version>]
def versions
  @versions ||= github_api_authenticated_get("/repos/#{repository_slug}/tags").map do |x|
    Gem::Version.new(x.fetch("name"))
  end.sort
end

#
# Returns hash with all tagged commits as keys (SHA-1) and versions as values.
#
# @return [Hash]
#   Key is commit's SHA-1 hash, value is instance of Gem::Version.
def tagged_commits_mapping
  @commits ||= github_api_authenticated_get("/repos/#{repository_slug}/tags").each_with_object({}) do |x, memo|
    memo[x.fetch("commit").fetch("sha")] = Gem::Version.new(x.fetch("name"))
  end
end

#
# Loads all Peatio branches, selects only version-specific, and returns them.
#
# @return [Array<Hash>]
#   Array of hashes each containing "name" & "version" keys.
def version_specific_branches
  @branches ||= github_api_authenticated_get("/repos/#{repository_slug}/branches").map do |x|
    if x.fetch("name") =~ /\A(\d)-(\d)-\w+\z/
      { name: x["name"], version: Gem::Version.new($1 + "." + $2) }
    end
  end.compact
end

#
# Performs call to GitHub API and returns the response. Raises in case of non-200 status.
#
# @param path [String]
#   Request path.
# @return [Hash]
def github_api_authenticated_get(path)
  http         = Net::HTTP.new("api.github.com", 443)
  http.use_ssl = true
  response     = http.get path, "Authorization" => %[token #{ENV.fetch("GITHUB_API_KEY")}]
  if response.code.to_i == 200
    JSON.load(response.body)
  else
    raise StandardError, %[HTTP #{response.code}: "#{response.body}".]
  end
end

#
# Returns true if version has exactly 3 version segments (major, minor, patch), and all are integers.
#
# @param version [Gem::Version]
# @return [true, false]
def generic_semver?(version)
  version.segments.count == 3 && version.segments.all? { |segment| segment.match?(/\A[0-9]+\z/) }
end

# Build must not run on a fork.
bump   = ENV["TRAVIS_REPO_SLUG"] == repository_slug
# Skip PRs.
bump &&= ENV["TRAVIS_PULL_REQUEST"] == "false"
# Build must run on branch.
bump &&= !ENV["TRAVIS_BRANCH"].to_s.empty?
# GitHub API key must be available.
bump &&= !ENV["GITHUB_API_KEY"].to_s.empty?
# Build must not run on tag.
bump &&= ENV["TRAVIS_TAG"].to_s.empty?
# Ensure this commit is not tagged.
bump &&= !tagged_commits_mapping.key?(ENV["TRAVIS_COMMIT"])

if bump
  if ENV["TRAVIS_BRANCH"] == "master"
    bump_from_master_branch
  else
    bump_from_version_specific_branch(ENV["TRAVIS_BRANCH"])
  end
end
