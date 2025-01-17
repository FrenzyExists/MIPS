module Hazard_Forwarding_Unit (
    output reg [1:0] fwdA, // Forwarding for operand A
    output reg [1:0] fwdB, // Forwarding for operand B

    output reg stallPC, // Stall the Program Counter
    output reg stallNPC, // Stall the Next Program Counter
    output reg stallIFID, // Stall the IF/ID Pipeline Register

    output reg controlMux, // Enable Control Unit Mux for NOP

    input wire enableEX, // RF enable signal from EX stage
    input wire enableMEM, // RF enable signal from MEM stage
    input wire enableWB, // RF enable signal from WB stage

    input wire loadEX, // Load instruction in EX stage

    input wire [4:0] regEX,  // Destination register in EX stage
    input wire [4:0] regMEM, // Destination register in MEM stage
    input wire [4:0] regWB, // Destination register in WB stage

    input wire [4:0] operandA, // Source operand A in ID stage
    input wire [4:0] operandB // Source operand B in ID stage
);

    always @* begin
        // Forwarding for operand A
        fwdA = (enableEX && (operandA == regEX)) ? 2'b01 :
               (enableMEM && (operandA == regMEM)) ? 2'b10 :
               (enableWB && (operandA == regWB)) ? 2'b11 : 2'b00;

        // Forwarding for operand B
        fwdB = (enableEX && (operandB == regEX)) ? 2'b01 :
               (enableMEM && (operandB == regMEM)) ? 2'b10 :
               (enableWB && (operandB == regWB)) ? 2'b11 : 2'b00;

        // Display forwarding information
        $display("Forwarding: fwdA=%b, fwdB=%b", fwdA, fwdB);
        $display("Time: %t, Inputs: enableEX=%b, enableMEM=%b, enableWB=%b, loadEX=%b, regEX=%d, regMEM=%d, regWB=%d, operandA=%d, operandB=%d", 
                 $time, enableEX, enableMEM, enableWB, loadEX, regEX, regMEM, regWB, operandA, operandB);
        // Detect load-use hazard
        if (loadEX && ((operandA == regEX) || (operandB == regEX))) begin
            stallPC = 1'b0;
            stallNPC = 1'b0;
            stallIFID = 1'b0;
            controlMux = 1'b1;
            $display("Load-use Hazard Detected, Stalling: stallPC=%b, stallNPC=%b, stallIFID=%b, controlMux=%b", stallPC, stallNPC, stallIFID, controlMux);
        end else begin
            stallPC = 1'b1;
            stallNPC = 1'b1;
            stallIFID = 1'b1;
            controlMux = 1'b0;
            $display("loadEx: loadEX = %b", loadEX);
            $display("No Hazard, Not Stalling: stallPC=%b, stallNPC=%b, stallIFID=%b, controlMux=%b", stallPC, stallNPC, stallIFID, controlMux);
        end
    end
endmodule
