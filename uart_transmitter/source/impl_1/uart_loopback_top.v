module UART_Loopback_Top
  (input  i_Clk,       // Main Clock
   input  i_UART_RX,   // UART RX Data
   output o_UART_TX,   // UART TX Data
   output o_Segment_A,
   output o_Segment_B,
   output o_Segment_C,
   output o_Segment_D,
   output o_Segment_E,
   output o_Segment_F,
   output o_Segment_G,
   output o_Segment_Digit);
 
  wire w_RX_DV;
  wire [7:0] w_RX_Byte;
  wire w_TX_Active, w_TX_Serial;
 
  wire w_Segment1_A, w_Segment2_A;
  wire w_Segment1_B, w_Segment2_B;
  wire w_Segment1_C, w_Segment2_C;
  wire w_Segment1_D, w_Segment2_D;
  wire w_Segment1_E, w_Segment2_E;
  wire w_Segment1_F, w_Segment2_F;
  wire w_Segment1_G, w_Segment2_G;

  reg r_Segment_A;
  reg r_Segment_B;
  reg r_Segment_C;
  reg r_Segment_D;
  reg r_Segment_E;
  reg r_Segment_F;
  reg r_Segment_G;
   
  // 12,000,000 / 115,200 = 107
  UART_RX #(.CLKS_PER_BIT(107)) UART_RX_Inst
  (.i_Clock(i_Clk),
   .i_RX_Serial(i_UART_RX),
   .o_RX_DV(w_RX_DV),
   .o_RX_Byte(w_RX_Byte));
    
  UART_TX #(.CLKS_PER_BIT(107)) UART_TX_Inst
  (.i_Clock(i_Clk),
   .i_Rst_L (1'b1), // No reset
   .i_TX_DV(w_RX_DV),      // Pass RX to TX module for loopback
   .i_TX_Byte(w_RX_Byte),  // Pass RX to TX module for loopback
   .o_TX_Active(w_TX_Active),
   .o_TX_Serial(w_TX_Serial),
   .o_TX_Done());
   
  // Drive UART line high when transmitter is not active
  assign o_UART_TX = w_TX_Active ? w_TX_Serial : 1'b1;
  
  // Binary to 7-Segment Converter for Upper Digit
  Binary_To_7Segment SevenSeg1_Inst
  (.i_Clk(i_Clk),
   .i_Binary_Num(w_RX_Byte[7:4]),
   .o_Segment_A(w_Segment1_A),
   .o_Segment_B(w_Segment1_B),
   .o_Segment_C(w_Segment1_C),
   .o_Segment_D(w_Segment1_D),
   .o_Segment_E(w_Segment1_E),
   .o_Segment_F(w_Segment1_F),
   .o_Segment_G(w_Segment1_G));

  // Binary to 7-Segment Converter for Lower Digit
  Binary_To_7Segment SevenSeg2_Inst
  (.i_Clk(i_Clk),
   .i_Binary_Num(w_RX_Byte[3:0]),
   .o_Segment_A(w_Segment2_A),
   .o_Segment_B(w_Segment2_B),
   .o_Segment_C(w_Segment2_C),
   .o_Segment_D(w_Segment2_D),
   .o_Segment_E(w_Segment2_E),
   .o_Segment_F(w_Segment2_F),
   .o_Segment_G(w_Segment2_G));
   
  // 7-Segment Multiplexer
  reg r_Segment_Digit;

  always @(posedge i_Clk) begin
    // Toggle the digit select on every clock cycle
    r_Segment_Digit <= ~r_Segment_Digit;
    
    if (r_Segment_Digit) begin
      // Display lower digit (second digit)
      r_Segment_A <= w_Segment2_A;
      r_Segment_B <= w_Segment2_B;
      r_Segment_C <= w_Segment2_C;
      r_Segment_D <= w_Segment2_D;
      r_Segment_E <= w_Segment2_E;
      r_Segment_F <= w_Segment2_F;
      r_Segment_G <= w_Segment2_G;
    end else begin
      // Display upper digit (first digit)
      r_Segment_A <= w_Segment1_A;
      r_Segment_B <= w_Segment1_B;
      r_Segment_C <= w_Segment1_C;
      r_Segment_D <= w_Segment1_D;
      r_Segment_E <= w_Segment1_E;
      r_Segment_F <= w_Segment1_F;
      r_Segment_G <= w_Segment1_G;
    end
  end

  // Assign outputs
  assign o_Segment_A = r_Segment_A;
  assign o_Segment_B = r_Segment_B;
  assign o_Segment_C = r_Segment_C;
  assign o_Segment_D = r_Segment_D;
  assign o_Segment_E = r_Segment_E;
  assign o_Segment_F = r_Segment_F;
  assign o_Segment_G = r_Segment_G;

  assign o_Segment_Digit = r_Segment_Digit;
   
endmodule