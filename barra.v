`include "defines.vh"



module barra(
    input indoCima,
    input porradao,
    input clk,
    input reset,
	input [9:0] x_inicial,
	input [9:0] y_inicial,
	
	output reg [9:0] x_barra,
	output reg [9:0] y_barra,
	output [9:0] velocidadePorradao
);

    reg [31:0] contadorBarraV;
    reg [31:0] contadorBarraH;
    reg [1:0] estadoBarraV;
    reg [31:0] contadorPorradao;
    reg [1:0] estadoPorradao;
    
	 
	 
	`define PORRADAO_NULL 2'b00
	`define PORRADAO_INDO 2'b01
	`define PORRADAO_VOLTANDO 2'b10
	`define PORRADAO_TEMPO 5000000


	`define VELOCIDADE_PORRADAO1 10
	`define VELOCIDADE_PORRADAO2 20
	`define VELOCIDADE_PORRADAO3 30
	`define VELOCIDADE_PORRADAO4 40
	`define VELOCIDADE_PORRADAO5 50

	assign velocidadePorradao = estadoPorradao == `PORRADAO_NULL ? 0 :
		contadorPorradao < `PORRADAO_TEMPO/10 ? `VELOCIDADE_PORRADAO1 :
		contadorPorradao < `PORRADAO_TEMPO/10*2 ? `VELOCIDADE_PORRADAO2 :
		contadorPorradao < `PORRADAO_TEMPO/10*3 ? `VELOCIDADE_PORRADAO3 :
		contadorPorradao < `PORRADAO_TEMPO/10*4 ? `VELOCIDADE_PORRADAO4 :
		contadorPorradao < `PORRADAO_TEMPO/10*5 ? `VELOCIDADE_PORRADAO5 :
		contadorPorradao < `PORRADAO_TEMPO/10*6 ? `VELOCIDADE_PORRADAO5 :
		contadorPorradao < `PORRADAO_TEMPO/10*7 ? `VELOCIDADE_PORRADAO4 :
		contadorPorradao < `PORRADAO_TEMPO/10*8 ? `VELOCIDADE_PORRADAO3 :
		contadorPorradao < `PORRADAO_TEMPO/10*9 ? `VELOCIDADE_PORRADAO2 :
		`VELOCIDADE_PORRADAO1;
	
	 
    //tamanho barra: x = 60, y = 20
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_barra <= x_inicial;
            y_barra <= y_inicial;
            contadorBarraV <= 0;
            estadoPorradao <= `PORRADAO_NULL;
            contadorPorradao <= 0;
            contadorBarraH <= 0;
        end else begin
		contadorBarraV <= contadorBarraV + `VELOCIDADE_BARRA_V;
		
//MAQUINA DE ESTADOS PARA O PORRADAO(CONTROLA DIRECAO)
        contadorPorradao <= contadorPorradao + 1;
            case(estadoPorradao)
                `PORRADAO_NULL: begin
                    if(!porradao) begin
				    contadorPorradao <= 0;
                        contadorBarraH <= 0;
                        estadoPorradao <= `PORRADAO_INDO;
                    end
		    end
                `PORRADAO_INDO: begin
			    contadorBarraH <= contadorBarraH + velocidadePorradao;
                    if (contadorPorradao >= `PORRADAO_TEMPO) begin
                        contadorPorradao <= 0;
								contadorBarraH <= 0;
                        estadoPorradao <= `PORRADAO_VOLTANDO;
                    end 
                end
                `PORRADAO_VOLTANDO: begin
			    contadorBarraH <= contadorBarraH + velocidadePorradao;
                    if (contadorPorradao >= `PORRADAO_TEMPO) begin
                        contadorPorradao <= 0;
                        estadoPorradao <= `PORRADAO_NULL;
                    end 
                end
            endcase

		//CONTROLA MOVIMENTO DA BARRA
		if (contadorBarraV >= 2500000) begin
			if (/*estadoBarraV == BARRA_CIMA*/ indoCima && y_barra > `LIMITE_TELA_CIMA) y_barra <= y_barra - 1;
			else if (/*estadoBarraV == BARRA_BAIXO*/ !indoCima	&& y_barra + `ALTURA_BARRA < `LIMITE_TELA_BAIXO) y_barra <= y_barra + 1;
			
			contadorBarraV <= 0;
		end

        if (contadorBarraH >= 2500000) begin
			if (estadoPorradao == `PORRADAO_INDO ^ x_inicial < `LIMITE_TELA_DIR/2) x_barra <= x_barra - 1;
			else if (estadoPorradao == `PORRADAO_VOLTANDO ^ x_inicial < `LIMITE_TELA_DIR/2) x_barra <= x_barra + 1;
			
			contadorBarraH <= 0;
		end

		
        end
    end

endmodule