# encoding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'data_objects/spec/command_spec'

describe DataObjects::Oracle::Command do
  it_should_behave_like 'a Command'
  # it_should_behave_like 'a Command with async'
end

describe DataObjects::Oracle::Command do

  include DataObjectsSpecHelpers

  # before :all do
  #   setup_test_environment
  # end

  describe 'running queries in parallel' do

    before :each do

      threads = []
      connections = []
      4.times do |i|
        # by default connection is not non_blocking, need to pass parameter
        connections[i] = DataObjects::Connection.new(CONFIG.uri+"?non_blocking=true")
      end

      @start = Time.now
      4.times do |i|
        threads << Thread.new do
          command = connections[i].create_command(CONFIG.sleep)
          result = command.execute_non_query
        end
      end

      threads.each{|t| t.join }
      @finish = Time.now

      connections.each {|c| c.close}
    end

    # after :each do
    #   @connection.close
    # end

    FINISH_IN_SECONDS = RUBY_VERSION > "1.9" ? 2 : 3

    it "should finish within #{FINISH_IN_SECONDS} seconds" do
      pending_if("Ruby on Windows doesn't support asynchronious operations", WINDOWS) do
        # puts "DEBUG: execution time = #{@finish - @start} seconds"
        (@finish - @start).should < FINISH_IN_SECONDS
      end
    end

  end
end
