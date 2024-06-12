module placar(
	input [9:0] placar,
	input [9:0] placarOponente,
	
	output reg [6:0] HEX0,
	output reg [6:0] HEX1,
	output reg [6:0] HEX2,
	output reg [6:0] HEX3,
	output reg [6:0] HEX4,
	output reg [6:0] HEX5
);
	
	parameter W = 10;
	reg [W+(W-4)/3:0] bcd1;
	reg [W+(W-4)/3:0] bcd2;

	always @(bcd2) begin
		case (bcd2[3:0])
			0: HEX0 <= 7'b1000000;
			1: HEX0 <= 7'b1111001;
			2: HEX0 <= 7'b0100100;
			3: HEX0 <= 7'b0110000;
			4: HEX0 <= 7'b0011001;
			5: HEX0 <= 7'b0010010;
			6: HEX0 <= 7'b0000010;
			7: HEX0 <= 7'b1111000;
			8: HEX0 <= 7'b0000000;
			9: HEX0 <= 7'b0011000;
		endcase
		
		case (bcd2[7:4])
			0: HEX1 <= 7'b1000000;
			1: HEX1 <= 7'b1111001;
			2: HEX1 <= 7'b0100100;
			3: HEX1 <= 7'b0110000;
			4: HEX1 <= 7'b0011001;
			5: HEX1 <= 7'b0010010;
			6: HEX1 <= 7'b0000010;
			7: HEX1 <= 7'b1111000;
			8: HEX1 <= 7'b0000000;
			9: HEX1 <= 7'b0011000;
		endcase
		
		case (bcd2[11:8])
			0: HEX2 <= 7'b1000000;
			1: HEX2 <= 7'b1111001;
			2: HEX2 <= 7'b0100100;
			3: HEX2 <= 7'b0110000;
			4: HEX2 <= 7'b0011001;
			5: HEX2 <= 7'b0010010;
			6: HEX2 <= 7'b0000010;
			7: HEX2 <= 7'b1111000;
			8: HEX2 <= 7'b0000000;
			9: HEX2 <= 7'b0011000;
		endcase
	end
	
	always @(bcd1) begin
		case (bcd1[3:0])
			0: HEX3 <= 7'b1000000;
			1: HEX3 <= 7'b1111001;
			2: HEX3 <= 7'b0100100;
			3: HEX3 <= 7'b0110000;
			4: HEX3 <= 7'b0011001;
			5: HEX3 <= 7'b0010010;
			6: HEX3 <= 7'b0000010;
			7: HEX3 <= 7'b1111000;
			8: HEX3 <= 7'b0000000;
			9: HEX3 <= 7'b0011000;
		endcase
		
		case (bcd1[7:4])
			0: HEX4 <= 7'b1000000;
			1: HEX4 <= 7'b1111001;
			2: HEX4 <= 7'b0100100;
			3: HEX4 <= 7'b0110000;
			4: HEX4 <= 7'b0011001;
			5: HEX4 <= 7'b0010010;
			6: HEX4 <= 7'b0000010;
			7: HEX4 <= 7'b1111000;
			8: HEX4 <= 7'b0000000;
			9: HEX4 <= 7'b0011000;
		endcase
		
		case (bcd1[11:8])
			0: HEX5 <= 7'b1000000;
			1: HEX5 <= 7'b1111001;
			2: HEX5 <= 7'b0100100;
			3: HEX5 <= 7'b0110000;
			4: HEX5 <= 7'b0011001;
			5: HEX5 <= 7'b0010010;
			6: HEX5 <= 7'b0000010;
			7: HEX5 <= 7'b1111000;
			8: HEX5 <= 7'b0000000;
			9: HEX5 <= 7'b0011000;
		endcase
	end

	integer i1, j1;
	always @(placarOponente) begin
		for(i1 = 0; i1 <= W+(W-4)/3; i1 = i1+1)
			bcd1[i1] = 0;     // initialize with zeros
		
		bcd1[W-1:0] = placarOponente;                                   // initialize with input vector
		
		for(i1 = 0; i1 <= W-4; i1 = i1+1)                       // iterate on structure depth
			for(j1 = 0; j1 <= i1/3; j1 = j1+1)                     // iterate on structure width
				if (bcd1[W-i1+4*j1 -: 4] > 4)                      // if > 4
					bcd1[W-i1+4*j1 -: 4] = bcd1[W-i1+4*j1 -: 4] + 4'd3; // add 3
	end

	always @(placar) begin
		for(i1 = 0; i1 <= W+(W-4)/3; i1 = i1+1)
			bcd2[i1] = 0;     // initialize with zeros
		
		bcd2[W-1:0] = placar;                                   // initialize with input vector
		
		for(i1 = 0; i1 <= W-4; i1 = i1+1)                       // iterate on structure depth
			for(j1 = 0; j1 <= i1/3; j1 = j1+1)                     // iterate on structure width
				if (bcd2[W-i1+4*j1 -: 4] > 4)                      // if > 4
					bcd2[W-i1+4*j1 -: 4] = bcd2[W-i1+4*j1 -: 4] + 4'd3; // add 3
	end
endmodule