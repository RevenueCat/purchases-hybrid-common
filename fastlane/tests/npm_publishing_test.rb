require 'minitest/autorun'
require 'json'
require 'tmpdir'
require 'fileutils'

class NpmPublishingTest < Minitest::Test
  # Load the helper without initializing Fastlane's release lanes.
  fastfile = File.expand_path('../Fastfile', __dir__)
  source = File.read(fastfile)[/^def build_and_publish_npm_package\(.*?(?=^def current_version_number)/m]
  class_eval(source, fastfile, File.readlines(fastfile).index { |line| line.start_with?('def build_and_publish_npm_package(') } + 1)

  def setup
    @root = Dir.mktmpdir
    FileUtils.mkdir_p(File.join(@root, 'package'))
    File.write(File.join(@root, 'package/package.json'), JSON.generate(name: '@revenuecat/test'))
    @version = '19.17.1'
    @latest = '20.7.0'
    @commands = []
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def test_backport_keeps_latest_on_the_newer_release
    build_and_publish_npm_package('package')
    assert_equal ['npm', 'publish', '--access', 'public', '--tag', 'release-19'], @commands.last
  end

  def test_new_release_uses_latest_explicitly
    @version = '20.8.0'
    build_and_publish_npm_package('package')
    assert_equal ['npm', 'publish', '--access', 'public', '--tag', 'latest'], @commands.last
  end

  def test_older_release_within_the_same_major_keeps_latest
    @version = '20.6.2'
    build_and_publish_npm_package('package')
    assert_equal ['npm', 'publish', '--access', 'public', '--tag', 'release-20'], @commands.last
  end

  def test_invalid_registry_version_prevents_publishing
    @latest = 'invalid'
    assert_raises(ArgumentError) { build_and_publish_npm_package('package') }
    refute @commands.any? { |command| command[0..1] == ['npm', 'publish'] }
  end

  def test_prerelease_uses_next_without_querying_latest
    @version = '21.0.0-beta.1'
    build_and_publish_npm_package('package')
    assert_equal ['npm', 'publish', '--access', 'public', '--tag', 'next'], @commands.last
    refute @commands.any? { |command| command[0..1] == ['npm', 'view'] }
  end

  def test_dry_run_only_packs_without_querying_latest
    build_and_publish_npm_package('package', dry_run: true)
    assert_equal ['npm', 'pack'], @commands.last
    refute @commands.any? { |command| command[0..1] == ['npm', 'view'] }
  end

  def current_version_number = @version
  def get_root_folder = @root

  def sh(*command, **_options)
    command = command.first if command.length == 1 && command.first.is_a?(Array)
    @commands << command
    command[0..1] == ['npm', 'view'] ? @latest : ''
  end
end

module UI
  def self.message(*) = nil
end
