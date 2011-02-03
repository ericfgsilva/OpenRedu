require 'spec_helper'

describe Environment do
  subject { Factory(:environment) }

  it { should have_many(:courses).dependent(:destroy) }
  it { should have_many(:user_environment_associations).dependent(:destroy) }
  it { should have_many(:bulletins).dependent(:destroy) }
  it { should have_many(:users).through(:user_environment_associations)}
  it { should belong_to(:owner)}
  it { should accept_nested_attributes_for :courses }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:path) }
  xit { should validate_uniqueness_of(:name) }
  xit { should validate_uniqueness_of(:path) }
  it { should ensure_length_of(:name).is_at_most 40 }
  it { should ensure_length_of(:initials).is_at_most(10)}
  it { should ensure_length_of(:description).is_at_most(400)}

  it { should_not allow_mass_assignment_of(:owner)}
  it { should_not allow_mass_assignment_of(:published)}

  context "validations" do
    it "ensure tags has a length of at most 110"  do
      tags = (1..100).collect { Factory(:tag) }
      subject = Factory.build(:environment, :tags => tags)
      subject.should_not be_valid
      subject.errors.on(:tags).should_not be_empty
    end
  end

  context "finders" do
    it "retrieves a Environment by its path" do
      Environment.find(subject.path).should == subject
    end
  end

  it "generates a permalink" do
    APP_URL.should_not be_nil
    subject.permalink.should include(subject.path)
  end

  it "changes a user role" do
    user = Factory(:user)
    subject.users << user
    subject.save

    expect {
      subject.change_role(user, Role[:environment_admin])
    }.should change {
      subject.user_environment_associations.last.role }.to(Role[:environment_admin])
  end

  it "choose another path if the specified already exists" do
    @environment = Factory.build(:environment, :path => subject.path)
    @environment.verify_path!
    @environment.path.should_not == subject.path
  end
  context "callbacks" do
    it "creates an environment association" do
      subject.users.last.should == subject.owner
    end
    it "creates an course association with the first course" do
    user = Factory(:user)
      subject = Factory(:environment, :owner => user,
                        :courses => [Factory(:course, :owner => user)])
      subject.courses.first.owner == subject.owner
    end
  end
end