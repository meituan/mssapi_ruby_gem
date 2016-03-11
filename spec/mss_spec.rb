# Copyright 2011-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

require 'spec_helper'
require 'thread'

describe MSS do

  context '#config' do

    it 'should return a configuration object' do
      MSS.config.should be_a(MSS::Core::Configuration)
    end

    it 'should pass options through to Configuration#with' do
      previous = MSS.config
      previous.should_receive(:with).with(:access_key_id => "FOO")
      MSS.config(:access_key_id => "FOO")
    end

    it 'should return the same config when no options are added' do
      MSS.config.should be(MSS.config)
    end

  end

  context '#stub!' do

    it 'should set the config :stub_clients to true' do
      MSS.should_receive(:config).with(:stub_requests => true)
      MSS.stub!
    end

  end

  context '#start_memoizing' do

    after(:each) { MSS.stop_memoizing }

    it 'should enable memoization' do
      MSS.start_memoizing
      MSS.memoizing?.should be_truthy
    end

    it 'should return nil' do
      MSS.start_memoizing.should be_nil
    end

    it 'should not extend into other threads' do
      MSS.start_memoizing
      Thread.new do
        MSS.memoizing?.should be_falsey
      end.join
    end

  end

  context '#stop_memoizing' do

    it 'should do nothing if memoization is disabled' do
      MSS.memoizing?.should be_falsey
      MSS.stop_memoizing
      MSS.memoizing?.should be_falsey
    end

    it 'should stop memoization' do
      MSS.start_memoizing
      MSS.memoizing?.should be_truthy
      MSS.stop_memoizing
      MSS.memoizing?.should be_falsey
    end

    it 'should only affect the current thread' do
      MSS.start_memoizing
      t = Thread.new do
        MSS.start_memoizing
        Thread.stop
        MSS.memoizing?.should be_truthy
      end
      Thread.pass until t.stop?
      MSS.stop_memoizing
      t.wakeup
      t.join
    end

  end

  context '#memoize' do

    before(:each) do
      MSS.stub(:start_memoizing)
      MSS.stub(:stop_memoizing)
    end

    it 'should call start_memoization' do
      MSS.should_receive(:start_memoizing)
      MSS.memoize { }
    end

    it 'should call stop_memoization at the end of the block' do
      MSS.memoize do
        MSS.should_receive(:stop_memoizing)
      end
    end

    it 'should call stop_memoization for an exceptional exit' do
      MSS.memoize do
        MSS.should_receive(:stop_memoizing)
        raise "FOO"
      end rescue nil
    end

    it 'should return the return value of the block' do
      MSS.memoize { "foo" }.should == "foo"
    end

    context 'while already memoizing' do

      it 'should do nothing' do
        MSS.stub(:memoizing?).and_return(true)
        MSS.should_not_receive(:start_memoizing)
        MSS.should_not_receive(:stop_memoizing)
        MSS.memoize { }
      end

    end

  end

  shared_examples_for "memoization cache" do

    context 'memoizing' do

      before(:each) { MSS.start_memoizing }
      after(:each) { MSS.stop_memoizing }

      it 'should return a resource cache object' do
        MSS.send(method).should be_a(cache_class)
      end

      it 'should return a different cache each time memoization is enabled' do
        cache = MSS.send(method)
        MSS.stop_memoizing
        MSS.start_memoizing
        MSS.send(method).should_not be(cache)
      end

      it 'should return a different cache in each thread' do
        cache = MSS.send(method)
        Thread.new do
          MSS.memoize { MSS.send(method).should_not be(cache) }
        end.join
      end

    end

    context 'not memoizing' do

      it 'should return nil' do
        MSS.send(method).should be_nil
      end

    end

  end

  context '#resource_cache' do
    let(:method) { :resource_cache }
    let(:cache_class) { MSS::Core::ResourceCache }
    it_should_behave_like "memoization cache"
  end

  context '#response_cache' do
    let(:method) { :response_cache }
    let(:cache_class) { MSS::Core::ResponseCache }
    it_should_behave_like "memoization cache"
  end

  context '#config' do

    context "SERVICE_region" do

      it 'returns REGION when endpoint is SERVICE.REGION.amazonmss.com' do
        MSS.config.stub(:ec2_endpoint).and_return('ec2.REGION.amazonmss.com')
        MSS.config.ec2_region.should == 'REGION'
      end

      it 'returns us-east-1 when endpoint is SERVCIE.amazonmss.com' do
        MSS.config.stub(:ec2_endpoint).and_return('ec2.amazonmss.com')
        MSS.config.ec2_region.should == 'us-east-1'
      end

      it 'returns us-gov-west-1 when endpoint is ec2.us-gov-west-1.amazonmss.com' do
        MSS.config.stub(:ec2_endpoint).and_return('ec2.us-gov-west-1.amazonmss.com')
        MSS.config.ec2_region.should == 'us-gov-west-1'
      end

      it 'returns us-gov-west-2 when endpoint is s3-fips-us-gov-west-1.amazonmss.com' do
        MSS.config.stub(:s3_endpoint).and_return('s3-fips-us-gov-west-2.amazonmss.com')
        MSS.config.s3_region.should == 'us-gov-west-2'
      end

      it 'returns us-gov-west-1 when endpoint is iam.us-gov.amazonmss.com' do
        MSS.config.stub(:iam_endpoint).and_return('iam.us-gov.amazonmss.com')
        MSS.config.iam_region.should == 'us-gov-west-1'
      end

      it 'observes the nested region' do
        config = MSS.config.with(:s3 => { :region => 'us-west-2' })
        config.s3_endpoint.should eq('s3-us-west-2.amazonmss.com')
      end

    end

  end

  context '#eager_autoload!' do

    it 'returns a list of loaded modules' do
      path = File.join(File.dirname(__FILE__), 'fixtures', 'autoload_target')
      mod = Module.new
      mod.send(:autoload, :AutoloadTarget, path)
      MSS.eager_autoload!(mod)
      mod.autoload?(:AutoloadTarget).should be(nil)
    end

    it 'eager autoloads passed defined modules' do
      path = File.join(File.dirname(__FILE__), 'fixtures', 'nested_autoload_target')
      mod = Module.new
      mod::Nested = Module.new
      mod::Nested.send(:autoload, :NestedAutoloadTarget, path)
      MSS.eager_autoload!(mod)
      mod::Nested.autoload?(:NestedAutoloadTarget).should be(nil)
    end

  end

end
