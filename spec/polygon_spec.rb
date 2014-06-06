require_relative "spec_helper"

require_relative "../lib/neo_barons/polygon"

describe NeoBarons::Polygon do
  it "closes a polygon on creation, if needed" do
    points               = [[0, 0], [0, 1], [1, 0], [0, 0]]
    manually_closed      = NeoBarons::Polygon.new(points)
    automatically_closed = NeoBarons::Polygon.new(points[0..-2])
    expect(automatically_closed.points).to eq(manually_closed.points)
  end

  it "can rotate all points" do
    polygon = NeoBarons::Polygon.new([[1, 0], [0, -2], [-3, 0], [0, 4]])
    polygon.rotate([0, 0], 90)
    expect(polygon.points).to eq([[0, 1], [2, 0], [0, -3], [-4, 0], [0, 1]])
  end

  context "containment" do
    let(:polygon) {
      NeoBarons::Polygon.new([[1, 1], [1, -1], [-1, -1], [-1, 1]])
    }

    it "can identify contained points" do
      expect(polygon.contains?([ 0.9,  0.9])).to be_truthy
      expect(polygon.contains?([ 0.9, -0.9])).to be_truthy
      expect(polygon.contains?([-0.9, -0.9])).to be_truthy
      expect(polygon.contains?([-0.9,  0.9])).to be_truthy
    end

    it "can identify not contained points" do
      expect(polygon.contains?([ 1.1,  1.1])).to be_falsey
      expect(polygon.contains?([ 1.1, -1.1])).to be_falsey
      expect(polygon.contains?([-1.1, -1.1])).to be_falsey
      expect(polygon.contains?([-1.1,  1.1])).to be_falsey
    end
  end
end
