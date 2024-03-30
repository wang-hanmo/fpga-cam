module bram
#(
    parameter Depth = 512,                      // RAM capacity
    parameter Width = 36                        // word width
)(
    input  logic                     clk,       // clock
    input  logic                     en,        // enable
    input  logic                     wen,       // write enable
    input  logic [$clog2(Depth)-1:0] addr,      // address
    input  logic [Width-1:0]         din,       // data input
    output logic [Width-1:0]         dout       // data output
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

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(Width),
        .RAM_DEPTH(Depth),
        .RAM_PERFORMANCE("LOW_LATENCY"),
        .INIT_FILE("")
    ) inst_xilinx_bram (
        .addra(addr),
        .dina(din),
        .clka(clk),
        .wea(we),
        .ena(en),
        .rsta(1'b0),
        .regcea(1'b1),
        .douta(dout)
    );

endmodule


module xilinx_single_port_ram_read_first #(
  parameter RAM_WIDTH = 18,                       // Specify RAM data width
  parameter RAM_DEPTH = 1024,                     // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
) (
  input [clogb2(RAM_DEPTH-1)-1:0] addra,  // Address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0] dina,           // RAM input data
  input clka,                           // Clock
  input wea,                            // Write enable
  input ena,                            // RAM Enable, for additional power savings, disable port when not in use
  input rsta,                           // Output reset (does not affect memory contents)
  input regcea,                         // Output register enable
  output [RAM_WIDTH-1:0] douta          // RAM output data
);

  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data = {RAM_WIDTH{1'b0}};

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
      ram_data <= BRAM[addra];
    end

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign douta = ram_data;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] douta_reg = {RAM_WIDTH{1'b0}};

      always @(posedge clka)
        if (rsta)
          douta_reg <= {RAM_WIDTH{1'b0}};
        else if (regcea)
          douta_reg <= ram_data;

      assign douta = douta_reg;

    end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule