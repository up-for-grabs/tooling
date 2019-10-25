require 'minitest/autorun'

class DummyTest < Minitest::Test
  def test_never_passes
    assert true
  end
end
