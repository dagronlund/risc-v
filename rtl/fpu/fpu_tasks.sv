/*
*   Written By Dmitriy Solomonov
*   This file contains some behavioral tasks 
*   that may help you in writing your floating point unit.
*   
*   getSticky_27 takes in a 27-bit number and a shift value, and returns
*   the "OR" of all bits that would be shifted out, 
*   if the shift were to take place.
*
*   LeadingZeros_27 and LeadingZeros_47 take 27-bit and 47-bit inputs
*   respectively and output how many zeros there are from left to
*   right before the first 1 is seen.
*
*
*   To use these tasks, include this file inside the module
*   that will need them. Then call the task like a "function"
*   inside your behavioral code. For instance:
*      always @(<inputs>) begin
*         sigA = {1'b1,A[22:0],3'b0};
*         getSticky_27 (sigA,5'hf,sticky_bit);
*
*      end
*
*/
   
   task getSticky_27;
      input bit [26:0] NumSig;
      input bit [4:0]  shift_val;
      output bit  sticky_shift;
      begin
         casex (shift_val)
         0 : sticky_shift = | NumSig[0:0];
         1 : sticky_shift = | NumSig[1:0];
         2 : sticky_shift = | NumSig[2:0];
         3 : sticky_shift = | NumSig[3:0];
         4 : sticky_shift = | NumSig[4:0];
         5 : sticky_shift = | NumSig[5:0];
         6 : sticky_shift = | NumSig[6:0];
         7 : sticky_shift = | NumSig[7:0];
         8 : sticky_shift = | NumSig[8:0];
         9 : sticky_shift = | NumSig[9:0];
         10 : sticky_shift = | NumSig[10:0];
         11 : sticky_shift = | NumSig[11:0];
         12 : sticky_shift = | NumSig[12:0];
         13 : sticky_shift = | NumSig[13:0];
         14 : sticky_shift = | NumSig[14:0];
         15 : sticky_shift = | NumSig[15:0];
         16 : sticky_shift = | NumSig[16:0];
         17 : sticky_shift = | NumSig[17:0];
         18 : sticky_shift = | NumSig[18:0];
         19 : sticky_shift = | NumSig[19:0];
         20 : sticky_shift = | NumSig[20:0];
         21 : sticky_shift = | NumSig[21:0];
         22 : sticky_shift = | NumSig[22:0];
         23 : sticky_shift = | NumSig[23:0];
         24 : sticky_shift = | NumSig[24:0];
         25 : sticky_shift = | NumSig[25:0];
         26 : sticky_shift = | NumSig[26:0];
         default : sticky_shift = 0;   
         endcase
      end
   endtask : getSticky_27


   task LeadingZeros_47;
      input  bit [46:0] Num;
      output bit [5:0]  Zeros;
      begin
         casex (Num)
         47'b1?????????????????????????????????????????????? : Zeros = 6'd0;
         47'b01????????????????????????????????????????????? : Zeros = 6'd1;
         47'b001???????????????????????????????????????????? : Zeros = 6'd2;
         47'b0001??????????????????????????????????????????? : Zeros = 6'd3;
         47'b00001?????????????????????????????????????????? : Zeros = 6'd4;
         47'b000001????????????????????????????????????????? : Zeros = 6'd5;
         47'b0000001???????????????????????????????????????? : Zeros = 6'd6;
         47'b00000001??????????????????????????????????????? : Zeros = 6'd7;
         47'b000000001?????????????????????????????????????? : Zeros = 6'd8;
         47'b0000000001????????????????????????????????????? : Zeros = 6'd9;
         47'b00000000001???????????????????????????????????? : Zeros = 6'd10;
         47'b000000000001??????????????????????????????????? : Zeros = 6'd11;
         47'b0000000000001?????????????????????????????????? : Zeros = 6'd12;
         47'b00000000000001????????????????????????????????? : Zeros = 6'd13;
         47'b000000000000001???????????????????????????????? : Zeros = 6'd14;
         47'b0000000000000001??????????????????????????????? : Zeros = 6'd15;
         47'b00000000000000001?????????????????????????????? : Zeros = 6'd16;
         47'b000000000000000001????????????????????????????? : Zeros = 6'd17;
         47'b0000000000000000001???????????????????????????? : Zeros = 6'd18;
         47'b00000000000000000001??????????????????????????? : Zeros = 6'd19;
         47'b000000000000000000001?????????????????????????? : Zeros = 6'd20;
         47'b0000000000000000000001????????????????????????? : Zeros = 6'd21;
         47'b00000000000000000000001???????????????????????? : Zeros = 6'd22;
         47'b000000000000000000000001??????????????????????? : Zeros = 6'd23;
         47'b0000000000000000000000001?????????????????????? : Zeros = 6'd24;
         47'b00000000000000000000000001????????????????????? : Zeros = 6'd25;
         47'b000000000000000000000000001???????????????????? : Zeros = 6'd26;
         47'b0000000000000000000000000001??????????????????? : Zeros = 6'd27;
         47'b00000000000000000000000000001?????????????????? : Zeros = 6'd28;
         47'b000000000000000000000000000001????????????????? : Zeros = 6'd29;
         47'b0000000000000000000000000000001???????????????? : Zeros = 6'd30;
         47'b00000000000000000000000000000001??????????????? : Zeros = 6'd31;
         47'b000000000000000000000000000000001?????????????? : Zeros = 6'd32;
         47'b0000000000000000000000000000000001????????????? : Zeros = 6'd33;
         47'b00000000000000000000000000000000001???????????? : Zeros = 6'd34;
         47'b000000000000000000000000000000000001??????????? : Zeros = 6'd35;
         47'b0000000000000000000000000000000000001?????????? : Zeros = 6'd36;
         47'b00000000000000000000000000000000000001????????? : Zeros = 6'd37;
         47'b000000000000000000000000000000000000001???????? : Zeros = 6'd38;
         47'b0000000000000000000000000000000000000001??????? : Zeros = 6'd39;
         47'b00000000000000000000000000000000000000001?????? : Zeros = 6'd40;
         47'b000000000000000000000000000000000000000001????? : Zeros = 6'd41;
         47'b0000000000000000000000000000000000000000001???? : Zeros = 6'd42;
         47'b00000000000000000000000000000000000000000001??? : Zeros = 6'd43;
         47'b000000000000000000000000000000000000000000001?? : Zeros = 6'd44;
         47'b0000000000000000000000000000000000000000000001? : Zeros = 6'd45;
         47'b00000000000000000000000000000000000000000000001 : Zeros = 6'd46;
         47'b00000000000000000000000000000000000000000000000 : Zeros = 6'd47;
         endcase
      end
   endtask : LeadingZeros_47

   task LeadingZeros_27;
      input  bit [26:0] Num;
      output bit [4:0]  Zeros;
      begin
         casex (Num)
         27'b1?????????????????????????? : Zeros = 5'd0;
         27'b01????????????????????????? : Zeros = 5'd1;
         27'b001???????????????????????? : Zeros = 5'd2;
         27'b0001??????????????????????? : Zeros = 5'd3;
         27'b00001?????????????????????? : Zeros = 5'd4;
         27'b000001????????????????????? : Zeros = 5'd5;
         27'b0000001???????????????????? : Zeros = 5'd6;
         27'b00000001??????????????????? : Zeros = 5'd7;
         27'b000000001?????????????????? : Zeros = 5'd8;
         27'b0000000001????????????????? : Zeros = 5'd9;
         27'b00000000001???????????????? : Zeros = 5'd10;
         27'b000000000001??????????????? : Zeros = 5'd11;
         27'b0000000000001?????????????? : Zeros = 5'd12;
         27'b00000000000001????????????? : Zeros = 5'd13;
         27'b000000000000001???????????? : Zeros = 5'd14;
         27'b0000000000000001??????????? : Zeros = 5'd15;
         27'b00000000000000001?????????? : Zeros = 5'd16;
         27'b000000000000000001????????? : Zeros = 5'd17;
         27'b0000000000000000001???????? : Zeros = 5'd18;
         27'b00000000000000000001??????? : Zeros = 5'd19;
         27'b000000000000000000001?????? : Zeros = 5'd20;
         27'b0000000000000000000001????? : Zeros = 5'd21;
         27'b00000000000000000000001???? : Zeros = 5'd22;
         27'b000000000000000000000001??? : Zeros = 5'd23;
         27'b0000000000000000000000001?? : Zeros = 5'd24;
         27'b00000000000000000000000001? : Zeros = 5'd25;
         27'b000000000000000000000000001 : Zeros = 5'd26;
         27'b000000000000000000000000000 : Zeros = 5'd27;
         endcase
      end
   endtask : LeadingZeros_27

   task mult_24;
      input  bit [23:0] A, B;
      output bit [47:0] Y;
      begin
         Y = A * B;
      end
   endtask : mult_24

task divide;
  input  logic [23:0] a, b;
  output logic [46:0] y;
  output logic [5:0] guard;

  logic [7:0] i;
  logic [72:0] A, B;
  logic [72:0] x, A2;

  begin
    A = a<<23;
    B = b;
    for (i=0; i<47; i++) begin
      x = B<<(46-i);
      if (x<=A) begin
        A = A - x;
        y[46-i] = 1;
      end else begin
        y[46-i] = 0;
      end;
    end

    A2 = A<<6;
    for (i=0;i<6;i++) begin
      x = B<<(5-i);
      if (x<=A2) begin
        A2 = A2 - x;
        guard[5-i] = 1;
      end else begin
        guard[5-i] = 0;
      end;
    end 
  end
endtask

task square_root;
  input  logic [47:0] sig;
  output logic [23:0] mant;
  output logic [2:0] guard;

  logic [47:0] temp, M, d;
  logic [4:0] i;

  begin
    temp = 48'd0;
    M = 48'd1;
    for (i=0;i<24;i++) begin
      temp = {temp[45:0], sig[47:46]};
      sig = sig<<2;
      if (M <= temp) begin
        temp = temp-M;
        mant[23-i] = 1;
        d = M+1;
        M = {d[46:0], 1'd1};
      end else begin
        mant[23-i] = 1'd0;
        M = {M[46:1], 2'd1};
      end 
    end

    for (i=0;i<3;i++) begin
      temp = {temp[45:0], 2'd0};
      if (M <= temp) begin
        temp = temp-M;
        guard[2-i] = 1;
        d = M+1;
        M = {d[46:0], 1'd1};
      end else begin
        guard[2-i] = 1'd0;
        M = {M[46:1], 2'd1};
      end 
    end
  end
endtask

task round;
  input  logic [23:0] temp_Y;
  input  logic [8:0] Y_exp;
  input  logic [2:0] guard;
  input  logic exp_n;
  output logic [30:0] Y;

  logic [23:0] result;
  logic [7:0] exp;
  logic OF;

  begin
    if (guard[2]) begin
      {OF, result} = temp_Y + 1;
      exp = Y_exp;
      if (OF) begin
        if(exp_n) exp = Y_exp - 1;
        else exp = Y_exp + 1;
      end
    end else begin
      exp = Y_exp;
      result = {temp_Y};
    end

    Y[30:23] = (exp_n) ? (127 - exp) : (exp + 127);
    Y[22:0] = result[22:0];
  end

endtask