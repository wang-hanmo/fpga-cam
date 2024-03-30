module pe 
#(
    parameter Width = 8
)(
    input  logic [Width-1:0]         in,
    output logic [$clog2(Width)-1:0] out
);

  always_comb begin
    out = '0;
    for (int i = 0; i < Width; i++) begin
      if (in[i]) begin
        out = i;
        break;
      end
    end
  end

endmodule