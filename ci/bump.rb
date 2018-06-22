# encoding: UTF-8
# frozen_string_literal: true

require "rubygems/version"
require "net/http"
require "json"
require "uri"
require "cgi"

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
  ENV.fetch("REPOSITORY_SLUG", "rubykube/barong")
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
  # Get latest version of Barong.
  return unless (latest_version = versions.last)

  # Find a branch which is specific the version.
  # Comparision is based only on major and minor version numbers since
  # these type of branches are named with a convention like: "1-0-stable", "2-4-stable", and so on.
  linked_branch = version_specific_branches.find { |b| b[:version].segments == latest_version.segments[0...2] }
  # If branch exists it means that version has been already released.
  return if linked_branch

  # Increment patch version number, tag, and push.
  candidate_version = Gem::Version.new(latest_version.segments.dup.tap { |s| s[2] += 1 }.join("."))
  tag_n_push(candidate_version.to_s, name: "master") unless versions.include?(candidate_version)
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
  tag_n_push(candidate_version.to_s, branch) unless versions.include?(candidate_version)
end

#
# Configures Git user name & email,
# updates version at lib/barong/version.rb,
# creates Git tag, and pushes all the changes made to repository.
#
# @param tag [String]
def tag_n_push(tag, branch)
  [ %( V="#{tag}" bin/bump ),
    %( git config --global user.email "#{bot_email}" ),
    %( git config --global user.name "#{bot_name}" ),
    %( git remote add authenticated-origin https://#{bot_username}:#{ENV.fetch("GITHUB_API_KEY")}@github.com/#{repository_slug} ),
    %( git checkout -b release ),
    %( git add lib/ ),
    %( git commit -m "[ci skip] Bump #{tag}." ),
    %( git push authenticated-origin release:#{branch.fetch(:name)} ),
    %( git tag #{tag} -a -m "Automatically generated tag from TravisCI build #{ENV.fetch("TRAVIS_BUILD_NUMBER")}." ),
    %( git push authenticated-origin #{tag} )
  ].map(&:strip).each do |command|
    unless Kernel.system(command)
      # Prevent GitHub API key from being published.
      command.gsub!(ENV["GITHUB_API_KEY"], "(secret)")
      raise %(Command "#{command}" exited with status #{$?.exitstatus || "(unavailable)"}.)
    end
  end
end

#
# Loads all Barong tags, and returns them in ascending order.
#
# @return [Array<Gem::Version>]
def versions
  @versions ||= github_api_load_collection("/repos/#{repository_slug}/tags").map do |x|
    Gem::Version.new(x.fetch("name"))
  end.sort
end

#
# Returns hash with all tagged commits as keys (SHA-1) and versions as values.
#
# @return [Hash]
#   Key is commit's SHA-1 hash, value is instance of Gem::Version.
def tagged_commits_mapping
  @commits ||= github_api_load_collection("/repos/#{repository_slug}/tags").each_with_object({}) do |x, memo|
    memo[x.fetch("commit").fetch("sha")] = Gem::Version.new(x.fetch("name"))
  end
end

#
# Loads all Barong branches, selects only version-specific, and returns them.
#
# @return [Array<Hash>]
#   Array of hashes each containing "name" & "version" keys.
def version_specific_branches
  @branches ||= github_api_load_collection("/repos/#{repository_slug}/branches").map do |x|
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
# @param query [Hash]
#   Query parameters.
# @return [Hash, Array]
def github_api_authenticated_get(path, query = {})
  http         = Net::HTTP.new("api.github.com", 443)
  http.use_ssl = true
  query_string = query.map { |(k, v)| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&")
  response     = http.get "#{path}?#{query_string}", "Authorization" => %[token #{ENV.fetch("GITHUB_API_KEY")}]
  if response.code.to_i == 200
    JSON.load(response.body)
  else
    raise StandardError, %[HTTP #{response.code}: "#{response.body}".]
  end
end

#
# Fetches full collection using GitHub API (performs pagination under the hood).
#
# @param path [String]
#   The collection request path.
# @return [Array]
def github_api_load_collection(path)
  objects = []
  page    = 0
  loop do
    loaded   = github_api_authenticated_get(path, page: page += 1, per_page: 100)
    objects += loaded
    break if loaded.empty?
  end
  objects
end

#
# Returns true if version has exactly 3 version segments (major, minor, patch), and all are integers.
#
# @param version [Gem::Version]
# @return [true, false]
def generic_semver?(version)
  version.segments.count == 3 && version.segments.all? { |segment| segment.match?(/\A[0-9]+\z/) }
end

unless ENV["TRAVIS_REPO_SLUG"] == repository_slug
  Kernel.abort "Bumping version aborted: invalid repository (expected #{repository_slug}, got #{ENV["TRAVIS_REPO_SLUG"]})."
end

unless ENV["TRAVIS_PULL_REQUEST"] == "false"
  Kernel.abort "Bumping version aborted: GitHub pull request detected."
end

if ENV["TRAVIS_BRANCH"].to_s.empty?
  Kernel.abort "Bumping version aborted: could not detect Git branch."
end

if ENV["GITHUB_API_KEY"].to_s.empty?
  Kernel.abort "Bumping version aborted: GitHub API key is missing."
end

unless ENV["TRAVIS_TAG"].to_s.empty?
  Kernel.abort "Bumping version aborted: the build has been triggered by Git tag."
end

if tagged_commits_mapping.key?(ENV["TRAVIS_COMMIT"])
  Kernel.abort "Bumping version aborted: commit #{ENV["TRAVIS_COMMIT"]} is already tagged."
end

if ENV["TRAVIS_BRANCH"] == "master"
  if ENV["INCREMENT_PATCH_LEVEL_ON_MASTER"]
    bump_from_master_branch
  else
    Kernel.abort "Bumping version aborted: bumping disabled for master branch."
  end
else
  bump_from_version_specific_branch(ENV["TRAVIS_BRANCH"])
end