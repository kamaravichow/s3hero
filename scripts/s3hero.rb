# S3Hero Homebrew Formula
#
# To install locally (for testing):
#   brew install --build-from-source ./s3hero.rb
#
# To add to a tap:
#   1. Create a tap repository: github.com/<username>/homebrew-s3hero
#   2. Copy this file to the tap repository as Formula/s3hero.rb
#   3. Install with: brew install <username>/s3hero/s3hero
#

class S3hero < Formula
  include Language::Python::Virtualenv

  desc "CLI tool to manage S3 buckets across AWS, Cloudflare R2, and more"
  homepage "https://github.com/kamaravichow/s3hero"
  url "https://github.com/kamaravichow/s3hero/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "e3a109ab7b106e8fb56cbb6a88a3e708768c775f8faf75be9c1ebcf2be547c95"
  license "MIT"
  head "https://github.com/kamaravichow/s3hero.git", branch: "main"

  depends_on "libyaml"
  depends_on "python@3.12"

  resource "boto3" do
    url "https://files.pythonhosted.org/packages/b8/ea/b96c77da49fed28744ee0347374d8223994a2b8570e76e8380a4064a8c4a/boto3-1.42.39.tar.gz"
    sha256 "d03f82363314759eff7f84a27b9e6428125f89d8119e4588e8c2c1d79892c956"
  end

  resource "botocore" do
    url "https://files.pythonhosted.org/packages/ac/a6/3a34d1b74effc0f759f5ff4e91c77729d932bc34dd3207905e9ecbba1103/botocore-1.42.39.tar.gz"
    sha256 "0f00355050821e91a5fe6d932f7bf220f337249b752899e3e4cf6ed54326249e"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/b9/2e/0090cbf739cee7d23781ad4b89a9894a41538e4fcf4c31dcdd705b78eb8b/click-8.1.8.tar.gz"
    sha256 "ed53c9d8990d83c2a27deae68e4ee337473f6330c040a31d4225c9574d16096a"
  end

  resource "humanize" do
    url "https://files.pythonhosted.org/packages/98/1d/3062fcc89ee05a715c0b9bfe6490c00c576314f27ffee3a704122c6fd259/humanize-4.13.0.tar.gz"
    sha256 "78f79e68f76f0b04d711c4e55d32bebef5be387148862cb1ef83d2b58e7935a0"
  end

  resource "jmespath" do
    url "https://files.pythonhosted.org/packages/d3/59/322338183ecda247fb5d1763a6cbe46eff7222eaeebafd9fa65d4bf5cb11/jmespath-1.1.0.tar.gz"
    sha256 "472c87d80f36026ae83c6ddd0f1d05d4e510134ed462851fd5f754c8c3cbb88d"
  end

  resource "markdown-it-py" do
    url "https://files.pythonhosted.org/packages/38/71/3b932df36c1a044d397a1f92d1cf91ee0a503d91e470cbd670aa66b07ed0/markdown-it-py-3.0.0.tar.gz"
    sha256 "e3f60a94fa066dc52ec76661e37c851cb232d92f9886b15cb560aaada2df8feb"
  end

  resource "mdurl" do
    url "https://files.pythonhosted.org/packages/d6/54/cfe61301667036ec958cb99bd3efefba235e65cdeb9c84d24a8293ba1d90/mdurl-0.1.2.tar.gz"
    sha256 "bb413d29f5eea38f31dd4754dd7377d4465116fb207585f97bf925588687c1ba"
  end

  resource "pygments" do
    url "https://files.pythonhosted.org/packages/b0/77/a5b8c569bf593b0140bde72ea885a803b82086995367bf2037de0159d924/pygments-2.19.2.tar.gz"
    sha256 "636cb2477cec7f8952536970bc533bc43743542f70392ae026374600add5b887"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/66/c0/0c8b6ad9f17a802ee498c46e004a0eb49bc148f2fd230864601a86dcf6db/python-dateutil-2.9.0.post0.tar.gz"
    sha256 "37dd54208da7e1cd875388217d5e00ebd4179249f90fb72437e91a35459a0ad3"
  end

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  resource "rich" do
    url "https://files.pythonhosted.org/packages/a1/84/4831f881aa6ff3c976f6d6809b58cdfa350593ffc0dc3c58f5f6586780fb/rich-14.3.1.tar.gz"
    sha256 "b8c5f568a3a749f9290ec6bddedf835cec33696bfc1e48bcfecb276c7386e4b8"
  end

  resource "s3transfer" do
    url "https://files.pythonhosted.org/packages/05/04/74127fc843314818edfa81b5540e26dd537353b123a4edc563109d8f17dd/s3transfer-0.16.0.tar.gz"
    sha256 "8e990f13268025792229cd52fa10cb7163744bf56e719e0b9cb925ab79abf920"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/94/e7/b2c673351809dca68a0e064b6af791aa332cf192da575fd474ed7d6f16a2/six-1.17.0.tar.gz"
    sha256 "ff70335d468e7eb6ec65b95b99d3a2836546063f63acc5171de367e834932a81"
  end

  resource "tqdm" do
    url "https://files.pythonhosted.org/packages/27/89/4b0001b2dab8df0a5ee2787dcbe771de75ded01f18f1f8d53dedeea2882b/tqdm-4.67.2.tar.gz"
    sha256 "649aac53964b2cb8dec76a14b405a4c0d13612cb8933aae547dd144eacc99653"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/e4/e8/6ff5e6bc22095cfc59b6ea711b687e2b7ed4bdb373f7eeec370a97d7392f/urllib3-1.26.20.tar.gz"
    sha256 "40c2dc0c681e47eb8f90e7e27bf6ff7df2e677421fd46756da1161c39ca70d32"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "s3hero", shell_output("#{bin}/s3hero --version")
  end
end
