# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "faker"


User.create!([
  { :name => "Uwe Zimmer", :uni_id => 2222222 },
  { :name => "Buck Shlegeris", :uni_id => 5192430 },
  { :name => "Tessa Bradbury", :uni_id => 3333333 }
  ])


uwe = User.find_by_name("Uwe Zimmer")

comp1100 = Course.new(:name => "Comp1100")
comp1100.convenor = uwe
comp1100.save!

comp1130 = Course.new(:name => "Comp1130")
comp1130.convenor = uwe
comp1130.save!

buck = User.find_by_name("Buck Shlegeris")
buck.enroll_staff_in_course!(comp1100)
buck.enroll_staff_in_course!(comp1130)

tessa = User.find_by_name("Tessa Bradbury")
tessa.enroll_staff_in_course!(comp1100)
tessa.enroll_staff_in_course!(comp1130)

tute = GroupType.create!(:name => "Comp1100/1130 labs", :courses => [comp1130, comp1100])

buck_tute, tessa_tute = tute.create_groups("Thursday A"=>[buck],
                                      "Thursday B"=>[tessa])

[buck_tute, tessa_tute].each do |tute|
  [comp1100, comp1130].each do |course|
    5.times do |time|
      user = User.create( { :name => Faker::Name.name,
                        :uni_id => 5000000 + rand(1000000) } )

      user.enroll_in_course!(course)
      user.join_group!(tute)
    end
  end
end