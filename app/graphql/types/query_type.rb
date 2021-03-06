module Types
  class QueryType < Types::BaseObject
    extend Mutations::HelperMethods

    field :get_users, [Types::UserType], null: false, description: 'Returns a list of users'

    field :get_user, Types::UserType, null: false, description: 'Returns a single user by id' do
      argument :id, ID, required: true
    end

    field :get_era, Types::EraType, null: false, description: 'Returns a single era by id' do
      argument :id, ID, required: true
    end

    # Events
    field :get_event, Types::EventType, null: false, description: 'Returns a single event by id' do
      argument :id, ID, required: true
    end

    # Questions
    field :get_onboarding_questions, [Types::QuestionType], null: false,
                                                            description: 'Returns a list of onboarding questions'

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    def get_users
      User.all
    end

    def get_user(id:)
      user = User.find(id)
      user.current_week = Mutations::HelperMethods.week_number(Date.today, user.birthdate)
      user
    end

    # Eras
    def get_era(id:)
      Era.find(id)
    end

    # Event queries
    def get_event(id:)
      Event.find(id)
    end

    # Questions
    def get_onboarding_questions
      Question.where(onboarding: true)
    end
  end
end
