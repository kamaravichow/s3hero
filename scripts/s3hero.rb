# S3Hero Homebrew Formula
#
# To install locally (for testing):
#   brew install --build-from-source ./s3hero.rb
#
# To add to a tap:
#   1. Create a tap repository: github.com/<username>/homebrew-tap
#   2. Copy this file to the tap repository as Formula/s3hero.rb
#   3. Install with: brew install <username>/tap/s3hero
#

class S3hero < Formula
  include Language::Python::Virtualenv

  desc "A powerful CLI tool to manage S3 buckets across AWS, Cloudflare R2, and S3-compatible services"
  homepage "https://github.com/aravindgopall/s3hero"
  url "https://github.com/aravindgopall/s3hero/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256"  # Replace with actual SHA256 of the release tarball
  license "MIT"
  head "https://github.com/aravindgopall/s3hero.git", branch: "main"

  depends_on "python@3.11"

  resource "boto3" do
    url "https://files.pythonhosted.org/packages/source/b/boto3/boto3-1.28.0.tar.gz"
    sha256 "PLACEHOLDER"
  end

  resource "botocore" do
    url "https://files.pythonhosted.org/packages/source/b/botocore/botocore-1.31.0.tar.gz"
    sha256 "PLACEHOLDER"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/source/c/click/click-8.1.7.tar.gz"
    sha256 "PLACEHOLDER"
  end

  resource "rich" do
    url "https://files.pythonhosted.org/packages/source/r/rich/rich-13.7.0.tar.gz"
    sha256 "PLACEHOLDER"
  end

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/source/P/PyYAML/PyYAML-6.0.1.tar.gz"
    sha256 "PLACEHOLDER"
  end

  resource "humanize" do
    url "https://files.pythonhosted.org/packages/source/h/humanize/humanize-4.9.0.tar.gz"
    sha256 "PLACEHOLDER"
  end

  resource "tqdm" do
    url "https://files.pythonhosted.org/packages/source/t/tqdm/tqdm-4.66.1.tar.gz"
    sha256 "PLACEHOLDER"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "S3Hero", shell_output("#{bin}/s3hero --version")
  end
end
