require 'git_repo_changelog/git_repo'

describe GitRepoChangelog::GitRepo do
  let(:repo_path) do
    ENV.fetch('CF_RELEASE_PATH', '/Users/pivotal/workspace/cf-release-git-repo')
  end

  subject(:git_repo) do
    GitRepoChangelog::GitRepo.new(repo_path)
  end

  describe '#release_stories' do
    it 'returns tracker story ids in all commits and submodule commits' do
      expect(git_repo.release_stories(
        'v211', 'v212',
        %w(mboedicker@pivotal.io cpiraino@pivotal.io)).to_hash).to eq(
          File.basename(repo_path) => ['96503820'],
          'src/routing-api' => %w(85546998 91732170)
        )
    end

    context 'when the root repo has no stories' do
      it 'is not included in the result' do
        expect(git_repo.release_stories(
          'v211', 'v212',
          %w(mboedicker@pivotal.io)).to_hash).to eq(
            'src/routing-api' => %w(85546998)
          )
      end
    end

    context 'when the bump is reverted' do
      it 'the stories in that bump are not included in the result' do
        stories = git_repo.release_stories('v211', 'v212', []).to_hash
        expect(stories).not_to have_key('src/loggregator')
        expect(stories).to have_key('src/routing-api')
      end
    end
  end

  describe '#commits' do
    it 'lists all commits between two refs filtered by authors' do
      expect(git_repo.commits(repo_path,
               'v211', 'v212',
               %w(mboedicker@pivotal.io cpiraino@pivotal.io))).to eq(%w(
                 b381dee02fb5d8f3ea768bf1676a564710caf812
                 bd8564cda360b746a86471fd6de8ef6b76a08d6e
                 6ff768d21cdc7dac762cb2cad410db038192cf6f
                 6ca2f56772bd3b6383caff3275f83b18a4c56cc5
                 970f218094b28f6a21c58e686673746289c75acb))
    end
  end

  describe '#submodule_commit_sha' do
    it 'returns the submodules shas at the the specified version' do
      expect(true).to be_falsey
    end
  end

  describe '#commit_message' do
    it 'gets the commit message for a sha' do
      expect(
        git_repo.commit_message(repo_path,
          '35833c603f78b2c6eb1d53053e8dedb89d58256c')).to eq(
            "Remove billing events configurations for CC\n\n[#92455198]\n\n")
    end
  end
end
