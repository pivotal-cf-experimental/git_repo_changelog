require 'git_repo_changelog/git_repo'

describe GitRepoChangelog::GitRepo do
  subject(:git_repo) do
    GitRepoChangelog::GitRepo.new('/Users/pivotal/workspace/cf-release')
  end

  describe '#release_stories' do
    it 'returns tracker story ids in all commits and submodule commits' do
      expect(git_repo.release_stories(
        'v211', 'v212',
        %w(mboedicker@pivotal.io cpiraino@pivotal.io)).to_hash).to eq(
          'cf-release' => ['96503820'],
          'src/routing-api' => %w(85546998 91732170),
          'src/acceptance-tests' => ['95212618']
        )
    end

    context 'when the root repo has no stories' do
      it 'is not included in the result' do
        expect(git_repo.release_stories(
          'v211', 'v212',
          %w(mboedicker@pivotal.io)).to_hash).to eq(
            'src/routing-api' => %w(85546998),
            'src/acceptance-tests' => ['95212618']
          )
      end
    end
  end

  describe '#commits' do
    it 'lists all commits between two refs filtered by authors' do
      expect(git_repo.commits(
               'v211', 'v212',
               %w(mboedicker@pivotal.io cpiraino@pivotal.io))).to eq(%w(
                 b381dee02fb5d8f3ea768bf1676a564710caf812
                 bd8564cda360b746a86471fd6de8ef6b76a08d6e
                 6ff768d21cdc7dac762cb2cad410db038192cf6f
                 6ca2f56772bd3b6383caff3275f83b18a4c56cc5
                 970f218094b28f6a21c58e686673746289c75acb))
    end
  end

  describe '#commit_submodules_changed' do
    it 'returns the submodules changed in a submodule bump commit' do
      expect(git_repo.commit_submodules_changed(
               'bd8564cda360b746a86471fd6de8ef6b76a08d6e')).to eq(
                 ['src/routing-api'])
    end
  end

  describe '#submodule_commit_message' do
    it 'returns the commit message of a commit in a submodule' do
      expect(git_repo.submodule_commit_message(
               'a344a16f0316ad5a992a5ce2989b776b1eb81cfa', 'src/routing-api'
      )).to eq("Run go vet when running tests.\n\n[#97439972]\n\n")
    end
  end

  describe '#commit_message' do
    it 'gets the commit message for a sha' do
      expect(
        git_repo.commit_message(
          '35833c603f78b2c6eb1d53053e8dedb89d58256c')).to eq(
            "Remove billing events configurations for CC\n\n[#92455198]\n\n")
    end
  end
end
