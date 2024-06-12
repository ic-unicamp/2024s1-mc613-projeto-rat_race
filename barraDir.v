`include "defines.vh"



module barra(
    input indoCima,
    input porradao,
    input clk,
    input reset,
    output reg [9:0] x_barra,
	output reg [9:0] y_barra
	  
	 
	output reg [9:0] x_inicial,
	output reg [9:0] y_inicial
);

    reg [31:0] contadorBarraV;
    reg [31:0] contadorBarraH;
    reg [1:0] estadoBarraV;
    reg [31:0] contadorPorradao;
    reg [1:0] estadoPorradao;
    
    //tamanho barra: x = 60, y = 20
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_barra <= x_inicial;
            y_barra <= y_inicial;
            estadoBarraV <= `BARRA_PARADA;
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
			    contadorBarraH <= contadorBarraH + `VELOCIDADE_PORRADAO;
                    if (contadorPorradao == 5000000) begin
                        contadorPorradao <= 0;
				contadorBarraH <= 0;
                        estadoPorradao <= `PORRADAO_VOLTANDO;
                    end 
                end
                `PORRADAO_VOLTANDO: begin
			    contadorBarraH <= contadorBarraH + `VELOCIDADE_PORRADAO;
                    if (contadorPorradao == 5000000) begin
                        contadorPorradao <= 0;
                        estadoPorradao <= `PORRADAO_NULL;
                    end 
                end
            endcase

		//CONTROLA MOVIMENTO DA BARRA
		if (contadorBarraV == 2500000) begin
			if (/*estadoBarraV == BARRA_CIMA*/ indoCima && y_barra > `LIMITE_TELA_CIMA) y_barra <= y_barra - 1;
			else if (/*estadoBarraV == BARRA_BAIXO*/ !indoCima	&& y_barra + `ALTURA_BARRA < `LIMITE_TELA_BAIXO) y_barra <= y_barra + 1;
			
			contadorBarraV <= 0;
		end

        if (contadorBarraH == 2500000) begin
			if (estadoPorradao == `PORRADAO_INDO) x_barra <= x_barra - 1;
			else if (estadoPorradao == `PORRADAO_VOLTANDO) x_barra <= x_barra + 1;
			
			contadorBarraH <= 0;
		end

		
        end
    end

endmodule