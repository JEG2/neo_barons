require_relative "spec_helper"

require_relative "../lib/neo_barons/highlighter"

describe NeoBarons::Highlighter do
  let(:hub)         { double(drawn_cargos: [ ]) }
  let(:map)         { [[hub] * 15] * 15 }
  let(:sizes)       {
    double(
      scaled_width:                 1280.0 / 2880,
      scaled_height:                800.0  / 1800,
      drawn_tile:                   120,
      half_tile:                    120 / 2,
      third_tile:                   120 / 3,
      two_thirds_tile:              120 / 3 * 2,
      drawn_columns:                15,
      drawn_rows:                   15,
      last_column:                  15 - 1,
      last_row:                     15 - 1,
      hub_x:                        (120 - 40) / 2 - 1,
      hub_width:                    40,
      hub_x_plus_width:             (120 - 40) / 2 - 1 + 40,
      hub_y:                        (120 - 40) / 2,
      hub_y_plus_height:            (120 - 40) / 2 + 40,
      half_hub_height:              40 / 2,
      half_rail_width:              2 / 2,
      highlightable_rail_width:     20,
      half_highlightable_rail_diff: (20 - 2) / 2,
      angled_rail:                  Math.sqrt(120 ** 2 + 60 ** 2).round,
      half_cargo_width:             40 / 2,
      y_offset:                     40 / 2 - 10,
      cargo_y:                      (120 - 40) / 2 - 120 / 2,
      cargo_y_tweak:                10,
      cargo_width:                  40,
      cargo_height:                 40
    )
  }
  let(:highlighter) { NeoBarons::Highlighter.new(map, sizes) }

  # X---X---X---X...
  #  \ / \ / \ / \
  #   X---X---*---X...
  #  / \ / \ / \ /
  # X---X---X---X...
  let(:column)           { 2 }
  let(:row)              { 1 }
  let(:tile)             { sizes.drawn_tile * sizes.scaled_width }
  let(:half_tile)        { tile / 2 }
  let(:half_cargo)       { sizes.half_cargo_width * sizes.scaled_width }
  let(:half_offset)      { sizes.y_offset         * sizes.scaled_height }
  let(:cargo_y)          { sizes.cargo_y * sizes.scaled_height }
  let(:cargo_tweak)      { sizes.cargo_y_tweak * sizes.scaled_height }
  let(:half_cargo_tweak) { cargo_tweak / 2 }
  let(:mouse_middle_x)   { tile * column + half_tile + half_tile + half_cargo }
  let(:mouse_middle_y)   { tile * row + half_tile + half_offset }

  it "highlights hubs when the mouse is inside of it" do
    highlighter.locate_mouse(mouse_middle_x, mouse_middle_y)
    expect(highlighter.highlight_hub?(column, row)).to be_truthy
  end

  context "with a point on a connection" do
    let(:half_hub) { 20 * sizes.scaled_width }
    let(:x_offset) { half_hub.ceil + 1 }
    let(:y_offset) { x_offset * Math.sqrt(3) }  # 30 60 90 triangle

    it "highlights upper left connections in the same tile" do
      highlighter.locate_mouse( mouse_middle_x - x_offset,
                                mouse_middle_y - y_offset )
      expect(highlighter.highlight_connection?(column, row, 2)).to be_truthy
    end

    it "highlights left connections in the same tile" do
      highlighter.locate_mouse(mouse_middle_x - x_offset, mouse_middle_y)
      expect(highlighter.highlight_connection?(column, row, 1)).to be_truthy
    end

    it "highlights lower left connections in the same tile" do
      highlighter.locate_mouse( mouse_middle_x - x_offset,
                                mouse_middle_y + y_offset )
      expect(highlighter.highlight_connection?(column, row, 0)).to be_truthy
    end

    it "highlights upper right connections as lower left in up right tile" do
      highlighter.locate_mouse( mouse_middle_x + x_offset,
                                mouse_middle_y - y_offset )
      expect(
        highlighter.highlight_connection?(column + 1, row - 1, 0)
      ).to be_truthy
    end

    it "highlights right connections as left in right tile" do
      highlighter.locate_mouse(mouse_middle_x + x_offset, mouse_middle_y)
      expect(highlighter.highlight_connection?(column + 1, row, 1)).to be_truthy
    end

    it "highlights lower right connections as upper left in down right tile" do
      highlighter.locate_mouse( mouse_middle_x + x_offset,
                                mouse_middle_y + y_offset )
      expect(
        highlighter.highlight_connection?(column + 1, row + 1, 2)
      ).to be_truthy
    end
  end

  context "cargos" do
    let(:city) { double(drawn_cargos: %w[apples bacon carrots]) }
    let(:map)  {
      ([[hub] * 15] * 15).tap do |hubs|
        hubs[row] = ([hub] * 15).tap do |row_of_hubs|
          row_of_hubs[column] = city
        end
      end
    }

    context "in this tile" do
      it "are highlighted at the top left" do
        highlighter.locate_mouse( mouse_middle_x - half_tile + 1,
                                  mouse_middle_y - half_tile + 1 )
        expect(highlighter.highlight_cargo?(column, row, 0)).to be_truthy
      end

      it "are highlighted at the top middle" do
        highlighter.locate_mouse(mouse_middle_x, mouse_middle_y - half_tile + 1)
        expect(highlighter.highlight_cargo?(column, row, 1)).to be_truthy
      end

      it "are highlighted at the top right" do
        highlighter.locate_mouse( mouse_middle_x + half_tile - 1,
                                  mouse_middle_y - half_tile + 1 )
        expect(highlighter.highlight_cargo?(column, row, 2)).to be_truthy
      end

      it "are not highlighted if they don't exist" do
        city.drawn_cargos[1] = nil
        highlighter.locate_mouse(mouse_middle_x, mouse_middle_y - half_tile + 1)
        expect(highlighter.highlight_cargo?(column, row, 1)).to be_falsey
      end
    end

    context "in the tile below" do
      it "are highlighted at the top left" do
        highlighter.locate_mouse(
          mouse_middle_x - half_tile + 1,
          mouse_middle_y - half_tile + cargo_y + cargo_tweak + half_cargo_tweak
        )
        expect(highlighter.highlight_cargo?(column, row, 0)).to be_truthy
      end

      it "are highlighted at the top middle" do
        highlighter.locate_mouse(
          mouse_middle_x,
          mouse_middle_y - half_tile + (cargo_y + half_cargo_tweak)
        )
        expect(highlighter.highlight_cargo?(column, row, 1)).to be_truthy
      end

      it "are highlighted at the top right" do
        highlighter.locate_mouse(
          mouse_middle_x + half_tile - 1,
          mouse_middle_y - half_tile + cargo_y + cargo_tweak + half_cargo_tweak
        )
        expect(highlighter.highlight_cargo?(column, row, 2)).to be_truthy
      end
    end
  end
end
