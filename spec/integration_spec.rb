require "spec_helper"

describe "bundle install against gemstash" do
  let(:dir) { bundle_path(bundle) }

  before(:all) do
    speaker_deps = {
      :name => "speaker",
      :number => "0.1.0",
      :platform => "ruby",
      :dependencies => []
    }

    @rubygems_server = SimpleServer.new("127.0.0.1", port: 9043)
    @rubygems_server.mount_gem_deps("speaker", [speaker_deps])
    @rubygems_server.mount_gem("speaker", "0.1.0")
    @rubygems_server.start
    @gemstash = TestGemstashServer.new(port: 9042,
                                       config: {
                                         :base_path => TEST_BASE_PATH,
                                         :rubygems_url => @rubygems_server.url
                                       })
    @gemstash.start
  end

  after(:all) do
    @gemstash.stop
    @rubygems_server.stop
  end

  after do
    clean_bundle bundle
  end

  context "with default upstream gems" do
    let(:bundle) { "integration_spec/default_upstream_gems" }

    it "successfully bundles" do
      expect(execute("bundle", dir: dir)).to exit_success
      expect(execute("bundle exec speaker hi", dir: dir)).to exit_success.and_output("Hello world\n")
    end
  end

  context "with upstream gems" do
    let(:bundle) { "integration_spec/upstream_gems" }

    it "successfully bundles" do
      expect(execute("bundle", dir: dir)).to exit_success
      expect(execute("bundle exec speaker hi", dir: dir)).to exit_success.and_output("Hello world\n")
    end

    it "can successfully bundle twice" do
      expect(execute("bundle", dir: dir)).to exit_success
      expect(execute("bundle exec speaker hi", dir: dir)).to exit_success.and_output("Hello world\n")

      clean_bundle bundle

      expect(execute("bundle", dir: dir)).to exit_success
      expect(execute("bundle exec speaker hi", dir: dir)).to exit_success.and_output("Hello world\n")
    end
  end

  context "with redirecting gems" do
    let(:bundle) { "integration_spec/redirecting_gems" }

    it "successfully bundles" do
      expect(execute("bundle", dir: dir)).to exit_success
      expect(execute("bundle exec speaker hi", dir: dir)).to exit_success.and_output("Hello world\n")
    end
  end

  context "with private gems" do
    before do
      # TODO: Push the speaker gem to the test gemstash server
    end

    let(:bundle) { "integration_spec/private_gems" }

    xit "successfully bundles" do
      expect(execute("bundle", dir: dir)).to exit_success
      expect(execute("bundle exec speaker hi", dir: dir)).to exit_success.and_output("Hello world\n")
    end
  end
end
