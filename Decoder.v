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

output reg [2-1:0] RegDst_o;
output reg ALUSrc_o;
output reg [2-1:0] MemtoReg_o;
output reg RegWrite_o;
output reg MemRead_o;
output reg MemWrite_o;
output reg [2-1:0] Branch_o;
output reg [2-1:0] ALUOp_o;
output reg Jump_o;

// Main function
always @(*) begin
    case(instr_op_i)
        6'b000000: begin // R-type
            RegDst_o = 2'b01;     
            ALUSrc_o = 1'b0;       
            MemtoReg_o = 2'b00;    
            RegWrite_o = 1'b1;   
            MemRead_o = 1'b0;     
            MemWrite_o = 1'b0;    
            Branch_o = 2'b00;     
            ALUOp_o = 2'b10;      
            Jump_o = 1'b0;         
        end
        6'b001000: begin // addi
            RegDst_o = 2'b00;     
            ALUSrc_o = 1'b1;      
            MemtoReg_o = 2'b00;    
            RegWrite_o = 1'b1;     
            MemRead_o = 1'b0;     
            MemWrite_o = 1'b0;     
            Branch_o = 2'b00;      
            ALUOp_o = 2'b11;      
            Jump_o = 1'b0;        
        end
        6'b101011: begin // lw
            RegDst_o = 2'b00;     
            ALUSrc_o = 1'b1;       
            MemtoReg_o = 2'b01;   
            RegWrite_o = 1'b1;     
            MemRead_o = 1'b1;     
            MemWrite_o = 1'b0;     
            Branch_o = 2'b00;     
            ALUOp_o = 2'b00;      
            Jump_o = 1'b0;         
        end
        6'b100011: begin // sw
            RegDst_o = 2'b00;      
            ALUSrc_o = 1'b1;       
            MemtoReg_o = 2'b00;    // Dont care
            RegWrite_o = 1'b0;     
            MemRead_o = 1'b0;      
            MemWrite_o = 1'b1;     
            Branch_o = 2'b00;      
            ALUOp_o = 2'b00;      
            Jump_o = 1'b0;         
        end
        6'b000101: begin // beq
            RegDst_o = 2'b00;      
            ALUSrc_o = 1'b0;       
            MemtoReg_o = 2'b00;    
            RegWrite_o = 1'b0;     
            MemRead_o = 1'b0;      
            MemWrite_o = 1'b0;     
            Branch_o = 2'b01;      
            ALUOp_o = 2'b01;      
            Jump_o = 1'b0;         
        end
        6'b000100: begin // bne
            RegDst_o = 2'b00;      
            ALUSrc_o = 1'b0;       
            MemtoReg_o = 2'b00;    
            RegWrite_o = 1'b0;     
            MemRead_o = 1'b0;      
            MemWrite_o = 1'b0;     
            Branch_o = 2'b10;      
            ALUOp_o = 2'b01;     
            Jump_o = 1'b0;         
        end
        6'b000011: begin // j
            RegDst_o = 2'b00;     
            ALUSrc_o = 1'b0;       
            MemtoReg_o = 2'b00;    
            RegWrite_o = 1'b0;     
            MemRead_o = 1'b0;      
            MemWrite_o = 1'b0;     
            Branch_o = 2'b00;      
            ALUOp_o = 2'b00;      // Dont care
            Jump_o = 1'b1;        
        end
        6'b000010: begin // jal
            RegDst_o = 2'b10;      
            ALUSrc_o = 1'b0;      
            MemtoReg_o = 2'b10;    
            RegWrite_o = 1'b1;     
            MemRead_o = 1'b0;      
            MemWrite_o = 1'b0;     
            Branch_o = 2'b00;      
            ALUOp_o = 2'b00;     
            Jump_o = 1'b1;         
        end
        default: begin
            RegDst_o = 2'b00;
            ALUSrc_o = 1'b0;
            MemtoReg_o = 2'b00;
            RegWrite_o = 1'b0;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o = 2'b00;
            ALUOp_o = 2'b00;
            Jump_o = 1'b0;
        end
    endcase
end

endmodule
                

