
require "faker"


User.create!([
  { :name => "Uwe Zimmer", :uni_id => 2222222 },
  { :name => "Buck Shlegeris", :uni_id => 5192430 },
  { :name => "Tessa Bradbury", :uni_id => 3333333 },
  { :name => "Eric McCreath", :uni_id => 4444444 },
  { :name => "James Fellows", :uni_id => 1234567 }
  ])


uwe = User.find_by_name("Uwe Zimmer")

james = User.find_by_name("James Fellows")
james.is_admin = true
james.save!

comp1100 = Course.new(:name => "Comp1100")
comp1100.convenor = uwe
comp1100.save!

comp1130 = Course.new(:name => "Comp1130")
comp1130.convenor = uwe
comp1130.save!

eric = User.find_by_name("Eric McCreath")
comp2300 = Course.new(:name => "Comp2300")
comp2300.convenor = eric
comp2300.save!

buck = User.find_by_name("Buck Shlegeris")
buck.enroll_staff_in_course!(comp1100)
buck.enroll_staff_in_course!(comp1130)

tessa = User.find_by_name("Tessa Bradbury")
tessa.enroll_staff_in_course!(comp1100)
tessa.enroll_staff_in_course!(comp1130)

tute = GroupType.create!(:name => "Comp1100/1130 labs",
                         :courses => [comp1130, comp1100])

wireworld = Assignment.create!(:name => "Wireworld",
                               :info => "cellular automata!",
                               :group_type => tute,
                               :due_date => "2014-01-03 23:04:26")

buck_tute, tessa_tute = tute.create_groups("Thursday A"=>[buck],
                                      "Thursday B"=>[tessa])

[buck_tute, tessa_tute].each do |tute|
  [comp1100, comp1130, comp2300].each do |course|
    5.times do |time|
      user = User.create( { :name => "#{Faker::Name.first_name} #{Faker::Name.last_name}",
                        :uni_id => 4000000 + rand(2000000) } )

      user.enroll_in_course!(course)
      user.join_group!(tute)
    end
  end
end

AssignmentSubmission.create!(:user_id => buck_tute.students.first.id,
                              :body => "main = error \"unimplemented\"",
                              :assignment_id => wireworld.id)