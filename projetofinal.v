module projetofinal(
   input [9:0] SW, // Sinal de reset para reiniciar o circuito
   input [3:0] KEY,
	input CLOCK_50,
	  
	output VGA_CLK,
	output VGA_HS,
	output VGA_VS,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_SYNC_N,
  output reg [6:0] HEX0,
  output reg [6:0] HEX1,
  output reg [6:0] HEX2,
  output reg [6:0] HEX3,
  output reg [6:0] HEX4,
  output reg [6:0] HEX5
	);

	
	
	//parametros necessarios para usar o modulo vga
  reg [7:0] VGA_R_aux;
  reg [7:0] VGA_G_aux;
  reg [7:0] VGA_B_aux;
  wire [9:0] i;
  wire [9:0] j;
  wire printing;
  assign reset = SW[0];
  vga vga_instance(
   .CLOCK_50(CLOCK_50),
   .reset(reset),
	.VGA_R_in(VGA_R_aux),
	.VGA_G_in(VGA_G_aux),
	.VGA_B_in(VGA_B_aux),
	
   .VGA_CLK(VGA_CLK),
   .VGA_HS(VGA_HS),
   .VGA_VS(VGA_VS),
   .VGA_R(VGA_R),
   .VGA_G(VGA_G),
   .VGA_B(VGA_B),
   .VGA_BLANK_N(VGA_BLANK_N),
	.VGA_SYNC_N(VGA_SYNC_N),
  .i(i),
  .j(j),
  .printing(printing)
  );
  
  
  
  parameter LIMITE_TELA_DIR = 640;
  parameter LIMITE_TELA_ESQ = 0;
  parameter LIMITE_TELA_CIMA = 0;
  parameter LIMITE_TELA_BAIXO = 480;
  
  wire esquerda;
  wire direita;
  wire porradao;
  assign porradao = KEY[2];
  assign esquerda = KEY[3];
  assign direita = KEY[0];

  wire start;
  assign start = KEY[1];
  reg running;
  reg [1:0] running_state;

  
  reg fimDeJogo;
  reg fimDeJogoAux;
  always @(posedge VGA_CLK or posedge reset) begin
    if (reset) begin
      running <= 0;
      running_state <= 0;
    end else begin
		if (!fimDeJogo && fimDeJogoAux) fimDeJogo <= 1;
      case(running_state)
        0: begin
          if (!start) begin
            running <= ~running;
            running_state <= 1;
            if (fimDeJogo) begin
              fimDeJogo <= 0;
              running <= 0;
            end
          end
        end
        1: begin
          if (start) begin
            running_state <= 0;
          end
        end
      endcase
    end
  end


  reg [9:0] x_barra;
  reg [9:0] y_barra;
  reg [31:0] contadorBarraV;
  reg [31:0] contadorBarraH;
  reg [1:0] estadoBarraV;
  reg [31:0] contadorPorradao;
  reg [1:0] estadoPorradao;
  parameter BARRA_PARADA = 2'b00;
  parameter BARRA_CIMA = 2'b01;
  parameter PORRADAO_NULL = 2'b00;
  parameter PORRADAO_INDO = 2'b01;
  parameter PORRADAO_VOLTANDO = 2'b10;
  parameter BARRA_BAIXO = 2'b10;
  parameter VELOCIDADE_BARRA_V = 20;
  parameter VELOCIDADE_PORRADAO = 20;
  parameter LARGURA_BARRA = 15;
  parameter ALTURA_BARRA = 180;
  
  //tamanho barra: x = 60, y = 20
  always @(posedge VGA_CLK or posedge reset) begin
    if (reset) begin
      x_barra <= 600;
      y_barra <= 240;
      estadoBarraV <= BARRA_PARADA;
      contadorBarraV <= 0;
      estadoPorradao <= PORRADAO_NULL;
      contadorPorradao <= 0;
      contadorBarraH <= 0;
	end else if (fimDeJogo) begin
      x_barra <= 600;
      y_barra <= 240;
      estadoBarraV <= BARRA_PARADA;
      contadorBarraV <= 0;
      estadoPorradao <= PORRADAO_NULL;
      contadorPorradao <= 0;
      contadorBarraH <= 0;
    end else begin
		//MAQUINA DE ESTADOS PARA A BARRA(CONTROLA DIRECAO)
		contadorBarraV <= contadorBarraV + VELOCIDADE_BARRA_V;
		case(estadoBarraV)
        BARRA_PARADA: begin
          if(!esquerda) begin
				contadorBarraV <= 0;
            estadoBarraV <= BARRA_CIMA;
          end
          else if(!direita) begin   
				contadorBarraV <= 0;
            estadoBarraV <= BARRA_BAIXO;
          end
		end
        BARRA_CIMA: begin
			 if(esquerda) begin
            estadoBarraV <= BARRA_PARADA; 
          end
        end
        BARRA_BAIXO: begin
			 if(direita) begin
            estadoBarraV <= BARRA_PARADA; 
          end
        end
      endcase


    //MAQUINA DE ESTADOS PARA O PORRADAO(CONTROLA DIRECAO)
    contadorPorradao <= contadorPorradao + 1;
      case(estadoPorradao)
        PORRADAO_NULL: begin
          if(!porradao) begin
				    contadorPorradao <= 0;
            contadorBarraH <= 0;
            estadoPorradao <= PORRADAO_INDO;
          end
		    end
        PORRADAO_INDO: begin
			    contadorBarraH <= contadorBarraH + VELOCIDADE_PORRADAO;
          if (contadorPorradao == 5000000) begin
            contadorPorradao <= 0;
				contadorBarraH <= 0;
            estadoPorradao <= PORRADAO_VOLTANDO;
          end 
        end
        PORRADAO_VOLTANDO: begin
			    contadorBarraH <= contadorBarraH + VELOCIDADE_PORRADAO;
          if (contadorPorradao == 5000000) begin
            contadorPorradao <= 0;
            estadoPorradao <= PORRADAO_NULL;
          end 
        end
      endcase

		//CONTROLA MOVIMENTO DA BARRA
		if (contadorBarraV == 2500000 && running) begin
			if (estadoBarraV == BARRA_CIMA && y_barra > LIMITE_TELA_CIMA) y_barra <= y_barra - 1;
			else if (estadoBarraV == BARRA_BAIXO && y_barra + ALTURA_BARRA < LIMITE_TELA_BAIXO) y_barra <= y_barra + 1;
			
			contadorBarraV <= 0;
		end

    if (contadorBarraH == 2500000 && running) begin
			if (estadoPorradao == PORRADAO_INDO) x_barra <= x_barra - 1;
			else if (estadoPorradao == PORRADAO_VOLTANDO) x_barra <= x_barra + 1;
			
			contadorBarraH <= 0;
		end

		
    end
  end

  
  
  
  parameter TAMANHO_BOLA = 20;
  reg sentidoHBola;
  parameter DIREITA_BOLA = 1;
  parameter ESQUERDA_BOLA = 0;
  reg sentidoVBola;
  parameter CIMA_BOLA = 1;
  parameter BAIXO_BOLA = 0;
  reg [31:0] contadorHBola;
  reg [31:0] contadorVBola;
  reg [9:0] x_bola;
  reg [9:0] y_bola;
  reg [1:0] estadoAnguloBola;
  parameter ESTADO_VERTICAL_BOLA = 0;
  parameter ESTADO_INCLINADO1_BOLA = 1;
  parameter ESTADO_INCLINADO2_BOLA = 2;
  reg[31:0] veloHBola;
  reg[31:0] veloVBola;
  
  
	wire [1:0] colisaoBarraBola;
	parameter COL_BB_NULL = 0;
	parameter COL_BB_ESQ = 1;
	parameter COL_BB_MEIO = 2;
	parameter COL_BB_DIR = 3;
	assign colisaoBarraBola = (x_bola + TAMANHO_BOLA != x_barra  ? COL_BB_NULL :
							(y_bola + 10 > y_barra && y_bola + 10 < y_barra + ALTURA_BARRA) ? COL_BB_MEIO : COL_BB_NULL);
                  //(x_bola + 10 >= x_barra && x_bola + 10 < x_barra + 60 ? COL_BB_ESQ :
                  //(x_bola + 10 >= x_barra + 60 && x_bola + 10 < x_barra + 120 ? COL_BB_MEIO :
                  //(x_bola + 10 >= x_barra + 120 && x_bola + 10 < x_barra + 180 ? COL_BB_DIR : COL_BB_NULL))));

	

  reg [32:0] periodo;
   always @(posedge VGA_CLK or posedge reset) begin
    if (reset) begin
      x_bola <= 50;
      y_bola <= 240;
		contadorHBola <= 0;
		contadorVBola <= 0;
		veloHBola <= 12;
		veloVBola <= 16;
		sentidoHBola <= 1;
		sentidoVBola <= 1;
		estadoAnguloBola <= ESTADO_INCLINADO2_BOLA;
		fimDeJogoAux <= 0;
    placar <= 0;
    placarOponente <= 0;
    periodo <= 2500000;
	end else if (fimDeJogo) begin
		x_bola <= 50;
      y_bola <= 240;
		veloHBola <= 12;
		veloVBola <=16;
		contadorHBola <= 0;
		contadorVBola <= 0;
		sentidoHBola <= 1;
		sentidoVBola <= 1;
		estadoAnguloBola <= ESTADO_INCLINADO2_BOLA;
		fimDeJogoAux <= 0;
    placar <= 0;
    periodo <= 2500000;
    end else begin
      //CONTROLA MOVIMENTO DA BOLA VERTICALMENTE
      contadorVBola <= contadorVBola + veloVBola;
      if(contadorVBola >= periodo && running) begin
        if (sentidoVBola == BAIXO_BOLA) begin
          if (y_bola + TAMANHO_BOLA < LIMITE_TELA_BAIXO) y_bola <= y_bola + 1;
          else sentidoVBola <= CIMA_BOLA;
        end
        else if (sentidoVBola == CIMA_BOLA) begin
          if (y_bola > LIMITE_TELA_CIMA) y_bola <= y_bola - 1;
          else sentidoVBola <= BAIXO_BOLA;
        end
        contadorVBola <= 0;
      end
      //CONTROLA MOVIMENTO DA BOLA HORIZONTALMENTE
      contadorHBola <= contadorHBola + veloHBola;
      if(contadorHBola >= periodo && running) begin
        if (sentidoHBola == DIREITA_BOLA) begin
          if (colisaoBarraBola != COL_BB_NULL) begin
            sentidoHBola <= ESQUERDA_BOLA;
            veloVBola <= veloVBola + 3;
				    veloHBola <= veloHBola + 4;
            // if (colisaoBarraBola == COL_BB_ESQ) begin
            //   sentidoHBola <= ESQUERDA_BOLA;
            // end
            // else if (colisaoBarraBola == COL_BB_DIR) begin
            //   sentidoHBola <= DIREITA_BOLA;
            // end
          end else if (x_bola + TAMANHO_BOLA < LIMITE_TELA_DIR) x_bola <= x_bola + 1;
          else begin //colisao com a direita da tela
            //fimDeJogoAux <= 1;
				    sentidoHBola <= ESQUERDA_BOLA;
            placarOponente <= placarOponente + 1;
          end
        end
        else if (sentidoHBola == ESQUERDA_BOLA) begin
          if (x_bola > LIMITE_TELA_ESQ) x_bola <= x_bola - 1;
          else begin
            sentidoHBola <= DIREITA_BOLA;
            placar <= placar + 1;
          end
        end
        contadorHBola <= 0;
      end
    end

	end
  
  
  reg [9:0] placar;
  reg [9:0] placarOponente;
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



	integer i1,j1;
  always @(placarOponente) begin
    for(i1 = 0; i1 <= W+(W-4)/3; i1 = i1+1) bcd1[i1] = 0;     // initialize with zeros
    bcd1[W-1:0] = placarOponente;                                   // initialize with input vector
    for(i1 = 0; i1 <= W-4; i1 = i1+1)                       // iterate on structure depth
      for(j1 = 0; j1 <= i1/3; j1 = j1+1)                     // iterate on structure width
        if (bcd1[W-i1+4*j1 -: 4] > 4)                      // if > 4
          bcd1[W-i1+4*j1 -: 4] = bcd1[W-i1+4*j1 -: 4] + 4'd3; // add 3
  end

  always @(placar) begin
    for(i1 = 0; i1 <= W+(W-4)/3; i1 = i1+1) bcd2[i1] = 0;     // initialize with zeros
    bcd2[W-1:0] = placar;                                   // initialize with input vector
    for(i1 = 0; i1 <= W-4; i1 = i1+1)                       // iterate on structure depth
      for(j1 = 0; j1 <= i1/3; j1 = j1+1)                     // iterate on structure width
        if (bcd2[W-i1+4*j1 -: 4] > 4)                      // if > 4
          bcd2[W-i1+4*j1 -: 4] = bcd2[W-i1+4*j1 -: 4] + 4'd3; // add 3
  end

  
  
  
  
  always @(posedge VGA_CLK) begin
	VGA_R_aux <= 0;
	VGA_G_aux <= 0;
	VGA_B_aux <= 0;
	if (printing) begin
    if (fimDeJogo) begin
      if (i >= 200 && i <= 280 && j >= 240 && j <= 400) begin
        VGA_R_aux <= 0;
        VGA_G_aux <= 0;
        VGA_B_aux <= 0;
      end else if (i >= 220 && i <= 260 && j >= 260 && j <= 380) begin
        VGA_R_aux <= 255;
        VGA_G_aux <= 255;
        VGA_B_aux <= 255;
      end else begin
        VGA_R_aux <= 0;
        VGA_G_aux <= 0;
        VGA_B_aux <= 0;
      end
  end else begin
    if ((j >= x_barra && j <= x_barra + LARGURA_BARRA) && (i >= y_barra && i <= y_barra + ALTURA_BARRA)) begin
			VGA_R_aux <= 255;
			VGA_G_aux <= 0;
			VGA_B_aux <= 0;
		end
		if ((j >= x_bola && j <= x_bola + 20) && (i >= y_bola && i <= y_bola + 20)) begin
			VGA_R_aux <= 0;
			VGA_G_aux <= 255;
			VGA_B_aux <= 255;
		end
  end
		
	end
end

endmodule