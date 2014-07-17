require_relative "spec_helper"

require_relative "../lib/neo_barons/map_generator"

describe NeoBarons::MapGenerator do
  it "can generate a map with the indicated width" do
    width = rand(1..100)
    map   = NeoBarons::MapGenerator.new(width: width).generate
    expect(map.first.size).to eq(width)
  end

  it "can generate a map with the indicated height" do
    height = rand(1..100)
    map    = NeoBarons::MapGenerator.new(height: height).generate
    expect(map.size).to eq(height)
  end

  it "allows you to specify the percentage of cities to add" do
    map = NeoBarons::MapGenerator.new(cities: 0.0).generate
    expect(map.flatten.none? { |cell| cell.is_a?(NeoBarons::City) }).to be_truthy

    map = NeoBarons::MapGenerator.new(cities: 1.0).generate
    expect(map.flatten.all? { |cell| cell.is_a?(NeoBarons::City) }).to be_truthy
  end

  it "allows you to specify the percentage of small cities" do
    map = NeoBarons::MapGenerator.new(cities: 1.0, small_cities: 1.0).generate
    expect(map.flatten.all?(&:small?)).to be_truthy
  end

  it "will not allow two large cities to be side by side" do
    map = NeoBarons::MapGenerator.new(cities: 1.0, small_cities: 0.0).generate
    map.each do |row|
      row.each_cons(2) do |left, right|
        expect(left.small? == right.small?).to be_falsey
      end
    end
  end

  it "generates unique names for all cities" do
    map    = NeoBarons::MapGenerator.new(cities: 1.0).generate
    cities = map.flatten
    expect(cities.map(&:name).uniq.size).to eq(cities.size)
  end

  it "adds cargos to a city" do
    map    = NeoBarons::MapGenerator.new(cities: 1.0, small_cities: 0.5).generate
    cities = map.flatten
    cities.each do |city|
      if city.small?
        expect(city.cargos.size.between?(0, 1)).to be_truthy
      else
        expect(city.cargos.size.between?(1, 3)).to be_truthy
      end
    end
  end
end
