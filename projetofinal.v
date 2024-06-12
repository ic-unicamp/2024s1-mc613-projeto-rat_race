`include "defines.vh"

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
  output  [6:0] HEX0,
  output [6:0] HEX1,
  output [6:0] HEX2,
  output [6:0] HEX3,
  output [6:0] HEX4,
  output [6:0] HEX5
	);

	
	
	//parametros necessarios para usar o modulo vga
  reg [7:0] VGA_R_aux;
  reg [7:0] VGA_G_aux;
  reg [7:0] VGA_B_aux;
  wire [9:0] i;
  wire [9:0] j;
  wire printing;
  assign reset = ~KEY[0];
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
  
   wire [9:0] x_barra_dir;
  wire [9:0] y_barra_dir;
  wire [9:0] velo_barra_dir;

  
  placar placar_instance(
    .placar(placar),
    .placarOponente(placarOponente),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3),
    .HEX4(HEX4),
    .HEX5(HEX5)
  );
  
  barra barraDir(
    .indoCima(~SW[0]),
    .porradao(KEY[2]),
    .clk(VGA_CLK),
    .reset(reset),
    .x_inicial(600),
    .y_inicial(240),
    
    
    .x_barra(x_barra_dir),
    .y_barra(y_barra_dir),
    .velocidadePorradao(velo_barra_dir)
  );

  
    wire [9:0] x_barra_esq;
  wire [9:0] y_barra_esq;
  wire [9:0] velo_barra_esq;

  
  barra barraEsq(
    .indoCima(SW[9]),
    .porradao(KEY[3]),
    .clk(VGA_CLK),
    .reset(reset),
    .x_inicial(40),
    .y_inicial(240),
    
    
    .x_barra(x_barra_esq),
    .y_barra(y_barra_esq),
    .velocidadePorradao(velo_barra_esq)
	 
  );
  
 


    
  
  
  
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
	parameter COL_BDIR = 1;
	parameter COL_BESQ = 2;
assign colisaoBarraBola = (((x_bola + TAMANHO_BOLA < x_barra_dir + `LARGURA_BARRA && x_bola + TAMANHO_BOLA > x_barra_dir ) && (y_bola + TAMANHO_BOLA > y_barra_dir && y_bola < y_barra_dir + `ALTURA_BARRA)) ? COL_BDIR :
 (x_bola > x_barra_esq && x_bola < x_barra_esq + `LARGURA_BARRA) && (y_bola + TAMANHO_BOLA > y_barra_esq && y_bola < y_barra_esq + `ALTURA_BARRA) ? COL_BESQ :
  COL_BB_NULL);

	

  reg [32:0] periodo;
   always @(posedge VGA_CLK or posedge reset) begin
    if (reset) begin
      x_bola <= 310;
      y_bola <= 240;
		contadorHBola <= 0;
		contadorVBola <= 0;
		veloHBola <= 12;
		veloVBola <= 16;
		sentidoHBola <= 1;
		sentidoVBola <= 1;
		estadoAnguloBola <= ESTADO_INCLINADO2_BOLA;
    placar <= 0;
    placarOponente <= 0;
    periodo <= 2500000;
	end else begin
      //CONTROLA MOVIMENTO DA BOLA VERTICALMENTE
      contadorVBola <= contadorVBola + veloVBola;
      if(contadorVBola >= periodo) begin
        if (sentidoVBola == BAIXO_BOLA) begin
          if (y_bola + TAMANHO_BOLA < `LIMITE_TELA_BAIXO) y_bola <= y_bola + 1;
          else sentidoVBola <= CIMA_BOLA;
        end
        else if (sentidoVBola == CIMA_BOLA) begin
          if (y_bola > `LIMITE_TELA_CIMA) y_bola <= y_bola - 1;
          else sentidoVBola <= BAIXO_BOLA;
        end
        contadorVBola <= 0;
      end
      //CONTROLA MOVIMENTO DA BOLA HORIZONTALMENTE
      contadorHBola <= contadorHBola + veloHBola;
      if(contadorHBola >= periodo) begin
        if (sentidoHBola == DIREITA_BOLA) begin
          if (colisaoBarraBola == COL_BDIR) begin
            sentidoHBola <= ESQUERDA_BOLA;
				if (velo_barra_dir > 0) begin
          veloHBola <= veloHBola + 50;
        end
          end else if (x_bola + TAMANHO_BOLA < `LIMITE_TELA_DIR) x_bola <= x_bola + 1;
          else if ((y_bola > `LIMITE_GOL_CIMA && y_bola + TAMANHO_BOLA < `LIMITE_GOL_BAIXO)) begin //colisao com a direita da tela
              placarOponente <= placarOponente + 1;
				  veloHBola <= 12;
					veloVBola <= 16;
					x_bola <= 310;
					y_bola <= 240;
				  
          end else begin 
              sentidoHBola <= ESQUERDA_BOLA;
            end
			
        end
        else if (sentidoHBola == ESQUERDA_BOLA) begin
          if (colisaoBarraBola == COL_BESQ) begin
            sentidoHBola <= DIREITA_BOLA;
            if (velo_barra_esq > 0) begin
              veloHBola <= veloHBola + 50;
            end
          end else if (x_bola > `LIMITE_TELA_ESQ) x_bola <= x_bola - 1;
          else begin
            if ((y_bola > `LIMITE_GOL_CIMA && y_bola + TAMANHO_BOLA < `LIMITE_GOL_BAIXO)) begin //colisao com a esquerda da tela
              placar <= placar + 1;
					veloHBola <= 12;
					veloVBola <= 16;
					x_bola <= 310;
					y_bola <= 240;
            end else begin
					sentidoHBola <= DIREITA_BOLA;
				end
          end
        end
        contadorHBola <= 0;
      end
    end

	end
  
  
  reg [9:0] placar;
  reg [9:0] placarOponente;
  


  
  
  always @(posedge VGA_CLK) begin
	VGA_R_aux <= 0;
	VGA_G_aux <= 0;
	VGA_B_aux <= 0;
	if (printing) begin
    if ((i >= 0 && i <= 10) || (i >= 470 && i <= 480)) begin
      VGA_R_aux <= 255;
      VGA_G_aux <= 255;
      VGA_B_aux <= 255;
    end
    if (((j >= 0 && j <= 10)|| (j >= 630 && j <= 640)) && ((i >= 0 && i <= 180) || (i >= 300 && i <= 480))) begin
      VGA_R_aux <= 255;
      VGA_G_aux <= 255;
      VGA_B_aux <= 255;
    end
    if(j >= 315 && j <= 325 && i >= 0 && i <= 480) begin
      VGA_R_aux <= 255;
      VGA_G_aux <= 255;
      VGA_B_aux <= 255;
    end
    if ((j >= x_barra_dir && j <= x_barra_dir + `LARGURA_BARRA) && (i >= y_barra_dir && i <= y_barra_dir + `ALTURA_BARRA)) begin
			VGA_R_aux <= 255;
			VGA_G_aux <= 0;
			VGA_B_aux <= 0;
		end
	if ((j >= x_barra_esq && j <= x_barra_esq + `LARGURA_BARRA) && (i >= y_barra_esq && i <= y_barra_esq + `ALTURA_BARRA)) begin
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

endmodule