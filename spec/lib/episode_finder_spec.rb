require 'spec_helper'
require_relative '../../lib/episode_finder'

describe EpisodeFinder do
  # subject { EpisodeFinder.new }
  #
  # it 'finds the next episode after pilot' do
  #   expect(subject.next_episode('pilot')).to eq 'deep throat'
  # end
  #
  # it 'finds the next episode after deep throat' do
  #   expect(subject.next_episode('deep throat')).to eq 'fallen angel'
  # end
  #
  # it 'finds the next mytharc episode after an episode that is not in the mytharc' do
  #   expect(subject.next_episode('squeeze')).to eq 'fallen angel'
  # end

  context 'class methods' do
    subject { EpisodeFinder.load_from_xml }

    it { is_expected.to be_a Array }
    specify { expect(subject.size).to eq 9 }
    specify { expect(subject.first).to be_a XFilesSeason }
  end

  describe XFilesEpisode do
    it 'errors when initalized with no args' do
      expect { XFilesEpisode.new() }.to raise_error
    end

    it 'errors when initalized with missing args' do
      expect { XFilesEpisode.new(title: 'foo') }.to raise_error(/required arg mytharc\? not found/)
      expect { XFilesEpisode.new(mytharc: false) }.to raise_error(/required arg title not found/)
    end

    it 'does not error when initalized with good args' do
      ep = XFilesEpisode.new(title: 'foo', mytharc?: false)
      expect(ep.title).to eq 'foo'
      expect(ep.mytharc?).to be false
    end
  end

  describe XFilesSeason do
    subject(:season) { EpisodeFinder.load_from_xml.first }

    it { is_expected.to be_a XFilesSeason }
    specify { expect(subject.size).to eq 24 }

    context 'first episode' do
      subject { season.first }

      specify { expect(subject).to be_a XFilesEpisode }
      specify { expect(subject.title).to eq 'Pilot' }
      specify { expect(subject).to be_mytharc }
    end

    context 'second episode' do
      subject { season[1] }

      specify { expect(subject).to be_a XFilesEpisode }
      specify { expect(subject.title).to eq 'Deep Throat' }
      specify { expect(subject).to be_mytharc }
    end

    context 'second episode' do
      subject { season[2] }

      specify { expect(subject).to be_a XFilesEpisode }
      specify { expect(subject.title).to eq 'Squeeze' }
      specify { expect(subject).not_to be_mytharc }
    end

    describe '#next_in_mytharc' do
      specify { expect(subject.next_in_mytharc).to eq subject.first }
      specify { expect(subject.next_in_mytharc('Pilot')).to eq subject[1] }
      specify { expect(subject.next_in_mytharc('Shadows')).to eq subject.find_by_title('Fallen Angel') }
      specify { expect(subject.next_in_mytharc('The Erlenmeyer Flask')).to be nil }
    end

  end
end
