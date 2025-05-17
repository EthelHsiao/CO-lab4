// 112550179

module ALU(
    src1_i,
    src2_i,
    ctrl_i,
    shamt_i,
    result_o,
    zero_o
);

// I/O ports
input  [32-1:0] src1_i;
input  [32-1:0] src2_i;
input  [4-1:0] ctrl_i;
input  [5-1:0] shamt_i; // for sll and srl

output reg [32-1:0] result_o;
output zero_o;

// Internal Signals
assign zero_o = (result_o == 32'b0);

// Main function
always @(*) begin
    case(ctrl_i)
        4'b0000: result_o = src1_i & src2_i;               // AND
        4'b0001: result_o = src1_i | src2_i;               // OR
        4'b0010: result_o = src1_i + src2_i;               // ADD
        4'b0110: result_o = src1_i - src2_i;               // SUB
        4'b1100: result_o = ~(src1_i | src2_i);            // NOR
        4'b0111: result_o = ($signed(src1_i) < $signed(src2_i)) ? 1 : 0;     // SLT
        4'b1000: result_o = src2_i << shamt_i;             // SLL
        4'b1001: result_o = src2_i >> shamt_i;             // SRL
        4'b1010: result_o = src2_i << src1_i[4:0];         // SLLV 
        4'b1011: result_o = src2_i >> src1_i[4:0]; 			// SRLV
		4'b1111: result_o = src1_i; //TEST JR
        default: result_o = 32'b0;
    endcase
end

endmodule
