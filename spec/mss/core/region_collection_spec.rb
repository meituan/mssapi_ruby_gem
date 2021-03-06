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

module MSS
  module Core
    describe RegionCollection do

      let(:regions) { RegionCollection.new }

      context '#[]' do

        it 'returns a region' do
          regions['name'].should be_a(Region)
        end

        it 'returns a region with the given name' do
          regions['name'].name.should eq('name')
        end

      end

      context '#each' do

        let(:json) { File.read(File.join(MSS::ROOT, 'endpoints.json')) }

        it 'should be enumerable' do
          regions.should be_an(Enumerable)
        end

        it 'yields Region objects' do
          yielded = false
          regions.each do |region|
            region.should be_a(Region)
            yielded = true
          end
          yielded.should be(true)
        end

        it 'loads data from the bundled endpoints.json file' do
          host = 'mss-sdk-configurations.amazonwebservices.com'
          path = '/endpoints.json'
          File.should_receive(:read).
            with(File.join(MSS::ROOT, 'endpoints.json')).
            and_return(json)
          regions.map(&:name)
        end

        it 'enumerates public regions from the endpoints.json file' do
          regions.map(&:name).sort.should eq(%w(
            us-east-1 us-west-1 us-west-2 eu-central-1 eu-west-1 ap-northeast-1
            ap-southeast-1 ap-southeast-2 sa-east-1
          ).sort)
        end

        it 'caches the endpoints.json file' do
          File.should_receive(:read).exactly(1).times.and_return(json)
          regions.map(&:name)
          regions.map(&:name)
        end

        context 'with service' do

          it 'provides access to services with a global endpoint via any region' do
            MSS::IAM.global_endpoint?.should be(true)
            MSS::IAM.regions.map(&:name).should eq(['us-east-1'])
            MSS.regions['us-west-2'].iam.client.config.iam_region.should eq('us-east-1')
          end

        end

      end

    end
  end
end
