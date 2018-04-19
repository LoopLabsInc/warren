module NotionSpecHelpers
  module IsAnticipated
    # #is_anticipated is a another form of RSpec's #is_expected but uses a block around the subject
    # instead of evaluating the subject itself
    def is_anticipated
      expect { subject }
    end

    # this is the inverse should, yield to the block given then execute should
    # useful for expectations set up before the subjec is executed
    def will
      yield if block_given?
      subject
    end

    # #is_anticipated_with_error is a another form of RSpec's #is_expected but uses a block around the subject
    # instead of evaluating the subject itself and is meant to suppress any errors encountered during execution
    # The primary function of this is to test for changes that may have occured even if an exception is raised.
    # For example, you may want to test if a record was created/saved/updated even if an exception was encountered.
    def is_anticipated_with_error
      expect do
        begin
          subject
        rescue StandardError => error

        end
      end
    end
  end
end
