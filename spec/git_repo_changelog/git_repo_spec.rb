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

    context 'when the submodule is deleted' do
      it 'the stories in that submodule should not be included in the result' do
        stories = git_repo.release_stories('v211', 'v212', []).to_hash
        expect(stories).not_to have_key('src/acceptance-tests')
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
    context 'when the submodule_shas is empty' do
      it 'returns the submodules shas at the the specified version' do
        submodule_shas = {}
        Dir.chdir(repo_path) do
          git_repo.submodule_commit_sha('v211', submodule_shas)
        end
        expect(submodule_shas).to eq('shared' => ['87112bae91127792ffbed7fc6c76ac7088708ace'],
                                     'src/acceptance-tests' => ['41d21c0224e43ced801fd65c11904beb747919db'],
                                     'src/cloud_controller_ng' => ['5fecc24082167a8d399cd0adac8c5a9dacd9e69b'],
                                     'src/collector' => ['d0f920e3569bb63e4b902e01a5507920b5725515'],
                                     'src/dea_next' => ['4b1a50ae5598b0c70cb3e5895ed800e0cff37722'],
                                     'src/etcd-metrics-server' => ['90c444c7f93cacb998e45c46f1e06ecf4c8eb9c4'],
                                     'src/etcd-release' => ['da768cfb5c31f6da7fbd48b221ace62702a6dbb2'],
                                     'src/gnatsd' => ['7fb53586108b89a68d3db9ad2f7cf84a6842194c'],
                                     'src/gorouter' => ['a3edc3a752c09bea3c10e9600c530254b058b81d'],
                                     'src/hm9000' => ['7eefc31903ac6520292b29584818420b2b231374'],
                                     'src/loggregator' => ['d648809112be62df9663ac82a7bd39babc47fa28'],
                                     'src/login' => ['c4e3209c91882edae6185da5794d8a4dea02c73d'],
                                     'src/routing-api' => ['60e1b8817246df8ec0aee06f1df854ad160a800f'],
                                     'src/smoke-tests' => ['29a5311a7f98e85f6a907cec09e6caa3cdb05526'],
                                     'src/statsd-injector' => ['f70771222f6ccfff3af6f5319f02e5543ce7f569'],
                                     'src/uaa' => ['a32678a82805c9c8296a821129f2bf974ca65e2e'],
                                     'src/warden' => ['015a27337bbd10c3050f50810f5b310a0c6f8315'])
      end
    end

    context "when the submodule_shas already contains the former version's shas" do
      it 'add the shas into the key-value pair which has the key of the submodule name' do
        submodule_shas = { 'shared' => ['87112bae91127792ffbed7fc6c76ac7088708ace'],
                           'src/acceptance-tests' => ['41d21c0224e43ced801fd65c11904beb747919db'],
                           'src/cloud_controller_ng' => ['5fecc24082167a8d399cd0adac8c5a9dacd9e69b'],
                           'src/collector' => ['d0f920e3569bb63e4b902e01a5507920b5725515'],
                           'src/dea_next' => ['4b1a50ae5598b0c70cb3e5895ed800e0cff37722'],
                           'src/etcd-metrics-server' => ['90c444c7f93cacb998e45c46f1e06ecf4c8eb9c4'],
                           'src/etcd-release' => ['da768cfb5c31f6da7fbd48b221ace62702a6dbb2'],
                           'src/gnatsd' => ['7fb53586108b89a68d3db9ad2f7cf84a6842194c'],
                           'src/gorouter' => ['a3edc3a752c09bea3c10e9600c530254b058b81d'],
                           'src/hm9000' => ['7eefc31903ac6520292b29584818420b2b231374'],
                           'src/loggregator' => ['d648809112be62df9663ac82a7bd39babc47fa28'],
                           'src/login' => ['c4e3209c91882edae6185da5794d8a4dea02c73d'],
                           'src/routing-api' => ['60e1b8817246df8ec0aee06f1df854ad160a800f'],
                           'src/smoke-tests' => ['29a5311a7f98e85f6a907cec09e6caa3cdb05526'],
                           'src/statsd-injector' => ['f70771222f6ccfff3af6f5319f02e5543ce7f569'],
                           'src/uaa' => ['a32678a82805c9c8296a821129f2bf974ca65e2e'],
                           'src/warden' => ['015a27337bbd10c3050f50810f5b310a0c6f8315'] }
        Dir.chdir(repo_path) do
          git_repo.submodule_commit_sha('v212', submodule_shas)
        end
        expect(submodule_shas).to eq('shared' => %w(87112bae91127792ffbed7fc6c76ac7088708ace 87112bae91127792ffbed7fc6c76ac7088708ace),
                                     'src/acceptance-tests' => ['41d21c0224e43ced801fd65c11904beb747919db'],
                                     'src/cloud_controller_ng' => %w(5fecc24082167a8d399cd0adac8c5a9dacd9e69b 8861a1efa717838645c45fe164ab62b2767952d5),
                                     'src/collector' => %w(d0f920e3569bb63e4b902e01a5507920b5725515 d0f920e3569bb63e4b902e01a5507920b5725515),
                                     'src/dea_next' => %w(4b1a50ae5598b0c70cb3e5895ed800e0cff37722 9db43f15e332ebc29eac99bbfdf5365db66d95f3),
                                     'src/etcd-metrics-server' => %w(90c444c7f93cacb998e45c46f1e06ecf4c8eb9c4 90c444c7f93cacb998e45c46f1e06ecf4c8eb9c4),
                                     'src/etcd-release' => %w(da768cfb5c31f6da7fbd48b221ace62702a6dbb2 da768cfb5c31f6da7fbd48b221ace62702a6dbb2),
                                     'src/github.com/cloudfoundry/cf-acceptance-tests' => ['cdced815f585ef4661b2182799d1d6a7119489b0'],
                                     'src/gnatsd' => %w(7fb53586108b89a68d3db9ad2f7cf84a6842194c 7fb53586108b89a68d3db9ad2f7cf84a6842194c),
                                     'src/gorouter' => %w(a3edc3a752c09bea3c10e9600c530254b058b81d 66144d2b2bc499cd9670eb59eb828835a1d33d86),
                                     'src/hm9000' => %w(7eefc31903ac6520292b29584818420b2b231374 7eefc31903ac6520292b29584818420b2b231374),
                                     'src/loggregator' => %w(d648809112be62df9663ac82a7bd39babc47fa28 d648809112be62df9663ac82a7bd39babc47fa28),
                                     'src/login' => %w(c4e3209c91882edae6185da5794d8a4dea02c73d c4e3209c91882edae6185da5794d8a4dea02c73d),
                                     'src/routing-api' => %w(60e1b8817246df8ec0aee06f1df854ad160a800f 9d71fe6513d0f50c540609bcd0407cdc6187ea48),
                                     'src/smoke-tests' => %w(29a5311a7f98e85f6a907cec09e6caa3cdb05526 29a5311a7f98e85f6a907cec09e6caa3cdb05526),
                                     'src/statsd-injector' => %w(f70771222f6ccfff3af6f5319f02e5543ce7f569 e7152f1b153d9f7a0acc0720378b862278af821b),
                                     'src/uaa' => %w(a32678a82805c9c8296a821129f2bf974ca65e2e 091c5e5961dd33c8c7ca5a15f4020e47d266a1c3),
                                     'src/warden' => %w(015a27337bbd10c3050f50810f5b310a0c6f8315 e8f31ee5e40df69199ca3d69b8d909397f5b5365))
      end
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
