describe Fastlane::Actions::AmazonAppSubmissionAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The amazon_app_submission plugin is working!")

      Fastlane::Actions::AmazonAppSubmissionAction.run(nil)
    end
  end
end
