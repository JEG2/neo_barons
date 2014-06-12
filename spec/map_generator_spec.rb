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
    map = NeoBarons::MapGenerator.new(cities: 1.0, small_cities: 0.0).generate
    expect(map.flatten.none?(&:small?)).to be_truthy

    map = NeoBarons::MapGenerator.new(cities: 1.0, small_cities: 1.0).generate
    expect(map.flatten.all?(&:small?)).to be_truthy
  end

  it "generates unique names for all cities" do
    map    = NeoBarons::MapGenerator.new(cities: 1.0).generate
    cities = map.flatten
    expect(cities.map(&:name).uniq.size).to eq(cities.size)
  end
end
