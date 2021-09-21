require "test_helper"

class SpectTest < Minitest::Test
  TEST_CASES_DIR = File.join(__dir__, 'kdl-org/tests/test_cases')
  INPUTS_DIR = File.join(TEST_CASES_DIR, 'input')
  EXPECTED_DIR = File.join(TEST_CASES_DIR, 'expected_kdl')

  Dir.glob(File.join(INPUTS_DIR, '*.kdl')).each do |input_path|
    input_name = File.basename(input_path, '.kdl')
    expected_path = File.join(EXPECTED_DIR, "#{input_name}.kdl")
    if File.exist?(expected_path)
      define_method "test_input_#{input_name}_matches_expected_output" do
        input = File.read(input_path)
        expected = File.read(expected_path)
        assert_equal expected, ::KDL.parse_document(input).to_s
      end
    else
      define_method "test_input_#{input_name}_does_not_parse" do
        input = File.read(input_path)
        assert_raises { ::KDL.parse_document(input) }
      end
    end
  end
end
