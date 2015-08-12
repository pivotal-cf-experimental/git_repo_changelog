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
          'src/routing-api' => %w(85546998 85546998 85546998 85546998 91732170),
          'src/acceptance-tests' => %w(95212618 95212618)
        )
    end

    context 'when the root repo has no stories' do
      it 'is not included in the result' do
        expect(git_repo.release_stories(
          'v211', 'v212',
          %w(mboedicker@pivotal.io)).to_hash).to eq(
            'src/routing-api' => %w(85546998 85546998 85546998 85546998),
            'src/acceptance-tests' => %w(95212618 95212618)
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
               '0a111f6933fe9e34777315c78e66e0e1c07ac5ad')).to eq(
                 [['src/cloud_controller_ng',
                   'd29558702808d8a7b1a3ce8535e28183f8ae884a',
                   '11b2eafcae22331b696efec72188d6da4ad21ca1'],
                  ['src/gorouter/src/github.com/cloudfoundry/gorouter',
                   '261822090071849721ea7b6cf4b1350db7991ad2',
                   '914b560f449a6235d6e994048e0dc9c03359bdb6'],
                  ['src/gorouter/src/github.com/cloudfoundry/yagnats',
                   'b7f4da8b87424c2e24c32e6f0f1048b2571d8fe1',
                   '719fb61b685b33a68925ccc827994029ed05a5e6']
                 ])
    end
  end

  describe '#submodule_commit_message' do
    it 'returns the commit message of a commit in a submodule' do
      expect(git_repo.submodule_commit_messages(
               '5b7b3fa12c899566c986538d911281b97048886b',
               'src/cloud_controller_ng',
               '31234c4c8a12f4c60243f4b68461d515e6d1c8e8',
               '0fc14205ce043c1f22a398c67ad080326f9ad115'
      )).to eq("commit 0fc14205ce043c1f22a398c67ad080326f9ad115\n"\
          "Author: Rohit Kumar and Zak Auerbach <rokumar@pivotal.io>\n"\
          "Date:   Thu Jun 25 15:45:53 2015 -0700\n"\
          "\n"\
          "    Allow roles to be unset by username on space\n    "\
          "\n    "\
          "[#97777418]\n"\
          "\n"\
          "commit 875cdd8b8a881778fb9018f67dfd64cabad5c72e\n"\
          "Author: Rohit Kumar and Zak Auerbach <zauerbach@pivotal.io>\n"\
          "Date:   Thu Jun 25 15:25:11 2015 -0700\n"\
          "\n"\
          "    Allow roles to be unset by username\n"\
          "    \n"\
          "    [#97777418]\n"\
          "\n"\
          "commit 92e93fca2d9335123f759530f77125969a151c6c\n"\
          "Author: Rohit Kumar and Zak Auerbach <rokumar@pivotal.io>\n"\
          "Date:   Thu Jun 25 14:13:03 2015 -0700\n"\
          "\n"\
          "    Remove billing events configurations\n"\
          "    \n    "\
          "[#92455198]\n"\
          "\n"\
          "commit 5d5897b8eae0bff55e81170a7ad38ed6a18edad8\n"\
          "Author: Rohit Kumar and Zak Auerbach <rokumar@pivotal.io>\n"\
          "Date:   Thu Jun 25 12:27:32 2015 -0700\n"\
          "\n    "\
          "Remove service billing events and base billing event\n"\
          "    \n    "\
          "[#92455198]\n"\
          "\n"\
          "commit 3c84b9885dacc699301aa8c239105180e704b44e\n"\
          "Author: Rohit Kumar and Zak Auerbach <rokumar@pivotal.io>\n"\
          "Date:   Thu Jun 25 12:15:43 2015 -0700\n"\
          "\n    "\
          "Remove Organization Start Event\n    "\
          "\n    "\
          "[#92455198]\n"\
          "\n"\
          "commit 7cf51e3329647370efffcd315087e37776c3e178\n"\
          "Author: Rohit Kumar and Zak Auerbach <zauerbach@pivotal.io>\n"\
          "Date:   Thu Jun 25 11:56:47 2015 -0700\n"\
          "\n    "\
          "Remove App Start and Stop Events\n"\
          "    \n    "\
          "* do not drop the table\n"\
          "    \n    "\
          "[#92455198]\n")
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
