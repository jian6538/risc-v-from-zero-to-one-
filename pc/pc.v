// A Program Counter module that increments by 4 on each clock cycle
module pc (
  input         clk,
  input         rst,     // Reset signal
  output reg [31:0] pc   // Output for the Program Counter value
);


  always @(posedge clk) begin

    if (rst) begin

      pc <= 32'h00000000;
    end else begin

      pc <= pc + 4;
    end
  end



endmodule
