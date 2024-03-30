module lutram
#(
    parameter Depth = 64,                       // RAM capacity
    parameter Width = 1                         // word width
)(
    input  logic                     clk,       // clock
    input  logic                     wen,       // write enable
    input  logic [$clog2(Depth)-1:0] raddr,     // read address
    input  logic [$clog2(Depth)-1:0] waddr,     // write address
    input  logic [Width-1:0]         din,       // data input
    output logic [Width-1:0]         dout       // data output
);
    
    (* ram_style="distributed" *)
    
    logic [Depth-1:0][Width-1:0] ram;

    always_ff @(posedge clk) begin : write_ram
        if(wen) begin
            ram[waddr] <= din;
        end
    end

    // read ram
    assign dout = ram[raddr];

endmodule