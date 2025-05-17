//112550179
module Decoder( 
	instr_op_i,
	ALUOp_o,
	ALUSrc_o,
	RegWrite_o,
	RegDst_o,
	Branch_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o
);

// I/O ports
input  [6-1:0] instr_op_i;

// 简化为1位宽，只需要区分Rt和Rd
output reg RegDst_o;
output reg ALUSrc_o;
// 简化为1位宽，只需要区分ALU结果和内存数据
output reg MemtoReg_o;
output reg RegWrite_o;
output reg MemRead_o;
output reg MemWrite_o;
// 简化为1位宽，只支持beq指令
output reg Branch_o;
output reg [2-1:0] ALUOp_o;
output reg Jump_o;

// Main function
always @(*) begin
    case(instr_op_i)
        6'b000000: begin // R-type
            RegDst_o = 1'b1;     // 选择Rd字段作为目标寄存器
            ALUSrc_o = 1'b0;      // 使用寄存器作为ALU的第二个操作数
            MemtoReg_o = 1'b0;    // 写回ALU结果
            RegWrite_o = 1'b1;    // 写回寄存器
            MemRead_o = 1'b0;     // 不读内存
            MemWrite_o = 1'b0;    // 不写内存
            Branch_o = 1'b0;      // 不是分支指令
            ALUOp_o = 2'b10;      // R类型ALU操作
            Jump_o = 1'b0;        // 不是跳转指令
        end
        6'b001000: begin // addi
            RegDst_o = 1'b0;      // 选择Rt字段作为目标寄存器
            ALUSrc_o = 1'b1;      // 使用立即数作为ALU的第二个操作数
            MemtoReg_o = 1'b0;    // 写回ALU结果
            RegWrite_o = 1'b1;    // 写回寄存器
            MemRead_o = 1'b0;     // 不读内存
            MemWrite_o = 1'b0;    // 不写内存
            Branch_o = 1'b0;      // 不是分支指令
            ALUOp_o = 2'b11;      // addi的ALU操作
            Jump_o = 1'b0;        // 不是跳转指令
        end
        6'b101011: begin // lw
            RegDst_o = 1'b0;      // 选择Rt字段作为目标寄存器
            ALUSrc_o = 1'b1;      // 使用立即数作为ALU的第二个操作数
            MemtoReg_o = 1'b1;    // 写回内存数据
            RegWrite_o = 1'b1;    // 写回寄存器
            MemRead_o = 1'b1;     // 读内存
            MemWrite_o = 1'b0;    // 不写内存
            Branch_o = 1'b0;      // 不是分支指令
            ALUOp_o = 2'b00;      // 内存操作的ALU操作
            Jump_o = 1'b0;        // 不是跳转指令
        end
        6'b100011: begin // sw
            RegDst_o = 1'b0;      // 不关心(选择Rt)
            ALUSrc_o = 1'b1;      // 使用立即数作为ALU的第二个操作数
            MemtoReg_o = 1'b0;    // 不关心
            RegWrite_o = 1'b0;    // 不写回寄存器
            MemRead_o = 1'b0;     // 不读内存
            MemWrite_o = 1'b1;    // 写内存
            Branch_o = 1'b0;      // 不是分支指令
            ALUOp_o = 2'b00;      // 内存操作的ALU操作
            Jump_o = 1'b0;        // 不是跳转指令
        end
        6'b000101: begin // beq
            RegDst_o = 1'b0;      // 不关心
            ALUSrc_o = 1'b0;      // 使用寄存器作为ALU的第二个操作数
            MemtoReg_o = 1'b0;    // 不关心
            RegWrite_o = 1'b0;    // 不写回寄存器
            MemRead_o = 1'b0;     // 不读内存
            MemWrite_o = 1'b0;    // 不写内存
            Branch_o = 1'b1;      // 是分支指令
            ALUOp_o = 2'b01;      // 分支操作的ALU操作
            Jump_o = 1'b0;        // 不是跳转指令
        end
        default: begin // 默认:无操作
            RegDst_o = 1'b0;
            ALUSrc_o = 1'b0;
            MemtoReg_o = 1'b0;
            RegWrite_o = 1'b0;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o = 1'b0;
            ALUOp_o = 2'b00;
            Jump_o = 1'b0;
        end
    endcase
end

endmodule