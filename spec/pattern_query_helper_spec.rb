RSpec.describe PatternQueryHelper do
  it "returns a paginated sql query" do
    results = PatternQueryHelper.run_sql_query(Child, "select * from children", {}, @url_params, ["name", "id"])
    expect(results[:pagination]).to_not be nil
    expect(results[:data]).to_not be nil
  end

  it "returns a sql query" do
    results = PatternQueryHelper.run_sql_query(Child, "select * from children", {}, @url_params, ["name", "id"])
    expect(results[:data]).to_not be nil
  end

  it "returns a single record sql query" do
    @url_params[:filter] = nil
    results = PatternQueryHelper.run_sql_query(Child, "select * from children where id=#{Child.first.id}", {}, @url_params, ["name", "id"], true)
    expect(results[:data]).to_not be nil
  end

  it "returns an active record query" do
    results = PatternQueryHelper.run_active_record_query(Child.all, @url_params, ["name", "id"])
    expect(results[:data]).to_not be nil
  end

  it "returns a paginated active record query" do
    results = PatternQueryHelper.run_active_record_query(Child.all, @url_params, ["name", "id"])
    expect(results[:pagination]).to_not be nil
    expect(results[:data]).to_not be nil
  end

  it "has a version number" do
    expect(PatternQueryHelper::VERSION).not_to be nil
  end

  it "sets up the test database correctly" do
    expect(Parent.all.count).to eq(100)
    # Every parent has between 2 and 6 children
    expect(Child.all.count).to be_between(200, 600).inclusive
  end
end
