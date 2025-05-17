// ID

`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Reg_File.v"
`include "Data_Memory.v"
`include "Decoder.v"
`include "Instruction_Memory.v"
`include "MUX_2to1.v"
`include "MUX_3to1.v"
`include "MUX_4to1.v"
`include "Pipe_Reg.v"
`include "ProgramCounter.v"
`include "Shift_Left_Two_32.v"
`include "Sign_Extend.v"


`timescale 1ns / 1ps

module Pipe_CPU(
    clk_i,
    rst_i
);

// I/O端口
input clk_i;
input rst_i;

// 内部信号定义
// IF 阶段信号
wire [31:0] pc_in, pc_out, pc_add4, instr;

// ID 阶段信号
wire [31:0] ID_pc_add4, ID_instr, ID_RSdata, ID_RTdata, ID_extended;
wire [1:0] ID_ALUOp;
wire ID_ALUSrc, ID_RegWrite, ID_Branch, ID_MemRead, ID_MemWrite, ID_MemtoReg, ID_RegDst;

// EX 阶段信号
wire [31:0] EX_pc_add4, EX_RSdata, EX_RTdata, EX_extended, EX_ALUresult, EX_branch_addr;
wire [4:0] EX_Rt, EX_Rd, EX_RegDst_out;
wire [1:0] EX_ALUOp;
wire [3:0] EX_ALUCtrl;
wire EX_ALUSrc, EX_RegWrite, EX_Branch, EX_MemRead, EX_MemWrite, EX_MemtoReg, EX_RegDst;
wire EX_Zero;
wire [31:0] EX_shifted_extended; // 移位后的扩展输出
wire [31:0] EX_ALUSrc_out; // ALU源选择器输出

// MEM 阶段信号
wire [31:0] MEM_ALUresult, MEM_RTdata, MEM_ReadData, MEM_branch_addr;
wire [4:0] MEM_RegDst_out;
wire MEM_RegWrite, MEM_Branch, MEM_MemRead, MEM_MemWrite, MEM_MemtoReg, MEM_Zero;
wire MEM_PCSrc;

// WB 阶段信号
wire [31:0] WB_ALUresult, WB_ReadData, WB_WriteData;
wire [4:0] WB_RegDst_out;
wire WB_RegWrite, WB_MemtoReg;

// 组件实例化
// IF 阶段组件
ProgramCounter PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc_in_i(pc_in),
    .pc_out_o(pc_out)
);

Adder Adder_PC_Plus_4(
    .src1_i(pc_out),
    .src2_i(32'd4),
    .sum_o(pc_add4)
);

Instruction_Memory IM(
    .addr_i(pc_out),
    .instr_o(instr)
);

MUX_2to1 #(.size(32)) MUX_PC_Source(
    .data0_i(pc_add4),
    .data1_i(MEM_branch_addr),
    .select_i(MEM_PCSrc),
    .data_o(pc_in)
);

// IF/ID 寄存器
Pipe_Reg #(.size(64)) IF_ID(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({pc_add4, instr}),
    .data_o({ID_pc_add4, ID_instr})
);

// ID 阶段组件
Decoder Decoder(
    .instr_op_i(ID_instr[31:26]),
    .ALUOp_o(ID_ALUOp),
    .ALUSrc_o(ID_ALUSrc),
    .RegWrite_o(ID_RegWrite),
    .RegDst_o(ID_RegDst),
    .Branch_o(ID_Branch),
    .Jump_o(), // 未使用，所以未连接
    .MemRead_o(ID_MemRead),
    .MemWrite_o(ID_MemWrite),
    .MemtoReg_o(ID_MemtoReg)
);

Reg_File RF(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(ID_instr[25:21]),
    .RTaddr_i(ID_instr[20:16]),
    .RDaddr_i(WB_RegDst_out),
    .RDdata_i(WB_WriteData),
    .RegWrite_i(WB_RegWrite),
    .RSdata_o(ID_RSdata),
    .RTdata_o(ID_RTdata)
);

Sign_Extend Sign_Extend(
    .data_i(ID_instr[15:0]),
    .data_o(ID_extended)
);

// ID/EX 寄存器
// 计算位宽: 1(RegWrite) + 1(MemtoReg) + 1(Branch) + 1(MemRead) + 1(MemWrite) + 
//           1(RegDst) + 2(ALUOp) + 1(ALUSrc) + 32(pc_add4) + 32(RSdata) + 
//           32(RTdata) + 32(extended) + 5(Rt) + 5(Rd) = 147位
Pipe_Reg #(.size(147)) ID_EX(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({
        ID_RegWrite, ID_MemtoReg, ID_Branch, ID_MemRead, ID_MemWrite, 
        ID_RegDst, ID_ALUOp, ID_ALUSrc, ID_pc_add4, ID_RSdata, ID_RTdata, 
        ID_extended, ID_instr[20:16], ID_instr[15:11]
    }),
    .data_o({
        EX_RegWrite, EX_MemtoReg, EX_Branch, EX_MemRead, EX_MemWrite, 
        EX_RegDst, EX_ALUOp, EX_ALUSrc, EX_pc_add4, EX_RSdata, EX_RTdata, 
        EX_extended, EX_Rt, EX_Rd
    })
);

// EX 阶段组件
Shift_Left_Two_32 Shifter(
    .data_i(EX_extended),
    .data_o(EX_shifted_extended)
);

Adder Adder_Branch(
    .src1_i(EX_pc_add4),
    .src2_i(EX_shifted_extended),
    .sum_o(EX_branch_addr)
);

// 选择写回寄存器地址
MUX_2to1 #(.size(5)) MUX_RegDst(
    .data0_i(EX_Rt),
    .data1_i(EX_Rd),
    .select_i(EX_RegDst),
    .data_o(EX_RegDst_out)
);

// 选择ALU的第二个操作数
MUX_2to1 #(.size(32)) MUX_ALUSrc(
    .data0_i(EX_RTdata),
    .data1_i(EX_extended),
    .select_i(EX_ALUSrc),
    .data_o(EX_ALUSrc_out)
);

ALU_Ctrl ALU_Ctrl(
    .funct_i(EX_extended[5:0]),
    .ALUOp_i(EX_ALUOp),
    .ALUCtrl_o(EX_ALUCtrl)
);

ALU ALU(
    .src1_i(EX_RSdata),
    .src2_i(EX_ALUSrc_out),
    .ctrl_i(EX_ALUCtrl),
    .shamt_i(EX_extended[10:6]), // 移位量输入
    .result_o(EX_ALUresult),
    .zero_o(EX_Zero)
);

// EX/MEM 寄存器
// 计算位宽: 1(RegWrite) + 1(MemtoReg) + 1(Branch) + 1(MemRead) + 1(MemWrite) + 
//           32(branch_addr) + 1(Zero) + 32(ALUresult) + 32(RTdata) + 5(RegDst_out) = 107位
Pipe_Reg #(.size(107)) EX_MEM(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({
        EX_RegWrite, EX_MemtoReg, EX_Branch, EX_MemRead, EX_MemWrite, 
        EX_branch_addr, EX_Zero, EX_ALUresult, EX_RTdata, EX_RegDst_out
    }),
    .data_o({
        MEM_RegWrite, MEM_MemtoReg, MEM_Branch, MEM_MemRead, MEM_MemWrite, 
        MEM_branch_addr, MEM_Zero, MEM_ALUresult, MEM_RTdata, MEM_RegDst_out
    })
);

// MEM 阶段组件
// 简化的分支控制逻辑 - 只支持beq指令
assign MEM_PCSrc = MEM_Branch & MEM_Zero;

Data_Memory DM(
    .clk_i(clk_i),
    .addr_i(MEM_ALUresult),
    .data_i(MEM_RTdata),
    .MemRead_i(MEM_MemRead),
    .MemWrite_i(MEM_MemWrite),
    .data_o(MEM_ReadData)
);

// MEM/WB 寄存器
// 计算位宽: 1(RegWrite) + 1(MemtoReg) + 32(ReadData) + 32(ALUresult) + 5(RegDst_out) = 71位
Pipe_Reg #(.size(71)) MEM_WB(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({MEM_RegWrite, MEM_MemtoReg, MEM_ReadData, MEM_ALUresult, MEM_RegDst_out}),
    .data_o({WB_RegWrite, WB_MemtoReg, WB_ReadData, WB_ALUresult, WB_RegDst_out})
);

// WB 阶段组件
MUX_2to1 #(.size(32)) MUX_MemtoReg(
    .data0_i(WB_ALUresult),
    .data1_i(WB_ReadData),
    .select_i(WB_MemtoReg),
    .data_o(WB_WriteData)
);

endmodule