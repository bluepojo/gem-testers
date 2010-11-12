require 'spec_helper'

describe TestResultsController do

  before :all do
    @results_yaml = <<-YAML
--- 
:arch: x86_64-linux
:vendor: unknown
:os: linux
:machine_arch: x86_64
:name: methlab
:version: !ruby/object:Gem::Version 
  prerelease: false
  segments: 
  - 0
  - 1
  - 0
  version: 0.1.0
:result: true
:test_output: |
  /home/josiah/.rvm/rubies/ruby-1.9.2-p0/bin/ruby -I"lib:lib" "/home/josiah/.rvm/rubies/ruby-1.9.2-p0/lib/ruby/1.9.1/rake/rake_test_loader.rb" "test/test_checks.rb" "test/test_integrate.rb" "test/test_inline.rb" "test/test_defaults.rb" 
  Loaded suite /home/josiah/.rvm/rubies/ruby-1.9.2-p0/lib/ruby/1.9.1/rake/rake_test_loader
  Started
  ............

YAML
  end

  it 'should accept test results yaml and store it' do
    r = Factory.create(:rubygem, :name => 'methlab')
    n = Factory.create(:version, :rubygem_id => r.id, :number => '0.1.0')
    
    post :create, 'results' => @results_yaml

    response.body.should == Response.new(:success).to_json

    result = TestResult.last

    output = "/home/josiah/.rvm/rubies/ruby-1.9.2-p0/bin/ruby -I\"lib:lib\" \"/home/josiah/.rvm/rubies/ruby-1.9.2-p0/lib/ruby/1.9.1/rake/rake_test_loader.rb\" \"test/test_checks.rb\" \"test/test_integrate.rb\" \"test/test_inline.rb\" \"test/test_defaults.rb\" \nLoaded suite /home/josiah/.rvm/rubies/ruby-1.9.2-p0/lib/ruby/1.9.1/rake/rake_test_loader\nStarted\n............\n"
    {
      :architecture => 'x86_64-linux',
      :vendor => 'unknown',
      :operating_system => 'linux',
      :machine_architecture => 'x86_64',
      :result => true,
      :test_output => output,
      :rubygem => r,
      :version => n
    }.each do |key, value|
      result.send(key).should == value
    end
    
  end

end