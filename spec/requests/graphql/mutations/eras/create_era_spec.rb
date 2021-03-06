require 'rails_helper'

RSpec.describe Mutations::Eras::CreateEra, type: :request do
  describe '.resolve' do
    before :each do
      @user = create(:user, birthdate: '1991-12-19')
      @eras = Era.all.size
    end

    it 'creates an era' do
      attributes = {
        userId: @user.id,
        name: 'Summer Abroad',
        startDate: '2000-01-01',
        endDate: '2000-01-10',
        color: '#000000'
      }

      post graphql_path, params: { query: query(attributes) }
      result = JSON.parse(response.body)

      data = result['data']['createEra']

      expect(Era.all.size).to eq(@eras + 1)
      expect(data['userId']).to eq("#{attributes[:userId]}")
      expect(data['name']).to eq(attributes[:name])
      expect(data['startDate']).to eq(attributes[:startDate])
      expect(data['endDate']).to eq(attributes[:endDate])
      expect(data['startWeek']).to eq(419)
      expect(data['endWeek']).to eq(420)
      expect(data['color']).to eq(attributes[:color])
    end

    it "does not create an era with a start date in the future" do
      attributes = {
        userId: @user.id,
        name: 'Summer Abroad',
        startDate: '3000-01-01',
        endDate: '2000-01-10',
        color: '#000000'
      }

      post graphql_path, params: { query: query(attributes) }
      result = JSON.parse(response.body)
      
      error = result["errors"].first

      expect(Era.all.size).to eq(@eras)
      expect(error["message"]).to eq("Validation failed: Start date cannot be in the future")
    end

    it "does not create an era with an end date in the future" do
      attributes = {
        userId: @user.id,
        name: 'Summer Abroad',
        startDate: '2000-01-01',
        endDate: '3000-01-10',
        color: '#000000'
      }

      post graphql_path, params: { query: query(attributes) }
      result = JSON.parse(response.body)

      error = result["errors"].first

      expect(Era.all.size).to eq(@eras)
      expect(error["message"]).to eq("Validation failed: End date cannot be in the future")
    end

    it "does not create an era with both start and end date in the future" do
      attributes = {
        userId: @user.id,
        name: 'Summer Abroad',
        startDate: '3000-01-01',
        endDate: '3000-01-10',
        color: '#000000'
      }

      post graphql_path, params: { query: query(attributes) }
      result = JSON.parse(response.body)

      error = result["errors"].first

      expect(Era.all.size).to eq(@eras)
      expect(error["message"]).to eq("Validation failed: Start date cannot be in the future, End date cannot be in the future")
    end

    it "creates an era with a default color" do
      attributes = {
        userId: @user.id,
        name: 'Summer Abroad',
        startDate: '2000-01-01',
        endDate: '2000-01-10'
      }

      post graphql_path, params: { query: query(attributes) }
      result = JSON.parse(response.body)

      data = result['data']['createEra']

      expect(data['color']).to be_a(String)
      expect(['#F7A83E', '#A94460', '#DB4709', '#96B40D', '#E7C408', '#70D6FF', '#FF70A6', '#AA9770', '#FFD670', '#E9FF70']).to include(data['color'])
    end

    def query(attributes)
      <<~GQL
        mutation {
          createEra(input:{
              userId: "#{attributes[:userId]}"
              name: "#{attributes[:name]}"
              startDate: "#{attributes[:startDate]}"
              endDate: "#{attributes[:endDate]}"
              color: "#{attributes[:color]}"
              }) {
                id
                userId
                name
                startDate
                endDate
                startWeek
                endWeek
                color
              }
            }
      GQL
    end
  end
end
