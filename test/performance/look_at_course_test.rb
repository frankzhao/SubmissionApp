require 'test_helper'
require 'rails/performance_test_help'

class LookAtCourseTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory]
  #                          :output => 'tmp/performance', :formats => [:flat] }

  def test_homepage
    uwe = User.find_by_uni_id(2222222)
    login!(uwe)
    get '/'
  end
end
