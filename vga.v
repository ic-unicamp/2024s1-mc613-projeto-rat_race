module vga(
  input CLOCK_50,  // Sinal de clock para sincronizar o circuito
  input reset, // Sinal de reset para reiniciar o circuito
  input [7:0] VGA_R_in,
  input [7:0] VGA_G_in,
  input [7:0] VGA_B_in,


  output reg VGA_CLK,
  output VGA_SYNC_N,
  output VGA_BLANK_N,
  output reg [7:0] VGA_R,
  output reg [7:0] VGA_G,
  output reg [7:0] VGA_B,
  output reg VGA_VS,
  output reg VGA_HS,
  output wire [9:0] i,
  output wire [9:0] j,
  output wire printing
);


//bloco always ultilitario para dividir o clock de 50 para 25 MHz
always @(posedge CLOCK_50) begin
  if (reset) begin
    VGA_CLK <= 0;
  end else begin
    VGA_CLK <= ~VGA_CLK;
  end
end

//Não alterar
assign VGA_SYNC_N = 0;
assign VGA_BLANK_N = 1;
reg [31:0] contadorH;
reg [31:0] contadorV;
reg [1:0] estadoH;
reg [1:0] estadoV;

always @(posedge VGA_CLK) begin
  //bloco de reset para reiniciar o sistema
  if (reset) begin
    contadorH <= 0;
    contadorV <= 0;
    estadoH <= 0;
    estadoV <= 0;
  end
  //caso o reset não esteja ativo, o codigo abaixo deve ser executado para gerar o sinal de video
  else begin
    //sinais default (que devem ser enviados caso não haja nenhuma outra alteração dentro dos cases) 
    contadorH <= contadorH + 1;
    VGA_HS <= 1; //HS deve estar ativos em todos os casos exeto o primeiro
    VGA_VS <= 1; //VS deve estar ativos em todos os casos exeto o primeiro
    VGA_R <= 0; //cor enviada deve estar em 0 em todos os casos, exeto na janela de transferência de cor
    VGA_G <= 0; //cor enviada deve estar em 0 em todos os casos, exeto na janela de transferência de cor
    VGA_B <= 0; //cor enviada deve estar em 0 em todos os casos, exeto na janela de transferência de cor

    //Maquina de estados do Hsync, na qual
    case (estadoH)
      //estado 0: Unico com Hsync ativo(monitor esta realizando a sincronizacao)
      0:  begin
        VGA_HS <= 0;
        if (contadorH == 95) begin //Deve ficar nesse estado nos clocks de 0 a 95
          estadoH <= 1;
        end

       end
      //estado 1: Estado de transicao, apenas conta tempo e vai para o proximo estado
      1:  begin
        VGA_HS <= 1;
        if (contadorH == 143) begin //Deve ficar nesse estado nos clocks de 96 a 143
          estadoH <= 2;
        end
      end
      //estado 2: Estado de transmissao das cores
      2:  begin
        if (estadoV == 2) begin //So deve transmitir cores se o estado do Vsync tambem for de transmissao (estado 2)
          VGA_R <= VGA_R_in;
          VGA_G <= VGA_G_in;
          VGA_B <= VGA_B_in;

          //implementar logica de transmissao de cores para fazer a imagem desejada aqui,
          //levando em conta que a imagem comeca com pixel(0,0) equivalente a contadorH = 144 e contadorV = 35
          //e termina em pixel(639,479) equivalente a contadorH = 783 e contadorV = 514
          //begin
          
          //end
        end
        if (contadorH == 783) begin //Deve ficar nesse estado nos clocks de 144 a 783
          estadoH <= 3;
        end
      end
      //estado 3: Estado de transicao, apenas conta tempo e finaliza a linha(voltando para o estado 0 e incrementando o contador de linhas)
      3:  begin
        if (contadorH == 799) begin //Deve ficar nesse estado nos clocks de 784 a 799
          contadorH <= 0;
          estadoH <= 0;
          contadorV <= contadorV + 1;
        end
      end 
      
      
    endcase



  //Maquina de estados do Vsync, na qual
  case (estadoV)
      //estado 0: Unico com Vsync ativo(monitor esta realizando a sincronizacao)
      0:  begin
        VGA_VS <= 0;
        if (contadorV == 1) begin //Deve ficar nesse estado nas linhas de 0 a 1
          estadoV <= 1;
        end
       end
      //estado 1: Estado de transicao, apenas conta tempo e vai para o proximo estado
      1:  begin
        if (contadorV == 34) begin //Deve ficar nesse estado nas linhas de 2 a 34
          estadoV <= 2;
        end
      end
      //estado 2: Estado de transmissao das cores, sendo verificado no estado 2 do Hsync
      2:  begin
        if (contadorV == 514) begin //Deve ficar nesse estado nas linhas de 35 a 514
          estadoV <= 3;
        end
      end
      //estado 3: Estado de transicao, apenas conta tempo e finaliza a tela(voltando para o estado 0 e reiniciando o contador de linhas)
      3:  begin
        if (contadorV == 524) begin //Deve ficar nesse estado nas linhas de 515 a 524
          estadoV <= 0;
          contadorV <= 0;
        end
      end 
      
      
    endcase


  end



end

assign printing = (estadoH == 2) && (estadoV == 2);
assign j = contadorH - 144;
assign i = contadorV - 35;



endmodule