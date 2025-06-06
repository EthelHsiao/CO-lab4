//112550179
module MUX_2to1(
               data0_i,
               data1_i,
               select_i,
               data_o
               );

parameter size = 32;		//TEST	   
			
// I/O ports               
input   [size-1:0] data0_i;          
input   [size-1:0] data1_i;
input              select_i;

output  reg [size-1:0] data_o; 

// Internal Signals


// Main function
always@(*)begin
    case (select_i)
        1'b0: data_o = data0_i;
        1'b1: data_o = data1_i;
        default: data_o = {size{1'b0}}; 
    endcase

end

endmodule      
          
          