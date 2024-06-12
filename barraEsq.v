`include "defines.vh"



module barraEsq(
     input indoCima,
	  input porradao,
	  input clk,
	  input reset,
	  
	 
	output reg [9:0] x_barra,
	output reg [9:0] y_barra
);

reg [9:0] x_barra;
reg [9:0] y_barra;

always @(posedge clk or posedge reset) begin
	if (reset) begin
		x_barra <= 0;
		y_barra <= 0;
	end else begin
		if (indoCima) begin
			if (y_barra > 0)
				y_barra <= y_barra - 1;
		end else begin
			if (y_barra < 10)
				y_barra <= y_barra + 1;
		end
	end
end

endmodule
