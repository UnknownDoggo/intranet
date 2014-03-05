require 'spec_helper'

describe LeaveApplication do
  it { should have_fields(:start_at, :end_at, :reason, :contact_number, :reject_reason, :leave_status) }
  it { should belong_to(:user) }
  it { should belong_to(:leave_type) }
  it { should validate_presence_of(:start_at) }
  it { should validate_presence_of(:end_at) }
  it { should validate_presence_of(:reason) }
  it { should validate_presence_of(:contact_number) }
  it { should validate_numericality_of(:contact_number) }

  it "mail for approval shouldn't get sent if not pending" do
    @user = FactoryGirl.create(:user, role: 'Employee')
    @user = FactoryGirl.create(:user, private_profile: FactoryGirl.build(:private_profile, date_of_joining: Date.new(Date.today.year, 01, 01))) 
    leave_type = FactoryGirl.create(:leave_type)
    leave_application = FactoryGirl.create(:leave_application, user_id: @user.id, number_of_days: 2, leave_type_id: leave_type.id)
    Sidekiq::Extensions::DelayedMailer.jobs.clear
    leave_application.update_attributes(leave_status: 'Appproved')
    Sidekiq::Extensions::DelayedMailer.jobs.size.should eq(0)
  end

  it "mail for approval should get sent if any field has been updated and if pending" do
    @user = FactoryGirl.create(:user, role: 'Employee')
    @user = FactoryGirl.create(:user, private_profile: FactoryGirl.build(:private_profile, date_of_joining: Date.new(Date.today.year, 01, 01))) 
    leave_type = FactoryGirl.create(:leave_type)
    leave_application = FactoryGirl.create(:leave_application, user_id: @user.id, number_of_days: 2, leave_type_id: leave_type.id)
    Sidekiq::Extensions::DelayedMailer.jobs.clear
    leave_application.update_attributes(number_of_days: 1)
    Sidekiq::Extensions::DelayedMailer.jobs.size.should eq(1)
  end

end
