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
  class SQS
    describe Policy::Statement do

      it_should_behave_like 'generic policy statement'

      it_should_behave_like 'service specific policy statement' do

        context 'resource arns' do

          it 'prefixes queues' do
            queue = SQS::Queue.new('http://domain.com/url/path')
            statement.resources = [queue]
            statement.to_h["Resource"].should == ["/url/path"]
          end

        end

      end

    end
  end
end
