module lutram
#(
    parameter Depth = 64,                       // RAM capacity
    parameter Width = 1                         // word width
)(
    input  logic                     clk,       // clock
    input  logic                     wen,       // write enable
    input  logic [$clog2(Depth)-1:0] addr,      // address
    input  logic [Width-1:0]         din,       // data input
    output logic [Width-1:0]         dout       // data output
);
    
    // (* ram_style="distributed" *) 
    // logic [Depth-1:0][Width-1:0] ram;

    // always_ff @(posedge clk) begin : write_ram
    //     if(wen) begin
    //         ram[addr] <= din;
    //     end
    // end

    // // read ram
    // assign dout = ram[addr];

    xilinx_single_port_dist_ram inst_xilinx_uram (
        .a(addr),
        .d(din),
        .clk(clk),
        .we(wen),
        .spo(dout)
    );

endmodule