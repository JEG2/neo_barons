require_relative "spec_helper"

require_relative "../lib/neo_barons/grid"

describe NeoBarons::Grid do
  it "fails with an error if an index is outside of the grid" do
    grid = NeoBarons::Grid.new(columns: 2, rows: 2, width: 42, height: 42)
    expect do
      grid[2, 2]
    end.to raise_error(NeoBarons::Grid::OutOfGridError)
  end

  it "knows the width of tiles" do
    width = rand(20..30)
    grid  = NeoBarons::Grid.new(columns: 2, rows: 1, width: width, height: 42)
    expect(grid[0, 0].width).to eq(width)
    expect(grid[1, 0].width).to eq(width)
  end

  it "knows the height of tiles" do
    height = rand(20..30)
    grid   = NeoBarons::Grid.new(columns: 1, rows: 2, width: 42, height: height)
    expect(grid[0, 0].height).to eq(height)
    expect(grid[0, 1].height).to eq(height)
  end

  it "calculates tile offsets" do
    grid = NeoBarons::Grid.new(columns: 3, rows: 3, width: 10, height: 100)
    expect(grid[0, 0].x_offset).to eq(0)
    expect(grid[1, 0].x_offset).to eq(10)
    expect(grid[2, 0].x_offset).to eq(20)
    expect(grid[0, 0].y_offset).to eq(0)
    expect(grid[0, 1].y_offset).to eq(100)
    expect(grid[0, 2].y_offset).to eq(200)
  end

  it "honors global and even/odd offsets" do
    grid = NeoBarons::Grid.new( columns:              2,
                                rows:                 2,
                                width:            1_000,
                                height:           2_000,
                                global_row_offset:    1,
                                even_row_offset:     10,
                                odd_row_offset:      20,
                                global_column_offset: 2,
                                even_column_offset: 100,
                                odd_column_offset:  200 )
    expect(grid[0, 0].x_offset).to eq(11)
    expect(grid[1, 0].x_offset).to eq(1011)
    expect(grid[0, 1].x_offset).to eq(21)
    expect(grid[1, 1].x_offset).to eq(1021)
    expect(grid[0, 0].y_offset).to eq(102)
    expect(grid[0, 1].y_offset).to eq(2102)
    expect(grid[1, 0].y_offset).to eq(202)
    expect(grid[1, 1].y_offset).to eq(2202)
  end

  it "can calculate last pixels in a tile" do
    grid = NeoBarons::Grid.new( columns:           2,
                                rows:              2,
                                width:         1_000,
                                height:        2_000,
                                global_row_offset: 1,
                                even_row_offset:  10,
                                odd_row_offset:   20 )
    expect(grid[0, 0].last_x).to eq(1_010)
    expect(grid[1, 0].last_x).to eq(2_010)
    expect(grid[0, 1].last_x).to eq(1_020)
    expect(grid[1, 1].last_x).to eq(2_020)
    expect(grid[0, 0].last_y).to eq(1_999)
    expect(grid[0, 1].last_y).to eq(3_999)
  end

  context "with mouse coordinates" do
    let(:grid) {
      NeoBarons::Grid.new( columns:         3,
                           rows:            3,
                           width:          50,
                           height:         50,
                           odd_row_offset: 25 )
    }

    it "can find a cell" do
      tile = grid.from_mouse(75, 25)
      expect([tile.x, tile.y]).to eq([1, 0])
      tile = grid.from_mouse(60, 75)
      expect([tile.x, tile.y]).to eq([0, 1])
    end

    it "returns nil if the coordinates are outside the grid" do
      expect(grid.from_mouse(10, 75)).to be_nil
      expect(grid.from_mouse(175, 25)).to be_nil
    end
  end

  it "can iterate over the grid" do
    tiles = [ ]
    grid  = NeoBarons::Grid.new(columns: 2, rows: 3, width: 42, height: 42)
    grid.each do |tile|
      tiles << [tile.x, tile.y]
    end
    expect(tiles).to eq( [ [0, 0], [1, 0],
                           [0, 1], [1, 1],
                           [0, 2], [1, 2] ] )
    expect(grid.map { |tile| [tile.x, tile.y] }).to eq(tiles)
  end
end
