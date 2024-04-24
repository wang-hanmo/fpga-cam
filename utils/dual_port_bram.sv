module dual_port_bram
#(
    parameter Depth = 512,                      // RAM capacity
    parameter Width = 36                        // word width
)(
    input  logic                     clk,       // clock
    input  logic                     en_0,      // enable
    input  logic                     wen_0,     // write enable
    input  logic [$clog2(Depth)-1:0] addr_0,    // address
    input  logic [Width-1:0]         din_0,     // data input
    output logic [Width-1:0]         dout_0,    // data output
    input  logic                     en_1,        // enable
    input  logic                     wen_1,       // write enable
    input  logic [$clog2(Depth)-1:0] addr_1,      // address
    input  logic [Width-1:0]         din_1,       // data input
    output logic [Width-1:0]         dout_1       // data output
);

    // logic [Depth-1:0][Width-1:0] ram;

    // always_ff @(posedge clk) begin : write_ram
    //     if(en) begin
    //         if(wen) begin
    //             ram[addr] <= din;
    //         end
    //     end
    // end

    // always_ff @(posedge clk) begin : read_ram
    //     if(en) begin
    //         dout <= ram[addr];
    //     end
    // end

    xilinx_true_dual_port_read_first_1_clock_ram #(
        .RAM_WIDTH(Width),
        .RAM_DEPTH(Depth),
        .RAM_PERFORMANCE("LOW_LATENCY"),
        .INIT_FILE("")
    ) inst_xilinx_bram (
        .addra(addr_0),
        .addrb(addr_1),
        .dina(din_0),
        .dinb(din_1),
        .clka(clk),
        .wea(wen_0),
        .web(wen_1),
        .ena(en_0),
        .enb(en_1),
        .rsta(1'b0),
        .rstb(1'b0),
        .regcea(1'b1),
        .regceb(1'b1),
        .douta(dout_0),
        .doutb(dout_1)
    );

endmodule


module xilinx_true_dual_port_read_first_1_clock_ram #(
  parameter RAM_WIDTH = 18,                       // Specify RAM data width
  parameter RAM_DEPTH = 1024,                     // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
) (
  input [clogb2(RAM_DEPTH-1)-1:0] addra,  // Port A address bus, width determined from RAM_DEPTH
  input [clogb2(RAM_DEPTH-1)-1:0] addrb,  // Port B address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0] dina,           // Port A RAM input data
  input [RAM_WIDTH-1:0] dinb,           // Port B RAM input data
  input clka,                           // Clock
  input wea,                            // Port A write enable
  input web,                            // Port B write enable
  input ena,                            // Port A RAM Enable, for additional power savings, disable port when not in use
  input enb,                            // Port B RAM Enable, for additional power savings, disable port when not in use
  input rsta,                           // Port A output reset (does not affect memory contents)
  input rstb,                           // Port B output reset (does not affect memory contents)
  input regcea,                         // Port A output register enable
  input regceb,                         // Port B output register enable
  output [RAM_WIDTH-1:0] douta,         // Port A RAM output data
  output [RAM_WIDTH-1:0] doutb          // Port B RAM output data
);

  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data_a = {RAM_WIDTH{1'b0}};
  reg [RAM_WIDTH-1:0] ram_data_b = {RAM_WIDTH{1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge clka)
    if (ena) begin
      if (wea)
        BRAM[addra] <= dina;
      ram_data_a <= BRAM[addra];
    end

  always @(posedge clka)
    if (enb) begin
      if (web)
        BRAM[addrb] <= dinb;
      ram_data_b <= BRAM[addrb];
    end

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign douta = ram_data_a;
       assign doutb = ram_data_b;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] douta_reg = {RAM_WIDTH{1'b0}};
      reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};

      always @(posedge clka)
        if (rsta)
          douta_reg <= {RAM_WIDTH{1'b0}};
        else if (regcea)
          douta_reg <= ram_data_a;

      always @(posedge clka)
        if (rstb)
          doutb_reg <= {RAM_WIDTH{1'b0}};
        else if (regceb)
          doutb_reg <= ram_data_b;

      assign douta = douta_reg;
      assign doutb = doutb_reg;

    end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule