require 'test_helper'

class KDL::V1::SpecTest < Minitest::Test
  TEST_CASES_DIR = File.join(__dir__, 'kdl-org/tests/test_cases')
  INPUTS_DIR = File.join(TEST_CASES_DIR, 'input')
  EXPECTED_DIR = File.join(TEST_CASES_DIR, 'expected_kdl')

  EXCLUDE = %w[
    escline_comment_node
  ]

  Dir.glob(File.join(INPUTS_DIR, '*.kdl')).each do |input_path|
    input_name = File.basename(input_path, '.kdl')
    next if EXCLUDE.include?(input_name)
    expected_path = File.join(EXPECTED_DIR, "#{input_name}.kdl")
    if File.exist?(expected_path)
      define_method "test_v1_#{input_name}_matches_expected_output" do
        input = File.read(input_path, encoding: Encoding::UTF_8)
        expected = File.read(expected_path, encoding: Encoding::UTF_8)
        assert_equal expected, ::KDL.parse(input, mode: :v1).to_s
        assert_equal ::KDL.parse(expected, output: :v2).to_s, ::KDL.parse(input, output: :v2).to_s
    end
    else
      define_method "test_v1_#{input_name}_does_not_parse" do
        assert_raises { ::KDL.load_file(input_path, mode: :v1) }
      end
    end
  end
end
