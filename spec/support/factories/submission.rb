FactoryGirl.define do

  factory :submission do
    assignment
    user

    factory :submission_with_source do
      body "2 + 2 == 5"
    end
  end

end