/*
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

module cpu_mem_iface (
    // Wishbone common signals
    input wb_clk_i,
    input wb_rst_i,

    // Wishbone slave interface
    input  [16:1] wbs_adr_i,
    input  [ 1:0] wbs_sel_i,
    input         wbs_we_i,
    input  [15:0] wbs_dat_i,
    output [15:0] wbs_dat_o,
    input         wbs_stb_i,
    output        wbs_ack_o,

    // Wishbone master to SRAM
    output [17:1] wbm_adr_o,
    output [ 1:0] wbm_sel_o,
    output        wbm_we_o,
    output [15:0] wbm_dat_o,
    input  [15:0] wbm_dat_i,
    output        wbm_stb_o,
    input         wbm_ack_i,

    // VGA configuration registers
    input        memory_mapping1,
    input [ 1:0] write_mode,
    input [ 1:0] raster_op,
    input        read_mode,
    input [ 7:0] bitmask,
    input [ 3:0] set_reset,
    input [ 3:0] enable_set_reset,
    input [ 3:0] map_mask,
    input [ 1:0] read_map_select,
    input [ 3:0] color_compare,
    input [ 3:0] color_dont_care
  );

  // Registers and nets
  wire        read_stb;
  wire        write_stb;
  wire        rd_wbs_ack_o;
  wire        wr_wbs_ack_o;
  wire [17:1] rd_wbm_adr_o;
  wire [17:1] wr_wbm_adr_o;
  wire        rd_wbm_stb_o;
  wire        wr_wbm_stb_o;

  wire [7:0] latch0, latch1, latch2, latch3;

  // Module instances
  read_iface rd_iface (
    .wb_clk_i (wb_clk_i),
    .wb_rst_i (wb_rst_i),

    .wbs_adr_i (wbs_adr_i),
    .wbs_sel_i (wbs_sel_i),
    .wbs_dat_o (wbs_dat_o),
    .wbs_stb_i (read_stb),
    .wbs_ack_o (rd_wbs_ack_o),

    .wbm_adr_o (rd_wbm_adr_o),
    .wbm_dat_i (wbm_dat_i),
    .wbm_stb_o (rd_wbm_stb_o),
    .wbm_ack_i (wbm_ack_i),

    .memory_mapping1 (memory_mapping1),
    .read_mode       (read_mode),
    .read_map_select (read_map_select),
    .color_compare   (color_compare),
    .color_dont_care (color_dont_care),

    .latch0 (latch0),
    .latch1 (latch1),
    .latch2 (latch2),
    .latch3 (latch3)
  );

  write_iface wr_iface (
    .wb_clk_i (wb_clk_i),
    .wb_rst_i (wb_rst_i),

    .wbs_adr_i (wbs_adr_i),
    .wbs_sel_i (wbs_sel_i),
    .wbs_dat_i (wbs_dat_i),
    .wbs_stb_i (write_stb),
    .wbs_ack_o (wr_wbs_ack_o),

    .wbm_adr_o (wr_wbm_adr_o),
    .wbm_sel_o (wbm_sel_o),
    .wbm_dat_o (wbm_dat_o),
    .wbm_stb_o (wr_wbm_stb_o),
    .wbm_ack_i (wbm_ack_i),

    .memory_mapping1  (memory_mapping1),
    .write_mode       (write_mode),
    .raster_op        (raster_op),
    .bitmask          (bitmask),
    .set_reset        (set_reset),
    .enable_set_reset (enable_set_reset),
    .map_mask         (map_mask),

    .latch0 (latch0),
    .latch1 (latch1),
    .latch2 (latch2),
    .latch3 (latch3)
  );

  // Continuous assignments
  assign read_stb  = wbs_stb_i & !wbs_we_i;
  assign write_stb = wbs_stb_i & wbs_we_i;

  assign wbs_ack_o = wbs_we_i ? wr_wbs_ack_o : rd_wbs_ack_o;
  assign wbm_adr_o = wbs_we_i ? wr_wbm_adr_o : rd_wbm_adr_o;
  assign wbm_stb_o = wbs_we_i ? wr_wbm_stb_o : rd_wbm_stb_o;

  assign wbm_we_o  = wbs_we_i;

endmodule
