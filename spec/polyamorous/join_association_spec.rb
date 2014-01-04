require 'spec_helper'

module Polyamorous
  describe JoinAssociation do
    if ActiveRecord::VERSION::STRING >= "4.1"
      include_examples "Join Association on ActiveRecord 4.1"
    else
      include_examples "Join Association on ActiveRecord 4.0 and below"
    end
  end
end
